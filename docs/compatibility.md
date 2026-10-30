# Compatibility and verification inventory

Scope: current NanoPi R6S configuration on official Tachyon/LuCI 1.5.21 with the ordered local patch series. Tachyon 1.5.21 generates runtime routes and nftables; generated firewall state is not copied during migration.

| Area | Patch/state | Verification | Limit |
|---|---|---|---|
| Small valid SRS | 0001 | Small valid CIDR/SRS fixtures pass; malformed content rejected | Additional third-party formats need their own fixture |
| Small startup lists | 0011 | Router-side fixture passes | Other target package paths need validation |
| KeepAlive delay | 0004–0005 | Generator fixture and installed core config check pass | Old GUI and warm/cold latency measurements should be repeated per target |
| Subscription headers | Migration helper | Legacy UA/HWID fields retained by conversion fixture | One refresh with the target provider is still required |
| Invalid subscription node | 0009 | Ucode positive and fail-closed fixtures pass | Current cache had no matching invalid node |
| Core/engine status | 0006, 0008 | Ucode fixtures pass for available variants | Check the target's init service, symlink, and installed engine |
| Priority selection | 0002 | Selection fixture passes | Full live outage/recovery cycle not claimed |
| Priority timeout debounce | 0014; equivalent behavior already existed on current router | Router-side fixture passes; current router source semantics compared | Controlled live failure-injection not performed |
| UPnP/DNAT synchronization | 0010 | Add/delete mapping synchronized between fw4 and Tachyon sets on router; fixture passes | Public inbound reachability and actual P2P session unverified |
| Daily list schedule | 0012 | Router crontab set for 05:00 MSK; GUI showed 05:00/1d; unchanged list update retained observed core PID | Reboot persistence and a changed-list reload were not tested in this handoff |
| zapret DNS resolver | 0007 | Isolated main/routed-DNS fixtures pass | Client path on another router is target-specific |
| IPv6 FakeIP nft exclusion | 0003 | Patch compiled and source case reviewed | Other IPv6 route policies need target checks |
| Later routed DNS/FakeIP query order | Not included | Identified as follow-up in `upstream-review.md` | Needs old-schema generation fixtures before a patch |
| Migration from modular objects | Helper | Unit fixtures and generated legacy-core checks pass; ambiguous graphs refused | Private conversion is target-specific; not a general importer |
| VLESS Encryption padding | Separate sing-box-extended issue | No Tachyon fix claimed | Preserve security; isolate incompatible leaf only when safe |

The official 1.5.21 source-file hashes in `official-files.sha256` were matched to the tag. The package checksum is not a signature and does not authenticate the publisher. On the current router, package identity and target file hashes were checked before application. A different router must repeat architecture, package, path, dependency, space, and rollback checks.

## Evidence classes

- **Fixture-only:** ordered overlay applies to clean official 1.5.21 sources; all included Ucode files compile on the router; Node syntax and Python migration fixtures pass; router-side fixtures for list, DNAT, status, VLESS isolation, KeepAlive generation, Priority, and subnet/SRS behavior pass.
- **Observed on current router:** official 1.5.21 package baseline, existing backport file state, 05:00 daily list schedule, list update without core PID change, and UPnP mapping add/delete synchronization.
- **Not established:** reboot persistence, public inbound reachability, actual P2P session routing, broad client/game coverage, complete Priority outage/recovery, or target behavior on any other router/provider.
