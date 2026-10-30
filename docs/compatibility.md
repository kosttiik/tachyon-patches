# Compatibility inventory

Status: investigation in progress. A checkbox below is not a claim of compatibility.

| Area | Issue | Initial finding | Status |
|---|---|---|---|
| Small valid SRS | local | 1.5.21 rejects files under 100 bytes before SRS validation | Patch applied on a disposable copy; syntax and format-validation behavior still require 1.5.21 integration testing |
| KeepAlive delay | #252 | 1.5.21 generator lacks unified_delay | Generator patch prepared; isolated extended/upstream fixtures and core check pass; old LuCI control patch prepared with syntax check; browser and integration tests pending |
| Subscription headers | #253 | Automatic User-Agent exists in 1.5.21; test HWID and device fields independently | Audit pending |
| Invalid subscription node | #253 | Quarantine and logging need comparison | Audit pending |
| Core status | #254 | Dashboard and diagnostics used legacy service name and engine ID | Patches prepared; isolated old-library engine status reports the active variant; UI test pending |
| Priority recovery | #261 | 1.5.21 probes level members sequentially | Patch prepared; selection fixtures pass with isolated 1.5.21 libraries; recovery-cycle and live tests pending |
| UPnP bypass | #259 | 1.5.21 watchdog has no UPnP lease sync | Backport required |
| Subscription source migration | #250 | Live configuration uses modular sections absent from old connections module | Migration required |
| P2P direct and relay | #256 | The new DNAT bypass includes nft sets, rule ordering and watchdog updates | Backport and real client validation required |
| Saved selector mode | #264 | Auto-balancer selection changed with the newer object model | Audit old selector and migrated state |
| Same-name groups | #267 | New modular balancer migration has different ownership rules | Audit reverse migration and group isolation |
| zapret real-IP resolver | #227 | 1.5.21 resolves zapret/zapret2 through bootstrap DNS | Upstream resolver change backported; isolated main/routed-DNS fixtures pass; live DNS remains untested |
| FakeIP/DNS | #265 | Requires compare of cache, DNS rule order and nft localv6 | IPv6 nft exclusion patch prepared; DNS rule-order and live tests pending |
| VLESS Encryption padding | extended #167 | Separate core project; issue previously open | Do not claim fixed |

The current configuration has section, condition, outbound_source, balancer and outbound_group objects. Do not install 1.5.21 over it without a verified reverse migration and full rollback.

Official 1.5.21 APK checksums match the release checksum file. Three patch target files extracted from the official APK match the 1.5.21 tag. The package is unsigned, so the checksum does not authenticate its publisher.
