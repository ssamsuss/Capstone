#!/usr/bin/env bash
# install_sra_toolkit.sh
#
# Installs the NCBI SRA Toolkit (provides fasterq-dump, fastq-dump, etc.)
# If fasterq-dump is already available in PATH the script exits immediately.
#
# Supported installation methods (tried in order):
#   1. Already installed — detected in PATH or ~/sratoolkit.*/bin/
#   2. conda / mamba    (recommended — manages PATH automatically)
#   3. apt-get          (Ubuntu / Debian)
#   4. dnf / yum        (AlmaLinux / RHEL / CentOS / Fedora)
#   5. NCBI binary release (Linux x86_64 fallback; installs to ~/sratoolkit.VERSION-OS/)
#
# Usage:
#   bash install_sra_toolkit.sh

set -euo pipefail

TOOLKIT_VERSION="3.3.0"
PATH_MARKER="# NCBI SRA Toolkit"

# ── helpers ───────────────────────────────────────────────────────────────────
have() { command -v "$1" &>/dev/null; }

show_version() {
  local bin="${1}"
  echo ">>> fasterq-dump installed: $("${bin}" --version 2>&1 | head -1)"
}

add_to_path_rc() {
  local bin_dir="${1}"
  local path_line="export PATH=\"${bin_dir}:\${PATH}\"  ${PATH_MARKER}"
  for RC in "${HOME}/.bashrc" "${HOME}/.bash_profile" "${HOME}/.profile"; do
    if [[ -f "${RC}" ]] && ! grep -qF "${bin_dir}" "${RC}"; then
      echo "${path_line}" >> "${RC}"
      echo ">>> Added PATH entry to ${RC}"
    fi
  done
}

# ── 1. Already installed ──────────────────────────────────────────────────────
# Check PATH first.
if have fasterq-dump; then
  echo ">>> fasterq-dump is already available in PATH."
  show_version "$(command -v fasterq-dump)"
  exit 0
fi

# Check common versioned install directories (e.g. ~/sratoolkit.3.3.0-alma_linux64/bin/).
for CANDIDATE in "${HOME}"/sratoolkit.*/bin/fasterq-dump; do
  if [[ -x "${CANDIDATE}" ]]; then
    BIN_DIR="$(dirname "${CANDIDATE}")"
    echo ">>> fasterq-dump found at ${CANDIDATE} but not in PATH."
    export PATH="${BIN_DIR}:${PATH}"
    add_to_path_rc "${BIN_DIR}"
    show_version "${CANDIDATE}"
    echo ">>> Run 'source ~/.bashrc' (or open a new terminal) to make PATH permanent."
    exit 0
  fi
done

# ── 2. conda / mamba ──────────────────────────────────────────────────────────
if have conda || have mamba; then
  MGR="conda"
  have mamba && MGR="mamba"
  echo ">>> Installing sra-tools via ${MGR} (bioconda) …"
  "${MGR}" install -y -c conda-forge -c bioconda sra-tools
  show_version "$(command -v fasterq-dump)"
  exit 0
fi

# ── 3. apt-get (Ubuntu / Debian) ──────────────────────────────────────────────
if have apt-get; then
  echo ">>> Installing sra-toolkit via apt-get …"
  sudo apt-get update -qq
  sudo apt-get install -y sra-toolkit
  vdb-config --interactive=false 2>/dev/null || true
  show_version "$(command -v fasterq-dump)"
  exit 0
fi

# ── 4. dnf / yum (AlmaLinux / RHEL / CentOS / Fedora) ────────────────────────
if have dnf || have yum; then
  PKG_MGR="dnf"
  have yum && ! have dnf && PKG_MGR="yum"
  echo ">>> Installing sra-tools via ${PKG_MGR} …"
  sudo "${PKG_MGR}" install -y sra-tools
  vdb-config --interactive=false 2>/dev/null || true
  show_version "$(command -v fasterq-dump)"
  exit 0
fi

# ── 5. NCBI binary release (Linux x86_64 fallback) ────────────────────────────
echo ">>> No supported package manager found; downloading NCBI SRA Toolkit ${TOOLKIT_VERSION} …"

ARCH="$(uname -m)"
if [[ "${ARCH}" != "x86_64" ]]; then
  echo "ERROR: Automatic binary install only supports x86_64 (detected: ${ARCH})." >&2
  echo "       Please install manually: https://github.com/ncbi/sra-tools/wiki/01.-Downloading-SRA-Toolkit" >&2
  exit 1
fi

# Select the correct OS-specific tarball.
OS_ID="$(. /etc/os-release 2>/dev/null && echo "${ID:-linux}" || echo "linux")"
case "${OS_ID}" in
  ubuntu|debian)           OS_SUFFIX="ubuntu64"     ;;
  almalinux|rhel|centos)   OS_SUFFIX="alma_linux64" ;;
  fedora)                  OS_SUFFIX="fedora64"      ;;
  *)                       OS_SUFFIX="ubuntu64"      ;;  # safest fallback
esac

TARBALL="sratoolkit.${TOOLKIT_VERSION}-${OS_SUFFIX}.tar.gz"
INSTALL_DIR="${HOME}/sratoolkit.${TOOLKIT_VERSION}-${OS_SUFFIX}"
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
add_to_path_rc "${BIN_DIR}"

echo ">>> Configuring SRA Toolkit …"
"${BIN_DIR}/vdb-config" --interactive=false 2>/dev/null || true

show_version "${BIN_DIR}/fasterq-dump"
echo ""
echo ">>> Done! Run 'source ~/.bashrc' (or open a new terminal) to make PATH permanent."
