# ANEXO H — Reproducibilidad computacional

## Entorno

El proyecto fue trabajado en R/RStudio. Los scripts ejecutables y validadores del repositorio final deben permanecer en R.

No se incluyen validadores operativos en Python.

## Flujo de reproducción

1. Configurar acceso autorizado a la fuente IDEAM.
2. Definir rutas portables en `03_CODE/00_config.R`.
3. Ejecutar el preprocesamiento y construir el dataset estación–hora.
4. Ejecutar la caracterización físico-estadística.
5. Ejecutar o verificar los modelos candidatos.
6. Verificar las salidas congeladas del pipeline final.
7. Ejecutar diagnósticos complementarios sin sustituir resultados aprobados.
8. Ejecutar la etapa trimestral separada del Capítulo 4.
9. Verificar manifiestos y hashes.
10. Ejecutar el validador global desde una descarga limpia del repositorio.

## Versiones de entorno disponibles

```text
support_files/H_environment/
support_files/D_cap3_freeze/sessionInfo_cap3_congelamiento.txt
support_files/G_cap4_canonical_audit/sessionInfo_cap4.txt
```

## Límites

La reproducción completa depende de la fuente observacional autorizada y de las versiones de paquetes registradas. El repositorio no debe distribuir datos restringidos ni prometer reproducción numérica independiente de esos insumos.

## Validación de esta carpeta

```r
source("05_APPENDICES_SUPPORT/validate_appendices.R")
```
