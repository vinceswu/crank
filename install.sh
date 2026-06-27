#!/usr/bin/env sh
set -e

REPO="vinceswu/crank"
INSTALL_DIR="${CRANK_INSTALL_DIR:-$HOME/.local/share/crank}"
BIN_DIR="${CRANK_BIN_DIR:-$HOME/.local/bin}"

die() { echo "error: $1" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "required tool '$1' not found"; }

need curl
need pit
need python3

LATEST_URL="https://api.github.com/repos/${REPO}/releases/latest"
TAG="$(curl -sSfL "$LATEST_URL" | grep '"tag_name"' | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/')"
[ -n "$TAG" ] || die "could not determine latest release tag"

SOURCE_URL="https://github.com/${REPO}/archive/refs/tags/${TAG}.tar.gz"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Downloading crank ${TAG}..."
curl -sSfL "$SOURCE_URL" -o "${TMP}/source.tar.gz" || die "download failed: $SOURCE_URL"

mkdir -p "$INSTALL_DIR"
tar -xzf "${TMP}/source.tar.gz" -C "$INSTALL_DIR" --strip-components=1

if [ -f "${INSTALL_DIR}/requirements.txt" ]; then
    echo "Installing Python dependencies..."
    python3 -m pip install -q -r "${INSTALL_DIR}/requirements.txt"
fi

echo "Downloading spaCy model..."
python3 -m spacy download en_core_web_md -q

mkdir -p "$BIN_DIR"
cat > "${BIN_DIR}/crank" <<EOF
#!/usr/bin/env sh
cd "${INSTALL_DIR}" && exec pit run "\$@"
EOF
chmod +x "${BIN_DIR}/crank"

echo "Installed crank ${TAG} to ${INSTALL_DIR}"
echo "Launcher: ${BIN_DIR}/crank"

case ":${PATH}:" in
    *":${BIN_DIR}:"*) ;;
    *)
        echo ""
        echo "  Add to PATH:"
        echo "    export PATH=\"${BIN_DIR}:\$PATH\""
        echo ""
        echo "  Then run: crank"
        ;;
esac
