# Variable Dictionary

## Purpose

This document defines the main observed, derived, statistical, predictive, and energetic variables used throughout the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

The purpose of this file is to provide a clear and technically consistent reference for understanding the physical meaning, analytical role, and methodological function of each variable used in the repository.

This dictionary should be interpreted as a scientific support document, not as a generic glossary.

---

## 1. Observed meteorological variables

These variables come directly from the observational meteorological records used in the thesis. They represent the empirical atmospheric system from which the physical, statistical, predictive, and energetic analyses were developed.

| Variable | Full name | Type | Reference unit | Description | Role in the thesis |
|---|---|---|---|---|---|
| **VV** | Wind speed | Observed meteorological variable | m/s | Wind-flow intensity measured in the observational records. | Primary observed atmospheric variable; basis for wind characterization, WPD construction, forecasting, and energetic interpretation. |
| **DV** | Wind direction | Observed meteorological variable | degrees or source-recorded unit | Direction of wind flow. | Complementary variable for describing wind-regime behavior and directional atmospheric structure. |
| **Tmin** | Minimum temperature | Observed meteorological variable | °C or source-recorded unit | Minimum temperature recorded in the observational series. | Thermodynamic support variable for regional atmospheric interpretation. |
| **TM** | Maximum temperature | Observed meteorological variable | °C or source-recorded unit | Maximum temperature recorded in the observational series. In some contexts, this variable may be referred to as Tmax. | Thermodynamic support variable used in the interpretation of thermal forcing and air-density estimation. |
| **PA** | Atmospheric pressure | Observed meteorological variable | source unit; harmonized to Pa for physical calculations | Atmospheric pressure measured in the meteorological records. | Required for the physical estimation of air density and for interpreting pressure-related boundary conditions. |
| **HR** | Relative humidity | Observed meteorological variable | % or source-recorded unit | Relative humidity of the atmosphere. | Complementary atmospheric variable for describing moisture conditions and regional meteorological context. |
| **EV** | Evaporation | Observed meteorological variable | source-recorded unit | Evaporation-related meteorological measurement. | Complementary physical variable associated with surface-atmosphere exchange processes. |
| **NU** | Cloudiness | Observed meteorological variable | source-recorded unit | Cloud-cover or cloudiness condition. | Complementary variable used to describe atmospheric state and radiative/cloud-related forcing conditions. |
| **PR** | Precipitation | Observed meteorological variable | source-recorded unit | Precipitation measurement. | Complementary variable for identifying hydrometeorological forcing and atmospheric variability. |
| **FA** | Atmospheric phenomenon | Observed contextual variable | categorical/source-recorded unit | Recorded atmospheric condition or event descriptor. | Contextual variable used to represent qualitative atmospheric-state conditions. |

---

## 2. Core derived physical variables

These variables are constructed from the observed data and form the physical backbone of the thesis.

| Variable | Full name | Type | Unit | Description | Role in the thesis |
|---|---|---|---|---|---|
| **ρ** | Air density | Derived physical variable | kg/m³ | Air density estimated from atmospheric pressure and temperature using a physically consistent approximation. | Fundamental physical quantity required for the construction of Wind Power Density. |
| **WPD** | Wind Power Density | Derived physical variable | W/m² | Wind power per unit area, defined from air density and the cubic dependence on wind speed. | Central target variable of the doctoral thesis. |
| **Eh** | Horizon-integrated energy | Derived energetic variable | kWh/m² or equivalent integrated energy unit | Energy accumulated over a given prediction horizon. | Derived energetic quantity used for accumulated-energy interpretation across forecasting horizons. |
| **E_free** | Free annual energy | Derived energetic variable | kWh/m²/year or equivalent annualized unit | Annual integrated energetic potential before structural penalization. | Represents the gross physically available wind-energy potential. |
| **E_usable** | Usable annual energy | Derived energetic variable | kWh/m²/year or equivalent annualized unit | Annual energetic potential after structural penalization through FNRR. | Represents the energetically usable component under regional irregularity conditions. |

---

## 3. Structural regional variable

This variable represents one of the original methodological contributions of the thesis.

| Variable | Full name | Type | Unit | Description | Role in the thesis |
|---|---|---|---|---|---|
| **FNRR** | Factor de No Regularidad Regional | Derived structural index | Dimensionless | Robust regional irregularity index based on the internal distributional structure of WPD. | Original doctoral contribution used to describe structural irregularity and to transform free energy into usable energy. |

---

## 4. Distributional and statistical characterization variables

These variables are mainly used for the physical-statistical characterization of wind behavior.

| Variable | Full name | Type | Unit | Description | Role in the thesis |
|---|---|---|---|---|---|
| **k** | Weibull shape parameter | Distributional parameter | dimensionless | Shape parameter controlling the form and asymmetry of the Weibull distribution. | Used to characterize wind-regime structure, variability, and intermittency. |
| **c** | Weibull scale parameter | Distributional parameter | m/s | Scale parameter associated with the characteristic magnitude of the Weibull distribution. | Used in regional distributional modeling of wind speed. |
| **μ** | Mean | Statistical quantity | depends on analyzed variable | Average value of the analyzed series. | Used in descriptive statistics and structural interpretation of the atmospheric signal. |
| **σ** | Standard deviation | Statistical quantity | depends on analyzed variable | Dispersion measure of the analyzed series. | Used to quantify variability and spread in the observed or derived signal. |
| **n** | Sample size | Statistical quantity | count | Total number of observations. | Indicates the observational scale of the analysis by dataset, zone, variable, or model stage. |

---

## 5. Predictive evaluation variables and metrics

These quantities are used to evaluate deterministic and probabilistic model performance.

| Variable | Full name | Type | Unit | Description | Role in the thesis |
|---|---|---|---|---|---|
| **RMSE** | Root Mean Squared Error | Evaluation metric | same unit as target variable | Error metric that penalizes large deviations more strongly. | Main deterministic metric for predictive error magnitude. |
| **MAE** | Mean Absolute Error | Evaluation metric | same unit as target variable | Average absolute prediction error. | Complementary deterministic metric less sensitive to extreme deviations. |
| **R²** | Coefficient of determination | Evaluation metric | dimensionless | Proportion of variance explained by the model. | Complementary measure of explanatory and predictive capacity. |
| **Skill** | Skill Score versus persistence | Evaluation metric | dimensionless | Relative improvement of a predictive model compared with a persistence benchmark. | Principal model-selection criterion in the thesis. |
| **PI90** | 90% prediction interval | Probabilistic quantity | same unit as target variable | Prediction interval designed to contain approximately 90% of future observations after calibration. | Main probabilistic uncertainty representation used in the thesis. |
| **Coverage_PI90** | Empirical PI90 coverage | Probabilistic metric | dimensionless | Fraction of observations falling within the predicted 90% interval. | Used to evaluate probabilistic calibration quality. |
| **c_PI90** | PI90 calibration factor | Calibration parameter | dimensionless | Calibration coefficient used to adjust prediction-interval width. | Used to align empirical interval coverage with the nominal confidence level. |

---

## 6. Time-series and indexing variables

These variables organize the data structurally within the doctoral workflow.

| Variable | Full name | Type | Unit | Description | Role in the thesis |
|---|---|---|---|---|---|
| **t** | Time index | Temporal index | date-time/hour | Temporal index associated with the hourly observational records. | Organizes the chronological structure of the time series. |
| **z** | Geographic zone | Spatial index | categorical | Geographic zone assigned to each regional grouping. | Supports zonal characterization, modeling, uncertainty analysis, and energy projection. |
| **obs** | Observed value | Notation | depends on target variable | Observed value of the analyzed series. | Used in forecasting notation and model evaluation. |
| **pred** | Predicted value | Notation | depends on target variable | Model-predicted value of the analyzed series. | Used in forecasting notation and model evaluation. |
| **90** | Confidence-level index | Notation | dimensionless | Indicates the nominal 90% level used in PI90. | Used in probabilistic interval notation. |

---

## 7. Auxiliary notation

These quantities appear in the formal definitions used throughout the thesis and appendices.

| Variable | Full name | Type | Unit | Description | Role in the thesis |
|---|---|---|---|---|---|
| **ε** | Numerical stability term | Auxiliary parameter | dimensionless or target-dependent | Small positive value introduced to avoid division by zero or numerical instability. | Used in formal definitions that require robust numerical behavior. |
| **π** | Nominal confidence level | Auxiliary parameter | dimensionless | Confidence-level parameter used in interval notation. | Used conceptually in probabilistic forecasting notation. |
| **3** | Cubic dependence exponent | Physical exponent | dimensionless | Exponent expressing the cubic dependence of wind power on wind speed. | Represents the high physical sensitivity of WPD to variations in wind speed. |
| **free** | Free-energy subindex | Subindex | — | Identifies non-penalized energy. | Used in the notation of annual free energy. |
| **usable** | Usable-energy subindex | Subindex | — | Identifies structurally usable energy. | Used in the notation of annual usable energy. |

---

## 8. Conceptual hierarchy of variables in the thesis

The doctoral framework is organized around the following hierarchy:

### Primary observed variable

- **VV**

### Core physical derived variable

- **WPD**

### Derived energetic interpretation

- **Eh**
- **E_free**
- **E_usable**

### Structural irregularity descriptor

- **FNRR**

### Deterministic and probabilistic validation

- **RMSE**
- **MAE**
- **R²**
- **Skill**
- **PI90**
- **Coverage_PI90**
- **c_PI90**

This hierarchy reflects the logic of the thesis: from atmospheric observation, to physical construction, to predictive modeling, to uncertainty control, and finally to energetic interpretation.

---

## 9. Final note

This dictionary preserves coherence between:

- the observed meteorological system,
- the physical formulation of the thesis,
- the predictive framework,
- the uncertainty architecture,
- the regional irregularity descriptor,
- and the energetic interpretation developed in the doctoral work.

For that reason, the variables listed here are organized according to their scientific role within the thesis rather than as an isolated glossary.
