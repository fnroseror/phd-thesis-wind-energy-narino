# PhD Thesis – Wind Energy Forecasting in Nariño

This repository contains the complete reproducible technical annexes of the doctoral research:

**"Estudio de la velocidad del viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas"**

## Study Period
2017–2022

## Data Volume
~8 million hourly meteorological records from 16 stations grouped into four geographical zones in Nariño, Colombia.

## Repository Structure

- `01_ANEXOS/` → Formal technical annexes
- `02_TABLAS/` → Extended metrics and comparative tables
- `03_FIGURAS/` → Publication-quality figures
- `04_CODIGO/` → Reproducible scripts (preprocessing, modeling, hybrid TDQ)
- `05_RESULTADOS/` → Model outputs and evaluation metrics
- `06_REPRODUCIBILIDAD/` → Software versions and execution logs

## Models Implemented

- Classical time series models (ARIMA / ARIMAX)
- Machine Learning models
- Deep Learning (LSTM-based architectures)
- Hybrid physical-statistical TDQ-PIESS framework

## Evaluation Metrics

- RMSE
- MAE
- R²
- Skill Score vs Persistence
- 90% Prediction Interval Coverage

## Reproducibility

All scripts were developed in R (v4.x) with TensorFlow integration for deep learning models. Session information and execution logs are provided.

---

Author: F.N. Rosero-Rodríguez  
Universidad Nacional de Colombia
