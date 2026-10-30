#!/bin/sh
set -eu
apply=${1:?Pass the candidate nft/apply.uc path}
task_dir=$(mktemp -d)
trap 'rm -rf "$task_dir"' EXIT INT TERM
mkdir -p "$task_dir/bin"
cat > "$task_dir/bin/nft" <<'SH'
#!/bin/sh
printf 'nft %s\n' "$*" >> "$NFT_TEST_LOG"
if [ "${NFT_TEST_FAIL:-0}" = 1 ] && [ "${1:-}" = flush ]; then exit 1; fi
if [ "${1:-}" = -f ]; then cat "$2" >> "$NFT_TEST_LOG"; fi
exit 0
SH
chmod +x "$task_dir/bin/nft"
for cmd in modprobe ip; do
    printf '#!/bin/sh\nexit 0\n' > "$task_dir/bin/$cmd"
    chmod +x "$task_dir/bin/$cmd"
done
export PATH="$task_dir/bin:$PATH"
export NFT_TEST_LOG="$task_dir/nft.log"
export TACHYON_DNAT_SIG_FILE="$task_dir/signature"
export TACHYON_UPNP_LEASES_FILE="$task_dir/leases"
printf '%s\n' '["192.0.2.22 . 47998-48000","192.0.2.22 . 47999","192.0.2.22 . 48001","192.0.2.23 . 47999","192.0.2.22 . 9"]' > "$task_dir/ranges.json"
ucode -L /usr/lib/tachyon "$apply" dnat-coalesce-fixture "$task_dir/ranges.json" > "$task_dir/coalesced.json"
grep -q '192.0.2.22 . 47998-48001' "$task_dir/coalesced.json"
grep -q '192.0.2.23 . 47999' "$task_dir/coalesced.json"
if grep -q '192.0.2.22 . 47999' "$task_dir/coalesced.json"; then
    echo 'overlapping port was retained' >&2
    exit 1
fi
printf '%s\n' 'TCP:47111:192.0.2.22:47111:0:test' > "$task_dir/leases"
ucode -L /usr/lib/tachyon "$apply" nft-create-runtime-base \
    FixtureTable localv4 tachyon_subnets tachyon_ports tachyon_ip_ports tachyon_interfaces br-lan \
    0x04000000 0x08000000 198.18.0.0/15 1602 0 localv6 tachyon_subnets6 tachyon_ip6_ports fc00::/18 ::1 0 off
grep -q 'FixtureTable proxy ct status dnat meta mark set 0 return' "$NFT_TEST_LOG"
grep -q 'FixtureTable mangle ip saddr . tcp sport @tachyon_dnat_tcp_v4 return' "$NFT_TEST_LOG"
ucode -L /usr/lib/tachyon "$apply" nft-insert-fully-routed-ip-rules \
    192.0.2.22 FixtureTable tachyon_interfaces localv4 localv6 0x04000000
grep -q 'FixtureTable mangle ip saddr 192.0.2.22 ip saddr . tcp sport @tachyon_dnat_tcp_v4 return' "$NFT_TEST_LOG"
rm -f "$TACHYON_DNAT_SIG_FILE"
ucode -L /usr/lib/tachyon "$apply" nft-sync-dnat-sets FixtureTable
grep -q '192.0.2.22 . 47111' "$NFT_TEST_LOG"
cp "$TACHYON_DNAT_SIG_FILE" "$task_dir/saved"
printf '%s\n' 'TCP:47112:192.0.2.22:47112:0:test' >> "$task_dir/leases"
if NFT_TEST_FAIL=1 ucode -L /usr/lib/tachyon "$apply" nft-sync-dnat-sets FixtureTable; then
    echo 'sync accepted a failed flush' >&2
    exit 1
fi
cmp "$task_dir/saved" "$TACHYON_DNAT_SIG_FILE"
ucode -L /usr/lib/tachyon "$apply" nft-sync-dnat-sets FixtureTable
grep -q '192.0.2.22 . 47111-47112' "$NFT_TEST_LOG"
echo 'DNAT sync and retry fixtures passed'
