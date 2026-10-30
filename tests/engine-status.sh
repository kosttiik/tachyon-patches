#!/bin/sh
set -eu
lib=${1:?Pass isolated 1.5.21 library directory}
expected_variant=${2:?Pass expected installed variant label}
result=$(TACHYON_LIB="$lib" ucode -L "$lib" -e 'require("diagnostics.system_info").get_engine_status();')
[ "$(printf '%s' "$result" | jsonfilter -e '@.engine')" = tachyon-core ]
[ "$(printf '%s' "$result" | jsonfilter -e '@.variant')" = "$expected_variant" ]
[ "$(printf '%s' "$result" | jsonfilter -e '@.managed_by')" = tachyon ]
printf '%s\n' 'Managed engine status passed'
