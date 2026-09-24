# Article 02 — Wind Energy working package

## Working title

**Wind power density forecasting in complex Andean terrain: benchmarking classical, machine-learning, deep-learning, and state-space models across multiple horizons**

## Primary target journal

- Journal: Wind Energy
- Publisher: Wiley
- Article type: Research Article
- Working status: Article development initiated
- Workspace branch: article-02-wind-energy
- Workspace initiated: 2026-09-24
- Journal scope verification: 2026-09-24

Official journal pages used for the editorial lock:

- Aims and scope: https://onlinelibrary.wiley.com/page/journal/10991824/homepage/productinformation.html
- Author guidelines: https://onlinelibrary.wiley.com/page/journal/10991824/homepage/forauthors.html
- APC information: https://onlinelibrary.wiley.com/page/journal/10991824/homepage/article_publication_charges

## Role within the three-article thesis portfolio

Article 01 — Physical-statistical characterization of wind and WPD  
Article 02 — Predictive modeling, benchmarking, uncertainty and diagnostics  
Article 03 — FNRR and regional energy projection

Article 02 is the predictive core of the doctoral publication portfolio and derives mainly from Chapter 3 of the thesis.

## Scientific question

How do classical, machine-learning, deep-learning and state-space forecasting approaches compare for Wind Power Density (WPD) prediction in complex Andean terrain when performance is evaluated by analytical zone, prediction horizon, persistence benchmarking, deterministic metrics, prediction-interval calibration and residual diagnostics?

## Central physical variable

WPD = 0.5 × rho × v^3

The article treats WPD as the physical energetic target. The cubic transformation makes error amplification, intermittency and tail behavior scientifically relevant to forecasting evaluation.

## Core experimental design

- Region: Nariño, Colombia.
- Observational period: 2017–2022.
- Analytical units: four zones.
- Forecast horizons: h = 1, 12 and 72 hours.
- Baseline: persistence.
- Candidate families: ARIMA/ARIMAX, Random Forest, XGBoost, Bayesian-optimized variants and LSTM.
- Final integration in the thesis: state-space/KFAS layer.
- Deterministic metrics: RMSE, MAE, R² and Skill-RMSE.
- Probabilistic support: PI90 coverage and interval width.
- Diagnostics: residual distribution, autocorrelation and comparative loss tests where supported.

## Publication-critical methodological lock

The thesis preserves historical results from the approved predictive pipeline, but it also documents that the persistence series used in historical outputs is not perfectly aligned with the theoretical horizon-specific persistence definition in every case.

**Therefore, Article 02 will not freeze its headline Skill-RMSE claims until the persistence benchmark has been re-audited with exact horizon alignment.**

The final paper must distinguish historical thesis outputs retained for traceability from audited/recomputed benchmark results used for publication claims.

## Scope boundaries

Article 02 includes the forecasting problem, model-family comparison, horizon/zone behavior, persistence benchmarking, PI90 support and residual diagnostics.

It will not use FNRR or the 2023–2028 regional energy scenario as its main novelty. Those belong to Article 03. It will also avoid turbine-level generation, micrositing, wind-farm feasibility, grid-integration or economic-feasibility claims.

## Principal repository evidence

03_CODE/03_classical_models/  
03_CODE/04_machine_learning/  
03_CODE/05_deep_learning/  
03_CODE/06_hybrid_tdq/  
04_RESULTS_COMPLETE/02_model_comparison/  
04_RESULTS_COMPLETE/03_pi90_uncertainty/  
04_RESULTS_COMPLETE/07_FIGURES/canonical_thesis_evidence/  
04_RESULTS_COMPLETE/08_TABLES/canonical_thesis_evidence/  
06_PRODUCTS/03_chapter_3_validation_audit/

## Immediate objective

Build an auditable Research Article for Wind Energy in which every quantitative claim is linked to a reproducible result and the persistence benchmark is verified before manuscript lock.
