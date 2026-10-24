#!/usr/bin/env bash
set -euo pipefail

# Cloudflare Pages currently exposes the standard Hugo binary. OINK compiles
# SCSS, so the build must use the Extended binary explicitly.
version="${HUGO_VERSION:-0.168.0}"
version="${version#v}"

case "$(uname -s):$(uname -m)" in
  Linux:x86_64) asset="linux-amd64" ;;
  Linux:aarch64|Linux:arm64) asset="linux-arm64" ;;
  *)
    echo "hugo-extended.sh supports Linux CI only; use local Hugo Extended on this host" >&2
    exit 2
    ;;
esac

cache_dir="${HUGO_EXTENDED_CACHE_DIR:-.hugo-extended/$version}"
binary="$cache_dir/hugo"
archive="$cache_dir/hugo_extended_${version}_${asset}.tar.gz"
url="https://github.com/gohugoio/hugo/releases/download/v${version}/hugo_extended_${version}_${asset}.tar.gz"

if [[ ! -x "$binary" ]]; then
  mkdir -p "$cache_dir"
  curl --fail --location --silent --show-error "$url" --output "$archive"
  tar -xzf "$archive" -C "$cache_dir" hugo
  chmod +x "$binary"
fi

"$binary" "$@"
