# Capstone

## Convert SRA to FASTQ

### Problem

Running `fastq-dump` with the `-t` flag fails:

```
fastq-dump /path/to/SRR37244542/SRR37244542.lite \
  --split-files \
  -O ~/fastq \
  -t ~/tmp
# err: param incorrect while reading argument list within application support module - -t
```

`fastq-dump` does **not** accept the `-t` (temp directory) argument.

### Fix

Use `fasterq-dump`, which does support `-t`:

```bash
mkdir -p ~/fastq ~/tmp

fasterq-dump /path/to/SRR37244542/SRR37244542.lite \
  --split-files \
  -O ~/fastq \
  -t ~/tmp
```

Or use the provided helper script (works with any SRA .lite file):

```bash
bash run_fastq_dump.sh <SRA_FILE> [OUTPUT_DIR] [TEMP_DIR]

# Example:
bash run_fastq_dump.sh "$HOME/sra/sra/SRR37244542/SRR37244542.lite"
```

### Why the error occurs

| Tool | `-t` / `--temp` support |
|---|---|
| `fastq-dump` | ❌ Not supported |
| `fasterq-dump` | ✅ Supported |

Both tools are part of the [NCBI SRA Toolkit](https://github.com/ncbi/sra-tools).
`fasterq-dump` is the modern replacement for `fastq-dump` and is recommended for new workflows.