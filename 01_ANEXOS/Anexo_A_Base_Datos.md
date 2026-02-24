# Anexo A – Base de datos consolidada (2017–2022)

## A.1 Formato de entrada (sin datos en el repositorio)
Los scripts parten de un dataset mínimo en formato largo con columnas:
**Estación, FechaYHora, Valor, Zona, Variable**.

Este formato se transforma internamente (long → wide) para construir series por zona y variable, y posteriormente calcular variables físicas derivadas.

Referencia: `06_REPRODUCIBILIDAD/data_contract.md`

## A.2 Variables derivadas en el pipeline
A partir de las variables meteorológicas, el pipeline construye:
- **ρ**: densidad del aire
- **WPD**: densidad de potencia eólica
- **Eh**: energía integrada por horizonte

## A.3 Limpieza y control
Incluye:
- Control de NA (imputación/interpolación según ventana válida)
- Consistencia temporal
- Escalamiento (cuando aplica, sin fuga temporal)

## A.4 Salidas esperadas (carpetas)
- `Capitulo 2/` (salidas del análisis físico y espectral)
- `SALIDAS/` (productos de Cap. 3)
- `SALIDAS_CAP4_TDQ_FINAL/` (productos finales TDQ y Cap. 4)
