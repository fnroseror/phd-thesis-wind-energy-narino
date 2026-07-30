# Auditoría de estabilidad del objeto predictivo — Capítulo 3

- Fecha: 2026-07-22 09:10:53
- Dataset: `E:/Academia/UNAL/DOCTORADO/Versión Final Tesis/Repos/tesis-doctoral-prediccion-energia-eolica-narino/02_capitulo_2_caracterizacion/06_processed/cap2_B_dataset_principal_VV_WPD_QC_articulo1.rds`
- MD5: `b65accec1f4a32992c8a39cebc3b372b`
- Inicio de prueba UTC: 2021-05-25 19:00:00 UTC
- Inicio de prueba local: 2021-05-25 14:00:00 -0500 -05

## Resultado central

La media de las estaciones disponibles no conserva automáticamente el mismo universo observacional entre preprueba y prueba.
Por ello no se adopta como objeto definitivo sin control de composición.
La ruta recomendada es modelar WPD a escala estación-hora y agregar observaciones y predicciones pareadas por zona y horizonte.

## Estaciones dominantes en preprueba

- Zona 1: estación 51025060 aporta 99.76% de la suma temporal de la media zonal.
- Zona 2: estación 52055160 aporta 67.82% de la suma temporal de la media zonal.
- Zona 3: estación 52055150 aporta 81.16% de la suma temporal de la media zonal.
- Zona 4: estación 52035040 aporta 98.37% de la suma temporal de la media zonal.

## Estaciones con soporte mínimo en los tres horizontes

- Zona 1: 3 estación(es): 5102500128|51025090|51035020
- Zona 2: 3 estación(es): 52055170|52055220|52055230
- Zona 3: 3 estación(es): 47015100|52045080|52055210
- Zona 4: 1 estación(es): 52035040

## Decisión

- **APROBADO para construir el pipeline estación-horizonte pareado** con 10 estaciones elegibles.
- El pipeline histórico y sus resultados se conservan como evidencia legacy.
- Este script no entrenó modelos ni modificó resultados.

