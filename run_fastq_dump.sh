#!/usr/bin/env bash
# Converts an SRA .lite file to FASTQ using fasterq-dump (which supports -t).
#
# fastq-dump does NOT accept the -t (temp directory) flag — use fasterq-dump instead.
#
# Usage:
#   bash run_fastq_dump.sh <SRA_FILE> [OUTPUT_DIR] [TEMP_DIR]
#
# Defaults:
#   SRA_FILE   = (required – pass as first argument)
#   OUTPUT_DIR = ~/fastq
#   TEMP_DIR   = ~/tmp

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <SRA_FILE> [OUTPUT_DIR] [TEMP_DIR]" >&2
  echo "Example: $0 \$HOME/sra/sra/SRR37244542/SRR37244542.lite" >&2
  exit 1
fi
SRA_FILE="${1}"
OUTPUT_DIR="${2:-${HOME}/fastq}"
TEMP_DIR="${3:-${HOME}/tmp}"

mkdir -p "${OUTPUT_DIR}" "${TEMP_DIR}"

fasterq-dump "${SRA_FILE}" \
  --split-files \
  -O "${OUTPUT_DIR}" \
  -t "${TEMP_DIR}"
