#!/bin/sh
set -eu
priority_file=${1:?Pass the patched priority.uc path}
task_dir=$(mktemp -d)
trap 'rm -rf "$task_dir"' EXIT INT TERM
printf '%s' '{"pick_fastest":true,"levels":[{"outbounds":["slow","fast"]},{"outbounds":["direct"]}]}' > "$task_dir/group.json"
check() {
    printf '%s' "$1" > "$task_dir/delays.json"
    actual=$(ucode -L /usr/lib/tachyon "$priority_file" select-fixture "$task_dir/group.json" "$task_dir/delays.json" 0 1)
    printf '%s' "$actual" | jsonfilter -e '@.tag' | grep -qx "$2"
}
check '{"slow":90,"fast":60,"direct":10}' fast
check '{"slow":-1,"fast":60,"direct":10}' fast
check '{"slow":-1,"fast":-1,"direct":10}' direct
printf '%s\n' 'Priority selection fixtures passed'
