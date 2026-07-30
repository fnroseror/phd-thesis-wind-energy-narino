# Preprocessing

Builds the controlled station-hour dataset from the restricted IDEAM long-format source. It applies the 2017–2022 window, physical VV control (`0 ≤ VV ≤ 75 m/s`), station-hour consolidation, hierarchical air-density provenance and WPD construction. Newly generated files are written to `TDQ_WORK_DIR`; approved canonical outputs are never overwritten.
