# ANEXO C — Configuraciones y resultados del pipeline predictivo aprobado

## Alcance

El pipeline horario aprobado modela WPD en horizontes:

- `h = 1`;
- `h = 12`;
- `h = 72`.

Se compararon persistencia, ARIMA, ARIMAX, Random Forest, XGBoost, variantes con búsqueda bayesiana, LSTM y la integración final TDQ–PIESS/KFAS.

## Resultados congelados

Esta carpeta conserva:

- la tabla global final;
- las predicciones globales aprobadas;
- el resumen ejecutivo de congelamiento.

```text
support_files/C_predictive_pipeline_approved/
```

El archivo `TDQ_FINAL_PREDS_GLOBAL.csv` se conserva sin alterar. Cuando aparezca una etiqueta histórica `FNRR` dentro del objeto horario, debe interpretarse conforme al Anexo F como la variable interna `I_TDQ`; no corresponde al FNRR regional del Capítulo 4.

## Métricas

Las salidas finales fueron evaluadas mediante RMSE, MAE, R², Skill-RMSE frente a persistencia, diagnóstico residual e intervalos PI90.

Los valores aprobados no deben recalcularse para “mejorar” el repositorio.
