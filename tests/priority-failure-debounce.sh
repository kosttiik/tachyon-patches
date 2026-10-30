#!/bin/sh
set -eu
lib=${1:-/usr/lib/tachyon}
priority_file=${2:-$lib/tachyon_core/priority.uc}
result=$(ucode -L "$lib" "$priority_file" active-failure-fixture 3 3)
printf '%s\n' "$result" | grep -qE '"waits":[[:space:]]*\[[[:space:]]*true,[[:space:]]*true,[[:space:]]*false[[:space:]]*\]'
printf '%s\n' "$result" | grep -qE '"count":[[:space:]]*0'
result=$(ucode -L "$lib" "$priority_file" active-failure-fixture 2 2)
printf '%s\n' "$result" | grep -qE '"waits":[[:space:]]*\[[[:space:]]*true,[[:space:]]*false[[:space:]]*\]'
printf '%s\n' "$result" | grep -qE '"count":[[:space:]]*0'
echo 'Priority failure debounce fixtures passed'
