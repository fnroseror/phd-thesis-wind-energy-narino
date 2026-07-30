# Repositorio doctoral | Doctoral thesis repository

## Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas

**Autor:** Favio Nicolás Rosero Rodríguez  
**Programa:** Doctorado en Ciencias – Física  
**Institución:** Universidad Nacional de Colombia, Sede Manizales  
**Ámbito regional:** Departamento de Nariño, Colombia  
**Flujo computacional:** R y RStudio

---

## Estado del repositorio

| Componente | Estado |
|---|---|
| Contenido científico de la tesis | Congelado |
| Carpetas `01`–`07` | Preparadas y documentadas |
| Código y validadores | R/RStudio |
| Figuras científicas | 31/31 indexadas |
| Tablas científicas | 25/25 indexadas |
| Evidencias originales de productos | 129/129 preservadas |
| PDF corregido de la tesis | Pendiente de confirmación de identidad exacta y autorización de publicación |
| Validación mediante clon limpio | Pendiente después de publicar |

La versión ensamblada debe considerarse **candidata de liberación `v1.0.0-rc1`** hasta que el PDF exacto remitido a los jurados sea confirmado y un clon limpio de GitHub produzca la línea:

```text
VALIDATION PASSED
```

El estado operativo completo se documenta en [`REPOSITORY_STATUS.md`](REPOSITORY_STATUS.md).

---

## Resumen científico

La tesis desarrolla y evalúa un marco físico-estadístico para:

1. caracterizar la velocidad del viento en terreno andino complejo;
2. construir la densidad de potencia eólica, WPD;
3. evaluar modelos de pronóstico horario;
4. cuantificar incertidumbre predictiva;
5. formalizar el Factor de No Regularidad Regional, FNRR;
6. construir un escenario energético regional condicionado para 2023–2028.

La fuente observacional comprende:

- **8.175.686** registros meteorológicos brutos;
- **2.218.605** registros válidos de velocidad del viento;
- **365.512** registros analíticos estación–hora;
- **16** estaciones;
- **4** zonas analíticas;
- periodo nominal **2017–2022**, con disponibilidad efectiva hasta el **1 de julio de 2022**.

La variable física central es:

```text
WPD = 0.5 × ρ × v³
```

donde `ρ` es la densidad del aire y `v` la velocidad del viento.

---

## Delimitaciones científicas obligatorias

- **TDQ–PIESS/KFAS** es un marco físico-estadístico operativo; no se presenta como teoría física universal.
- `I_TDQ` es una variable interna del pipeline horario.
- **FNRR** es un descriptor regional de irregularidad y no equivale a `I_TDQ`.
- `E_free` es un indicador anualizado de energía integrada por unidad de área.
- `E_usable` es un indicador estructuralmente modulado mediante `1 − FNRR`.
- Estos indicadores **no representan** generación eléctrica real, energía libre termodinámica ni energía técnicamente garantizada.
- El escenario 2023–2028 procede de una etapa trimestral separada desde 2022-T3; no es una extensión directa de los horizontes horarios `h = 1, 12, 72`.
- La tesis no diseña parques eólicos, no selecciona aerogeneradores y no demuestra factibilidad técnico-económica.

---

## Estructura

```text
phd-thesis-wind-energy-narino/
├── 01_THESIS/
├── 02_DATA_METADATA/
├── 03_CODE/
├── 04_RESULTS_COMPLETE/
├── 05_APPENDICES_SUPPORT/
├── 06_PRODUCTS/
├── 07_REPRODUCIBILITY/
├── 00_check_environment.R
├── 00_validate_repository.R
├── phd-thesis-wind-energy-narino.Rproj
├── CITATION.cff
├── LICENSE.md
├── RELEASE_NOTES.md
├── REPOSITORY_STATUS.md
├── .gitattributes
├── .gitignore
└── README.md
```

### Navegación principal

| Ruta | Función |
|---|---|
| [`01_THESIS/`](01_THESIS/) | Autoridad documental, alcance, contribuciones, citación y control del PDF. |
| [`02_DATA_METADATA/`](02_DATA_METADATA/) | Fuente observacional, estaciones, variables, cobertura, calidad y trazabilidad. |
| [`03_CODE/`](03_CODE/) | Preprocesamiento, caracterización, modelos y proyección en R. |
| [`04_RESULTS_COMPLETE/`](04_RESULTS_COMPLETE/) | Resultados canónicos, figuras, tablas y resultados complementarios separados. |
| [`05_APPENDICES_SUPPORT/`](05_APPENDICES_SUPPORT/) | Anexos digitales A–H y soporte técnico. |
| [`06_PRODUCTS/`](06_PRODUCTS/) | Productos y evidencias originales completas. |
| [`07_REPRODUCIBILITY/`](07_REPRODUCIBILITY/) | Ambiente, manifiestos, protocolos y validación global. |

---

## Inicio rápido en RStudio

### 1. Abrir el proyecto

Abra:

```text
phd-thesis-wind-energy-narino.Rproj
```

### 2. Verificar el entorno

```r
source("00_check_environment.R")
```

### 3. Configurar la fuente observacional autorizada

Las rutas se administran en:

```text
03_CODE/00_config.R
```

La base IDEAM exacta utilizada en la tesis no se distribuye como dato abierto dentro del repositorio. Debe configurarse mediante una ruta local autorizada, sin modificar los resultados canónicos.

### 4. Validar el repositorio

```r
source("00_validate_repository.R")
```

Resultado final requerido:

```text
VALIDATION PASSED
```

La validación global comprueba estructura, hashes, manifiestos, figuras, tablas, estaciones, zonas, productos, evidencias preservadas, tamaños de archivo y enlaces relativos.

---

## Orden científico de ejecución

```text
datos autorizados
→ preprocesamiento estación–hora
→ construcción de ρ y WPD
→ caracterización físico-estadística
→ modelos candidatos
→ integración TDQ–PIESS/KFAS
→ diagnóstico complementario
→ etapa trimestral separada
→ FNRR e indicadores energéticos
→ validación contra resultados canónicos
```

La ejecución no debe utilizarse para redefinir, reoptimizar o sustituir resultados aprobados.

---

## Datos y reproducibilidad

La reproducibilidad tiene dos niveles:

### Reproducibilidad documental

Puede verificarse directamente mediante:

- tablas y figuras canónicas;
- scripts en R;
- manifiestos SHA-256;
- archivos de entorno;
- logs y paquetes de auditoría;
- correspondencia entre tesis, código y resultados.

### Reproducción computacional completa

Requiere:

- la fuente observacional autorizada;
- las dependencias R documentadas;
- recursos computacionales suficientes;
- respeto por las particiones, configuraciones y objetos congelados.

Los límites se detallan en [`07_REPRODUCIBILITY/`](07_REPRODUCIBILITY/).

---

## Tesis en PDF

El PDF corregido no debe reemplazarse, comprimirse ni regenerarse al incorporarlo.

Candidato registrado:

```text
Tesis Doctoral Corregida - 1053833697(6).pdf
SHA-256:
0a5fffefbe7ff394f3e27270050f4849fff42db3d7e38dda274c9f67cee7bb57
```

Antes de publicarlo deben confirmarse:

1. identidad byte a byte con el archivo enviado a los jurados;
2. resolución de la diferencia entre 152 objetos de página PDF y 153 páginas físicas registradas;
3. finalización del control institucional de similitud.

Consulte [`01_THESIS/`](01_THESIS/) y el protocolo de liberación del PDF en [`07_REPRODUCIBILITY/03_protocols/thesis_pdf_release_gate.md`](07_REPRODUCIBILITY/03_protocols/thesis_pdf_release_gate.md).

---

## Productos y evidencias

`06_PRODUCTS` conserva la evidencia original completa, sin anonimización ni eliminación, de acuerdo con la directriz del proyecto.

Esto incluye, según la fuente disponible:

- manuscritos y paquetes editoriales;
- certificados y constancias;
- documentos editables;
- figuras y tablas;
- scripts y archivos de sesión;
- evidencias de trabajos dirigidos;
- soportes del proyecto institucional;
- productos tecnológicos y de apropiación social.

La publicación temporal no impide que terceros clonen, indexen o redistribuyan copias. El aviso operativo se encuentra en [`07_REPRODUCIBILITY/03_protocols/temporary_publication_notice.md`](07_REPRODUCIBILITY/03_protocols/temporary_publication_notice.md).

---

## Citación

GitHub puede leer automáticamente [`CITATION.cff`](CITATION.cff).

La guía ampliada se encuentra en:

```text
01_THESIS/04_citation.md
```

Título de la tesis:

> Rosero Rodríguez, F. N. (2026). *Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas*. Tesis doctoral, Universidad Nacional de Colombia, Sede Manizales.

---

## Licencia y uso

El repositorio contiene una combinación de:

- código de investigación;
- resultados doctorales;
- manuscritos no publicados;
- evidencia institucional;
- documentos con derechos de terceros;
- información personal contenida en soportes originales.

Por ello no se adopta automáticamente una licencia abierta estándar para todo el contenido. Consulte [`LICENSE.md`](LICENSE.md) antes de reutilizar o redistribuir archivos.

---

## Cierre del repositorio

El repositorio se considera cerrado únicamente cuando se cumpla:

```text
tesis remitida
↔ resultados canónicos
↔ código R
↔ figuras y tablas
↔ documentación
↔ manifiestos
↔ clon limpio validado
```

y el clon limpio produzca exactamente:

```text
VALIDATION PASSED
```
