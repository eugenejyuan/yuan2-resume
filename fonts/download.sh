#!/usr/bin/env sh
# Download the exact font files used by the original yuan-resume template.
set -eu

font_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
upstream_commit=29b39442a176410012c6454cf64493175a19289c
upstream_root="https://raw.githubusercontent.com/xyz-yuanhf/yuan-resume/$upstream_commit/Fonts"

if ! command -v curl >/dev/null 2>&1; then
  echo "error: curl is required to download the fonts" >&2
  exit 1
fi

hash_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    echo "error: sha256sum or shasum is required to verify the fonts" >&2
    exit 1
  fi
}

stage_root=$(mktemp -d "${TMPDIR:-/tmp}/yuan2resume-fonts.XXXXXX")
cleanup() {
  rm -rf -- "$stage_root"
}
trap cleanup EXIT HUP INT TERM

download_font() {
  source_path=$1
  destination_path=$2
  expected_hash=$3
  destination="$font_dir/$destination_path"

  if [ -f "$destination" ] && [ "$(hash_file "$destination")" = "$expected_hash" ]; then
    printf '  ok    %s\n' "$destination_path"
    return
  fi

  staged="$stage_root/$destination_path"
  mkdir -p "$(dirname -- "$staged")"
  printf '  fetch %s\n' "$destination_path"
  curl --fail --location --silent --show-error --retry 3 \
    "$upstream_root/$source_path" --output "$staged"

  actual_hash=$(hash_file "$staged")
  if [ "$actual_hash" != "$expected_hash" ]; then
    echo "error: checksum mismatch for $destination_path" >&2
    echo "  expected: $expected_hash" >&2
    echo "  actual:   $actual_hash" >&2
    exit 1
  fi

  mkdir -p "$(dirname -- "$destination")"
  mv -- "$staged" "$destination"
}

download_font Sabon/SabonLTStd-Regular.ttf \
  SabonLTStd/SabonLTStd-Regular.ttf \
  3d2bf79c38e0c8de542998491596b9b7bd2d82cec799b1d2ad8b86492f404716
download_font Sabon/SabonLTStd-Bold.ttf \
  SabonLTStd/SabonLTStd-Bold.ttf \
  03db873ecdccb3c63653a7fc0f5334a2a73ce1c65bbf77b8a4d89c7670d509ed
download_font Sabon/SabonLTStd-Italic.ttf \
  SabonLTStd/SabonLTStd-Italic.ttf \
  d328650fee8269a526a6c2176ce281f55259e38a52f26e7be2db55d0ee1f7802
download_font Sabon/SabonLTStd-BoldItalic.ttf \
  SabonLTStd/SabonLTStd-BoldItalic.ttf \
  72ea78f28a5496292ce82eb517cddc016857bbbae04a56d8dbabc8f10ec6150b
download_font Calluna/Calluna-Regular.otf \
  Calluna/Calluna-Regular.otf \
  93bafffcf9bef76775ac41f281dd7db49d9420600037b774030366b20ea5b70a
download_font Cronos/CronosProLT-Regular.ttf \
  CronosProLT/CronosProLT-Regular.ttf \
  c1fcba6c22fdb974d6288dd38176cbebd272ff9086ea3fa20b2a2cd057fe1ac8
download_font Courier/CourierNew-Regular.ttf \
  CourierNew/CourierNew-Regular.ttf \
  c886ca3172d8ce9189976992d145ec090500a4ff516ecb9d4df56b1a78336247

echo "Commercial fonts are ready under $font_dir"
