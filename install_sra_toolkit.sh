#!/usr/bin/env bash
# install_sra_toolkit.sh
#
# Installs the NCBI SRA Toolkit (provides fasterq-dump, fastq-dump, etc.)
#
# Supported installation methods (tried in order):
#   1. conda / mamba  (recommended — manages PATH automatically)
#   2. apt-get        (Ubuntu / Debian)
#   3. NCBI binary release (Linux x86_64 fallback; installs to ~/sratoolkit)
#
# Usage:
#   bash install_sra_toolkit.sh

set -euo pipefail

TOOLKIT_VERSION="3.3.0"
INSTALL_DIR="${HOME}/sratoolkit"
PATH_MARKER="# NCBI SRA Toolkit"

# ── helpers ───────────────────────────────────────────────────────────────────
have() { command -v "$1" &>/dev/null; }

show_version() {
  local bin="${1:-fasterq-dump}"
  echo ">>> fasterq-dump installed: $("${bin}" --version 2>&1 | head -1)"
}

# ── 1. conda / mamba ──────────────────────────────────────────────────────────
if have conda || have mamba; then
  MGR="conda"
  have mamba && MGR="mamba"
  echo ">>> Installing sra-tools via ${MGR} (bioconda) …"
  "${MGR}" install -y -c conda-forge -c bioconda sra-tools
  show_version fasterq-dump
  exit 0
fi

# ── 2. apt-get (Ubuntu / Debian) ──────────────────────────────────────────────
if have apt-get; then
  echo ">>> Installing sra-toolkit via apt-get …"
  sudo apt-get update -qq
  sudo apt-get install -y sra-toolkit
  # The apt package ships an older version; use vdb-config to configure it.
  echo ">>> Running vdb-config --interactive=false …"
  vdb-config --interactive=false 2>/dev/null || true
  show_version fasterq-dump
  exit 0
fi

# ── 3. NCBI binary release (Linux x86_64 fallback) ────────────────────────────
echo ">>> conda/mamba and apt-get not found; downloading NCBI SRA Toolkit ${TOOLKIT_VERSION} …"

ARCH="$(uname -m)"
if [[ "${ARCH}" != "x86_64" ]]; then
  echo "ERROR: Automatic binary install only supports x86_64 (detected: ${ARCH})." >&2
  echo "       Please install manually from https://github.com/ncbi/sra-tools/wiki/01.-Downloading-SRA-Toolkit" >&2
  exit 1
fi

TARBALL="sratoolkit.${TOOLKIT_VERSION}-ubuntu64.tar.gz"
URL="https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/${TOOLKIT_VERSION}/${TARBALL}"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

echo ">>> Downloading ${URL} …"
curl -fsSL "${URL}" -o "${TMP_DIR}/${TARBALL}"

echo ">>> Extracting to ${INSTALL_DIR} …"
rm -rf "${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}"
tar -xzf "${TMP_DIR}/${TARBALL}" -C "${INSTALL_DIR}" --strip-components=1

BIN_DIR="${INSTALL_DIR}/bin"
echo ">>> Adding ${BIN_DIR} to PATH for this session …"
export PATH="${BIN_DIR}:${PATH}"

# Persist PATH entry in shell rc files, keyed by the exact BIN_DIR to avoid duplicates.
PATH_LINE="export PATH=\"${BIN_DIR}:\${PATH}\"  ${PATH_MARKER}"
for RC in "${HOME}/.bashrc" "${HOME}/.bash_profile" "${HOME}/.profile"; do
  if [[ -f "${RC}" ]] && ! grep -qF "${BIN_DIR}" "${RC}"; then
    echo "${PATH_LINE}" >> "${RC}"
    echo ">>> Added PATH entry to ${RC}"
  fi
done

echo ">>> Configuring SRA Toolkit …"
"${BIN_DIR}/vdb-config" --interactive=false 2>/dev/null || true

show_version "${BIN_DIR}/fasterq-dump"
echo ""
echo ">>> Done! Open a new terminal (or run: source ~/.bashrc) so the PATH update takes effect."
