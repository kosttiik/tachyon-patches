# Review of changes after 1.5.21

Source comparison: 1.5.21 `3b820f0d` through 1.7.0 `1ff6491b`; full history fetched and 85 commits enumerated. A commit may mix changes across concerns; use the specific hunk and its dependencies rather than cherry-picking a title wholesale. This is an initial priority assessment, not evidence that all changes have been implemented or tested.

## Required for the current router and safe migration

- `a28268a5`: #227 DNS resolver fix; patch 0007 prepared. Other server/UI changes in the same commit are not automatically needed.
- `b2d20e9e`, `f14584ba`: #231/#238 section fail-policy behavior. Audit actual scheduler and return-to-original behavior; upstream's implementation does not establish UDP checks or reload-free transitions.
- `68d79c4d`, `078360db`, `d58363b1`: priority fastest selection, failed-node exclusion and accelerated recovery. Patch 0002 needs full live recovery tests and a compatible old UI/state representation.
- `490c9c1d`, `66ef145c`, `d58363b1`: DNAT/P2P and UPnP; port sets, firewall order, watchdog and retry form one feature. Validate together.
- `f3c7fc91`, `d1370ee1`: recovery of routing after network restart and DNS fail-safe after unclean startup. Compare old code and verify on controlled reboot/network restoration before deciding exact hunks.
- `4f3f5ce2`, `860e81c3`, `781c686f`, `13a449e0`: UDP routing, FakeIP/routed-DNS, IP-based rule interactions and DNS-section priority. Required to investigate against current architecture; use fixtures for applicable paths.
- `d58363b1`: IPv6 FakeIP exclusion patch 0003; other unrelated UI and migration changes require separate review.
- `4476eec5` / 1.6.1 changes: #252 KeepAlive, #253 invalid-node isolation and #254 status. KeepAlive and one status path are prepared; subscription repair/dependent outbounds and backend status remain incomplete. Locate actual functional commits rather than assuming a release label contains one atomic patch.
- `1ff6491b`: preserve old subscription URL behavior and avoid re-creating deleted sources; examine reverse-migration relevance, do not recreate modular objects blindly.
- `5b207132`, `c6099aba`, `0597e42f`, `237f802a`: package installation/update and apk robustness. Check existing old release code and target OpenWrt before carrying exact applicable changes.

## Conditional on target functionality

- `39599044`: Reality ML-KEM flag and native desync version gating; preserve if imported nodes use those options.
- `6cf6e8f9`, `7c096a87`, `cd70727f`: AWG/WARP and pool isolation; only if used on a target, with current architecture-specific tests. Lite mode remains off unless measured need.
- `af96f24b`: TUN schema/routing and Mieru port range; apply only where used; do not turn on TUN or expose new server ports.
- `cb41ff6e`, `af6903f5`: inbound schemas, engine switching, Reality/XHTTP; relevant only to configured inbounds or engine switches, but must not break existing configurations.
- `11678bb7`, `6b9b747c`: fuzzer background cleanup and descriptor handling; apply if running the fuzzer on 1.5.21, with timeout regression test.
- `247bc134`: GitHub token and password-manager behavior; evaluate exact code on the legacy UI and existing #138 protection before patching.
- `bb45e744`, `569d545d`: update feedback, download robustness and subscription-related changes. Compare feature use and avoid copying new UI wholesale.

## Do not port for the stated goal

- `1b7ebb8e`, `32348aaf`, `1143fd5b`: modular redesign / 1.7 release UI. The user explicitly wants the legacy section model and appearance. Reverse-migrate current state instead.
- Dashboard presentation, styling, typography, color, QR/sidebar and layout changes: do not bring them into the legacy UI merely because they are newer. Review functional fixes separately from mixed presentation commits.
- Tests, CI, dependency bumps, translations and release-only commits are not router runtime patches. Adapt useful tests to the legacy code and keep any newly added UI text understandable.
- Changes exclusively for another project (Forkop) or another core's parser cannot be presented as Tachyon fixes.

## Remaining audit

Read the full commit inventory in `docs/upstream-commits.tsv` and inspect mixed commits before assigning each final hunk. Status `review` means unassessed, not safe to omit. Confirm upstream source/package hashes and keep local backports narrowly scoped and independently reversible.
