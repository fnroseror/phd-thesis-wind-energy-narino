# Dataset overview

## 1. Observational source

The thesis uses terrestrial meteorological observations supplied by the **Instituto de Hidrología, Meteorología y Estudios Ambientales (IDEAM)** for stations located in Nariño, Colombia.

The frozen source used by the thesis contains **8,175,686 records** in long format. The detected fields are:

```text
Estación | FechaYHora | Valor | Zona | Variable
```

The date parser selected in the final audit was `dmy`. The nominal period is **2017–2022**, with effective source availability through **1 July 2022**.

## 2. Observed variables

The raw long-format source contains ten variable codes:

- `VV`: wind speed;
- `DV`: wind direction;
- `PR`: precipitation;
- `TM`: mean temperature;
- `TMIN`: minimum temperature;
- `HR`: relative humidity;
- `PA`: atmospheric pressure;
- `NU`: cloudiness;
- `FA`: atmospheric phenomenon;
- `EV`: evaporation.

The exact audited counts are provided in [`tables/variable_counts.csv`](tables/variable_counts.csv). Their sum equals the canonical raw total of 8,175,686 records.

## 3. Wind-speed layer

The control stage identified **2,218,605 valid wind-speed records** across all 16 stations and four zones. These records are non-missing, finite, non-negative, and within the adopted plausibility threshold of 75 m/s.

Zeros were retained because they can represent physical calm conditions. Their occurrence was quantified by station and zone instead of being removed automatically.

## 4. Analytical station-hour layer

After station-hour consolidation and hierarchical construction of air density, the analytical VV/WPD dataset contains **365,512 station-hour rows**:

| Zone | Analytical rows |
|---|---:|
| 1 | 104,055 |
| 2 | 98,480 |
| 3 | 123,109 |
| 4 | 39,868 |

This layer supports the descriptive and distributional results reported in Chapter 2 and feeds subsequent modeling stages. It must not be confused with the 2,218,605 valid source-level wind-speed observations, which can have finer-than-hourly resolution.

## 5. Spatial organization

The 16 stations are organized into four analytical zones. The grouping is operational and comparative. It is not an administrative regionalization, a continuous wind-field interpolation, or proof of exhaustive spatial representativeness.

The zones allow comparison of observed regimes under differentiated geographic conditions while preserving station-level traceability through IDEAM codes.

## 6. Derived physical layer

Air density is constructed hierarchically from available pressure and temperature information:

1. station-hour density;
2. zone-hour median density;
3. zone-month median density;
4. reference density `rho_ref = 1.10 kg/m³` when the previous levels are unavailable.

Each analytical record retains the density-source category. WPD is then computed as:

```text
WPD(t) = 0.5 × rho(t) × v(t)^3
```

Because 68.0361% of the analytical rows use the reference density, WPD must be interpreted as a regional physical estimate with partial thermodynamic variability and explicit fallback traceability, not as a complete atmospheric-density reconstruction.

## 7. Separation of analytical stages

The repository must keep three stages distinct:

1. **observational and station-hour characterization**;
2. **hourly WPD forecasting** for horizons `h = 1, 12, 72`;
3. **quarterly scenario stage** from `2022-Q3` to `2028-Q4`, summarized annually for 2023–2028.

The quarterly stage is informed by the approved pipeline but is not a direct extension of the hourly forecast horizons.
