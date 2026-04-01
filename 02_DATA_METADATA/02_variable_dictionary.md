# Variable Dictionary

## Purpose

This document defines the main observed, derived, and analytical variables used throughout the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”**

Its purpose is to provide a clear reference for understanding the physical meaning, analytical role, and methodological function of each variable used in the repository.

---

## 1. Observed meteorological variables

These variables come directly from the observational meteorological records used in the thesis.

| Variable | Full name | Type | Unit | Description | Role in the thesis |
|---|---|---|---|---|---|
| **VV** | Wind speed | Observed | m/s | Primary physical variable representing wind-flow intensity. | Central observed atmospheric variable; basis for physical characterization and energetic modeling. |
| **DV** | Wind direction | Observed | As recorded in source data | Direction of wind flow. | Complementary meteorological variable used to characterize wind behavior. |
| **Tmin** | Minimum temperature | Observed | As recorded in source data | Minimum temperature recorded in the observational series. | Thermodynamic support variable used in regional physical interpretation and data context. |
| **Tmax** | Maximum temperature | Observed | As recorded in source data | Maximum temperature recorded in the observational series. | Thermodynamic support variable used in regional physical interpretation and data context. |
| **PA** | Atmospheric pressure | Observed | Pa | Atmospheric pressure measured in the meteorological records. | Used in the physical estimation of air density and in the interpretation of boundary conditions. |
| **HR** | Relative humidity | Observed | As recorded in source data | Relative humidity of the atmosphere. | Complementary atmospheric variable used in the regional meteorological context and predictive framework. |
| **EV** | Evaporation | Observed | As recorded in source data | Evaporation-related meteorological measurement. | Complementary physical variable within the multivariable atmospheric description. |
| **NU** | Cloudiness | Observed | As recorded in source data | Measure of cloud cover or cloudiness condition. | Complementary variable used to describe atmospheric state and regional forcing conditions. |
| **PR** | Precipitation | Observed | As recorded in source data | Precipitation measurement. | Complementary atmospheric variable relevant for regional physical interpretation. |
| **FA** | Atmospheric phenomenon | Observed | Categorical / as recorded in source data | Recorded atmospheric condition or event descriptor. | Contextual variable used to represent atmospheric state conditions within the observational system. |

---

## 2. Core derived physical variables

These variables are constructed from the observed data and form the physical backbone of the thesis.

| Variable | Full name | Type | Unit | Description | Role in the thesis |
|---|---|---|---|---|---|
| **ρ** | Air density | Derived physical variable | kg/m³ | Air density estimated using the ideal gas approximation. | Fundamental physical quantity used in the construction of Wind Power Density. |
| **WPD** | Wind Power Density | Derived physical variable | W/m² | Physical measure of wind power per unit area, defined as \( \tfrac{1}{2}\rho v^3 \). | Central target variable of the thesis. |
| **Eh** | Horizon-integrated energy | Derived energetic variable | kWh/m² | Energy accumulated over a given prediction horizon. | Derived energetic quantity used for operational and accumulated-energy interpretation. |
| **E_free** | Free annual energy | Derived energetic variable | kWh/m² | Annual integrated energetic potential without structural penalization. | Represents the physically available gross wind-energy potential. |
| **E_usable** | Usable annual energy | Derived energetic variable | kWh/m² | Structurally penalized annual energy, computed from free energy and FNRR. | Represents the energetically usable component under regional structural irregularity. |

---

## 3. Structural regional variable

This variable is one of the original contributions of the thesis.

| Variable | Full name | Type | Unit | Description | Role in the thesis |
|---|---|---|---|---|---|
| **FNRR** | Factor de No Regularidad Regional | Derived structural index | Adimensional | Robust regional irregularity index based on quantiles of WPD. | Original doctoral contribution used to describe structural irregularity and to transform free energy into usable energy. |

---

## 4. Distributional and statistical characterization variables

These variables are used in Chapter 2 for the physical–statistical characterization of wind behavior.

| Variable | Full name | Type | Unit | Description | Role in the thesis |
|---|---|---|---|---|---|
| **k** | Weibull shape parameter | Distributional parameter | 1 | Shape parameter controlling asymmetry and form of the Weibull distribution. | Used to characterize wind-regime structure and intermitency. |
| **c** | Weibull scale parameter | Distributional parameter | m/s | Scale parameter defining the characteristic magnitude of the Weibull distribution. | Used in regional distributional modeling of wind speed. |
| **μ** | Mean | Statistical quantity | m/s | Average value of the analyzed variable. | Used in descriptive statistics and structural interpretation of the signal. |
| **σ** | Standard deviation | Statistical quantity | m/s | Dispersion measure of the analyzed variable. | Used to quantify variability and spread in wind behavior. |
| **n** | Sample size | Statistical quantity | 1 | Total number of observations. | Indicates the observational scale of the analysis by zone or dataset. |

---

## 5. Predictive evaluation variables and metrics

These quantities are used in Chapters 3 and 4 to evaluate deterministic and probabilistic model performance.

| Variable | Full name | Type | Unit | Description | Role in the thesis |
|---|---|---|---|---|---|
| **RMSE** | Root Mean Squared Error | Evaluation metric | — | Error metric that penalizes large deviations more strongly. | Main deterministic metric for predictive error magnitude. |
| **MAE** | Mean Absolute Error | Evaluation metric | — | Average absolute prediction error. | Complementary deterministic metric less sensitive to extreme values. |
| **R²** | Coefficient of determination | Evaluation metric | — | Proportion of variance explained by the model. | Complementary measure of explanatory capacity. |
| **Skill** | Skill Score vs persistence | Evaluation metric | — | Relative improvement of a predictive model compared with persistence. | Principal model-selection criterion in the thesis. |
| **PI90** | 90% prediction interval | Probabilistic quantity | — | Prediction interval designed to contain approximately 90% of future observations after calibration. | Main probabilistic uncertainty representation used in the thesis. |
| **Coverage\_PI90** | Empirical PI90 coverage | Probabilistic metric | — | Fraction of observations falling within the predicted 90% interval. | Used to evaluate probabilistic calibration quality. |
| **c\_PI90** | PI90 calibration factor | Calibration parameter | — | Calibration coefficient used to adjust interval width. | Used to align empirical interval coverage with nominal confidence. |

---

## 6. Time-series and indexing variables

These variables organize the data structurally in the doctoral workflow.

| Variable | Full name | Type | Unit | Description | Role in the thesis |
|---|---|---|---|---|---|
| **t** | Time index | Index | Time | Temporal index associated with the hourly observational records. | Organizes the chronological structure of the time series. |
| **z** | Geographic zone | Index | Categorical | Geographic zone label assigned to each regional grouping. | Supports zonal characterization, modeling, and energy projection. |
| **obs** | Observed value | Index / notation | — | Indicates observed series values. | Used in forecasting notation and evaluation. |
| **pred** | Predicted value | Index / notation | — | Indicates model-predicted values. | Used in forecasting notation and evaluation. |
| **90** | Confidence level index | Index / notation | — | Indicates the nominal 90% level used in PI90. | Used in probabilistic interval notation. |

---

## 7. Auxiliary numerical and analytical notation

These quantities appear in the formal definitions used throughout the thesis.

| Variable | Full name | Type | Unit | Description | Role in the thesis |
|---|---|---|---|---|---|
| **ε** | Numerical stability term | Auxiliary parameter | — | Small positive value introduced for numerical stability. | Used in the formal definition of FNRR. |
| **π** | Nominal confidence level | Auxiliary parameter | — | Confidence level parameter used in interval notation. | Used conceptually in probabilistic forecasting notation. |
| **3** | Cubic dependence exponent | Exponent / notation | — | Indicates the cubic dependence of WPD on wind speed. | Represents the physical sensitivity of wind power to velocity. |
| **free** | Free-energy subindex | Subindex | — | Identifies non-penalized energy. | Used in the notation of annual free energy. |
| **usable** | Usable-energy subindex | Subindex | — | Identifies structurally usable energy. | Used in the notation of annual usable energy. |

---

## 8. Conceptual hierarchy of variables in the thesis

The doctoral framework is organized around a clear hierarchy of variables:

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

This dictionary should be read as a support document for the repository, not merely as a list of symbols. Its purpose is to preserve coherence between:

- the observed meteorological system,
- the physical formulation of the thesis,
- the predictive framework,
- the uncertainty architecture,
- and the energetic interpretation developed in the doctoral work.

For this reason, the variables listed here are organized according to their scientific role within the thesis rather than as a generic glossary.
