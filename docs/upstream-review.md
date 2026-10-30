# Upstream audit after Tachyon 1.5.21

## Scope and method

Compared official 1.5.21 (`3b820f0db80abf5214dbfd5246d4a2106955052f`) with upstream tag 1.7.3 (`108d6d63b4816aba947ba15c35ae9e668e01ec02`). The range contains 91 commits, including merges and release commits. Every commit is listed in `upstream-commits.tsv` with a terminal decision. Mixed commits were separated by changed path and hunk; titles alone were not treated as proof that a fix applies to the legacy schema.

The intended next-router baseline remains official 1.5.21 plus this ordered local patch series. The newer 1.6+ modular UI and data model are deliberately excluded. A new source patch must be based on the already patched tree, after 0001–0012 and then 0014 where it touches Priority; never apply a raw later-upstream patch against pristine 1.5.21.

## Backported in the ordered series

- Small valid SRS/list acceptance: 0001 and 0011.
- Priority fastest-member selection and failed-node isolation: 0002; timeout debounce: 0014.
- IPv6 FakeIP nft exclusion: 0003.
- Legacy KeepAlive UI/generator: 0004–0005.
- Managed-core and engine identity/status: 0006 and 0008.
- Zapret DNS resolver path: 0007.
- VLESS subscription leaf isolation with fail-closed dependency checks: 0009.
- Legacy nft-aware UPnP/DNAT synchronization: 0010.
- Daily list-update scheduling: 0012.

Patch 0013 was explicitly removed at the user's request. It modified broad ruleset/constants/UI behavior and is not part of the series. The series has a numbering gap by design.

## Useful follow-up candidates

These are findings, not claims that a patch is already implemented:

1. **DNS recovery after an unclean start** (`d1370ee1`). Upstream restores the dnsmasq failsafe in init/lifecycle paths. This is a strong operational candidate for a narrow legacy backport. First compare 1.5.21 cleanup/restore ownership and add fixtures for normal start, unclean state, and repeated start; then validate boot recovery on a spare target. No reboot test is claimed here.
2. **Reapply routing after WAN/network restart** (`f3c7fc91`). The hotplug/initd change may help networks that renew or restart interfaces, but it touches route and nft lifecycle. Port only the relevant old-schema hunk after testing repeated interface events, no duplicate chains, and restoration of normal traffic. Not included.
3. **Routed DNS/FakeIP ordering** (`860e81c3`, `13a449e0`, later refinement in `781c686f`). These address source-aware routed DNS, FakeIP interception, DNS-only section order, and mixed/domain/IP ruleset distinctions. The later implementation assumes evolved condition and ruleset helpers. The current series only includes 0003's IPv6 FakeIP range fix and 0007's zapret resolver fix; it does not claim these later query-order fixes. Before adding a patch, compare generated legacy core JSON and nft state for domain-only, mixed, IP-only, DNS-only, closed GeoIP, routed DNS, and excluded-source cases.
4. **DNAT/P2P bypass completeness** (`490c9c1d`, `66ef145c`). Patch 0010 covers legacy mapping synchronization and its add/delete fixture/live observation. That does not prove upstream's broader static-forward capture fixes or real peer traffic. Test a dynamic and static forward, direct vs proxy route, counters, replies, and deletion before claiming P2P fixed. External inbound and an actual P2P session remain unverified.
5. **Discord UDP/desync override** (`a8095af6`). This mixes generator behavior and substantial UI changes. A narrow legacy generator patch is a candidate only if the target uses that desync path; retain the old UI and test TCP, UDP voice, and automatic preset precedence. Not included.
6. **Community list deduplication and reload guards** (`8d743ff0`). This spans downloader locks, lifecycle, runtime reload, and major UI changes. The idempotence improvements may be useful, but require old-schema concurrent update/reload tests. Not included.
7. **Package installation/version reliability** (`5b207132`, `42642a16`, `0597e42f`, `237f802a`). These affect local APK installation, mirror/certificate fallback, asset revision selection, and install/uninstall cleanup. Keep TLS validation intact; test each package transaction against the target OpenWrt `apk` before backporting. Not included.

## Version-specific findings

- **1.7.0** introduced the modular graph model and broad UI redesign. Its contained fixes must be considered individually. Priority fastest/failure handling and IPv6 FakeIP are represented by 0002/0003; the schema migrations and new UI are not.
- **1.7.1** includes mixed runtime, download, and SIGHUP/reload changes. The broad `8d743ff0` change is not a safe wholesale backport.
- **1.7.2** disables `.trs` for sing-box variants and repairs invalid rule-set files. The current home router runs `sing-box-extended`, uses `.srs`, and already has local SRS validation fixes; the `.trs` format switch does not apply. Core-specific repair behavior needs separate fixtures before porting.
- **1.7.3** adds 256-way parallel latency probing, a `priority_level` to `outbound_group` migration, and non-proxy section ping behavior. The parallel probe fan-out is not assumed safe on low-memory routers; the migration conflicts with the legacy data model. The non-proxy diagnostic change may be considered separately if the legacy status path demonstrates the same defect. Follow-up commit `5b30bc0b` covers Tachyon Core 0.2.6 WARP, `.trs`/`.srs` handling, RSS display, and a URLTest race; those are conditional and do not justify importing the modular UI. Tag `1.7.3` points at `108d6d63`; the release commit is `9cab66ca`.

## Not backported

- Visual redesign, dashboard layout, status badges, modals, and presentation-only changes: preserve the 1.5.21 interface.
- Modular conditions, outbound sources/groups, Priority migration, and related repair/migration logic: do not transplant into the legacy schema; use the explicit one-way private migration helper only where its constraints are satisfied.
- Features not configured on the target (TUN, Mieru, AWG/WARP, Telegram recovery, Tailscale, new inbound types): leave conditional; do not enable or expose new listeners automatically.
- Tests/CI/build-only commits: reuse the test idea only where it covers a backported behavior; no runtime change.

No source-level or live evidence is claimed for the follow-up candidates above. See `docs/compatibility.md` for what was tested in fixtures and on the current router.
