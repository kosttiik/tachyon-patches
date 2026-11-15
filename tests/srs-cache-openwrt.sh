#!/bin/sh
# Run on OpenWrt with Tachyon installed and a populated cached ruleset.
set -eu
source=${1:?Pass the path to a populated cached SRS file}
base=$(mktemp -d)
sample=/etc/tachyon/rulesets/.tachyon-cache-test-$$.srs
trap 'rm -f "$sample"; rm -rf "$base"' EXIT INT TERM
cp -p "$source" "$sample"
export TEST_BASE="$base"
sha256sum "$sample" | cut -d ' ' -f1 > "$base/expected"
cat > "$base/parser" <<'PARSER'
#!/bin/sh
echo x >> "$TEST_BASE/calls"
[ "$(sha256sum "$5" | cut -d ' ' -f1)" = "$(cat "$TEST_BASE/expected")" ]
PARSER
chmod 755 "$base/parser"
run() {
 TACHYON_SRS_VERIFY_PERSIST_DIR="$base/persist" TACHYON_SRS_VERIFY_DIR="$base/transient" TACHYON_SING_BOX_BIN="$base/parser" ucode -L /usr/lib/tachyon /usr/lib/tachyon/tachyon_core/rulesets.uc is-adoptable-srs-file "$sample"
}
run
run
[ "$(wc -l < "$base/calls")" -eq 1 ]
touch -t 202001010000 "$base/parser"
run
[ "$(wc -l < "$base/calls")" -eq 2 ]
printf X | dd of="$sample" bs=1 seek=25 conv=notrunc 2>/dev/null
touch -r "$source" "$sample"
if run; then echo 'Corrupt ruleset was accepted' >&2; exit 1; fi
[ "$(wc -l < "$base/calls")" -eq 3 ]
echo 'SRS cache checks passed'
