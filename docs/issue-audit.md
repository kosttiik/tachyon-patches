# Issue audit for the 1.5.21 backport

Compared the official Tachyon 1.5.21 base (`3b820f0db80abf5214dbfd5246d4a2106955052f`) with upstream tag 1.7.3 (`108d6d63b4816aba947ba15c35ae9e668e01ec02`). Issue closure or commit ancestry does not prove behavior on this router. The listed patch numbers refer to this repository's cumulative ordered series.

| Issue/area | Finding on 1.5.21 | Decision and evidence |
|---|---|---|
| #261 Priority recovery | Preferred tier was probed sequentially and failed-node replacement was weak | 0002 backports fastest responsive selection and failed-node exclusion; fixture passes. 0014 debounces isolated timeout; fixture passes. Full live outage/recovery not claimed. |
| #259 UPnP sync | Newer nft contract cannot be copied directly to 1.5.21 | 0010 adapts to legacy sets. Mapping add/delete synced on router and fixture passes; external inbound unverified. |
| #256 DNAT/P2P bypass | Upstream adds broader static/dynamic DNAT capture and P2P bypass behavior | 0010 covers mapping synchronization only. Actual direct P2P path remains unverified; do not mark the complete issue fixed from set membership alone. |
| #265 IPv6 FakeIP overlap | `fc00::/7` local handling overlaps the FakeIP `fc00::/18` range | 0003 carries the narrow range exclusion; target nft rules still require inspection. |
| #252 KeepAlive | 1.5.21 generator/legacy UI did not expose warm delay | 0004–0005 included; generator fixture and core config check pass. Browser/latency validation is target-specific. |
| #253 invalid subscription node | Bad VLESS leaf can invalidate dependent section | 0009 isolates only when references are safe, preserves encryption, and fails closed otherwise; fixtures pass. |
| #254 core status | Legacy dashboard/backend used incorrect service/engine identities for some variants | 0006/0008 included; variant fixtures pass; verify actual service on each target. |
| #250 modular migration duplicates | New 1.6+ graph objects do not exist in the legacy model | Private conversion helper refuses ambiguous graphs; it does not recreate modular objects or promise a universal migration. |
| #264 saved selector mode | Newer selector semantics depend on modular balancers | No 1.5.21 runtime patch; inspect migrated selector and effective outbound on each target. |
| #267 same-name groups | Newer object ownership rules differ from legacy sections | No modular migration patch; conversion must preserve section ownership and reject ambiguity. |
| #238 section fail policy | New check/recovery intervals and expected HTTP status were added upstream | Not ported: current active sections use Keep/no fail policy. Only consider with target-config use and evidence for core response semantics/reload behavior. |
| #231 section strategy fallback | New per-section probe/recovery behavior changes state and may reload | Not ported: target does not enable it. Priority VPN→Direct behavior remains separate in 0002/0014. |
| #227 zapret real-IP DNS | 1.5.21 resolver path used bootstrap DNS | 0007 backports the resolver selection; isolated fixtures pass. Client traffic must be checked on the target. |
| Routed DNS/FakeIP ordering | Later commits 860e81c3/13a449e0 distinguish DNS-only, source, domain, mixed, and IP rulesets | Not included in current series; needs legacy generated-config fixtures before a new patch. |
| #205 zapret2 updater errors | Fix is already an ancestor of 1.5.21 | No duplicate patch. Validate updater on target before upgrades. |
| #181 extended updater binary path | Fix is already in 1.5.21 ancestry | No duplicate patch; verify installed symlink/binary per target. |
| #138 browser autofill | Fix is already in 1.5.21 ancestry | No duplicate patch; never place secrets in test artifacts. |
| #141 multiple Routed DNS servers | Generator behavior depends on actual legacy tags | Not a blanket fix; validate each configured server reference in target-generated config. |
| #130 FakeIP binary cache | Core-specific cache format/stop behavior is separate from Tachyon UI | Do not delete or convert a live cache blindly; validate round-trip for the installed core. |
| #120 APK world cleanup | Existing 1.5.21 ancestry contains the earlier correction | No duplicate patch; simulate package transactions before updates. |
| #58 plain `.lst` as SRS | Existing 1.5.21 ancestry includes the format correction | Keep content validation; 0001/0011 only remove size rejection for valid content. |
| #50 Discord subnet overmatch | Earlier fixes are already in 1.5.21 ancestry | Inspect extracted sets and UDP/port scoping, especially if community subnet toggles change. |
| #52 watchdog restart and #51 WAN Telegram spam | Release ancestry contains prior changes | No new patch; test actual watchdog debounce/state on target before relying on it. |
| Forkop issues #47, #93, #15 | Different project/device/core paths | Not Tachyon backports; validate only on an actual configured Forkop/AWG/Rockchip target. |
| sing-box-extended #167 VLESS padding | Separate core parser issue | Not fixed by Tachyon patches; preserve encryption and isolate only a safely removable leaf. |

The detailed upstream commit inventory is `docs/upstream-commits.tsv`; actionable follow-up candidates and their required old-schema checks are in `docs/upstream-review.md`. No issue comments or other external messages were posted.
