#!/bin/sh
set -eu
source_root=${1:?Pass the directory containing extracted official 1.5.21 packages}
output=${2:?Pass a new output tar.gz path}
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
source_root=$(CDPATH= cd -- "$source_root" && pwd)
case "$output" in /*) ;; *) output="$(pwd)/$output" ;; esac
[ ! -e "$output" ] || { echo 'Output already exists' >&2; exit 1; }
if command -v sha256sum >/dev/null 2>&1; then
    check_hashes() { sha256sum -c "$1"; }
elif command -v shasum >/dev/null 2>&1; then
    check_hashes() { shasum -a 256 -c "$1"; }
else
    echo 'SHA256 tool is required' >&2; exit 1
fi
command -v patch >/dev/null 2>&1 || { echo 'patch is required' >&2; exit 1; }
(cd "$source_root" && check_hashes "$repo_dir/official-files.sha256")
task_dir=$(mktemp -d "${TMPDIR:-/tmp}/tachyon-overlay.XXXXXX")
trap 'rm -rf "$task_dir"' EXIT INT TERM
while read -r hash path; do
    [ -f "$source_root/$path" ] && [ ! -L "$source_root/$path" ] || exit 1
    mkdir -p "$task_dir/$(dirname "$path")"
    cp -p "$source_root/$path" "$task_dir/$path"
done < "$repo_dir/official-files.sha256"
for patch_file in "$repo_dir"/patches/*.patch; do
    patch --batch --forward -p1 -d "$task_dir" < "$patch_file"
done
COPYFILE_DISABLE=1 tar -czf "$output" -C "$task_dir" usr www
echo "Prepared $output"
