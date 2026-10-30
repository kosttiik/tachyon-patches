#!/bin/sh
set -eu
lib=${1:?Pass isolated 1.5.21 library directory}
generator=${2:?Pass patched generator.uc path}
fixture=${3:?Pass fixture JSON path}
task_dir=$(mktemp -d)
trap 'rm -rf "$task_dir"' EXIT INT TERM
for variant in extended upstream; do
    version=1.14.3
    [ "$variant" != extended ] || version=1.14.3-extended-2.7.3
    TACHYON_LIB="$lib" SB_VERSION_OVERRIDE="$version" SB_VARIANT_STATE_FILE="$task_dir/no-marker" \
      ucode -L "$lib" "$generator" generate-config-fixture "$fixture" "$task_dir/$variant.json" 127.0.0.1 0 1
    value=$(jsonfilter -i "$task_dir/$variant.json" -e '@.experimental.unified_delay.enabled' 2>/dev/null || true)
    if [ "$variant" = extended ]; then [ "$value" = true ]; else [ -z "$value" ]; fi
done
sing-box check -c "$task_dir/extended.json"
printf '%s\n' 'KeepAlive generator fixtures passed'
