# Contributions Summary

## Central contribution

The thesis establishes a reproducible physical-statistical workflow that connects meteorological observations, construction of Wind Power Density (WPD), comparative forecasting, uncertainty evaluation, regional irregularity, and conditioned energy scenarios for Nariño, Colombia.

The contribution lies in the integration of these components under explicit traceability and limitations. It does not rely on presenting a single algorithm, zone, or descriptor as universal.

## 1. Physical-statistical characterization

The study organizes 16 IDEAM stations into four analytical zones and preserves the heterogeneity of coverage and physical regime. The characterization combines:

- descriptive analysis of wind speed and WPD;
- Weibull/Rayleigh comparison;
- ACF and PACF;
- FFT;
- Morlet Continuous Wavelet Transform.

The resulting interpretation distinguishes regional distributional behavior, temporal memory, spectral organization, multiscale variability, and sensitivity to extremes.

## 2. Traceable construction of WPD

WPD is used as the main physical variable linking meteorological observations to energy interpretation. Air density is incorporated through a documented hierarchy of available pressure-temperature information and fallback sources. This preserves the physical identity of WPD while making the limitations of density coverage explicit.

## 3. Comparative forecasting framework

The predictive workflow evaluates different model families under a common regional and horizon-based structure:

- persistence;
- ARIMA and ARIMAX;
- Random Forest and XGBoost;
- Bayesian-tuned variants;
- LSTM;
- final TDQ-PIESS/KFAS integration.

The model families are not treated as interchangeable. They provide complementary linear, nonlinear, sequential, state-space, and probabilistic views of the WPD process.

## 4. Benchmark-based and residual-aware evaluation

Predictive value is assessed relative to persistence, with Skill-RMSE as a principal comparative metric and RMSE, MAE, and R-squared as complementary measures. The approved final pipeline reports positive Skill-RMSE for the twelve zone-horizon combinations, while the thesis explicitly retains the limitations revealed by residual autocorrelation and loss-function sensitivity.

## 5. Probabilistic evaluation

The final pipeline includes nominal 90% prediction intervals (PI90), empirical coverage, interval-width analysis, and residual diagnostics. PI90 calibration is interpreted within the evaluated design and is not generalized beyond the validation protocol without further external assessment.

## 6. Operational distinction between `I_TDQ` and FNRR

The thesis separates two different objects:

- `I_TDQ`: internal causal state information used in the hourly predictive pipeline;
- FNRR: a regional descriptor of irregularity used in the aggregated energy interpretation.

This distinction prevents internal model state from being conflated with the regional structural descriptor.

## 7. FNRR and structurally modulated energy indicator

FNRR is formalized as a bounded, dimensionless regional descriptor based on robust WPD quantiles defined in the final thesis. It is used to modulate the annualized integrated-energy indicator:

`E_usable = (1 - FNRR) * E_free`

The relation is an operational structural modulation. It does not estimate turbine output, grid-deliverable energy, thermodynamic free energy, or guaranteed generation.

## 8. Explicit transition between forecasting scales

A specific doctoral contribution is the separation between:

- hourly forecasting at `h = 1, 12, 72`;
- the quarterly stage beginning at 2022-Q3;
- the central annual scenario for 2023-2028.

This transition prevents the multiyear scenario from being misrepresented as a direct extrapolation of the hourly forecast.

## 9. Regional conditioned scenario

The regional scenario supports comparative interpretation of magnitude and irregularity among zones. It is presented with physical and methodological limits and does not constitute site selection, turbine selection, wind-farm design, or techno-economic feasibility.

## 10. Reproducible and auditable architecture

The thesis contributes an evidence architecture linking:

`submitted thesis <-> canonical outputs <-> code <-> figures and tables <-> appendices <-> manifests and validation`

The repository is the public implementation of this architecture. Complementary robustness analyses are preserved as supporting evidence but do not replace the approved figures and metrics reported in the dissertation.
