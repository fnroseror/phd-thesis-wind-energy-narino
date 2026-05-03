# Appendix G — Physical and Mathematical Formulation of the Model and FNRR

## Purpose

This appendix presents the physical and mathematical formulation supporting the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”.**

Its purpose is to formalize the physical construction of Wind Power Density, the predictive structure of the model, the uncertainty representation through PI90 intervals, the energy-integration logic, and the definition of the **Factor de No Regularidad Regional (FNRR)**.

This appendix supports the scientific connection between:

```text
meteorological observations
→ physical variables
→ Wind Power Density
→ predictive modeling
→ uncertainty quantification
→ FNRR
→ free energy
→ usable energy
→ regional energy projection
```

The appendix is written as a mathematical support document for repository review, thesis defense, and future derivative products.

---

## G.1 General structure of the physical–statistical system

The doctoral model can be represented as a structured physical–statistical system:

```text
S = {D, P, Γ, M, U, Ψ, Ω}
```

where:

| Symbol | Meaning |
|---|---|
| `D` | Observational meteorological dataset. |
| `P` | Preprocessing and traceability operator. |
| `Γ` | Physical transformation from meteorological variables to energetic variables. |
| `M` | Predictive modeling operator. |
| `U` | Uncertainty quantification operator. |
| `Ψ` | Structural irregularity operator associated with FNRR. |
| `Ω` | Energy integration and projection operator. |

The complete workflow can be expressed as:

```text
D_raw → P(D_raw) → Γ(P(D_raw)) → M(Γ) → U(M) → Ψ(WPD) → Ω(E_free, FNRR)
```

This expression summarizes the central logic of the thesis: the final energetic interpretation is not obtained directly from raw data, but from a sequence of physically and computationally traceable transformations.

---

## G.2 Observational state vector

For each analytical zone `z` and time index `t`, the meteorological state may be represented as:

```text
x_z(t) = [v_z(t), d_z(t), p_z(t), T_z(t), RH_z(t), PR_z(t), EV_z(t), NU_z(t), FA_z(t)]
```

where:

| Symbol | Meaning |
|---|---|
| `v_z(t)` | Wind speed in zone `z` at time `t`. |
| `d_z(t)` | Wind direction. |
| `p_z(t)` | Atmospheric pressure. |
| `T_z(t)` | Air temperature. |
| `RH_z(t)` | Relative humidity. |
| `PR_z(t)` | Precipitation. |
| `EV_z(t)` | Evaporation. |
| `NU_z(t)` | Cloudiness. |
| `FA_z(t)` | Atmospheric phenomenon or qualitative atmospheric descriptor. |

The primary observed variable for energetic modeling is wind speed:

```text
v_z(t) ≥ 0
```

The derived physical target variable is Wind Power Density:

```text
WPD_z(t)
```

The model therefore moves from an atmospheric state vector to a physical energetic quantity.

---

## G.3 Physical derivation of Wind Power Density

Wind power density is derived from the kinetic energy flux of moving air.

The kinetic energy per unit mass of an air parcel moving with speed `v` is:

```text
e_k = 0.5 · v²
```

The mass flow rate per unit area crossing a surface perpendicular to the wind direction is:

```text
ṁ_A = ρ · v
```

where:

| Symbol | Meaning |
|---|---|
| `ρ` | Air density. |
| `v` | Wind speed. |
| `ṁ_A` | Mass flow rate per unit area. |

The kinetic power per unit area is obtained by multiplying kinetic energy per unit mass by mass flow rate per unit area:

```text
WPD = e_k · ṁ_A
```

Substituting:

```text
WPD = (0.5 · v²)(ρ · v)
```

Therefore:

```text
WPD = 0.5 · ρ · v³
```

This is the central physical equation of the thesis.

---

## G.4 Dimensional consistency of WPD

The units are:

```text
ρ → kg/m³
v → m/s
v³ → m³/s³
```

Then:

```text
ρ · v³ = (kg/m³)(m³/s³) = kg/s³
```

Since:

```text
1 W = 1 kg·m²/s³
```

then:

```text
1 W/m² = 1 kg/s³
```

Therefore:

```text
WPD = 0.5 · ρ · v³
```

has units of:

```text
W/m²
```

This confirms that the expression is dimensionally consistent.

---

## G.5 Air-density approximation

Air density can be estimated using the ideal gas approximation:

```text
ρ = p / (R_d · T_K)
```

where:

| Symbol | Meaning |
|---|---|
| `ρ` | Air density in kg/m³. |
| `p` | Atmospheric pressure in Pa. |
| `R_d` | Specific gas constant for dry air. |
| `T_K` | Absolute temperature in K. |

The absolute temperature is:

```text
T_K = T_C + 273.15
```

where `T_C` is temperature in degrees Celsius.

The dry-air constant is:

```text
R_d ≈ 287.05 J·kg⁻¹·K⁻¹
```

Thus, the operational physical chain is:

```text
p, T → ρ
v, ρ → WPD
```

If humidity correction is explicitly implemented, the moist-air density can be expressed as:

```text
ρ = (p_d / (R_d · T_K)) + (e / (R_v · T_K))
```

where:

| Symbol | Meaning |
|---|---|
| `p_d` | Partial pressure of dry air. |
| `e` | Water-vapor pressure. |
| `R_v` | Specific gas constant for water vapor. |

However, unless the code explicitly implements the moist-air correction, the operational thesis formulation should be interpreted through the dry-air approximation or the specific implemented density formula.

---

## G.6 Nonlinear sensitivity of WPD to wind speed

Because:

```text
WPD = 0.5 · ρ · v³
```

the derivative of WPD with respect to wind speed is:

```text
∂WPD/∂v = 1.5 · ρ · v²
```

This derivative shows that sensitivity increases quadratically with wind speed.

The relative differential form is:

```text
dWPD / WPD = dρ / ρ + 3 · dv / v
```

This means that a small relative change in wind speed produces approximately three times that relative change in WPD, assuming air density remains locally constant.

Therefore:

```text
wind-speed variability → amplified energetic variability
```

This justifies why the thesis does not treat wind speed only as a meteorological variable, but as a physically amplified energetic driver.

---

## G.7 Zonal formulation

Let:

```text
z ∈ {1, 2, 3, 4}
```

represent the four analytical zones.

For each zone `z`, the wind-speed series is:

```text
V_z = {v_z(t_1), v_z(t_2), ..., v_z(t_n)}
```

The corresponding WPD series is:

```text
Y_z = {WPD_z(t_1), WPD_z(t_2), ..., WPD_z(t_n)}
```

where:

```text
WPD_z(t_i) = 0.5 · ρ_z(t_i) · v_z(t_i)^3
```

The zonal structure allows the thesis to interpret the atmospheric system as a set of regional subsystems rather than as a single homogeneous domain.

---

## G.8 Physical interpretation of the zone

A zone is not treated as a purely administrative unit.

In the thesis, a zone is an operational atmospheric subsystem:

```text
Z_z = {stations, variables, temporal records, derived physical quantities}
```

The zone supports:

- regional physical characterization,
- predictive modeling,
- uncertainty interpretation,
- FNRR computation,
- free-energy estimation,
- usable-energy estimation,
- and projection toward 2028.

Thus, the zone is the spatial unit through which the atmospheric signal becomes physically and computationally interpretable.

---

## G.9 Predictive formulation

Let `h` represent the prediction horizon.

The target variable may be represented as:

```text
Y_z(t+h) = WPD_z(t+h)
```

A predictive model `m` estimates:

```text
Ŷ_z,m(t+h) = f_m(Φ_z(t); θ_m)
```

where:

| Symbol | Meaning |
|---|---|
| `Ŷ_z,m(t+h)` | Predicted WPD for zone `z`, model `m`, and horizon `h`. |
| `f_m` | Predictive function associated with model `m`. |
| `Φ_z(t)` | Feature vector or lagged information available at time `t`. |
| `θ_m` | Parameters or hyperparameters of model `m`. |

The feature vector may include:

```text
Φ_z(t) = [Y_z(t), Y_z(t-1), ..., meteorological covariates, temporal indicators]
```

depending on the model family and implementation.

---

## G.10 Model families

The predictive operator may include several model families:

```text
M = {M_classical, M_ML, M_DL, M_hybrid}
```

where:

| Model family | Interpretation |
|---|---|
| `M_classical` | Classical time-series models such as ARIMA or ARIMAX. |
| `M_ML` | Machine learning models such as Random Forest or XGBoost. |
| `M_DL` | Deep learning models such as LSTM. |
| `M_hybrid` | Hybrid physical–statistical integration stage. |

The purpose of using several model families is not only to compare algorithms, but to evaluate which modeling structure captures the physical and temporal behavior of the wind-energy signal more effectively.

---

## G.11 Persistence benchmark

The persistence benchmark is defined as a physically meaningful reference model.

For horizon `h`, a simple persistence prediction can be expressed as:

```text
Ŷ_z,pers(t+h) = Y_z(t)
```

This assumes that the future value is approximated by the most recent available value.

Persistence is relevant because atmospheric variables often contain temporal dependence.

A model is scientifically useful only if it improves over this baseline.

---

## G.12 Deterministic evaluation metrics

For observed values `Y_i` and predictions `Ŷ_i`, the residual is:

```text
e_i = Y_i − Ŷ_i
```

The Root Mean Squared Error is:

```text
RMSE = sqrt((1/n) · Σ(e_i²))
```

The Mean Absolute Error is:

```text
MAE = (1/n) · Σ|e_i|
```

The coefficient of determination is:

```text
R² = 1 − [Σ(Y_i − Ŷ_i)² / Σ(Y_i − Ȳ)²]
```

where:

```text
Ȳ = (1/n) · ΣY_i
```

These metrics provide deterministic information about predictive error and explanatory capacity.

---

## G.13 Skill Score versus persistence

The Skill Score evaluates improvement relative to persistence.

Using RMSE as the loss measure:

```text
Skill = 1 − (RMSE_model / RMSE_persistence)
```

Interpretation:

```text
Skill > 0  → the model improves over persistence
Skill = 0  → the model performs similarly to persistence
Skill < 0  → the model performs worse than persistence
```

A stronger condition may be expressed as:

```text
Skill > 0.50
```

which indicates that the model reduces predictive error by more than 50% relative to persistence, under this RMSE-based definition.

This criterion is central because it prevents the thesis from selecting a model only because it produces acceptable isolated metrics. The model must demonstrate improvement over a physically meaningful temporal baseline.

---

## G.14 Prediction residuals

The residual series is:

```text
R_z,m,h = {e_z,m,h(t_i)}
```

where:

```text
e_z,m,h(t_i) = Y_z(t_i+h) − Ŷ_z,m(t_i+h)
```

Residual analysis is required because global metrics may hide systematic error behavior.

Residuals should be inspected in relation to:

- zone,
- horizon,
- target variable,
- model family,
- and temporal structure.

A model with low RMSE but structured residuals may still require methodological caution.

---

## G.15 PI90 uncertainty interval

A 90% prediction interval for model `m`, zone `z`, and horizon `h` can be expressed as:

```text
PI90_z,m,h(t) = [L_z,m,h(t), U_z,m,h(t)]
```

where:

| Symbol | Meaning |
|---|---|
| `L_z,m,h(t)` | Lower bound of the prediction interval. |
| `U_z,m,h(t)` | Upper bound of the prediction interval. |

A generic symmetric residual-based interval may be written as:

```text
L_z,m,h(t) = Ŷ_z,m(t+h) − c_PI90 · q_0.95(|R_z,m,h|)
```

```text
U_z,m,h(t) = Ŷ_z,m(t+h) + c_PI90 · q_0.95(|R_z,m,h|)
```

where:

| Symbol | Meaning |
|---|---|
| `q_0.95(|R|)` | 95th percentile of absolute residuals. |
| `c_PI90` | Calibration factor. |

The exact interval construction should follow the implemented code, but the mathematical role is the same: to provide an uncertainty range around the central prediction.

---

## G.16 Empirical coverage of PI90

The empirical coverage of PI90 is:

```text
Coverage_PI90 = (1/n) · Σ I[L_i ≤ Y_i ≤ U_i]
```

where:

| Symbol | Meaning |
|---|---|
| `I` | Indicator function. |
| `Y_i` | Observed value. |
| `L_i` | Lower interval bound. |
| `U_i` | Upper interval bound. |

A calibrated 90% interval should satisfy:

```text
Coverage_PI90 ≈ 0.90
```

This does not mean that every individual observation will fall inside the interval.

It means that, under the validation conditions, approximately 90% of observations should be contained within the interval.

---

## G.17 Calibration factor

The calibration factor `c_PI90` is introduced to adjust interval width.

A formal calibration objective can be written as:

```text
c*_PI90 = argmin_c |Coverage_PI90(c) − 0.90|
```

The purpose of calibration is to align empirical coverage with nominal coverage.

If intervals are too narrow, empirical coverage will be below 0.90.

If intervals are too wide, empirical coverage may exceed 0.90 but with low sharpness.

Thus, calibration balances reliability and interval width.

---

## G.18 Energy integration over a horizon

Let `Δt` be the temporal resolution in hours.

For hourly data:

```text
Δt = 1 h
```

The horizon-integrated energy density can be expressed as:

```text
E_h,z(t) = (Δt / 1000) · Σ_{i=1}^{h} WPD_z(t+i)
```

where:

| Symbol | Meaning |
|---|---|
| `E_h,z(t)` | Horizon-integrated energy density for zone `z`. |
| `h` | Prediction horizon. |
| `WPD_z(t+i)` | Wind Power Density at future step `i`. |
| `1000` | Conversion from Wh/m² to kWh/m² when WPD is in W/m² and time is in hours. |

If predicted values are used:

```text
Ê_h,z(t) = (Δt / 1000) · Σ_{i=1}^{h} ŴPD_z(t+i)
```

This connects prediction with energetic interpretation.

---

## G.19 Annual free energy

For a time window `T`, the free energy density is defined as:

```text
E_free,z(T) = (Δt / 1000) · Σ_{t ∈ T} WPD_z(t)
```

If projection outputs are used:

```text
Ê_free,z(T) = (Δt / 1000) · Σ_{t ∈ T} ŴPD_z(t)
```

This represents the physically available energetic potential before structural irregularity adjustment.

Free energy is therefore the gross energy implied by the WPD behavior.

---

## G.20 Need for a structural irregularity descriptor

A region may present high WPD or high free energy, but this does not imply that the energy is structurally regular or usable.

Wind-energy interpretation requires distinguishing between:

```text
available energetic magnitude
```

and

```text
structurally usable energetic behavior
```

The thesis introduces FNRR to represent regional irregularity in a compact, dimensionless, robust form.

---

## G.21 Formal definition of FNRR

Let:

```text
Y_z(T) = {WPD_z(t) : t ∈ T}
```

be the WPD sample for zone `z` over a temporal window `T`.

Let:

```text
Q_25,z(T) = 25th percentile of Y_z(T)
Q_75,z(T) = 75th percentile of Y_z(T)
```

The interquartile range is:

```text
IQR_z(T) = Q_75,z(T) − Q_25,z(T)
```

The **Factor de No Regularidad Regional (FNRR)** is defined as:

```text
FNRR_z(T) = IQR_z(T) / [Q_75,z(T) + Q_25,z(T) + ε]
```

where:

| Symbol | Meaning |
|---|---|
| `FNRR_z(T)` | Regional non-regularity factor for zone `z` and window `T`. |
| `IQR_z(T)` | Interquartile range of WPD. |
| `Q_75,z(T)` | Upper quartile of WPD. |
| `Q_25,z(T)` | Lower quartile of WPD. |
| `ε` | Small positive constant for numerical stability. |

This definition is robust because it is based on quantiles rather than extreme values.

---

## G.22 Mathematical properties of FNRR

Assume:

```text
WPD_z(t) ≥ 0
```

Then:

```text
Q_75,z(T) ≥ Q_25,z(T) ≥ 0
```

Therefore:

```text
IQR_z(T) = Q_75,z(T) − Q_25,z(T) ≥ 0
```

Since:

```text
Q_75,z(T) + Q_25,z(T) + ε > 0
```

then:

```text
FNRR_z(T) ≥ 0
```

Also, because:

```text
Q_75,z(T) − Q_25,z(T) ≤ Q_75,z(T) + Q_25,z(T) + ε
```

for nonnegative quartiles and `ε > 0`, it follows that:

```text
FNRR_z(T) ≤ 1
```

Thus:

```text
0 ≤ FNRR_z(T) ≤ 1
```

This proves that FNRR is bounded and dimensionless.

---

## G.23 Interpretation of FNRR values

The interpretation is:

```text
FNRR ≈ 0
```

indicates low interquartile irregularity.

```text
FNRR → 1
```

indicates high structural irregularity relative to the robust central range of WPD.

Therefore, FNRR is interpreted as a regional structural descriptor.

It is not a universal physical constant.

It depends on:

- the zone,
- the temporal window,
- the WPD construction,
- the preprocessing criteria,
- and the quantile definition used in the implementation.

---

## G.24 Why quantiles are used

Quantiles are used because WPD can be highly skewed due to the cubic dependence on wind speed.

Extreme values may strongly affect mean and variance.

The interquartile structure provides a robust measure of the central spread of the energetic signal.

Thus:

```text
FNRR = robust irregularity of WPD central distribution
```

This protects the descriptor from being dominated only by isolated extreme events.

---

## G.25 Usable energy formulation

The thesis distinguishes between:

```text
E_free
```

and

```text
E_usable
```

The usable energy is defined as:

```text
E_usable,z(T) = [1 − FNRR_z(T)] · E_free,z(T)
```

where:

| Symbol | Meaning |
|---|---|
| `E_usable,z(T)` | Structurally usable energy for zone `z` and window `T`. |
| `E_free,z(T)` | Physically available energy before irregularity adjustment. |
| `FNRR_z(T)` | Regional non-regularity factor. |

This expression applies a structural penalty to the physically available energy.

---

## G.26 Boundedness of usable energy

Because:

```text
0 ≤ FNRR_z(T) ≤ 1
```

then:

```text
0 ≤ 1 − FNRR_z(T) ≤ 1
```

If:

```text
E_free,z(T) ≥ 0
```

then:

```text
0 ≤ E_usable,z(T) ≤ E_free,z(T)
```

This proves that usable energy is bounded by free energy.

Therefore, the FNRR adjustment cannot create energy artificially.

It can only reduce the physically available energy according to structural irregularity.

---

## G.27 Monotonicity of usable energy with respect to FNRR

From:

```text
E_usable = (1 − FNRR) · E_free
```

assuming `E_free` is fixed:

```text
∂E_usable/∂FNRR = −E_free
```

Since:

```text
E_free ≥ 0
```

then:

```text
∂E_usable/∂FNRR ≤ 0
```

Thus, usable energy decreases monotonically as FNRR increases.

This is physically and methodologically coherent: higher irregularity reduces the structurally usable portion of energy.

---

## G.28 Interpretation of free and usable energy

The distinction can be summarized as:

```text
E_free → what the wind system physically offers
E_usable → what remains after structural irregularity is considered
```

This distinction protects the thesis from overinterpreting gross energetic potential.

A zone with high free energy but high FNRR may not be as structurally favorable as a zone with moderate free energy and lower irregularity.

---

## G.29 FNRR over annual and quarterly windows

For annual analysis:

```text
FNRR_z(year) = FNRR_z(T_year)
```

For quarterly analysis:

```text
FNRR_z(quarter) = FNRR_z(T_quarter)
```

This allows regional irregularity to be evaluated at different temporal scales.

Annual FNRR supports long-term interpretation.

Quarterly FNRR supports subannual or seasonal interpretation.

Both are useful because wind-energy behavior may change across time scales.

---

## G.30 Projection toward 2028

The projection stage extends the historical analysis toward 2028.

For a projected window `T_proj`, the model estimates:

```text
ŴPD_z(t),  t ∈ T_proj
```

Then:

```text
Ê_free,z(T_proj) = (Δt / 1000) · Σ_{t ∈ T_proj} ŴPD_z(t)
```

and:

```text
FNRR_z(T_proj) = IQR(ŴPD_z(T_proj)) / [Q_75(ŴPD_z(T_proj)) + Q_25(ŴPD_z(T_proj)) + ε]
```

Finally:

```text
Ê_usable,z(T_proj) = [1 − FNRR_z(T_proj)] · Ê_free,z(T_proj)
```

Projected values must be interpreted as model-based scenarios, not as direct observations.

---

## G.31 Uncertainty-aware energy projection

If prediction intervals are available for WPD, then energy can also be interpreted through lower and upper projected scenarios.

Let:

```text
L_WPD,z(t)
```

and:

```text
U_WPD,z(t)
```

be the lower and upper PI90 bounds for WPD.

Then:

```text
E_free,z^L(T) = (Δt / 1000) · Σ_{t ∈ T} L_WPD,z(t)
```

```text
E_free,z^U(T) = (Δt / 1000) · Σ_{t ∈ T} U_WPD,z(t)
```

This produces an energy interval:

```text
E_free,z(T) ∈ [E_free,z^L(T), E_free,z^U(T)]
```

A corresponding usable-energy interval may be approximated as:

```text
E_usable,z^L(T) = [1 − FNRR_z(T)] · E_free,z^L(T)
```

```text
E_usable,z^U(T) = [1 − FNRR_z(T)] · E_free,z^U(T)
```

If FNRR uncertainty is also estimated, then interval propagation should include uncertainty in FNRR as well.

---

## G.32 Complete mathematical chain

The complete mathematical chain of the thesis can be summarized as:

```text
x_z(t) → ρ_z(t) → WPD_z(t) → ŴPD_z(t+h) → PI90_z(t+h)
```

then:

```text
ŴPD_z(T) → E_free,z(T)
```

then:

```text
WPD_z(T) → FNRR_z(T)
```

finally:

```text
E_usable,z(T) = [1 − FNRR_z(T)] · E_free,z(T)
```

This chain connects observation, physics, prediction, uncertainty, irregularity, and energy.

---

## G.33 Scientific interpretation of the model

The model should be interpreted as a physical–statistical framework, not as a purely algorithmic system.

The physical component is represented by:

- wind-speed dynamics,
- air-density estimation,
- WPD construction,
- energy integration,
- and physical units.

The statistical component is represented by:

- distributional characterization,
- predictive modeling,
- performance metrics,
- persistence comparison,
- residual analysis,
- and uncertainty intervals.

The structural component is represented by:

- FNRR,
- free-energy adjustment,
- usable-energy estimation,
- and regional projection.

Together, these components form the doctoral contribution.

---

## G.34 Relationship with Chapter 2

Chapter 2 provides the physical and statistical characterization of wind speed.

It supports:

- descriptive statistics,
- Weibull fitting,
- Rayleigh comparison,
- ACF,
- PACF,
- FFT,
- Wavelet analysis,
- and zonal interpretation.

Mathematically, Chapter 2 establishes properties of:

```text
V_z = {v_z(t)}
```

which later determine:

```text
WPD_z(t) = 0.5 · ρ_z(t) · v_z(t)^3
```

Thus, Chapter 2 provides the empirical and physical basis for the energetic model.

---

## G.35 Relationship with Chapter 3

Chapter 3 provides the predictive modeling layer.

It estimates:

```text
ŴPD_z(t+h)
```

and evaluates model performance using:

- RMSE,
- MAE,
- R²,
- Skill Score versus persistence,
- PI90 coverage,
- residual behavior,
- and horizon-based interpretation.

Mathematically, Chapter 3 defines the transition:

```text
WPD_z(t) → ŴPD_z(t+h)
```

This transition is required before energy projection.

---

## G.36 Relationship with Chapter 4

Chapter 4 integrates prediction, uncertainty, FNRR, and energy.

It formalizes:

```text
E_free,z(T)
```

```text
FNRR_z(T)
```

```text
E_usable,z(T)
```

and projection toward 2028.

Mathematically, Chapter 4 provides the closure:

```text
prediction + uncertainty + irregularity → usable energy projection
```

This is the final scientific stage of the thesis.

---

## G.37 Relationship with repository results

This appendix supports the following repository folders:

```text
04_RESULTS_COMPLETE/01_physical_characterization/
04_RESULTS_COMPLETE/02_model_comparison/
04_RESULTS_COMPLETE/03_pi90_uncertainty/
04_RESULTS_COMPLETE/04_fnrr_outputs/
04_RESULTS_COMPLETE/05_energy_projection/
04_RESULTS_COMPLETE/07_FIGURES/
04_RESULTS_COMPLETE/08_TABLES/
```

The appendix provides the mathematical explanation behind the evidence stored in those folders.

---

## G.38 Relationship with code

The formulation in this appendix is operationally connected to:

```text
03_CODE/01_preprocessing/
03_CODE/02_physical_characterization/
03_CODE/03_classical_models/
03_CODE/04_machine_learning/
03_CODE/05_deep_learning/
03_CODE/06_hybrid_tdq/
03_CODE/07_energy_projection/
03_CODE/08_utils/
```

The folder `03_CODE/06_hybrid_tdq/` reflects the current repository naming. In this appendix, it should be interpreted as the hybrid physical–statistical integration stage of the doctoral workflow.

---

## G.39 Methodological assumptions

The formulation depends on the following assumptions:

1. Wind speed values used for WPD construction are physically admissible.
2. Air density is estimated through the density formulation implemented in the thesis workflow.
3. Units are harmonized before physical calculations.
4. WPD is nonnegative when wind speed and air density are nonnegative.
5. Prediction horizons are defined consistently.
6. Persistence is used as the main benchmark for predictive gain.
7. PI90 intervals are interpreted empirically.
8. FNRR is a dimensionless robust descriptor, not a universal constant.
9. Energy projection is model-based and should not be interpreted as direct observation.
10. Usable energy is bounded above by free energy.

---

## G.40 Methodological cautions

This appendix does not claim that the wind system is deterministic.

It does not claim that FNRR eliminates uncertainty.

It does not claim that all projected values are guaranteed future values.

It does not claim that FNRR is a universal physical law.

Instead, it defines a physically consistent, mathematically bounded, and computationally traceable framework for interpreting wind-energy prediction under regional irregularity and uncertainty.

---

## G.41 Main propositions

### Proposition 1 — Nonnegativity of WPD

If:

```text
ρ ≥ 0
```

and:

```text
v ≥ 0
```

then:

```text
WPD = 0.5 · ρ · v³ ≥ 0
```

Thus, WPD is physically nonnegative.

---

### Proposition 2 — WPD is dimensionally consistent

Given:

```text
ρ → kg/m³
v³ → m³/s³
```

then:

```text
ρv³ → kg/s³ = W/m²
```

Thus, WPD has units of power per unit area.

---

### Proposition 3 — FNRR is bounded

For nonnegative WPD:

```text
0 ≤ FNRR ≤ 1
```

because:

```text
0 ≤ Q_75 − Q_25 ≤ Q_75 + Q_25 + ε
```

---

### Proposition 4 — Usable energy is bounded by free energy

If:

```text
E_usable = (1 − FNRR) · E_free
```

with:

```text
0 ≤ FNRR ≤ 1
```

and:

```text
E_free ≥ 0
```

then:

```text
0 ≤ E_usable ≤ E_free
```

---

### Proposition 5 — Usable energy decreases with irregularity

If `E_free` is fixed:

```text
∂E_usable/∂FNRR = −E_free ≤ 0
```

Thus, increasing irregularity decreases usable energy.

---

## G.42 Final synthesis

The doctoral model can be summarized as:

```text
Meteorological system:
x_z(t)

Physical transformation:
WPD_z(t) = 0.5 · ρ_z(t) · v_z(t)^3

Prediction:
ŴPD_z(t+h) = f_m(Φ_z(t); θ_m)

Uncertainty:
PI90_z,m,h(t) = [L_z,m,h(t), U_z,m,h(t)]

Free energy:
E_free,z(T) = (Δt / 1000) · Σ WPD_z(t)

Regional irregularity:
FNRR_z(T) = [Q_75,z(T) − Q_25,z(T)] / [Q_75,z(T) + Q_25,z(T) + ε]

Usable energy:
E_usable,z(T) = [1 − FNRR_z(T)] · E_free,z(T)
```

This sequence is the mathematical backbone of the doctoral thesis.

---

## G.43 Final statement

The physical and mathematical formulation of the thesis is built on one central idea:

```text
Wind-energy potential cannot be interpreted only from wind speed;
it must be constructed physically, predicted statistically,
bounded probabilistically, corrected structurally,
and interpreted energetically.
```

The role of FNRR is to introduce a mathematically bounded and robust structural descriptor that prevents the overinterpretation of free energy as fully usable energy.

For that reason, this appendix provides the formal support for the final doctoral contribution:

```text
a physical–statistical framework for forecasting and interpreting
regional wind-energy potential under uncertainty and structural irregularity.
```
