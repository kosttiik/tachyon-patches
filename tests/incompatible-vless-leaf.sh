#!/bin/sh
set -eu
lib=${1:?Pass the patched 1.5.21 library directory}
runtime="$lib/tachyon_core/runtime.uc"
task_dir=$(mktemp -d)
trap 'rm -rf "$task_dir"' EXIT INT TERM

cat > "$task_dir/config.json" <<'JSON'
{"outbounds":[{"type":"vless","tag":"bad-node","encryption":"mlkem-invalid"},{"type":"vless","tag":"good-node"},{"type":"selector","tag":"Proxy-out","outbounds":["bad-node","good-node"],"default":"bad-node"},{"type":"urltest","tag":"Proxy-urltest","outbounds":["bad-node","good-node"]}],"route":{"final":"Proxy-out"}}
JSON
result=$(TACHYON_LIB="$lib" ucode -L "$lib" "$runtime" incompatible-vless-fixture "$task_dir/config.json" 'initialize outbound[0]: parse encryption: invalid encryption key length')
[ "$result" = removed ]
! grep -q 'bad-node\|mlkem-invalid' "$task_dir/config.json"
[ "$(jsonfilter -i "$task_dir/config.json" -e '@.outbounds[1].default')" = good-node ]
[ "$(jsonfilter -i "$task_dir/config.json" -e '@.outbounds[2].outbounds[0]')" = good-node ]

cat > "$task_dir/config.json" <<'JSON'
{"outbounds":[{"type":"vless","tag":"bad-node","encryption":"mlkem-invalid"},{"type":"selector","tag":"Proxy-out","outbounds":["bad-node"],"default":"bad-node"}],"route":{"final":"Proxy-out"}}
JSON
result=$(TACHYON_LIB="$lib" ucode -L "$lib" "$runtime" incompatible-vless-fixture "$task_dir/config.json" 'initialize outbound[0]: parse encryption: invalid encryption key length')
[ "$result" = retained ]
grep -q 'bad-node' "$task_dir/config.json"

cat > "$task_dir/config.json" <<'JSON'
{"outbounds":[{"type":"vless","tag":"bad-node","encryption":"mlkem-invalid"},{"type":"vless","tag":"good-node"},{"type":"selector","tag":"Proxy-out","outbounds":["bad-node","good-node"],"default":"bad-node"}],"route":{"final":"bad-node"}}
JSON
result=$(TACHYON_LIB="$lib" ucode -L "$lib" "$runtime" incompatible-vless-fixture "$task_dir/config.json" 'initialize outbound[0]: parse encryption: invalid encryption key length')
[ "$result" = retained ]
grep -q 'bad-node' "$task_dir/config.json"

printf '%s\n' 'Incompatible VLESS leaf fixtures passed'
