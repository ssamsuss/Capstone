#!/bin/bash
# setup_env.sh
# Sets up the shell environment and installs required bioinformatics tools.
# Designed to work even when common utilities (sudo, which, cat) are missing
# from PATH by first restoring a sane PATH.

set -e

# Step 1: Restore a sane PATH that includes all standard system directories.
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$HOME/.local/bin:$HOME/bin"

echo "PATH set to: $PATH"

# Step 2: Verify that basic utilities are now available.
for cmd in cat which curl wget tar; do
    if command -v "$cmd" > /dev/null 2>&1; then
        echo "  [OK] $cmd found at $(command -v "$cmd")"
    else
        echo "  [WARN] $cmd not found – some steps may be skipped"
    fi
done

# Step 3: Install the NCBI SRA Toolkit (provides fastq-dump / fasterq-dump).
SRATOOLKIT_VERSION="3.1.1"
SRATOOLKIT_DIR="$HOME/sratoolkit"
INSTALL_DIR="$HOME/.local/bin"

install_sra_toolkit() {
    echo ""
    echo "=== Installing NCBI SRA Toolkit v${SRATOOLKIT_VERSION} ==="

    # Detect architecture.
    ARCH="$(uname -m)"
    case "$ARCH" in
        x86_64)
            PLATFORM="ubuntu64"
            ;;
        aarch64 | arm64)
            # NCBI names the ARM64 Linux package "aarch64" in recent releases.
            PLATFORM="aarch64"
            ;;
        *)
            echo "Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac

    TARBALL="sratoolkit.${SRATOOLKIT_VERSION}-${PLATFORM}.tar.gz"
    DOWNLOAD_URL="https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/${SRATOOLKIT_VERSION}/${TARBALL}"

    echo "Downloading from: $DOWNLOAD_URL"

    mkdir -p "$SRATOOLKIT_DIR"
    if command -v curl > /dev/null 2>&1; then
        curl -fsSL "$DOWNLOAD_URL" -o "/tmp/${TARBALL}"
    elif command -v wget > /dev/null 2>&1; then
        wget -q "$DOWNLOAD_URL" -O "/tmp/${TARBALL}"
    else
        echo "Neither curl nor wget is available. Cannot download SRA Toolkit."
        exit 1
    fi

    tar -xzf "/tmp/${TARBALL}" -C "$SRATOOLKIT_DIR" --strip-components=1
    rm -f "/tmp/${TARBALL}"

    # Add the bin directory to the install directory via symlinks.
    mkdir -p "$INSTALL_DIR"
    for tool in fastq-dump fasterq-dump prefetch sra-stat vdb-config; do
        if [ -f "${SRATOOLKIT_DIR}/bin/${tool}" ]; then
            ln -sf "${SRATOOLKIT_DIR}/bin/${tool}" "${INSTALL_DIR}/${tool}"
            echo "  Linked: ${tool} -> ${INSTALL_DIR}/${tool}"
        fi
    done

    echo "SRA Toolkit installed. Tools are available under: $INSTALL_DIR"
}

# Only install if fastq-dump is not already present.
if command -v fastq-dump > /dev/null 2>&1; then
    echo ""
    echo "fastq-dump is already installed at: $(command -v fastq-dump)"
elif command -v fasterq-dump > /dev/null 2>&1; then
    echo ""
    echo "fasterq-dump is already installed at: $(command -v fasterq-dump)"
else
    install_sra_toolkit
fi

# Step 4: Persist the corrected PATH and the local bin directory in ~/.bashrc
# so that every new interactive shell session picks them up automatically.
BASHRC="$HOME/.bashrc"
PATH_EXPORT='export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$HOME/.local/bin:$HOME/bin:$PATH"'

SETUP_ENV_MARKER="# BEGIN setup_env.sh PATH fix"

if ! grep -qF "$SETUP_ENV_MARKER" "$BASHRC" 2>/dev/null; then
    {
        echo ""
        echo "$SETUP_ENV_MARKER"
        echo "$PATH_EXPORT"
        echo "# END setup_env.sh PATH fix"
    } >> "$BASHRC"
    echo "PATH entry added to $BASHRC"
else
    echo "PATH entry already present in $BASHRC – skipping"
fi

echo ""
echo "=== Setup complete ==="
echo "Run 'source ~/.bashrc' or start a new shell session to apply changes."
echo "Verify the tools:"
echo "  fastq-dump  --version"
echo "  fasterq-dump --version"
