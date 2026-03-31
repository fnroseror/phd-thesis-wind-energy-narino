# Anexo B – Pipeline clásico (ARIMA / ARIMAX)

## B.1 Objetivo
Implementar modelos clásicos de series de tiempo como línea base reproducible.

## B.2 Validación
- Validación temporal tipo walk-forward / rolling origin (según configuración del pipeline)
- Comparación contra baseline de persistencia

## B.3 Métricas
RMSE, MAE, R² y Skill Score vs persistencia.

## B.4 Salida
Resultados consolidados en:
- `SALIDAS_CONSOLIDADAS_CAP3/`
y/o `SALIDAS/` (según organización final).

## B.5 Reproducibilidad
Ver: `06_REPRODUCIBILIDAD/sessionInfo.txt`
