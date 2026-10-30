# User issue audit

Audited against official 1.5.21 commit `3b820f0db80abf5214dbfd5246d4a2106955052f` and official 1.7.0 commit `1ff6491b7ad08a1a12ab3c9cb932f628157a545a`. An ancestor relationship establishes that a commit is in the release history; it does not by itself establish correct behavior on this router. Statuses are as retrieved on 2026-10-30.

| Issue | 1.5.21 finding | Decision and verification |
|---|---|---|
| #261 Priority recovery | Sequential level probing is present | Backport prepared; selection fixtures pass, full fallback and recovery cycle still required. |
| #259 UPnP sync | Watchdog has no equivalent periodic lease sync | Required with #256's nft DNAT sets; test add/delete and retry, no standalone watchdog patch. |
| #253 invalid subscription node | Full leaf isolation and dependent-outbound handling are later | Required; backport as a cohesive unit and test malformed node plus dependent section. Do not weaken encryption. |
| #252 KeepAlive | Generator/UI lack warm latency | Generator and legacy UI patches prepared; generator fixtures pass, browser and measured warm/cold probes pending. |
| #250 modular migration duplicates | New 1.6 graph objects do not exist in legacy model | Avoid forward-migration code; explicitly test reverse migration, duplicate sources and retained dependencies. |
| #254 service status | Legacy dashboard checks S99sing-box | One dashboard patch prepared; backend engine/variant/managed_by still needs complete audit and tests. |
| #238 fail policy enhancements | Implemented after 1.5.21 in f14584ba | Carry relevant features only after testing actual scheduler, status and switching behavior. Issue closed does not prove every requested feature works. 1.7 code still calls reload and only checks status when returned; no independent UDP probe found. |
| #231 strategy fallback | Implemented after 1.5.21 in b2d20e9e | Port per-section probes, hysteresis, Direct reachability and recovery, plus legacy UI; test transitions without altering unrelated routing. |
| #227 real-IP DNS for zapret | 1.5.21 selects bootstrap DNS | Upstream resolver change ported; isolated main/routed-DNS fixtures pass. Verify DNS tags and client traffic after migration. |
| #205 zapret2 updater errors | Fix 3b4d66a1 is an ancestor of 1.5.21 | Already included in source; verify package/update behavior, no duplicate patch without regression. |
| #181 extended updater binary path | Fix ca6ade03 is an ancestor | Included in source; verify installed binary/symlink and updater on an isolated test before any real upgrade. |
| #138 browser autofill | Fix e618c004 is an ancestor | Included in source; test legacy UI fields and avoid exposing secrets. |
| #141 multiple Routed DNS servers | Fix e618c004 is an ancestor; inspect actual generator tags | Validate first and subsequent server references with 1.5.21 fixture. |
| #130 FakeIP binary cache | Specific defect is in tachyon-core 0.0.7, not established as fixed by the Tachyon UI release | Preserve consistent DB; never use incompatible cores or silently delete mappings. Test binary round-trip per core before switching. |
| #120 installer removes APK world entries | Fix bb09022b is an ancestor | Included in source; check current world and simulate package changes before transaction. |
| #58 plain .lst as SRS | Fix d28af621 is an ancestor | Included in source; test rejection and plain-list import. |
| #50 Discord subnet overmatch | Fixes ea0de78c and 0ea1c738 are ancestors | Included in source; inspect actual sets and rule tracing; re-test voice separately. |
| #52 watchdog health restart | Release commit 2019ddd1 is an ancestor | Included in history; inspect current probe and exercise controlled transient failure. |
| #51 WAN Telegram spam | Fix 0ea1c738 and release 2019ddd1 are ancestors | Included in history; test settings and debounce without sending external messages. |
| #47 Forkop migration | Fixes 70f09e8e and 63ea7fac are ancestors | Included in history; only relevant to a Forkop target; test a synthetic configuration before claiming migration. |
| ushan0v/forkop #93 AWG 3.1 | Different project; issue closed not planned | Not a Tachyon patch. Test actual AWG/WireGuard path if the target uses it, without assuming support from the fork issue. |
| slayer326/forkop #15 Rockchip | Different project | Not a Tachyon patch. Confirm device architecture and package compatibility on each target. |
| sing-box-extended #167 VLESS padding | Separate core project; issue remains open | Not solved by a Tachyon backport. Isolate the incompatible node and preserve security; do not declare parser fixed. |

Links: issue numbers without a repository prefix refer to `https://github.com/Dushnilin/tachyon/issues/<number>`. The release issues were checked read-only; no messages were posted.
