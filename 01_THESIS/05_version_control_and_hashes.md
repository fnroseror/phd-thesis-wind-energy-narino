# Version Control and Hashes

## Canonical authority candidate

The corrected thesis PDF supplied for final repository alignment is:

`Tesis Doctoral Corregida - 1053833697(6).pdf`

SHA-256:

`0a5fffefbe7ff394f3e27270050f4849fff42db3d7e38dda274c9f67cee7bb57`

PDF technical page-object count: 152.

This checksum must be compared with the exact file retained in the author's submitted-record archive before the full PDF is added to a public release. A matching checksum establishes byte-for-byte identity.

## Superseded first version

The first thesis version previously stored in the repository was:

`Tesis Doctoral - 1053833697.pdf`

SHA-256:

`262ead6e745e758abcf1c73a8802df42a99d6d166518fc043c27d13d85ad24d4`

This hash matches the 75-page first-version PDF supplied for comparison. It is superseded and must not remain in the final public `01_THESIS/` folder.

## Rules

- File names do not establish authority; hashes and documented provenance do.
- Intermediate PDFs must not be published under names that could be mistaken for the corrected thesis.
- The corrected PDF must not be recompressed, re-exported, linearized, or metadata-edited before hash verification; any byte-level modification changes the checksum.
- If an accessibility-optimized or repository-stamped PDF is later required, it must be stored as a distinct derivative with its own checksum and must not replace the submitted-file record.
- All canonical manifests must use relative repository paths and SHA-256 checksums.
