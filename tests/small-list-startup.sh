#!/bin/sh
set -eu
apply=${1:?Pass the patched nft/apply.uc path}
valid_srs=${2:?Pass a valid populated SRS smaller than 100 bytes}
task_dir=$(mktemp -d)
trap 'rm -rf "$task_dir"' EXIT INT TERM
printf '%s\n' '128.116.0.0/17' '209.206.40.0/21' > "$task_dir/short.lst"
printf '%s\n' '<html>error</html>' > "$task_dir/error.lst"
printf '%s\n' '# empty' > "$task_dir/empty.lst"
ucode -L /usr/lib/tachyon "$apply" community-subnet-file-usable "$task_dir/short.lst"
if ucode -L /usr/lib/tachyon "$apply" community-subnet-file-usable "$task_dir/error.lst"; then exit 1; fi
if ucode -L /usr/lib/tachyon "$apply" community-subnet-file-usable "$task_dir/empty.lst"; then exit 1; fi
test "$(wc -c < "$valid_srs")" -lt 100
printf 'bad' > "$task_dir/bad.srs"
ucode -L /usr/lib/tachyon /usr/lib/tachyon/tachyon_core/rulesets.uc is-usable-srs-file "$valid_srs"
if ucode -L /usr/lib/tachyon /usr/lib/tachyon/tachyon_core/rulesets.uc is-usable-srs-file "$task_dir/bad.srs"; then exit 1; fi
echo 'Small subnet list and SRS fixtures passed'
