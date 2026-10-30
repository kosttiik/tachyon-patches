# Tachyon 1.5.21 backports

This repository targets the official Tachyon and LuCI 1.5.21 source at commit `3b820f0db80abf5214dbfd5246d4a2106955052f`. It contains source patches and test fixtures only; it contains no router configuration, credentials, package binaries, subscription URLs, or FakeIP database.

## Applying the series

The patches form one ordered series. Each patch is based on the cumulative result of the earlier patches; do not apply a later patch directly to pristine 1.5.21 or cherry-pick a patch out of order. `tools/prepare-overlay.sh` verifies the official-file hashes, applies every `patches/*.patch` in lexical order to a private temporary copy, and produces an overlay containing only the listed target files. Build from a clean extraction of the official 1.5.21 packages. Patch 0013 was removed at the user's request and must not be restored. Patch 0014 follows 0012 and builds on the earlier Priority changes.

```sh
tools/prepare-overlay.sh /path/to/clean-1.5.21-extraction /path/to/new-overlay.tar.gz
```

The extraction root must contain the exact paths in `official-files.sha256`. Do not reuse a generated overlay as the official source root. Review the target device's package revision, architecture, Ucode version, core variant, UI paths, and free space before applying. Back up every target file and configuration first, then validate Ucode and JavaScript and run the included fixtures. An upstream package update can overwrite these file-level patches.

## Patch series

| Patch | Change | Evidence/limit |
|---|---|---|
| 0001 | Accept small valid preset SRS files | Keeps SRS content validation; malformed fixtures remain rejected. |
| 0002 | Prefer responsive, faster Priority members and avoid immediately reselecting a failed node | Selection fixture passes; long live failure/recovery cycle is not claimed. |
| 0003 | Exclude IPv6 FakeIP space from real-destination handling | Addresses the `fc00::/18` vs `fc00::/7` overlap; verify generated nftables on each target. |
| 0004–0005 | Generate and expose warm KeepAlive latency in the legacy settings UI | Generator fixtures pass; browser display and cold/warm measurements are target checks. |
| 0006, 0008 | Report managed core and engine variant consistently | Ucode fixtures pass for the available variants. |
| 0007 | Resolve zapret destinations through the intended DNS path | Isolated main/routed-DNS fixtures pass; target client DNS remains a live check. |
| 0009 | Isolate a VLESS leaf rejected by the core only when references can safely be removed | Preserves encryption and fails closed on ambiguous dependencies. |
| 0010 | Synchronize UPnP/DNAT mapping sets with the 1.5.21 nft contract | Router add/delete mapping synchronization was observed; public inbound/P2P reachability remains unverified. |
| 0011 | Accept small valid startup lists | Content validation remains; fixture covers small valid and invalid inputs. |
| 0012 | Add daily list-update time to the legacy UI and scheduler | Router is configured for 05:00 MSK; unchanged list update kept the observed core PID. |
| 0014 | Debounce isolated Priority health-check timeouts until repeated failure | Fixture passes. Equivalent debounce behavior was already present on the router; no restart is needed for the source refactor. |

See `docs/compatibility.md`, `docs/issue-audit.md`, `docs/upstream-review.md`, and `docs/upstream-commits.tsv` for scope, evidence, omissions, and the commit-by-commit audit through upstream tag 1.7.3.

## Migration helper

`tools/migrate-modular-config.py` converts a private modular UCI snapshot into the 1.5.21 section model. It refuses unsupported or ambiguous graphs rather than guessing. Keep source and output files private, review the generated sections and Conditions, and use a target-specific backup/rollback plan. Migration is separate from patch application and does not copy generated firewall state.

The GitHub repository is `https://github.com/kosttiik/tachyon-patches.git`. Pin the reviewed commit in any reusable router bundle; do not rely on a moving branch name.
