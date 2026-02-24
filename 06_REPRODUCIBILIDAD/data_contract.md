# Data Contract (Input Format)

This repository does not include raw data. All scripts expect a minimal input dataset in *long format* with the following columns:

## Required columns
- **Estación**: station identifier (string)
- **FechaYHora**: timestamp (POSIXct / ISO-8601)
- **Valor**: numeric measurement
- **Zona**: integer zone identifier (1–4)
- **Variable**: variable code (e.g., VV, PA, TM, HR, etc.)

## Notes
- Scripts internally reshape data from long format to wide format when required.
- Derived physical variables (ρ, WPD, Eh) are computed after reshaping and cleaning.
