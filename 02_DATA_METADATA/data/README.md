# Data directory

No raw or processed scientific dataset is included in this package.

The expected raw long-format schema is defined in [`expected_input_schema.csv`](expected_input_schema.csv). The header is provided without fabricated observations.

Before adding a dataset here, record:

- source and access date;
- exact temporal bounds;
- row count;
- station and variable counts;
- file size;
- SHA-256 hash;
- redistribution basis;
- relationship to the frozen thesis workflow;
- whether the file is canonical or complementary.

Do not commit temporary exports, local caches, `.RData`, `.Rhistory`, credentials, or files that exceed the selected Git/Git LFS policy.
