# Tachyon 1.5.21 patches

Base: official Tachyon/LuCI 1.5.21, source commit `3b820f0db80abf5214dbfd5246d4a2106955052f`.

Apply every file in `patches/` to a clean extraction of the official 1.5.21 files, in lexical order. Each patch expects all earlier patches. Patch 0014 follows 0012; patch 0013 is intentionally absent. Do not skip, reorder, or apply a later patch directly to pristine 1.5.21 or another release.
