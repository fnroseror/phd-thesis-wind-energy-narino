# Anexo A – Base de datos consolidada (2017–2022)

## Contenido
- Dataset limpio por zonas (NO incluido en GitHub; se describe su estructura).
- Variables: VV, PA, TM, ρ, WPD, Eh.
- Script de limpieza, control de NA y escalamiento.

## Dataset (estructura)
**Archivo local esperado (ejemplo):**
- `data/Datos.txt` (o `.csv`) – dataset consolidado.
- `SALIDAS/WPD_hourly_por_zona.csv` – dataset zonal horario para WPD/Eh (si aplica).

### Columnas mínimas
- `Zona` (int)
- `FechaHora` (POSIXct, tz = America/Bogota)
- `VV`, `PA`, `TM`
- `rho`, `WPD`, `Eh` (derivadas)

## Script asociado
- `04_CODIGO/cap2_cap2_physical_spectral.R` (Capítulo 2 – físico/espectral)
- `04_CODIGO/cap3_cap3_classics_ml.R` / `cap3_cap3_ml_only.R` (si parte de limpieza está allí)
- Ajusta rutas en los encabezados `data_path` / `input_path`.

## Reproducibilidad
- Fijar semilla: `set.seed(123)`
- División temporal estricta (train/val/test).
