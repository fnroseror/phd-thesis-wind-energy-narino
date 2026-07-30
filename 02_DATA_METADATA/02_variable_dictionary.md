# Variable dictionary

## Observed meteorological variables

| Code | Name | Source status | Reference unit | Role |
|---|---|---|---|---|
| `VV` | Wind speed | Observed | m/s | Primary physical input and basis for WPD. |
| `DV` | Wind direction | Observed | source-recorded angular unit | Complementary wind-regime descriptor. |
| `PR` | Precipitation | Observed | source-recorded unit | Meteorological covariate/context. |
| `TM` | Mean temperature | Observed | source-recorded temperature unit | Used, when available, in air-density estimation and as a covariate. |
| `TMIN` | Minimum temperature | Observed | source-recorded temperature unit | Meteorological covariate/context. |
| `HR` | Relative humidity | Observed | % or source-recorded unit | Meteorological covariate/context. |
| `PA` | Atmospheric pressure | Observed | harmonized to Pa for physical calculations | Used, when available, in air-density estimation. |
| `NU` | Cloudiness | Observed | source-recorded unit | Meteorological context. |
| `FA` | Atmospheric phenomenon | Observed categorical variable | source-recorded category | Meteorological context. |
| `EV` | Evaporation | Observed | source-recorded unit | Surface-atmosphere context. |

`TM` denotes **mean temperature** in the corrected thesis. It must not be relabeled as maximum temperature.

## Core physical and data-construction variables

| Symbol/name | Meaning | Unit | Repository interpretation |
|---|---|---|---|
| `rho` / `ρ` | Air density | kg/m³ | Estimated from pressure and temperature or assigned through the documented hierarchy. |
| `rho_source` | Provenance of air density | categorical | One of `station_hour`, `zone_hour`, `zone_month`, `rho_ref`. |
| `v` | Wind speed | m/s | Physical input after quality control. |
| `WPD` | Wind power density | W/m² | Central physical variable: `0.5 × rho × v³`. |
| `station_code` | IDEAM station code | text | Primary stable station identifier. |
| `zone` | Analytical zone | integer 1–4 | Comparative regional grouping. |
| `timestamp` | Observation/aggregation time | datetime | Chronological index; preserve timezone declaration. |

## Predictive variables and metrics

| Symbol/name | Meaning | Unit/status | Limit |
|---|---|---|---|
| `h` | Forecast horizon | hours | Approved values: 1, 12, 72. |
| `y_t` | Observed WPD | W/m² | Target at the forecast origin/verification time. |
| `yhat_t` | Predicted WPD | W/m² | Model output. |
| `e_t` | Forecast residual | W/m² | Observed minus predicted WPD. |
| `RMSE` | Root mean squared error | W/m² | Deterministic error metric. |
| `MAE` | Mean absolute error | W/m² | Deterministic error metric. |
| `R²` | Coefficient of determination | dimensionless | Complementary; not the sole model-selection criterion. |
| `S_RMSE` | RMSE-based skill relative to persistence | dimensionless | Positive values indicate improvement over persistence under RMSE. |
| `PI90` | Nominal 90% prediction interval | W/m² | Evaluated by empirical coverage and width. |
| `I_TDQ` | Internal TDQ state index | dimensionless/internal | Causal internal variable of the hourly pipeline; not equivalent to FNRR. |

## Quarterly/annual scenario variables

| Symbol/name | Meaning | Unit/status | Limit |
|---|---|---|---|
| `Q0.50` | Median WPD | W/m² | Central quantile used in FNRR. |
| `Q0.90` | 90th percentile of WPD | W/m² | Upper-regime quantile used in FNRR. |
| `W0` | Common WPD reference scale | W/m² | Fixed at 1 W/m² in the audited logarithmic FNRR transformation. |
| `FNRR` | Factor de No Regularidad Regional | dimensionless [0,1] | Quarterly irregularity descriptor, aggregated annually by theoretical hours. |
| `C = 1 − FNRR` | Operational coherence | dimensionless [0,1] | Complement of FNRR; not proof of stationarity or guaranteed operation. |
| `E_free` | Annualized integrated-energy indicator | kWh/m² | WPD integrated per unit area before FNRR modulation; not thermodynamic free energy. |
| `E_usable` | Annualized structurally modulated-energy indicator | kWh/m² | `E_free × (1 − FNRR)`; not actual electrical generation or guaranteed usable energy. |

## FNRR identity rule

FNRR is computed in the separate quarterly scenario stage from the median and 90th percentile of WPD using the audited logarithmic transformation and duration weighting. It is not a renaming, rescaling, or annual average of `I_TDQ`.
