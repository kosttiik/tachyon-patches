# Tachyon 1.5.21 backports

Work in progress. This repository targets the official Tachyon 1.5.21 release, commit `3b820f0db80abf5214dbfd5246d4a2106955052f`. It does not contain router configuration, credentials, or package binaries.

Do not apply these patches to a router until the complete migration and rollback have been tested. The patches are tracked independently of the official packages; there is no automatic build or release.

`patches/0001-small-srs.patch` removes the arbitrary 100-byte minimum in the two preset SRS paths. Existing SRS validation remains in place.
