#!/bin/sh
set -eu
updates=${1:?Pass the patched components/updates.uc path}
task_dir=$(mktemp -d)
trap 'rm -rf "$task_dir"' EXIT INT TERM
run_plan() {
    ucode -L /usr/lib/tachyon "$updates" cron-refresh-plan-fixture "$task_dir/input.json" /usr/bin/tachyon '# list' '# sub' '# comp'
}
printf '%s' '{"settings":{"list_update_enabled":"1","update_interval":"1d","list_update_time":"05:00","download_all_presets":"1"},"section":[]}' > "$task_dir/input.json"
test "$(run_plan)" = "$(printf 'list\t0 5 * * * /usr/bin/tachyon list_update # list')"
printf '%s' '{"settings":{"list_update_enabled":"1","update_interval":"1h","download_all_presets":"1"},"section":[]}' > "$task_dir/input.json"
test "$(run_plan)" = "$(printf 'list\t0 * * * * /usr/bin/tachyon list_update_if_due # list')"
printf '%s' '{"settings":{"list_update_enabled":"0","list_update_time":"05:00","download_all_presets":"1"},"section":[]}' > "$task_dir/input.json"
test "$(run_plan)" = list-disabled
printf '%s' '{"settings":{"list_update_enabled":"1","update_interval":"1d","list_update_time":"25:90","download_all_presets":"1"},"section":[]}' > "$task_dir/input.json"
if run_plan >/dev/null; then echo 'Invalid schedule accepted' >&2; exit 1; fi
echo 'Daily list schedule fixtures passed'
