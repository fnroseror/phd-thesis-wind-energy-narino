# Validación canónica y panel zona-hora — Capítulo 3

- Fecha: 2026-07-22 08:51:01
- Dataset: `E:/Academia/UNAL/DOCTORADO/Versión Final Tesis/Repos/tesis-doctoral-prediccion-energia-eolica-narino/02_capitulo_2_caracterizacion/06_processed/cap2_B_dataset_principal_VV_WPD_QC_articulo1.rds`
- MD5: `b65accec1f4a32992c8a39cebc3b372b`
- Filas: 365.512
- Estaciones: 16
- Zonas: 4
- Rango UTC: 2017-01-01 05:00:00 UTC — 2022-07-01 05:00:00 UTC
- Rango local: 2017-01-01 00:00:00 -05 — 2022-07-01 00:00:00 -05
- WPD coherente con 0.5*rho*VV^3: 100%
- Duplicados estación-hora: 0

## Decisión de agregación

Se adopta como candidato canónico para modelado la media simple de la WPD estación-hora entre las estaciones disponibles de cada zona-hora.
La operación cúbica se realiza antes de agregar y cada estación tiene igual peso en una hora determinada.
La media ponderada por n_vv_original y la mediana se conservan solo para sensibilidad.
La construcción 0.5*media(rho)*media(VV)^3 se clasifica como diagnóstico legacy y no como WPD canónica.

## Imputación

El panel entregado conserva las horas faltantes como NA. No se aplicó interpolación, LOCF ni relleno retrospectivo.
La estrategia de tratamiento causal se definirá dentro del pipeline de modelado y se ajustará exclusivamente con entrenamiento.

## Partición propuesta

- Inicio validación UTC: 2020-04-19 09:00:00 UTC
- Inicio prueba UTC: 2021-05-25 19:00:00 UTC
La partición se asigna según la fecha objetivo t+h.

## Puerta científica

- Estado: **APROBADA**

No iniciar reentrenamiento si la puerta científica no queda completamente aprobada.
