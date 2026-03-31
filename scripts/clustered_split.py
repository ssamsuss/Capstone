#!/usr/bin/env python3
"""
Clustered train/test split for AMP Capstone training TSV files.

Goal
----
Create leakage-resistant train/test splits for peptide classification.

Why this is needed
------------------
Metagenomic peptide datasets (and AMP/non-AMP corpora) often contain duplicates
and near-duplicates. A naive random split can place highly similar sequences
into both train and test, inflating evaluation metrics because the model can
memorize families instead of generalizing.

What this script does (per input TSV)
-------------------------------------
For each unique_*.tsv in work/0_1_amps/:
  1) Read the TSV and locate the 'sequence' column
  2) Write sequences to a temporary FASTA (IDs: seq_0, seq_1, ...)
  3) Cluster sequences with CD-HIT at IDENTITY (e.g., 0.90)
  4) Assign whole clusters to train (80%) or test (20%)
     - This guarantees no train/test pair is >= IDENTITY similar
  5) Write clustered_split_<original>.tsv with two new columns:
       - cluster_id : CD-HIT cluster index
       - split      : train/test/unknown

Outputs
-------
- clustered_split_<input>.tsv in the same AMP_DIR directory.

Author
------
Samsus Saintloth
"""

import csv
import random
import re
import subprocess
import tempfile
from pathlib import Path

# Directory containing the training TSVs.
# AMP_DIR points to: <repo_root>/work/0_1_amps
AMP_DIR = Path(__file__).resolve().parents[1] / "work" / "0_1_amps"

# CD-HIT sequence identity threshold:
# - 0.90 means sequences with >=90% identity will be grouped into the same cluster.
# - Common choices: 0.80–0.90 depending on how strict you want leakage prevention.
IDENTITY = 0.90

# Target fraction of clusters assigned to training.
# Note: because we split *by cluster*, the final train/test sequence counts can
# deviate slightly from 80/20 if clusters have different sizes.
TRAIN_FRAC = 0.80

# Seed ensures deterministic (reproducible) shuffling of clusters.
SEED = 42


def detect_seq_col(header: list[str]) -> int:
    """
    Find the column index containing peptide sequences.

    Assumption: TSV header contains a column named 'sequence' (case-insensitive).
    This makes the script robust to different column orders as long as the name matches.

    Raises
    ------
    ValueError if no sequence column is found.
    """
    for i, h in enumerate(header):
        if h.lower() == "sequence":
            return i
    raise ValueError(f"No 'sequence' column found in header: {header}")


def write_fasta(rows: list[list[str]], seq_col: int, fasta_path: Path) -> None:
    """
    Write sequences to a FASTA file for CD-HIT clustering.

    We assign synthetic IDs (seq_0, seq_1, ...) corresponding to row order.
    That creates a stable mapping from TSV rows -> FASTA entries -> CD-HIT clusters.

    Notes
    -----
    - Empty sequences are skipped.
    - FASTA format uses:
        >seq_i
        SEQUENCE
    """
    with fasta_path.open("w") as fh:
        for i, row in enumerate(rows):
            seq = row[seq_col].strip()
            if seq:
                fh.write(f">seq_{i}\n{seq}\n")


def run_cdhit(fasta_path: Path, out_path: Path, identity: float) -> None:
    """
    Run CD-HIT to cluster peptide sequences by sequence identity.

    Parameters
    ----------
    fasta_path : input FASTA file of peptide sequences
    out_path   : base output path for CD-HIT (produces out_path and out_path.clstr)
    identity   : clustering threshold (e.g., 0.90)

    Important parameters and rationale
    ---------------------------------
    - -c identity:
        identity threshold for clustering.
    - -n word_size:
        k-mer word size used by CD-HIT's heuristic. Smaller values can help with
        short sequences but may increase runtime.
        We use 4 because peptides are short (10–80 aa).
    - -M 2000, -T 4:
        memory limit (MB) and threads. Adjust to your machine.
    - -d 0:
        keep full FASTA IDs in the .clstr file (otherwise truncated).
        This is critical so we can parse seq_123 correctly.
    - -l 4:
        minimum length to keep (CD-HIT default is higher). Setting to 4 prevents
        CD-HIT from dropping very short sequences. In practice, your pipeline
        uses 10–80 aa, but this avoids accidental exclusions if any shorter
        sequences remain.

    Raises
    ------
    RuntimeError if CD-HIT exits non-zero.
    """
    # Word size guidance: CD-HIT recommends -n based on identity,
    # but for short peptides smaller -n can behave better.
    word_size = 4

    cmd = [
        "cd-hit",
        "-i", str(fasta_path),
        "-o", str(out_path),
        "-c", str(identity),
        "-n", str(word_size),
        "-M", "2000",
        "-T", "4",
        "-d", "0",    # full seq ID in .clstr output
        "-l", "4",    # min length (default ~10); allow shorter peptides if present
    ]

    # capture_output=True allows us to show stderr on failure.
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(f"cd-hit failed:\n{result.stderr}")


def parse_clstr(clstr_path: Path) -> dict[str, int]:
    """
    Parse CD-HIT .clstr output and build a mapping from sequence ID -> cluster ID.

    CD-HIT .clstr file structure (simplified):
      >Cluster 0
      0  50aa, >seq_0... *
      1  49aa, >seq_123...
      >Cluster 1
      0  30aa, >seq_5... *

    We increment cluster_id each time we see a new cluster header, then capture
    IDs like 'seq_123' from the member lines.

    Returns
    -------
    dict mapping 'seq_<row_index>' -> <cluster_index>
    """
    mapping: dict[str, int] = {}
    cluster_id = -1

    with clstr_path.open() as fh:
        for line in fh:
            line = line.strip()

            # New cluster marker
            if line.startswith(">Cluster"):
                cluster_id += 1
                continue

            # Member line: extract "seq_###" token from ">seq_###..."
            m = re.search(r">(seq_\d+)\.\.\.", line)
            if m:
                mapping[m.group(1)] = cluster_id

    return mapping


def assign_cluster_splits(
    seq_to_cluster: dict[str, int],
    train_frac: float,
    seed: int
) -> dict[int, str]:
    """
    Assign each cluster (not each sequence) to train/test.

    Why cluster-level assignment?
    -----------------------------
    If we split sequences independently, two sequences from the same CD-HIT
    cluster could land in different splits, creating leakage (near duplicates
    in both train and test). Splitting *clusters* prevents that.

    Implementation
    --------------
    - Collect unique cluster IDs
    - Shuffle deterministically (seed)
    - First round(train_frac * n_clusters) clusters -> train, remainder -> test

    Returns
    -------
    dict mapping cluster_id -> 'train'|'test'
    """
    rng = random.Random(seed)

    # Unique cluster IDs present in this dataset.
    cluster_ids = sorted(set(seq_to_cluster.values()))

    # Deterministic shuffling ensures reproducibility across runs.
    rng.shuffle(cluster_ids)

    # Use round so the split isn't systematically biased downwards.
    split_point = round(len(cluster_ids) * train_frac)

    result: dict[int, str] = {}
    for i, cid in enumerate(cluster_ids):
        result[cid] = "train" if i < split_point else "test"
    return result


def process_file(tsv_path: Path) -> None:
    """
    Process one TSV file: cluster sequences and output a train/test split TSV.

    Output file is written next to the input in AMP_DIR:
      clustered_split_<original_name>.tsv
    """
    print(f"\nProcessing: {tsv_path.name}")

    # Read TSV into memory. This is fine for moderate TSV sizes; for very large
    # inputs you could stream and use a stable ID column instead of seq_i.
    with tsv_path.open(newline="", encoding="utf-8") as fh:
        reader = csv.reader(fh, delimiter="\t")
        header = next(reader)
        rows = list(reader)

    # Find the peptide sequence column.
    seq_col = detect_seq_col(header)

    # Temporary directory ensures we don't litter the repo with intermediate files.
    # Everything in tmpdir is deleted automatically.
    with tempfile.TemporaryDirectory() as tmpdir:
        fasta_in = Path(tmpdir) / "seqs.faa"

        # CD-HIT outputs:
        #   cdhit_out      (representative sequences)
        #   cdhit_out.clstr (cluster membership listing)
        cdhit_out = Path(tmpdir) / "cdhit_out"
        clstr_path = Path(str(cdhit_out) + ".clstr")

        # Write input sequences and run CD-HIT clustering.
        write_fasta(rows, seq_col, fasta_in)
        run_cdhit(fasta_in, cdhit_out, IDENTITY)

        # Build seq_id -> cluster_id mapping from CD-HIT's .clstr file.
        seq_to_cluster = parse_clstr(clstr_path)

    # Assign train/test by cluster.
    cluster_to_split = assign_cluster_splits(seq_to_cluster, TRAIN_FRAC, SEED)

    # Prepare output TSV file.
    out_name = "clustered_split_" + tsv_path.name
    out_path = AMP_DIR / out_name

    # Add new columns documenting cluster membership and split assignment.
    out_header = header + ["cluster_id", "split"]

    # Track split counts for a quick summary.
    counts: dict[str, int] = {"train": 0, "test": 0, "unknown": 0}

    with out_path.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.writer(fh, delimiter="\t")
        writer.writerow(out_header)

        # We use seq_i IDs to join TSV rows back to clusters.
        for i, row in enumerate(rows):
            key = f"seq_{i}"

            # If a sequence was not clustered (e.g., filtered out by CD-HIT or empty),
            # it won't appear in seq_to_cluster and will be assigned cluster_id=-1.
            cid = seq_to_cluster.get(key, -1)

            # If cid=-1 (unclustered), it will fall back to "unknown".
            split = cluster_to_split.get(cid, "unknown")

            writer.writerow(row + [cid, split])

            # Safe counting even if split label is unexpected.
            counts[split] = counts.get(split, 0) + 1

    # Reporting: number of distinct clusters discovered in the file.
    n_clusters = len(set(seq_to_cluster.values()))

    print(f"  Sequences : {len(rows)}")
    print(f"  Clusters  : {n_clusters}  (at {int(IDENTITY * 100)}% identity)")
    print(f"  Train     : {counts['train']} sequences")
    print(f"  Test      : {counts['test']} sequences")
    if counts.get("unknown", 0):
        print(f"  Unknown   : {counts['unknown']} (not clustered by cd-hit, likely too short)")
    print(f"  Written   : {out_name}")


def main() -> None:
    """
    Entry point: find all unique_*.tsv files in AMP_DIR and process them.

    This matches your project convention where training sets begin with unique_.
    """
    files = sorted(AMP_DIR.glob("unique_*.tsv"))
    if not files:
        print("No unique_*.tsv files found in", AMP_DIR)
        return

    for f in files:
        process_file(f)

    print("\nAll files processed.")


if __name__ == "__main__":
    # Standard Python main guard so this script can be imported without executing.
    main()