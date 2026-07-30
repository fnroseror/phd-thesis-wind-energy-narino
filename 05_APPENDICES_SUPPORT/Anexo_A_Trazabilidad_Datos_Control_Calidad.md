# ANEXO A — Trazabilidad de datos y control de calidad

## Propósito

Documentar la transición desde la fuente meteorológica IDEAM hasta el conjunto analítico estación–hora utilizado para construir velocidad del viento y WPD.

## Cifras canónicas

- 8.175.686 registros meteorológicos brutos.
- 2.218.605 registros válidos de velocidad del viento.
- 365.512 registros analíticos estación–hora de VV/WPD.
- 16 estaciones agrupadas en cuatro zonas.
- Periodo nominal: 2017–2022.
- Disponibilidad efectiva: hasta el 1 de julio de 2022 a las 00:00, hora local de Colombia.

## Controles aplicados

- normalización de nombres, variables y marcas temporales;
- exclusión de fechas inválidas, valores no numéricos, no finitos y velocidades negativas;
- umbral físico de plausibilidad de 75 m/s;
- conservación y cuantificación de velocidades iguales a cero;
- no imputación para la caracterización descriptiva y distribucional;
- consolidación estación–hora;
- construcción jerárquica de densidad del aire:
  `estación-hora → zona-hora → zona-mes → ρref = 1,10 kg/m³`;
- cálculo de WPD mediante `WPD = ½ρv³`.

## Identificador canónico de estación

El código IDEAM es la llave primaria. Los alias gráficos `S01–S16` son auxiliares y no deben emplearse para unir datasets sin verificación explícita.

## Evidencia

Los archivos auditables se encuentran en:

```text
support_files/A_data_quality/
```

Las tablas y figuras incorporadas en la tesis se encuentran en:

```text
../04_RESULTS_COMPLETE/01_physical_characterization/
../04_RESULTS_COMPLETE/07_FIGURES/
../04_RESULTS_COMPLETE/08_TABLES/
```
