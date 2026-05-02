# Data Contract (Input Format)

This repository does not include raw data. All scripts expect a minimal input dataset in *long format* with the following columns:

## Required columns
- **Estación**: station identifier (string)
- **FechaYHora**: timestamp (POSIXct / ISO-8601)
- **Valor**: numeric measurement
- **Zona**: integer zone identifier (1–4)
- **Variable**: variable code

## Variable codes used in this thesis

| Code | Description |
|------|-------------|
| VV   | Wind speed |
| PA   | Atmospheric pressure |
| TM   | Mean temperature |
| Tm   | Minimum temperature |
| HR   | Relative humidity |
| PR   | Precipitation |
| EV   | Evaporation |
| NU   | Cloud cover |
| DV   | Wind direction |
| FA   | Atmospheric phenomenon indicator |

## Notes
- Scripts internally reshape data from long format to wide format.
- Air density (ρ) is derived from pressure and temperature.
- Wind Power Density (WPD) is computed as 0.5·ρ·VV³.
- Energy horizon (Eh) is calculated as rolling aggregation of WPD.
