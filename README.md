# Capstone

Bioinformatics Capstone project – RNA-seq / SRA data retrieval and analysis pipeline.

---

## Problem: shell commands not found (`sudo`, `which`, `cat`, `fastq-dump` …)

When the shell `PATH` environment variable is empty or too restrictive, even
standard utilities such as `sudo`, `which`, and `cat` become unavailable:

```
-bash: which: command not found
-bash: cat: command not found
```

The root cause is that the login shell started without the standard system
directories (`/bin`, `/usr/bin`, `/usr/local/bin`, etc.) in `PATH`.

---

## Quick fix

### Option A – one-time fix for the current session

Paste this line directly in the broken shell to restore a sane `PATH` immediately:

```bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$HOME/.local/bin:$HOME/bin"
```

After running that command, `cat`, `which`, `sudo`, and other utilities will
work again for the duration of the current session.

### Option B – persistent fix + tool installation (recommended)

Run the bundled `setup_env.sh` script.  It restores the PATH, downloads and
installs the **NCBI SRA Toolkit** (`fastq-dump` / `fasterq-dump`), and
persists the PATH fix in `~/.bashrc` so every future shell session works
correctly.

```bash
# Make the script executable, then run it
bash setup_env.sh
```

After it finishes, reload your shell configuration:

```bash
source ~/.bashrc
```

Then verify the tools are available:

```bash
fastq-dump  --version
fasterq-dump --version
```

---

## What `setup_env.sh` does

1. **Restores `PATH`** to include all standard system directories.
2. **Checks** that basic utilities (`cat`, `which`, `curl`/`wget`, `tar`) are
   reachable.
3. **Downloads and installs the NCBI SRA Toolkit** (v3.1.1) for the detected
   CPU architecture (x86_64 or arm64).  Symlinks for `fastq-dump`,
   `fasterq-dump`, `prefetch`, `sra-stat`, and `vdb-config` are placed in
   `~/.local/bin`.
4. **Persists the `PATH` fix** in `~/.bashrc` so future sessions are
   unaffected.

---

## Requirements

| Requirement | Notes |
|-------------|-------|
| GNU Bash 4+ | The system already has Bash 5.2 |
| `curl` **or** `wget` | Needed to download the SRA Toolkit |
| `tar` | Needed to extract the archive |
| Internet access | Required to fetch the SRA Toolkit from NCBI |

---

## SRA Toolkit usage examples

Download a public SRA run in FASTQ format:

```bash
# Fast multi-threaded download (preferred)
fasterq-dump SRR000001 --outdir ./data

# Classic single-threaded download
fastq-dump --gzip SRR000001 --outdir ./data
```
