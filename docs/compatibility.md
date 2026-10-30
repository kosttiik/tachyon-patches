# Compatibility inventory

Status: investigation in progress. A checkbox below is not a claim of compatibility.

| Area | Issue | Initial finding | Status |
|---|---|---|---|
| Small valid SRS | local | 1.5.21 rejects files under 100 bytes before SRS validation | Patch applied on a disposable copy; syntax and format-validation behavior still require 1.5.21 integration testing |
| KeepAlive delay | #252 | 1.5.21 generator lacks unified_delay | Backport required |
| Subscription headers | #253 | Automatic User-Agent exists in 1.5.21; test HWID and device fields independently | Audit pending |
| Invalid subscription node | #253 | Quarantine and logging need comparison | Audit pending |
| Core status | #254 | Engine and variant detection need comparison | Audit pending |
| Priority recovery | #261 | 1.5.21 probes level members sequentially | Patch prepared; selection fixtures pass with isolated 1.5.21 libraries; recovery-cycle and live tests pending |
| UPnP bypass | #259 | 1.5.21 watchdog has no UPnP lease sync | Backport required |
| Subscription source migration | #250 | Live configuration uses modular sections absent from old connections module | Migration required |
| FakeIP/DNS | #265 | Requires compare of cache, DNS rule order and nft localv6 | IPv6 nft exclusion patch prepared; DNS rule-order and live tests pending |
| VLESS Encryption padding | extended #167 | Separate core project; issue previously open | Do not claim fixed |

The current configuration has section, condition, outbound_source, balancer and outbound_group objects. Do not install 1.5.21 over it without a verified reverse migration and full rollback.

Official 1.5.21 APK checksums match the release checksum file. Three patch target files extracted from the official APK match the 1.5.21 tag. The package is unsigned, so the checksum does not authenticate its publisher.
