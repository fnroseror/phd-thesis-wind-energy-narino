# 08_utils

Utilidades portables para rutas, dependencias, métricas, exportación y validación estática.

La validación de esta carpeta se ejecuta exclusivamente en R/RStudio:

```r
source("03_CODE/08_utils/06_static_code_validation.R")
```

El validador revisa estructura, rutas absolutas, referencias a datos sintéticos, posibles secretos y tamaño de archivos. No ejecuta ni recalcula modelos científicos.
