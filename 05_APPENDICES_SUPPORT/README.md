# 05_APPENDICES_SUPPORT

Esta carpeta implementa los anexos digitales A–H declarados en las páginas 138–139 de la tesis doctoral corregida.

## Regla de autoridad

Los anexos documentan y enlazan la evidencia aprobada. No recalculan resultados ni sustituyen:

1. el PDF exacto remitido a los jurados;
2. los resultados canónicos de `04_RESULTS_COMPLETE`;
3. los scripts trazados de `03_CODE`;
4. los manifiestos y validaciones de `07_REPRODUCIBILITY`.

Los análisis complementarios se conservan separados de las salidas aprobadas.

## Índice

| Anexo | Contenido |
|---|---|
| A | Trazabilidad de datos y control de calidad |
| B | Resultados extendidos de caracterización físico-estadística |
| C | Configuraciones y resultados del pipeline predictivo aprobado |
| D | Congelamiento y reproducibilidad del Capítulo 3 |
| E | Análisis complementario de robustez del Capítulo 3 |
| F | Distinción entre `I_TDQ` y FNRR |
| G | Paquete canónico del Capítulo 4 |
| H | Reproducibilidad computacional en R/RStudio |

## Ejecución de la validación

Desde RStudio:

```r
source("05_APPENDICES_SUPPORT/validate_appendices.R")
```

Resultado esperado:

```text
APPENDICES VALIDATION PASSED
```

## Límites interpretativos

- WPD es la variable física principal.
- TDQ–PIESS/KFAS es un marco físico-estadístico operativo.
- `I_TDQ` es una variable interna del pipeline horario.
- FNRR es un descriptor regional trimestral/anual y no equivale a `I_TDQ`.
- `E_free` y `E_usable` son indicadores por unidad de área; no representan generación eléctrica real, energía libre termodinámica ni energía técnicamente garantizada.
- El escenario 2023–2028 procede de una etapa trimestral separada desde 2022-T3, no de una extensión directa de los horizontes horarios.
