# Tachyon 1.5.21 backports

Work in progress. This repository targets the official Tachyon 1.5.21 release, commit `3b820f0db80abf5214dbfd5246d4a2106955052f`. It does not contain router configuration, credentials, or package binaries.

Do not apply these patches to a router until the complete migration and rollback have been tested. The patches are tracked independently of the official packages; there is no automatic build or release.

`patches/0001-small-srs.patch` removes the arbitrary 100-byte minimum in the two preset SRS paths. Existing SRS validation remains in place.

## Patch status

- `0001-small-srs.patch`: isolated patch and syntax checks pass; integration remains untested.
- `0002-priority-recovery.patch`: isolated priority selection fixtures pass against 1.5.21 libraries; a complete recovery cycle remains untested.
- `0003-ipv6-fakeip.patch`: syntax and subnet-overlap checks pass; live IPv6 remains untested.
- `0004-keepalive-core.patch`: generator fixtures pass for extended and upstream cores; generated extended configuration passes the installed core checker.
- `0005-keepalive-ui.patch`: legacy settings module syntax passes; browser behavior remains untested.
- `0006-managed-core-status.patch`: syntax passes; this changes one dashboard status path only and does not complete issue #254.

A reverse migration from the current 1.7.0 object model, UPnP/P2P support, subscription failure isolation, and several diagnostics are still missing. This repository is not an installer and does not authorize a downgrade yet. See `docs/compatibility.md`.
