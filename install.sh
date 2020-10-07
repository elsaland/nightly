#!/bin/sh

set -e

if [ "$(uname -m)" != "x86_64" ]; then
  echo "Error: Unsupported architecture $(uname -m). Only x64 binaries are available." 1>&2
  exit 1
fi

if ! command -v unzip >/dev/null; then
  echo "Error: unzip is required to install Elsa (Nightly)." 1>&2
  exit 1
fi

case $(uname -s) in
Darwin) target="x86_64-apple-darwin" ;;
*) target="x86_64-unknown-linux-gnu" ;;
esac

if [ $# -eq 0 ]; then
  elsa_asset_path=$(
    curl -sSf https://github.com/elsaland/nightly/releases |
      grep -o "/elsaland/nightly/releases/download/.*/elsa-nightly-${target}\\.zip" |
      head -n 1
  )
  if [ ! "$elsa_asset_path" ]; then
    echo "Error: Unable to find latest Elsa (Nightly) release on GitHub." 1>&2
    exit 1
  fi
  elsa_uri="https://github.com${elsa_asset_path}"
else
  elsa_uri="https://github.com/elsaland/nightly/releases/download/${1}/elsa-nightly-${target}.zip"
fi

elsa_install="${ELSA_INSTALL:-$HOME/.elsa}"
bin_dir="$elsa_install/bin"
tmp_dir="$elsa_install/tmp"
tmp_exe="$tmp_dir/elsa"
exe="$bin_dir/elsa-nightly"

if [ ! -d "$bin_dir" ]; then
  mkdir -p "$bin_dir"
fi

if [ ! -d "$tmp_dir" ]; then
  mkdir -p "$tmp_dir"
fi

curl --fail --location --progress-bar --output "$tmp_exe.zip" "$elsa_uri"
cd "$tmp_dir"
unzip -o "$tmp_exe.zip"
chmod +x "$tmp_exe"
mv "$tmp_exe" "$exe"
rm -rf "$tmp_dir"

echo "Elsa (Nightly) was installed successfully to $bin_dir/elsa-nightly"
if command -v elsa-nightly >/dev/null; then
  echo "Run 'elsa-nightly --help' to get started"
else
  case $SHELL in
  /bin/zsh) shell_profile=".zshrc" ;;
  *) shell_profile=".bash_profile" ;;
  esac
  echo "Manually add the directory to your \$HOME/$shell_profile (or similar)"
  echo "  export ELSA_INSTALL=\"$elsa_install\""
  echo "  export PATH=\"\$ELSA_INSTALL/bin:\$PATH\""
  echo "Run '$bin_dir/elsa-nightly --help' to get started"
fi
