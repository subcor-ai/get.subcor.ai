#!/bin/sh
# subcor CLI installer.
#
#   curl -fsSL https://get.subcor.ai/install.sh | sh
#
# Environment knobs:
#   SUBCOR_VERSION        install an exact version (e.g. 1.4.0) instead of latest
#   SUBCOR_INSTALL        install prefix (default: $HOME/.subcor); binary lands in $SUBCOR_INSTALL/bin
#   SUBCOR_NO_MODIFY_PATH set to any value to skip editing your shell profile
#
# Supports macOS and Linux on amd64/arm64. Source: https://github.com/subcor-ai/get.subcor.ai
set -eu

REPO="subcor-ai/get.subcor.ai"
INSTALL_DIR="${SUBCOR_INSTALL:-$HOME/.subcor}"
BIN_DIR="$INSTALL_DIR/bin"

err()  { printf 'subcor install: %s\n' "$1" >&2; exit 1; }
info() { printf '%s\n' "$1"; }
have() { command -v "$1" >/dev/null 2>&1; }

# --- detect platform -------------------------------------------------------
os=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$os" in
	darwin | linux) ;;
	*) err "unsupported OS '$os' (supported: macOS, Linux; Windows is not yet supported)." ;;
esac

arch=$(uname -m)
case "$arch" in
	x86_64 | amd64) arch=amd64 ;;
	arm64 | aarch64) arch=arm64 ;;
	*) err "unsupported architecture '$arch' (supported: amd64, arm64)." ;;
esac

asset="subcor_${os}_${arch}.tar.gz"

# --- resolve download URLs -------------------------------------------------
base="https://github.com/${REPO}/releases"
if [ -n "${SUBCOR_VERSION:-}" ]; then
	ver="${SUBCOR_VERSION#v}" # accept "1.4.0" or "v1.4.0"
	url="${base}/download/v${ver}/${asset}"
	sums_url="${base}/download/v${ver}/checksums.txt"
	label="v${ver}"
else
	url="${base}/latest/download/${asset}"
	sums_url="${base}/latest/download/checksums.txt"
	label="latest"
fi

# --- downloader ------------------------------------------------------------
if have curl; then
	dl() { curl -fsSL "$1" -o "$2"; }
elif have wget; then
	dl() { wget -qO "$2" "$1"; }
else
	err "need curl or wget to download subcor."
fi

tmp=$(mktemp -d 2>/dev/null || mktemp -d -t subcor)
trap 'rm -rf "$tmp"' EXIT INT TERM

info "Downloading subcor ($label, ${os}/${arch})..."
dl "$url" "$tmp/$asset" || err "download failed: $url"
dl "$sums_url" "$tmp/checksums.txt" || err "download failed: $sums_url"

# --- verify checksum -------------------------------------------------------
# checksums.txt lines are "<sha256>  <filename>"; awk yields "" if absent.
expected=$(grep " ${asset}\$" "$tmp/checksums.txt" | awk '{print $1}')
[ -n "$expected" ] || err "no checksum for $asset in checksums.txt."

if have shasum; then
	actual=$(shasum -a 256 "$tmp/$asset" | awk '{print $1}')
elif have sha256sum; then
	actual=$(sha256sum "$tmp/$asset" | awk '{print $1}')
else
	err "need shasum or sha256sum to verify the download."
fi

[ "$actual" = "$expected" ] || err "checksum mismatch for $asset (expected $expected, got $actual)."

# --- install ---------------------------------------------------------------
tar -xzf "$tmp/$asset" -C "$tmp" || err "failed to extract $asset."
[ -f "$tmp/subcor" ] || err "archive did not contain a subcor binary."

mkdir -p "$BIN_DIR" 2>/dev/null || err "cannot create $BIN_DIR (not writable?)."
install -m 0755 "$tmp/subcor" "$BIN_DIR/subcor" 2>/dev/null ||
	err "cannot write to $BIN_DIR (permission denied?)."

info "Installed subcor to $BIN_DIR/subcor"

# --- PATH ------------------------------------------------------------------
case ":$PATH:" in
	*":$BIN_DIR:"*)
		info ""
		info "subcor is ready. Run: subcor --version"
		exit 0
		;;
esac

manual="export PATH=\"$BIN_DIR:\$PATH\""

if [ -n "${SUBCOR_NO_MODIFY_PATH:-}" ]; then
	info ""
	info "$BIN_DIR is not on your PATH. Add it with:"
	info "  $manual"
	exit 0
fi

# Pick the profile for the user's shell.
shell_name=$(basename "${SHELL:-}")
case "$shell_name" in
	zsh) rc="$HOME/.zshrc" ;;
	bash) [ "$os" = darwin ] && rc="$HOME/.bash_profile" || rc="$HOME/.bashrc" ;;
	fish) rc="$HOME/.config/fish/config.fish" ;;
	*) rc="" ;;
esac

added=0
if [ -n "$rc" ] && ! grep -qs 'subcor (managed' "$rc" 2>/dev/null; then
	mkdir -p "$(dirname "$rc")" 2>/dev/null || true
	if [ "$shell_name" = fish ]; then
		line="fish_add_path $BIN_DIR"
	else
		line="$manual"
	fi
	{
		printf '\n# subcor (managed) >>>\n'
		printf '%s\n' "$line"
		printf '# <<< subcor (managed)\n'
	} >>"$rc" && added=1
fi

info ""
if [ "$added" = 1 ]; then
	info "Added $BIN_DIR to your PATH in $rc."
	info "Restart your shell or run:  $manual"
else
	info "$BIN_DIR is not on your PATH. Add it with:"
	info "  $manual"
fi
info ""
info "Then run:  subcor --version"
