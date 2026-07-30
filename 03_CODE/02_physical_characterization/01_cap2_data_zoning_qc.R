# ============================================================
# CAPITULO 2 — Parte A
# Tesis doctoral
# Favio Nicolás Rosero Rodríguez
# ============================================================
#
# Propósito:
#   Ejecutar en un único archivo lo que ya quedó consolidado para
#   el Capítulo 2:
#
#   BLOQUE 01:
#   - lectura de datos
#   - normalización temporal
#   - auditoría de fuente
#   - verificación de 16 estaciones y 4 zonas
#   - control de calidad de VV
#   - cobertura temporal por estación y por zona
#   - disponibilidad mensual
#   - proporción de ceros
#   - figuras y tablas finales del bloque
#
#   BLOQUE 01B:
#   - mapa final del Artículo 1 en español para la tesis
#   - manteniendo composición y estilo del mapa original
#
# Nota:
#   Este archivo unifica únicamente lo que ya quedó funcional y
#   auditado para el Capítulo 2. Los siguientes análisis
#   (descriptivos multizona, WPD, Weibull/Rayleigh, ACF/PACF,
#   FFT y Wavelet) se integrarán después en nuevos bloques.
#
# Ejecución recomendada:
#   source("<configured-path>")
#
# ============================================================

options(warn = 1)

cat("\n============================================================\n")
cat("CAPÍTULO 2 — SCRIPT MAESTRO UNIFICADO\n")
cat("Inicio:", as.character(Sys.time()), "\n")
cat("============================================================\n\n")

# ============================================================
# SECCIÓN A
# DATOS, ZONIFICACIÓN, QC Y FIGURAS/TABLAS DEL BLOQUE 01
# ============================================================

# ============================================================
# 01_cap2_datos_zonificacion_qc_FINAL.R
# CAPÍTULO 2 — DATOS, ZONIFICACIÓN, QC Y MAPA EN ESPAÑOL
# Tesis doctoral: Estudio de la velocidad de viento e inclusión
# de parámetros físicos para la predicción de energía eléctrica
# producida por fuentes eólicas
# Autor: Favio Nicolás Rosero Rodríguez
# ============================================================
#
# Estado:
#   Versión limpia y definitiva del bloque 01 del Capítulo 2,
#   consolidada a partir de lo que ya funcionó en V3.
#
# Decisiones incorporadas:
#   1. Se usa parser de fecha dmy porque fue el parser validado en la corrida V3.
#   2. Se conserva solo el periodo doctoral 2017–2022.
#   3. Se verifica la estructura real de 16 estaciones y 4 zonas.
#   4. Se calcula cobertura temporal real por días con VV válido.
#   5. Se documenta proporción de ceros en velocidad del viento.
#   6. Se corrige disponibilidad mensual usando fecha_mes como Date.
#   7. Se intenta regenerar el mapa del Artículo 1 en español.
#      Si no hay coordenadas, se copia el mapa del Artículo 1 como referencia
#      y se genera plantilla para completar coordenadas.
#
# Importante:
#   Este script NO inventa coordenadas.
#   Para regenerar el mapa en español se requiere un archivo:
#      stations_zones_narino.csv
#   con columnas:
#      station_code, station_name, latitude, longitude, zone
#
# ============================================================

rm(list = ls())
gc()

source(file.path("03_CODE", "00_config.R"))


# ============================================================
# 1. RUTAS OFICIALES
# ============================================================

DATA_FILE <- TDQ_DATA_FILE

SOURCE_REPO <- TDQ_REPO_ROOT

ARTICLE_ROOT <- file.path(
  SOURCE_REPO,
  "06_PRODUCTS",
  "01_articles",
  "article_01_energy_reports"
)

CAP_DIR <- file.path(TDQ_WORK_DIR, "02_physical_characterization")

DIR_INPUTS    <- file.path(CAP_DIR, "00_inputs")
DIR_CODE      <- file.path(CAP_DIR, "01_code")
DIR_TABLES    <- file.path(CAP_DIR, "02_tables")
DIR_FIGURES   <- file.path(CAP_DIR, "03_figures")
DIR_TEXTOS    <- file.path(CAP_DIR, "04_textos_para_insertar")
DIR_LOGS      <- file.path(CAP_DIR, "05_logs")
DIR_PROCESSED <- file.path(CAP_DIR, "06_processed")
DIR_MAP_CACHE <- file.path(CAP_DIR, "07_map_cache")

dirs <- c(
  CAP_DIR, DIR_INPUTS, DIR_CODE, DIR_TABLES, DIR_FIGURES,
  DIR_TEXTOS, DIR_LOGS, DIR_PROCESSED, DIR_MAP_CACHE
)

invisible(lapply(dirs, dir.create, recursive = TRUE, showWarnings = FALSE))

# ============================================================
# 2. PAQUETES
# ============================================================

required_packages <- c(
  "data.table",
  "dplyr",
  "tidyr",
  "tibble",
  "stringr",
  "lubridate",
  "ggplot2",
  "scales",
  "readr",
  "knitr",
  "ragg",
  "svglite"
)

optional_map_packages <- c(
  "sf",
  "terra",
  "geodata",
  "ggrepel",
  "ggspatial",
  "ggnewscale"
)

install_if_missing <- function(pkgs, required = TRUE) {
  missing <- pkgs[!pkgs %in% rownames(installed.packages())]
  if (length(missing) > 0) {
    for (pkg in missing) {
      tryCatch(
        install.packages(pkg, dependencies = TRUE),
        error = function(e) {
          message("No se pudo instalar paquete: ", pkg, " | ", e$message)
          if (required) stop(e)
        }
      )
    }
  }
}

install_if_missing(required_packages, required = TRUE)
install_if_missing(optional_map_packages, required = FALSE)

suppressPackageStartupMessages({
  invisible(lapply(required_packages, library, character.only = TRUE))
  library(grid)
})

HAY_MAPA <- all(optional_map_packages %in% rownames(installed.packages()))

if (HAY_MAPA) {
  suppressPackageStartupMessages({
    invisible(lapply(optional_map_packages, library, character.only = TRUE))
  })
}

# Operador auxiliar seguro
`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0) y else x
}

# ============================================================
# 3. CONFIGURACIÓN DOCTORAL
# ============================================================

CFG <- list(
  TZ = "America/Bogota",
  TARGET_VAR = "VV",
  FORCE_DATE_PARSER = "dmy",
  MIN_VV = 0,
  MAX_VV_PLAUSIBLE = 75,
  EXPECTED_STATIONS = 16,
  STUDY_START = as.POSIXct("2017-01-01 00:00:00", tz = "America/Bogota"),
  STUDY_END   = as.POSIXct("2023-01-01 00:00:00", tz = "America/Bogota"),
  PERIOD_LABEL = "2017–2022",
  FIG_DPI = 900
)

# ============================================================
# 4. ESTILO EDITORIAL
# ============================================================

if (.Platform$OS.type == "windows") {
  try(
    grDevices::windowsFonts(Garamond = grDevices::windowsFont("Garamond")),
    silent = TRUE
  )
}

FONT_FAMILY <- ifelse(.Platform$OS.type == "windows", "Garamond", "serif")

COL_NAVY      <- "#0D4B73"
COL_TEAL      <- "#26A69A"
COL_GREEN     <- "#38B66F"
COL_GOLD      <- "#E0A100"
COL_ORANGE    <- "#E98321"
COL_PURPLE    <- "#6C5CE7"
COL_BLUE      <- "#2F7EB8"
COL_RED       <- "#D04A36"

COL_TEXT      <- "#2F2F2F"
COL_SOFTTEXT  <- "#5A5A5A"
COL_BORDER    <- "#4C6272"
COL_LIGHTGREY <- "#F4F6F7"

pal_zona <- c(
  "1" = COL_NAVY,
  "2" = COL_TEAL,
  "3" = COL_GREEN,
  "4" = COL_GOLD
)

theme_cap2 <- function(base_size = 22) {
  ggplot2::theme_minimal(base_size = base_size, base_family = FONT_FAMILY) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_line(linewidth = 0.25, colour = "grey88"),
      axis.title = ggplot2::element_text(face = "bold", size = base_size + 1),
      axis.text  = ggplot2::element_text(size = base_size - 2, colour = COL_TEXT),
      strip.text = ggplot2::element_text(face = "bold", size = base_size),
      legend.position = "bottom",
      legend.title = ggplot2::element_text(face = "bold", size = base_size - 1),
      legend.text  = ggplot2::element_text(size = base_size - 2),
      plot.title = ggplot2::element_text(
        size = 40,
        face = "bold",
        hjust = 0.5,
        colour = COL_TEXT,
        margin = ggplot2::margin(b = 6)
      ),
      plot.subtitle = ggplot2::element_text(
        size = 21,
        hjust = 0.5,
        colour = COL_SOFTTEXT,
        margin = ggplot2::margin(b = 10)
      ),
      plot.caption = ggplot2::element_text(
        size = 14,
        hjust = 1,
        colour = COL_SOFTTEXT
      ),
      plot.background = ggplot2::element_rect(fill = "white", colour = NA),
      panel.background = ggplot2::element_rect(fill = "white", colour = NA),
      plot.margin = ggplot2::margin(20, 25, 20, 25)
    )
}

theme_map_cap2 <- function(base_size = 17) {
  ggplot2::theme_minimal(base_size = base_size, base_family = FONT_FAMILY) +
    ggplot2::theme(
      panel.grid.major = ggplot2::element_line(colour = "grey85", linewidth = 0.25),
      panel.grid.minor = ggplot2::element_blank(),
      axis.title = ggplot2::element_blank(),
      axis.text = ggplot2::element_text(size = base_size - 1, colour = COL_TEXT),
      legend.position = "right",
      legend.title = ggplot2::element_text(face = "bold", size = base_size),
      legend.text = ggplot2::element_text(size = base_size - 1),
      plot.title = ggplot2::element_text(
        size = 36,
        face = "bold",
        hjust = 0.5,
        colour = COL_TEXT
      ),
      plot.subtitle = ggplot2::element_text(
        size = 19,
        hjust = 0.5,
        colour = COL_SOFTTEXT
      ),
      plot.caption = ggplot2::element_text(
        size = 12,
        hjust = 1,
        colour = COL_SOFTTEXT
      ),
      plot.background = ggplot2::element_rect(fill = "white", colour = NA),
      panel.background = ggplot2::element_rect(fill = "white", colour = NA),
      plot.margin = ggplot2::margin(15, 15, 15, 15)
    )
}

# ============================================================
# 5. LOG Y EXPORTACIÓN
# ============================================================

LOG_FILE <- file.path(
  DIR_LOGS,
  paste0("log_cap2_01_FINAL_datos_zonificacion_qc_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".txt")
)

logi <- function(...) {
  msg <- paste(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "|", paste(..., collapse = " "))
  cat(msg, "\n")
  cat(msg, "\n", file = LOG_FILE, append = TRUE)
}

exportar_tabla <- function(df, nombre_archivo) {
  ruta_csv <- file.path(DIR_TABLES, paste0(nombre_archivo, ".csv"))
  ruta_md  <- file.path(DIR_TABLES, paste0(nombre_archivo, ".md"))
  
  data.table::fwrite(as.data.frame(df), ruta_csv, bom = TRUE)
  writeLines(knitr::kable(as.data.frame(df), format = "markdown"), ruta_md, useBytes = TRUE)
  
  logi("Tabla exportada:", ruta_csv)
}

exportar_figura <- function(plot_obj, nombre_archivo, width = 18, height = 11, dpi = CFG$FIG_DPI) {
  ruta_png <- file.path(DIR_FIGURES, paste0(nombre_archivo, ".png"))
  ruta_pdf <- file.path(DIR_FIGURES, paste0(nombre_archivo, ".pdf"))
  ruta_svg <- file.path(DIR_FIGURES, paste0(nombre_archivo, ".svg"))
  
  ragg::agg_png(
    filename = ruta_png,
    width = width,
    height = height,
    units = "in",
    res = dpi,
    background = "white"
  )
  print(plot_obj)
  dev.off()
  
  ggplot2::ggsave(
    filename = ruta_pdf,
    plot = plot_obj,
    width = width,
    height = height,
    bg = "white",
    device = grDevices::cairo_pdf
  )
  
  ggplot2::ggsave(
    filename = ruta_svg,
    plot = plot_obj,
    width = width,
    height = height,
    bg = "white",
    device = svglite::svglite
  )
  
  logi("Figura exportada:", ruta_png)
}

# ============================================================
# 6. FUNCIONES DE LECTURA Y FECHA
# ============================================================

limpiar_nombre_columna <- function(x) {
  x <- stringr::str_replace_all(x, "á", "a")
  x <- stringr::str_replace_all(x, "é", "e")
  x <- stringr::str_replace_all(x, "í", "i")
  x <- stringr::str_replace_all(x, "ó", "o")
  x <- stringr::str_replace_all(x, "ú", "u")
  x <- stringr::str_replace_all(x, "ñ", "n")
  x <- stringr::str_replace_all(x, "Á", "A")
  x <- stringr::str_replace_all(x, "É", "E")
  x <- stringr::str_replace_all(x, "Í", "I")
  x <- stringr::str_replace_all(x, "Ó", "O")
  x <- stringr::str_replace_all(x, "Ú", "U")
  x <- stringr::str_replace_all(x, "Ñ", "N")
  x <- stringr::str_trim(x)
  x
}

read_any_delim <- function(path) {
  if (!file.exists(path)) stop("No existe DATA_FILE: ", path)
  
  intentos <- list(
    function() data.table::fread(path, sep = "\t", header = TRUE, data.table = TRUE, showProgress = TRUE, encoding = "UTF-8"),
    function() data.table::fread(path, sep = ";",  header = TRUE, data.table = TRUE, showProgress = TRUE, encoding = "UTF-8"),
    function() data.table::fread(path, sep = ",",  header = TRUE, data.table = TRUE, showProgress = TRUE, encoding = "UTF-8"),
    function() data.table::fread(path, sep = "|",  header = TRUE, data.table = TRUE, showProgress = TRUE, encoding = "UTF-8"),
    function() data.table::fread(path, header = TRUE, data.table = TRUE, showProgress = TRUE, encoding = "UTF-8")
  )
  
  for (f in intentos) {
    dt <- tryCatch(f(), error = function(e) NULL)
    if (!is.null(dt) && ncol(dt) > 1) return(dt)
  }
  
  stop("No fue posible leer el archivo con delimitadores comunes.")
}

manual_parse_datetime <- function(x, order = "dmy", tz = CFG$TZ) {
  x <- as.character(x)
  x <- stringr::str_squish(x)
  x <- stringr::str_replace_all(x, "T", " ")
  
  date_part <- sub("\\s+.*$", "", x)
  time_part <- ifelse(grepl("\\s+", x), sub("^\\S+\\s+", "", x), "00:00:00")
  
  date_part <- gsub("[-.]", "/", date_part)
  parts <- data.table::tstrsplit(date_part, "/", fixed = TRUE, fill = NA)
  
  a <- suppressWarnings(as.integer(parts[[1]]))
  b <- suppressWarnings(as.integer(parts[[2]]))
  c <- suppressWarnings(as.integer(parts[[3]]))
  
  if (order == "ymd") {
    yy <- a; mm <- b; dd <- c
  } else if (order == "dmy") {
    dd <- a; mm <- b; yy <- c
  } else if (order == "mdy") {
    mm <- a; dd <- b; yy <- c
  } else {
    stop("Orden de fecha no soportado.")
  }
  
  yy <- ifelse(!is.na(yy) & yy < 100, 2000 + yy, yy)
  
  time_part <- gsub("\\..*$", "", time_part)
  tparts <- data.table::tstrsplit(time_part, ":", fixed = TRUE, fill = "0")
  
  HH <- suppressWarnings(as.integer(tparts[[1]]))
  MM <- suppressWarnings(as.integer(tparts[[2]]))
  SS <- suppressWarnings(as.integer(tparts[[3]]))
  
  HH[is.na(HH)] <- 0L
  MM[is.na(MM)] <- 0L
  SS[is.na(SS)] <- 0L
  
  valid <- !is.na(yy) &
    !is.na(mm) &
    !is.na(dd) &
    yy >= 1900 &
    yy <= 2100 &
    mm >= 1 &
    mm <= 12 &
    dd >= 1 &
    dd <= 31 &
    HH >= 0 &
    HH <= 23 &
    MM >= 0 &
    MM <= 59 &
    SS >= 0 &
    SS <= 59
  
  out <- rep(as.POSIXct(NA, tz = tz), length(x))
  
  iso_string <- sprintf("%04d-%02d-%02d %02d:%02d:%02d", yy, mm, dd, HH, MM, SS)
  
  out[valid] <- suppressWarnings(as.POSIXct(
    iso_string[valid],
    format = "%Y-%m-%d %H:%M:%S",
    tz = tz
  ))
  
  out
}

normalizar_base <- function(dt_raw) {
  nombres_originales <- names(dt_raw)
  nombres_limpios <- limpiar_nombre_columna(nombres_originales)
  data.table::setnames(dt_raw, nombres_originales, nombres_limpios)
  
  renombrar_si_existe <- function(viejos, nuevo) {
    existe <- viejos[viejos %in% names(dt_raw)]
    if (length(existe) > 0 && !(nuevo %in% names(dt_raw))) {
      data.table::setnames(dt_raw, existe[1], nuevo)
    }
  }
  
  renombrar_si_existe(c("Estación", "Estacion", "station", "Station", "CodigoEstacion", "codigo_estacion"), "Estacion")
  renombrar_si_existe(c("FechaYHora", "Fecha Hora", "Fecha_Hora", "Fecha", "datetime", "DateTime"), "FechaYHora")
  renombrar_si_existe(c("Valor", "value", "Value", "Dato", "Medicion"), "Valor")
  renombrar_si_existe(c("Zona", "zone", "Zone"), "Zona")
  renombrar_si_existe(c("Variable", "variable", "var", "parametro"), "Variable")
  
  requeridas <- c("Estacion", "FechaYHora", "Valor", "Zona", "Variable")
  faltantes <- setdiff(requeridas, names(dt_raw))
  
  if (length(faltantes) > 0) {
    stop(
      "Faltan columnas requeridas en Datos.txt: ",
      paste(faltantes, collapse = ", "),
      ". Columnas detectadas: ",
      paste(names(dt_raw), collapse = ", ")
    )
  }
  
  dt_raw[, raw_datetime_string := as.character(FechaYHora)]
  dt_raw[, raw_datetime_string := stringr::str_squish(raw_datetime_string)]
  
  logi("Usando parser de fecha validado:", CFG$FORCE_DATE_PARSER)
  dt_raw[, FechaYHora := manual_parse_datetime(raw_datetime_string, order = CFG$FORCE_DATE_PARSER)]
  
  dt_raw[, Estacion := as.character(Estacion)]
  dt_raw[, Variable := as.character(Variable)]
  dt_raw[, Variable_clean := Variable |>
           stringr::str_to_upper() |>
           stringr::str_replace_all("[^A-Z0-9_]", "_") |>
           stringr::str_replace_all("_+", "_") |>
           stringr::str_remove("^_") |>
           stringr::str_remove("_$")]
  
  dt_raw[, Zona := suppressWarnings(as.integer(stringr::str_extract(as.character(Zona), "\\d+")))]
  dt_raw[, Valor := suppressWarnings(as.numeric(gsub(",", ".", as.character(Valor))))]
  dt_raw[, parser_usado := CFG$FORCE_DATE_PARSER]
  
  data.table::setorder(dt_raw, Zona, Estacion, Variable_clean, FechaYHora)
  dt_raw
}

calc_resolution_min <- function(fechas) {
  fechas <- sort(unique(fechas[!is.na(fechas)]))
  if (length(fechas) < 3) return(NA_real_)
  as.numeric(stats::median(diff(fechas), na.rm = TRUE), units = "mins")
}

# ============================================================
# 7. METADATA DE ESTACIONES Y MAPA
# ============================================================

metadata_template <- tibble::tribble(
  ~zone, ~station_code, ~station_id, ~station_name, ~municipality, ~altitude_group_m_asl, ~latitude, ~longitude,
  1, "5102500128", "S01", "Reserva Natural La Planada", "Barbacoas / Ricaurte", "1–1835", NA_real_, NA_real_,
  1, "51025060",   "S02", "Biotopo", "Barbacoas / Ricaurte", "1–1835", NA_real_, NA_real_,
  1, "51025080",   "S03", "Altaquer", "Barbacoas / Ricaurte", "1–1835", NA_real_, NA_real_,
  1, "51025090",   "S04", "Granja Mira", "Barbacoas / Ricaurte", "1–1835", NA_real_, NA_real_,
  1, "51035020",   "S05", "CCCP DI Pacífico", "Tumaco", "1–1835", NA_real_, NA_real_,
  2, "52055160",   "S06", "Volcán Chiles", "Cumbal", "442–3120", NA_real_, NA_real_,
  2, "52055170",   "S07", "La Josefina", "Contadero", "442–3120", NA_real_, NA_real_,
  2, "52055220",   "S08", "El Paraíso", "Aldana / Túquerres", "442–3120", NA_real_, NA_real_,
  2, "52055230",   "S09", "Aeropuerto San Luis", "Ipiales / Aldana", "442–3120", NA_real_, NA_real_,
  3, "47015100",   "S10", "El Encano", "Pasto", "2626–3585", NA_real_, NA_real_,
  3, "52045080",   "S11", "Universidad de Nariño", "Pasto", "2626–3585", NA_real_, NA_real_,
  3, "5205500123", "S12", "Las Iglesias", "Puerres", "2626–3585", NA_real_, NA_real_,
  3, "52055150",   "S13", "Cerro Páramo", "Pasto / Puerres", "2626–3585", NA_real_, NA_real_,
  3, "52055210",   "S14", "Botana", "Pasto", "2626–3585", NA_real_, NA_real_,
  4, "52035040",   "S15", "Viento Libre", "El Tablón", "1400–1800", NA_real_, NA_real_,
  4, "52040050",   "S16", "Aponte", "Taminango", "1400–1800", NA_real_, NA_real_
)

normalizar_metadata_estaciones <- function(md) {
  names(md) <- limpiar_nombre_columna(names(md))
  names(md) <- stringr::str_replace_all(names(md), "\\s+", "_")
  
  ren <- function(old, new) {
    hit <- old[old %in% names(md)]
    if (length(hit) > 0 && !(new %in% names(md))) names(md)[names(md) == hit[1]] <<- new
  }
  
  ren(c("station_code", "codigo_estacion", "codigo", "estacion", "Estacion"), "station_code")
  ren(c("station_name", "nombre_estacion", "nombre", "estacion_nombre"), "station_name")
  ren(c("station_id", "id_estacion", "id"), "station_id")
  ren(c("zone", "zona", "analytical_zone"), "zone")
  ren(c("latitude", "latitud", "lat"), "latitude")
  ren(c("longitude", "longitud", "lon", "lng"), "longitude")
  ren(c("municipality", "municipio", "municipalities"), "municipality")
  ren(c("altitude_group_m_asl", "altitude_range_m_asl", "altitud", "altitude"), "altitude_group_m_asl")
  
  if (!"station_code" %in% names(md)) stop("La metadata no tiene station_code/codigo_estacion/estacion.")
  if (!"station_name" %in% names(md)) md$station_name <- md$station_code
  if (!"zone" %in% names(md)) md$zone <- NA_integer_
  if (!"station_id" %in% names(md)) md$station_id <- sprintf("S%02d", seq_len(nrow(md)))
  if (!"municipality" %in% names(md)) md$municipality <- NA_character_
  if (!"latitude" %in% names(md)) md$latitude <- NA_real_
  if (!"longitude" %in% names(md)) md$longitude <- NA_real_
  if (!"altitude_group_m_asl" %in% names(md)) md$altitude_group_m_asl <- NA_character_
  
  md <- md %>%
    dplyr::mutate(
      station_code = as.character(station_code),
      station_name = as.character(station_name),
      station_id = as.character(station_id),
      zone = as.integer(stringr::str_extract(as.character(zone), "\\d+")),
      latitude = suppressWarnings(as.numeric(latitude)),
      longitude = suppressWarnings(as.numeric(longitude)),
      municipality = as.character(municipality),
      altitude_group_m_asl = as.character(altitude_group_m_asl)
    )
  
  tibble::as_tibble(md)
}

expandir_tabla_articulo_estaciones <- function(path_csv) {
  if (!file.exists(path_csv)) return(NULL)
  
  ztab <- readr::read_csv(path_csv, show_col_types = FALSE)
  
  if (!all(c("analytical_zone", "station_ids", "station_codes", "station_names") %in% names(ztab))) {
    return(NULL)
  }
  
  out <- list()
  
  for (i in seq_len(nrow(ztab))) {
    zone_num <- as.integer(stringr::str_extract(ztab$analytical_zone[i], "\\d+"))
    
    ids <- stringr::str_split(ztab$station_ids[i], ";\\s*")[[1]]
    codes <- stringr::str_split(ztab$station_codes[i], ";\\s*")[[1]]
    names_st <- stringr::str_split(ztab$station_names[i], ";\\s*")[[1]]
    
    municipalities <- if ("municipalities" %in% names(ztab)) ztab$municipalities[i] else NA_character_
    altitude <- if ("altitude_range_m_asl" %in% names(ztab)) ztab$altitude_range_m_asl[i] else NA_character_
    
    out[[i]] <- tibble::tibble(
      zone = zone_num,
      station_id = ids,
      station_code = codes,
      station_name = names_st,
      municipality = municipalities,
      altitude_group_m_asl = altitude,
      latitude = NA_real_,
      longitude = NA_real_
    )
  }
  
  dplyr::bind_rows(out)
}

buscar_metadata_estaciones <- function() {
  candidatos <- c(
    file.path(DIR_INPUTS, "stations_zones_narino.csv"),
    file.path(DIR_INPUTS, "estaciones_zonas_narino.csv"),
    file.path(DIR_INPUTS, "Fig_01_station_key_for_map.csv"),
    file.path(ARTICLE_ROOT, "01_data_processed", "stations_zones_narino.csv"),
    file.path(ARTICLE_ROOT, "03_figures", "publication_ready_final", "Fig_01_station_key_for_map.csv"),
    file.path(ARTICLE_ROOT, "03_figures", "publication_ready_final", "stations_zones_narino.csv")
  )
  
  existentes <- candidatos[file.exists(candidatos)]
  
  if (length(existentes) > 0) {
    logi("Metadata de estaciones encontrada:", existentes[1])
    md <- readr::read_csv(existentes[1], show_col_types = FALSE)
    md <- normalizar_metadata_estaciones(md)
    return(md)
  }
  
  tabla_articulo <- file.path(
    ARTICLE_ROOT,
    "04_tables",
    "main_text",
    "Table_01_IDEAM_meteorological_stations_and_analytical_zoning.csv"
  )
  
  md_art <- expandir_tabla_articulo_estaciones(tabla_articulo)
  
  if (!is.null(md_art)) {
    logi("Metadata sin coordenadas expandida desde Tabla 01 del Artículo 1:", tabla_articulo)
    ruta_md_art <- file.path(DIR_INPUTS, "stations_zones_narino_from_article1_TABLE01_sin_coordenadas.csv")
    readr::write_csv(md_art, ruta_md_art)
    return(normalizar_metadata_estaciones(md_art))
  }
  
  ruta_template <- file.path(DIR_INPUTS, "stations_zones_narino_TEMPLATE_COMPLETAR_COORDENADAS.csv")
  readr::write_csv(metadata_template, ruta_template)
  logi("No se encontró metadata. Se creó plantilla:", ruta_template)
  normalizar_metadata_estaciones(metadata_template)
}

copiar_mapa_articulo_referencia <- function() {
  candidatos <- c(
    file.path(ARTICLE_ROOT, "03_figures", "main_text", "Fig_01_physiographic_setting_zoning_narino_FINAL.tiff"),
    file.path(ARTICLE_ROOT, "03_figures", "publication_ready_final", "Fig_01_physiographic_setting_zoning_narino_FINAL.tiff")
  )
  
  existentes <- candidatos[file.exists(candidatos)]
  
  if (length(existentes) == 0) return(FALSE)
  
  destino <- file.path(DIR_FIGURES, "Fig_Cap2_01_Mapa_Articulo1_REFERENCIA_original_ingles.tiff")
  file.copy(existentes[1], destino, overwrite = TRUE)
  logi("Mapa original del Artículo 1 copiado como referencia:", destino)
  TRUE
}

crear_mapa_espanol_si_hay_coord <- function(tabla_estaciones_final) {
  if (!HAY_MAPA) {
    logi("Mapa en español no generado: paquetes cartográficos no disponibles.")
    return(FALSE)
  }
  
  stations <- as.data.frame(tabla_estaciones_final) %>%
    dplyr::filter(
      !is.na(latitud),
      !is.na(longitud),
      is.finite(latitud),
      is.finite(longitud)
    ) %>%
    dplyr::mutate(
      Zona = factor(as.character(Zona), levels = c("1", "2", "3", "4")),
      etiqueta = paste0(id_estacion, " · Z", Zona)
    )
  
  if (nrow(stations) == 0) {
    logi("Mapa en español no generado: no hay coordenadas en metadata.")
    return(FALSE)
  }
  
  logi("Generando mapa en español con", nrow(stations), "estaciones con coordenadas.")
  
  stations_sf <- sf::st_as_sf(
    stations,
    coords = c("longitud", "latitud"),
    crs = 4326,
    remove = FALSE
  )
  
  colombia_admin1 <- geodata::gadm(country = "COL", level = 1, path = DIR_MAP_CACHE)
  colombia_admin2 <- geodata::gadm(country = "COL", level = 2, path = DIR_MAP_CACHE)
  
  colombia_sf <- sf::st_as_sf(colombia_admin1)
  municipios_sf <- sf::st_as_sf(colombia_admin2)
  
  narino_sf <- colombia_sf %>%
    dplyr::filter(stringr::str_detect(stringr::str_to_lower(NAME_1), "nari"))
  
  narino_muni_sf <- municipios_sf %>%
    dplyr::filter(stringr::str_detect(stringr::str_to_lower(NAME_1), "nari"))
  
  if (nrow(narino_sf) == 0 || nrow(narino_muni_sf) == 0) {
    logi("Mapa en español no generado: no se encontró Nariño en GADM.")
    return(FALSE)
  }
  
  bbox_nar <- sf::st_bbox(narino_sf)
  xrange <- as.numeric(bbox_nar["xmax"] - bbox_nar["xmin"])
  yrange <- as.numeric(bbox_nar["ymax"] - bbox_nar["ymin"])
  
  xmin_ext <- as.numeric(bbox_nar["xmin"]) - 0.08 * xrange
  xmax_ext <- as.numeric(bbox_nar["xmax"]) + 0.05 * xrange
  ymin_ext <- as.numeric(bbox_nar["ymin"]) - 0.05 * yrange
  ymax_ext <- as.numeric(bbox_nar["ymax"]) + 0.05 * yrange
  
  dem_colombia <- geodata::elevation_30s(country = "COL", path = DIR_MAP_CACHE)
  ext_terra <- terra::ext(xmin_ext, xmax_ext, ymin_ext, ymax_ext)
  dem_crop <- terra::crop(dem_colombia, ext_terra)
  names(dem_crop) <- "elevation_m"
  
  dem_smooth <- terra::focal(dem_crop, w = matrix(1, 3, 3), fun = mean, na.policy = "omit")
  names(dem_smooth) <- "elevation_m"
  
  slope <- terra::terrain(dem_smooth, v = "slope", unit = "radians")
  aspect <- terra::terrain(dem_smooth, v = "aspect", unit = "radians")
  hill <- terra::shade(slope, aspect, angle = 40, direction = 315)
  names(hill) <- "hillshade"
  
  dem_df <- as.data.frame(dem_smooth, xy = TRUE, na.rm = TRUE)
  hill_df <- as.data.frame(hill, xy = TRUE, na.rm = TRUE)
  
  names(dem_df) <- c("x", "y", "elevation_m")
  names(hill_df) <- c("x", "y", "hillshade")
  
  p_map <- ggplot() +
    geom_raster(
      data = hill_df,
      aes(x = x, y = y, alpha = hillshade),
      fill = "grey20"
    ) +
    scale_alpha(range = c(0.05, 0.35), guide = "none") +
    ggnewscale::new_scale_fill() +
    geom_raster(
      data = dem_df,
      aes(x = x, y = y, fill = elevation_m),
      alpha = 0.60
    ) +
    scale_fill_gradientn(
      colours = c("#EAF4FB", "#D9EAD3", "#F4E2B8", "#C7B299", "#8C7A6B"),
      name = "Elevación\n(m s.n.m.)",
      labels = scales::label_number(big.mark = ".")
    ) +
    ggnewscale::new_scale_fill() +
    geom_sf(
      data = narino_muni_sf,
      fill = NA,
      colour = "white",
      linewidth = 0.25,
      alpha = 0.65
    ) +
    geom_sf(
      data = narino_sf,
      fill = NA,
      colour = COL_BORDER,
      linewidth = 1.05
    ) +
    geom_sf(
      data = stations_sf,
      aes(fill = Zona),
      shape = 21,
      colour = "black",
      size = 4.8,
      stroke = 0.9
    ) +
    ggrepel::geom_text_repel(
      data = stations,
      aes(x = longitud, y = latitud, label = etiqueta, colour = Zona),
      family = FONT_FAMILY,
      fontface = "bold",
      size = 5.0,
      box.padding = 0.35,
      point.padding = 0.22,
      min.segment.length = 0,
      segment.size = 0.30,
      segment.color = "grey35",
      max.overlaps = 60,
      show.legend = FALSE
    ) +
    scale_fill_manual(values = pal_zona, name = "Zona") +
    scale_colour_manual(values = pal_zona, guide = "none") +
    ggspatial::annotation_scale(
      location = "bl",
      width_hint = 0.28,
      text_family = FONT_FAMILY
    ) +
    ggspatial::annotation_north_arrow(
      location = "tl",
      which_north = "true",
      style = ggspatial::north_arrow_fancy_orienteering(text_family = FONT_FAMILY),
      height = unit(1.15, "cm"),
      width = unit(1.15, "cm")
    ) +
    coord_sf(
      xlim = c(xmin_ext, xmax_ext),
      ylim = c(ymin_ext, ymax_ext),
      expand = FALSE
    ) +
    labs(
      title = "Zonificación analítica y red de estaciones IDEAM en Nariño",
      subtitle = "Contexto fisiográfico, estaciones meteorológicas y cuatro zonas de caracterización eólica",
      caption = "Fuente: elaboración propia con datos IDEAM y GADM/GEODATA. La zonificación corresponde a agrupación analítica de estaciones."
    ) +
    theme_map_cap2(base_size = 17)
  
  exportar_figura(
    p_map,
    "Fig_Cap2_01_Mapa_Zonificacion_Estaciones_Narino_ES_FINAL",
    width = 18,
    height = 14
  )
  
  TRUE
}

# ============================================================
# 8. EJECUCIÓN: LECTURA Y NORMALIZACIÓN
# ============================================================

logi("============================================================")
logi("CAPÍTULO 2 — BLOQUE 01 FINAL")
logi("Inicio:", as.character(Sys.time()))
logi("DATA_FILE:", DATA_FILE)
logi("SOURCE_REPO:", SOURCE_REPO)
logi("ARTICLE_ROOT:", ARTICLE_ROOT)
logi("CAP_DIR:", CAP_DIR)
logi("Parser de fecha:", CFG$FORCE_DATE_PARSER)
logi("============================================================")

dt_raw <- read_any_delim(DATA_FILE)
dt <- normalizar_base(dt_raw)

dt_period <- dt[
  !is.na(FechaYHora) &
    FechaYHora >= CFG$STUDY_START &
    FechaYHora < CFG$STUDY_END
]

if (nrow(dt_period) == 0) {
  stop(
    "No quedaron registros dentro de 2017–2022. ",
    "Revise el parser de fecha o el formato real de FechaYHora."
  )
}

data.table::fwrite(
  dt_period,
  file.path(DIR_PROCESSED, "cap2_01_FINAL_datos_normalizados_periodo_2017_2022.csv"),
  bom = TRUE
)

# ============================================================
# 9. AUDITORÍA GENERAL
# ============================================================

tabla_parser_decision <- tibble::tibble(
  decision = c(
    "Parser seleccionado",
    "Criterio",
    "Periodo doctoral conservado",
    "Nota"
  ),
  valor = c(
    CFG$FORCE_DATE_PARSER,
    "Parser validado en corrida V3 y coherente con periodo 2017–2022",
    CFG$PERIOD_LABEL,
    "Se evita recomparar parsers para optimizar tiempo de ejecución."
  )
)

exportar_tabla(tabla_parser_decision, "Tabla_Cap2_00C_Decision_Parser_Fecha_FINAL")

tabla_auditoria <- tibble::tibble(
  elemento = c(
    "Ruta del archivo",
    "Existe archivo",
    "Tamaño aproximado MB",
    "Registros crudos leídos",
    "Registros dentro de 2017–2022",
    "Parser de fecha usado",
    "Periodo mínimo corregido",
    "Periodo máximo corregido",
    "Número de estaciones observado",
    "Número esperado de estaciones",
    "Número de zonas observado",
    "Número de variables observado",
    "Variable objetivo",
    "Fecha de generación"
  ),
  valor = c(
    DATA_FILE,
    as.character(file.exists(DATA_FILE)),
    as.character(round(file.info(DATA_FILE)$size / 1024^2, 3)),
    as.character(nrow(dt)),
    as.character(nrow(dt_period)),
    as.character(unique(dt$parser_usado)[1]),
    as.character(min(dt_period$FechaYHora, na.rm = TRUE)),
    as.character(max(dt_period$FechaYHora, na.rm = TRUE)),
    as.character(data.table::uniqueN(dt_period$Estacion)),
    as.character(CFG$EXPECTED_STATIONS),
    as.character(data.table::uniqueN(dt_period$Zona)),
    as.character(data.table::uniqueN(dt_period$Variable_clean)),
    CFG$TARGET_VAR,
    as.character(Sys.time())
  )
)

exportar_tabla(tabla_auditoria, "Tabla_Cap2_00_Auditoria_Fuente_Datos_FINAL")

# ============================================================
# 10. ESTACIONES Y ZONAS
# ============================================================

md_estaciones <- buscar_metadata_estaciones()

dt_estaciones <- dt_period[
  ,
  .(
    n_registros = .N,
    fecha_min = min(FechaYHora, na.rm = TRUE),
    fecha_max = max(FechaYHora, na.rm = TRUE),
    n_variables = data.table::uniqueN(Variable_clean),
    variables = paste(sort(unique(Variable_clean)), collapse = "; ")
  ),
  by = .(Zona, Estacion)
][order(Zona, Estacion)]

md_dt <- data.table::as.data.table(md_estaciones)
md_dt[, station_code := as.character(station_code)]

tabla_estaciones <- merge(
  dt_estaciones,
  md_dt,
  by.x = "Estacion",
  by.y = "station_code",
  all.x = TRUE
)

tabla_estaciones[, zona_metadata := zone]
tabla_estaciones[, zona_consistente := is.na(zona_metadata) | Zona == zona_metadata]
tabla_estaciones[, nombre_estacion := ifelse(!is.na(station_name), station_name, Estacion)]
tabla_estaciones[, id_estacion := ifelse(!is.na(station_id), station_id, paste0("S", sprintf("%02d", .I)))]

tabla_estaciones_final <- tabla_estaciones[
  ,
  .(
    Zona,
    id_estacion,
    codigo_estacion = Estacion,
    nombre_estacion,
    municipio = municipality,
    rango_altitud_articulo_msnm = altitude_group_m_asl,
    latitud = latitude,
    longitud = longitude,
    n_registros,
    fecha_min,
    fecha_max,
    n_variables,
    variables,
    zona_metadata,
    zona_consistente
  )
][order(Zona, codigo_estacion)]

exportar_tabla(tabla_estaciones_final, "Tabla_Cap2_01_Inventario_Estaciones_Zonas_FINAL")

tabla_resumen_zonas <- tabla_estaciones_final[
  ,
  .(
    n_estaciones = data.table::uniqueN(codigo_estacion),
    n_registros = sum(n_registros, na.rm = TRUE),
    fecha_min = min(fecha_min, na.rm = TRUE),
    fecha_max = max(fecha_max, na.rm = TRUE),
    estaciones = paste(nombre_estacion, collapse = "; ")
  ),
  by = Zona
][order(Zona)]

tabla_resumen_zonas[, porcentaje_estaciones := round(100 * n_estaciones / sum(n_estaciones), 2)]
tabla_resumen_zonas[, cumple_total_16 := sum(n_estaciones) == CFG$EXPECTED_STATIONS]

exportar_tabla(tabla_resumen_zonas, "Tabla_Cap2_01B_Resumen_Zonal_Estaciones_FINAL")

verificacion_estaciones <- tibble::tibble(
  criterio = c(
    "Número observado de estaciones",
    "Número declarado/esperado en tesis",
    "Coincidencia",
    "Zonas observadas",
    "Periodo corregido"
  ),
  valor = c(
    as.character(data.table::uniqueN(dt_period$Estacion)),
    as.character(CFG$EXPECTED_STATIONS),
    as.character(data.table::uniqueN(dt_period$Estacion) == CFG$EXPECTED_STATIONS),
    paste(sort(unique(dt_period$Zona)), collapse = ", "),
    CFG$PERIOD_LABEL
  )
)

exportar_tabla(verificacion_estaciones, "Tabla_Cap2_01C_Verificacion_Numero_Estaciones_FINAL")

# ============================================================
# 11. CONTROL DE CALIDAD VV
# ============================================================

dt_vv0 <- dt_period[Variable_clean == CFG$TARGET_VAR]

dt_vv <- dt_vv0[
  !is.na(FechaYHora) &
    !is.na(Valor) &
    is.finite(Valor) &
    Valor >= CFG$MIN_VV &
    Valor <= CFG$MAX_VV_PLAUSIBLE
]

if (nrow(dt_vv) == 0) {
  stop(
    "No quedaron registros VV válidos después del filtro físico y temporal. ",
    "Revise nombres de Variable_clean y la tabla de auditoría."
  )
}

dt_vv[, VV := Valor]
dt_vv[, fecha := as.Date(FechaYHora)]
dt_vv[, fecha_mes := as.Date(lubridate::floor_date(FechaYHora, "month"))]
dt_vv[, anio := lubridate::year(FechaYHora)]
dt_vv[, mes := lubridate::month(FechaYHora)]

data.table::fwrite(
  dt_vv[, .(Zona, Estacion, FechaYHora, VV, fecha, fecha_mes, anio, mes)],
  file.path(DIR_PROCESSED, "cap2_01_FINAL_vv_limpio_2017_2022.csv"),
  bom = TRUE
)

tabla_trazabilidad_vv <- tibble::tibble(
  paso = c(
    "Registros iniciales VV dentro de 2017–2022",
    "Fecha válida",
    "Valor numérico no NA y finito",
    "Valor mayor o igual a cero",
    "Valor menor o igual a máximo plausible"
  ),
  criterio = c(
    "Variable_clean == VV",
    "FechaYHora no NA",
    "Valor no NA y finito",
    paste0("Valor >= ", CFG$MIN_VV),
    paste0("Valor <= ", CFG$MAX_VV_PLAUSIBLE, " m/s")
  ),
  n = c(
    nrow(dt_vv0),
    nrow(dt_vv0[!is.na(FechaYHora)]),
    nrow(dt_vv0[!is.na(FechaYHora) & !is.na(Valor) & is.finite(Valor)]),
    nrow(dt_vv0[!is.na(FechaYHora) & !is.na(Valor) & is.finite(Valor) & Valor >= CFG$MIN_VV]),
    nrow(dt_vv)
  )
) %>%
  dplyr::mutate(
    porcentaje_respecto_inicial = round(100 * n / dplyr::first(n), 4)
  )

exportar_tabla(tabla_trazabilidad_vv, "Tabla_Cap2_03_Trazabilidad_Limpieza_VV_FINAL")

# ============================================================
# 12. COBERTURA TEMPORAL
# ============================================================

study_dates <- data.table::data.table(
  fecha = seq(
    as.Date(CFG$STUDY_START),
    as.Date(CFG$STUDY_END) - 1,
    by = "day"
  )
)

n_dias_esperados <- nrow(study_dates)

tabla_dias_vv_est <- dt_vv[
  ,
  .(
    n_registros_vv_validos = .N,
    n_dias_con_vv = data.table::uniqueN(fecha),
    n_ceros_vv = sum(VV == 0, na.rm = TRUE),
    vv_min = min(VV, na.rm = TRUE),
    vv_media = mean(VV, na.rm = TRUE),
    vv_mediana = median(VV, na.rm = TRUE),
    vv_max = max(VV, na.rm = TRUE),
    resolucion_mediana_min = calc_resolution_min(FechaYHora)
  ),
  by = .(Zona, Estacion)
][order(Zona, Estacion)]

tabla_dias_vv_est[, n_dias_esperados := n_dias_esperados]
tabla_dias_vv_est[, porcentaje_dias_con_vv := round(100 * n_dias_con_vv / n_dias_esperados, 3)]
tabla_dias_vv_est[, porcentaje_ceros_vv := round(100 * n_ceros_vv / n_registros_vv_validos, 4)]

tabla_dias_vv_est <- merge(
  tabla_dias_vv_est,
  tabla_estaciones_final[, .(codigo_estacion, id_estacion, nombre_estacion, municipio)],
  by.x = "Estacion",
  by.y = "codigo_estacion",
  all.x = TRUE
)

tabla_dias_vv_est <- tabla_dias_vv_est[
  ,
  .(
    Zona,
    id_estacion,
    codigo_estacion = Estacion,
    nombre_estacion,
    municipio,
    n_registros_vv_validos,
    n_dias_con_vv,
    n_dias_esperados,
    porcentaje_dias_con_vv,
    n_ceros_vv,
    porcentaje_ceros_vv,
    vv_min,
    vv_media,
    vv_mediana,
    vv_max,
    resolucion_mediana_min
  )
][order(Zona, codigo_estacion)]

exportar_tabla(tabla_dias_vv_est, "Tabla_Cap2_04_Cobertura_Temporal_VV_por_Estacion_FINAL")

tabla_dias_vv_zona <- tabla_dias_vv_est[
  ,
  .(
    n_estaciones = data.table::uniqueN(codigo_estacion),
    n_registros_vv_validos = sum(n_registros_vv_validos, na.rm = TRUE),
    n_dias_estacion_esperados = sum(n_dias_esperados, na.rm = TRUE),
    n_dias_estacion_con_vv = sum(n_dias_con_vv, na.rm = TRUE),
    n_ceros_vv = sum(n_ceros_vv, na.rm = TRUE),
    vv_media = mean(vv_media, na.rm = TRUE),
    vv_mediana = mean(vv_mediana, na.rm = TRUE),
    vv_max = max(vv_max, na.rm = TRUE)
  ),
  by = Zona
][order(Zona)]

tabla_dias_vv_zona[, porcentaje_dias_estacion_con_vv := round(100 * n_dias_estacion_con_vv / n_dias_estacion_esperados, 3)]
tabla_dias_vv_zona[, porcentaje_ceros_vv := round(100 * n_ceros_vv / n_registros_vv_validos, 4)]

exportar_tabla(tabla_dias_vv_zona, "Tabla_Cap2_05_Resumen_Cobertura_Temporal_VV_por_Zona_FINAL")

# ============================================================
# 13. DISPONIBILIDAD MENSUAL CORREGIDA
# ============================================================

calendar_months <- data.table::data.table(
  fecha_mes = seq(
    as.Date("2017-01-01"),
    as.Date("2022-12-01"),
    by = "month"
  )
)

calendar_months[, dias_esperados_mes := lubridate::days_in_month(fecha_mes)]

estaciones_base <- unique(dt_vv[, .(Zona, Estacion)])

# Cruce completo estación × mes
estaciones_base[, tmp_key_cross_join := 1L]
calendar_months[, tmp_key_cross_join := 1L]

grid_mes_est <- merge(
  estaciones_base,
  calendar_months,
  by = "tmp_key_cross_join",
  allow.cartesian = TRUE
)

grid_mes_est[, tmp_key_cross_join := NULL]
estaciones_base[, tmp_key_cross_join := NULL]
calendar_months[, tmp_key_cross_join := NULL]

disp_mes <- dt_vv[
  ,
  .(
    n_registros_vv_validos = .N,
    n_dias_con_vv = data.table::uniqueN(fecha)
  ),
  by = .(Zona, Estacion, fecha_mes)
]

disp_mes[, fecha_mes := as.Date(fecha_mes)]

disp_mes <- merge(
  grid_mes_est,
  disp_mes,
  by = c("Zona", "Estacion", "fecha_mes"),
  all.x = TRUE
)

disp_mes[is.na(n_registros_vv_validos), n_registros_vv_validos := 0L]
disp_mes[is.na(n_dias_con_vv), n_dias_con_vv := 0L]
disp_mes[, porcentaje_dias_con_vv_mes := round(100 * n_dias_con_vv / dias_esperados_mes, 2)]

disp_mes <- merge(
  disp_mes,
  tabla_estaciones_final[, .(codigo_estacion, id_estacion, nombre_estacion)],
  by.x = "Estacion",
  by.y = "codigo_estacion",
  all.x = TRUE
)

disp_mes[, etiqueta_estacion := paste0("Z", Zona, " — ", id_estacion, " — ", nombre_estacion)]

data.table::fwrite(
  disp_mes,
  file.path(DIR_PROCESSED, "cap2_01_FINAL_disponibilidad_mensual_vv_estacion.csv"),
  bom = TRUE
)

exportar_tabla(
  disp_mes[, .(
    Zona,
    id_estacion,
    codigo_estacion = Estacion,
    nombre_estacion,
    fecha_mes,
    dias_esperados_mes,
    n_dias_con_vv,
    porcentaje_dias_con_vv_mes,
    n_registros_vv_validos
  )],
  "Tabla_Cap2_06_Disponibilidad_Mensual_VV_por_Estacion_FINAL"
)

# ============================================================
# 14. FIGURAS
# ============================================================

# 14.1 Estructura zonal
df_zonas_fig <- as.data.frame(tabla_resumen_zonas)
df_zonas_fig$Zona <- factor(df_zonas_fig$Zona, levels = sort(unique(df_zonas_fig$Zona)))

p_zonas <- ggplot(df_zonas_fig, aes(x = Zona, y = n_estaciones, fill = Zona)) +
  geom_col(width = 0.68, colour = COL_BORDER, linewidth = 0.9) +
  geom_text(
    aes(label = paste0(n_estaciones, " estaciones\n", porcentaje_estaciones, "%")),
    family = FONT_FAMILY,
    fontface = "bold",
    colour = "white",
    size = 8.3,
    lineheight = 0.95
  ) +
  scale_fill_manual(values = pal_zona, guide = "none") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.18)), breaks = scales::pretty_breaks()) +
  labs(
    title = "Estructura zonal de la red observacional",
    subtitle = "Distribución de estaciones IDEAM por zona analítica",
    x = "Zona analítica",
    y = "Número de estaciones",
    caption = "Fuente: elaboración propia con datos IDEAM."
  ) +
  theme_cap2(base_size = 24)

exportar_figura(
  p_zonas,
  "Fig_Cap2_01B_Estructura_Zonal_Red_Observacional_FINAL",
  width = 18,
  height = 11
)

# 14.2 Cobertura temporal por estación
df_cov <- as.data.frame(tabla_dias_vv_est)
df_cov$etiqueta_estacion <- paste0("Z", df_cov$Zona, " — ", df_cov$id_estacion, " — ", df_cov$nombre_estacion)
df_cov$Zona <- factor(df_cov$Zona, levels = c(1, 2, 3, 4))

p_cov <- ggplot(
  df_cov,
  aes(
    x = porcentaje_dias_con_vv,
    y = reorder(etiqueta_estacion, porcentaje_dias_con_vv),
    fill = factor(Zona)
  )
) +
  geom_col(width = 0.72, colour = COL_BORDER, linewidth = 0.35) +
  geom_text(
    aes(label = paste0(round(porcentaje_dias_con_vv, 1), "%")),
    family = FONT_FAMILY,
    size = 5.8,
    hjust = -0.08,
    colour = COL_TEXT
  ) +
  scale_fill_manual(values = pal_zona, name = "Zona") +
  scale_x_continuous(
    limits = c(0, 105),
    labels = function(x) paste0(x, "%")
  ) +
  labs(
    title = "Cobertura temporal de velocidad del viento por estación",
    subtitle = "Porcentaje de días con al menos un registro VV válido durante 2017–2022",
    x = "Días con VV válido",
    y = "Estación",
    caption = "Fuente: elaboración propia con datos IDEAM."
  ) +
  theme_cap2(base_size = 21) +
  theme(
    axis.text.y = element_text(size = 13),
    legend.position = "bottom"
  )

exportar_figura(
  p_cov,
  "Fig_Cap2_02_Cobertura_Temporal_VV_por_Estacion_FINAL",
  width = 22,
  height = 13
)

# 14.3 Disponibilidad mensual
df_disp <- as.data.frame(disp_mes)
df_disp$etiqueta_estacion <- factor(
  df_disp$etiqueta_estacion,
  levels = rev(unique(df_disp$etiqueta_estacion[order(df_disp$Zona, df_disp$Estacion)]))
)

p_disp <- ggplot(
  df_disp,
  aes(x = fecha_mes, y = etiqueta_estacion, fill = porcentaje_dias_con_vv_mes)
) +
  geom_tile(colour = "white", linewidth = 0.12) +
  scale_fill_gradient(
    low = "#F4F6F7",
    high = COL_NAVY,
    limits = c(0, 100),
    labels = function(x) paste0(x, "%"),
    name = "Días con\nVV válido"
  ) +
  scale_x_date(
    date_breaks = "1 year",
    date_labels = "%Y",
    expand = expansion(mult = c(0.005, 0.005))
  ) +
  labs(
    title = "Disponibilidad mensual de registros de velocidad del viento",
    subtitle = "Porcentaje de días con VV válido por estación y mes, periodo 2017–2022",
    x = "Año",
    y = "Estación",
    caption = "Fuente: elaboración propia con datos IDEAM."
  ) +
  theme_cap2(base_size = 21) +
  theme(
    axis.text.y = element_text(size = 12),
    axis.text.x = element_text(angle = 0, hjust = 0.5),
    legend.position = "right"
  )

exportar_figura(
  p_disp,
  "Fig_Cap2_03_Disponibilidad_Mensual_VV_por_Estacion_FINAL",
  width = 22,
  height = 13
)

# 14.4 Proporción de ceros por estación
p_ceros <- ggplot(
  df_cov,
  aes(
    x = porcentaje_ceros_vv,
    y = reorder(etiqueta_estacion, porcentaje_ceros_vv),
    fill = factor(Zona)
  )
) +
  geom_col(width = 0.72, colour = COL_BORDER, linewidth = 0.35) +
  geom_text(
    aes(label = paste0(round(porcentaje_ceros_vv, 2), "%")),
    family = FONT_FAMILY,
    size = 5.5,
    hjust = -0.08,
    colour = COL_TEXT
  ) +
  scale_fill_manual(values = pal_zona, name = "Zona") +
  scale_x_continuous(
    limits = c(0, max(5, max(df_cov$porcentaje_ceros_vv, na.rm = TRUE) * 1.25)),
    labels = function(x) paste0(x, "%")
  ) +
  labs(
    title = "Proporción de registros de velocidad del viento iguales a cero",
    subtitle = "Diagnóstico de ceros por estación durante 2017–2022",
    x = "Registros VV iguales a cero",
    y = "Estación",
    caption = "Fuente: elaboración propia con datos IDEAM."
  ) +
  theme_cap2(base_size = 21) +
  theme(
    axis.text.y = element_text(size = 13),
    legend.position = "bottom"
  )

exportar_figura(
  p_ceros,
  "Fig_Cap2_04_Proporcion_Ceros_VV_por_Estacion_FINAL",
  width = 22,
  height = 13
)

# ============================================================
# 15. MAPA EN ESPAÑOL
# ============================================================

mapa_articulo_referencia <- copiar_mapa_articulo_referencia()
mapa_espanol_generado <- crear_mapa_espanol_si_hay_coord(tabla_estaciones_final)

if (!mapa_espanol_generado) {
  ruta_template <- file.path(DIR_INPUTS, "stations_zones_narino_TEMPLATE_COMPLETAR_COORDENADAS.csv")
  if (!file.exists(ruta_template)) {
    readr::write_csv(metadata_template, ruta_template)
  }
  
  nota_mapa <- c(
    "# Mapa del Capítulo 2 en español",
    "",
    "El script intentó regenerar el mapa del Artículo 1 en español.",
    "",
    "Resultado:",
    if (mapa_articulo_referencia) {
      "- Se copió el mapa original del Artículo 1 como referencia."
    } else {
      "- No se encontró el mapa original del Artículo 1 en la ruta esperada."
    },
    "- No se pudo regenerar el mapa en español porque no se encontró metadata con latitud y longitud.",
    "",
    "Para generar el mapa en español, ubique un archivo con coordenadas en una de estas rutas:",
    "",
    "- 02_capitulo_2_caracterizacion/00_inputs/stations_zones_narino.csv",
    "- 06_PRODUCTS/01_articles/article_01_energy_reports/01_data_processed/stations_zones_narino.csv",
    "",
    "Columnas requeridas:",
    "",
    "station_code, station_name, latitude, longitude, zone",
    "",
    "Se dejó una plantilla en:",
    "",
    ruta_template
  )
  
  writeLines(
    nota_mapa,
    file.path(DIR_TEXTOS, "cap2_01_mapa_espanol_pendiente_por_coordenadas.md"),
    useBytes = TRUE
  )
}

# ============================================================
# 16. GUÍA DE INSERCIÓN Y MANIFIESTO
# ============================================================

guia <- c(
  "# Guía de inserción — Capítulo 2, Bloque 01 FINAL",
  "",
  "## Elementos recomendados para el cuerpo del Capítulo 2",
  "",
  "1. Fig_Cap2_01_Mapa_Zonificacion_Estaciones_Narino_ES_FINAL, si se generó.",
  "2. Tabla_Cap2_01_Inventario_Estaciones_Zonas_FINAL.",
  "3. Tabla_Cap2_01C_Verificacion_Numero_Estaciones_FINAL.",
  "4. Tabla_Cap2_04_Cobertura_Temporal_VV_por_Estacion_FINAL o su resumen por zona.",
  "5. Fig_Cap2_02_Cobertura_Temporal_VV_por_Estacion_FINAL.",
  "",
  "## Elementos recomendados para anexo",
  "",
  "- Fig_Cap2_01B_Estructura_Zonal_Red_Observacional_FINAL.",
  "- Fig_Cap2_03_Disponibilidad_Mensual_VV_por_Estacion_FINAL.",
  "- Fig_Cap2_04_Proporcion_Ceros_VV_por_Estacion_FINAL.",
  "- Tabla_Cap2_06_Disponibilidad_Mensual_VV_por_Estacion_FINAL.",
  "",
  "## Interpretación clave",
  "",
  "Debe distinguirse entre validez física de registros existentes y cobertura temporal real.",
  "Los registros VV existentes superan el control físico básico, pero la cobertura temporal real se reporta por días con al menos un registro VV válido.",
  "",
  "## Mapa",
  "",
  if (mapa_espanol_generado) {
    "El mapa fue regenerado en español y puede usarse como Figura 2.1."
  } else {
    "El mapa en español quedó pendiente porque no se encontró metadata con coordenadas. Se copió el mapa original del Artículo 1 solo como referencia."
  }
)

writeLines(
  guia,
  file.path(DIR_TEXTOS, "cap2_01_FINAL_guia_insercion_datos_zonificacion_qc.md"),
  useBytes = TRUE
)

manifest <- tibble::tribble(
  ~tipo, ~archivo, ~ubicacion, ~uso_sugerido,
  "tabla", "Tabla_Cap2_00C_Decision_Parser_Fecha_FINAL.csv", DIR_TABLES, "Evidencia de decisión metodológica de fecha",
  "tabla", "Tabla_Cap2_00_Auditoria_Fuente_Datos_FINAL.csv", DIR_TABLES, "Anexo metodológico",
  "tabla", "Tabla_Cap2_01_Inventario_Estaciones_Zonas_FINAL.csv", DIR_TABLES, "Cuerpo del Capítulo 2",
  "tabla", "Tabla_Cap2_01B_Resumen_Zonal_Estaciones_FINAL.csv", DIR_TABLES, "Cuerpo del Capítulo 2",
  "tabla", "Tabla_Cap2_01C_Verificacion_Numero_Estaciones_FINAL.csv", DIR_TABLES, "Respuesta a inconsistencia de estaciones",
  "tabla", "Tabla_Cap2_03_Trazabilidad_Limpieza_VV_FINAL.csv", DIR_TABLES, "Cuerpo o anexo",
  "tabla", "Tabla_Cap2_04_Cobertura_Temporal_VV_por_Estacion_FINAL.csv", DIR_TABLES, "Cuerpo del Capítulo 2",
  "tabla", "Tabla_Cap2_05_Resumen_Cobertura_Temporal_VV_por_Zona_FINAL.csv", DIR_TABLES, "Cuerpo del Capítulo 2",
  "tabla", "Tabla_Cap2_06_Disponibilidad_Mensual_VV_por_Estacion_FINAL.csv", DIR_TABLES, "Anexo",
  "figura", "Fig_Cap2_01_Mapa_Zonificacion_Estaciones_Narino_ES_FINAL.png/pdf/svg", DIR_FIGURES, "Figura principal si se generó",
  "figura", "Fig_Cap2_01B_Estructura_Zonal_Red_Observacional_FINAL.png/pdf/svg", DIR_FIGURES, "Anexo o soporte",
  "figura", "Fig_Cap2_02_Cobertura_Temporal_VV_por_Estacion_FINAL.png/pdf/svg", DIR_FIGURES, "Cuerpo o anexo",
  "figura", "Fig_Cap2_03_Disponibilidad_Mensual_VV_por_Estacion_FINAL.png/pdf/svg", DIR_FIGURES, "Anexo",
  "figura", "Fig_Cap2_04_Proporcion_Ceros_VV_por_Estacion_FINAL.png/pdf/svg", DIR_FIGURES, "Anexo",
  "procesado", "cap2_01_FINAL_vv_limpio_2017_2022.csv", DIR_PROCESSED, "Entrada oficial para descriptivos, distribuciones, ACF, FFT y Wavelet"
)

data.table::fwrite(
  as.data.frame(manifest),
  file.path(DIR_LOGS, "manifest_cap2_01_FINAL_datos_zonificacion_qc.csv"),
  bom = TRUE
)

writeLines(
  capture.output(sessionInfo()),
  file.path(DIR_LOGS, "sessionInfo_cap2_01_FINAL_datos_zonificacion_qc.txt"),
  useBytes = TRUE
)

logi("Mapa original del artículo copiado:", mapa_articulo_referencia)
logi("Mapa en español generado:", mapa_espanol_generado)
logi("CAPÍTULO 2 — BLOQUE 01 FINALIZADO")
logi("Fin:", as.character(Sys.time()))
logi("============================================================")


cat("\n============================================================\n")
cat("SECCIÓN A COMPLETADA: DATOS, ZONIFICACIÓN Y QC\n")
cat("Hora:", as.character(Sys.time()), "\n")
cat("============================================================\n\n")

# ============================================================
# SECCIÓN B
# MAPA FINAL DEL ARTÍCULO 1 EN ESPAÑOL PARA TESIS
# ============================================================

# ============================================================
# FIGURA 2.1 — MAPA FINAL PARA TESIS EN ESPAÑOL — V4 CORRECCION RESCALE
# Misma figura del Artículo 1: contexto fisiográfico, zonificación analítica
# y estaciones IDEAM en Nariño, Colombia
# Versión para Capítulo 2 de tesis doctoral
# ============================================================

required_packages <- c(
  "sf", "terra", "geodata", "ggplot2", "dplyr", "readr",
  "ggrepel", "ggspatial", "patchwork", "stringr",
  "grid", "scales", "ggnewscale"
)

installed_packages <- rownames(installed.packages())

for (pkg in required_packages) {
  if (!pkg %in% installed_packages) {
    install.packages(pkg, dependencies = TRUE)
  }
}

library(sf)
library(terra)
library(geodata)
library(ggplot2)
library(dplyr)
library(readr)
library(ggrepel)
library(ggspatial)
library(patchwork)
library(stringr)
library(grid)
library(scales)
library(ggnewscale)

# ============================================================
# NOTA DE USO
# ============================================================
#
# Este script conserva la geometría, extensión, paleta, relieve, envolventes
# zonales, etiquetas, inset, flecha norte, escala y tamaños de exportación
# del script original del Artículo 1. Solo traduce textos al español y cambia
# la carpeta/nombre de salida para el Capítulo 2 de la tesis.
#
# ============================================================
# 1. PATHS
# ============================================================

# Ruta del flujo original del Artículo 1.
# Aquí debe existir 01_data_processed/stations_zones_narino.csv
article_root <- file.path(TDQ_REPO_ROOT, "06_PRODUCTS", "01_articles", "article_01_energy_reports")

# Ruta de salida para la tesis.
cap2_dir <- "<configured-path>"

input_dir <- file.path(article_root, "01_data_processed")
article_figure_dir <- file.path(article_root, "03_figures", "publication_ready_final")
figure_dir <- file.path(cap2_dir, "03_figures")
table_dir <- file.path(cap2_dir, "02_tables")
map_dir <- file.path(article_root, "02_results", "map_boundaries")

dir.create(input_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(article_figure_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(table_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(map_dir, recursive = TRUE, showWarnings = FALSE)

# ============================================================
# 1.1 LOCALIZACIÓN ROBUSTA DE METADATA DE ESTACIONES
# ============================================================
#
# El mapa original requiere metadata con:
# station_code, station_name, longitude, latitude, zone
#
# En diferentes corridas esta metadata puede estar en:
# - 01_data_processed/stations_zones_narino.csv
# - 03_figures/publication_ready_final/Fig_01_station_key_for_map.csv
# - 02_capitulo_2_caracterizacion/00_inputs/stations_zones_narino.csv
# - carpetas intermedias del repositorio o del artículo 1.
#
# Esta función busca recursivamente y selecciona el primer CSV que tenga
# las columnas necesarias. Así evitamos depender de una única ruta histórica.

has_station_columns <- function(path) {
  ok <- FALSE
  required_cols <- c("station_code", "station_name", "longitude", "latitude", "zone")
  
  tryCatch({
    x <- readr::read_csv(path, show_col_types = FALSE, n_max = 5)
    ok <- all(required_cols %in% names(x))
  }, error = function(e) {
    ok <<- FALSE
  })
  
  ok
}

find_station_metadata <- function() {
  fixed_candidates <- c(
    file.path(input_dir, "stations_zones_narino.csv"),
    file.path(article_figure_dir, "Fig_01_station_key_for_map.csv"),
    file.path(article_figure_dir, "stations_zones_narino.csv"),
    file.path(cap2_dir, "00_inputs", "stations_zones_narino.csv"),
    file.path(cap2_dir, "00_inputs", "Fig_01_station_key_for_map.csv"),
    file.path(file.path(TDQ_WORK_DIR, "external_inputs", "article_01"), "01_data_processed", "stations_zones_narino.csv"),
    file.path(file.path(TDQ_WORK_DIR, "external_inputs", "article_01"), "03_figures", "publication_ready_final", "Fig_01_station_key_for_map.csv"),
    file.path(file.path(TDQ_WORK_DIR, "external_inputs", "article_01"), "03_figures", "publication_ready_final", "stations_zones_narino.csv")
  )
  
  fixed_candidates <- fixed_candidates[file.exists(fixed_candidates)]
  
  for (candidate in fixed_candidates) {
    if (has_station_columns(candidate)) {
      message("Metadata de estaciones encontrada: ", candidate)
      return(candidate)
    }
  }
  
  search_roots <- unique(c(
    article_root,
    cap2_dir,
    file.path(TDQ_WORK_DIR, "external_inputs", "article_01")
  ))
  
  search_roots <- search_roots[dir.exists(search_roots)]
  
  patterns <- c(
    "stations_zones_narino.csv",
    "Fig_01_station_key_for_map.csv",
    "station_key",
    "stations",
    "estaciones"
  )
  
  candidates <- character(0)
  
  for (root in search_roots) {
    csvs <- list.files(root, pattern = "\\.csv$", recursive = TRUE, full.names = TRUE)
    if (length(csvs) > 0) {
      hit <- csvs[
        Reduce(`|`, lapply(patterns, function(p) grepl(p, basename(csvs), ignore.case = TRUE)))
      ]
      candidates <- unique(c(candidates, hit))
    }
  }
  
  for (candidate in candidates) {
    if (has_station_columns(candidate)) {
      message("Metadata de estaciones encontrada por búsqueda recursiva: ", candidate)
      return(candidate)
    }
  }
  
  report_dir <- file.path(cap2_dir, "05_logs")
  dir.create(report_dir, recursive = TRUE, showWarnings = FALSE)
  
  if (length(candidates) > 0) {
    readr::write_csv(
      data.frame(candidate = candidates, has_required_columns = sapply(candidates, has_station_columns)),
      file.path(report_dir, "reporte_busqueda_metadata_mapa_espanol.csv")
    )
  }
  
  stop(
    "No se encontró metadata de estaciones con columnas station_code, station_name, longitude, latitude y zone. ",
    "Revise 05_logs/reporte_busqueda_metadata_mapa_espanol.csv si fue generado, o copie stations_zones_narino.csv a: ",
    file.path(cap2_dir, "00_inputs")
  )
}

stations_file <- find_station_metadata()

# ============================================================
# 2. LOAD STATIONS
# ============================================================

stations <- read_csv(stations_file, show_col_types = FALSE)

required_cols <- c("station_code", "station_name", "longitude", "latitude", "zone")
missing_cols <- setdiff(required_cols, names(stations))

if (length(missing_cols) > 0) {
  stop(paste("Missing columns:", paste(missing_cols, collapse = ", ")))
}

stations <- stations %>%
  mutate(
    station_code = as.character(station_code),
    station_name = as.character(station_name),
    longitude    = as.numeric(longitude),
    latitude     = as.numeric(latitude),
    zone         = factor(as.character(zone), levels = c("1", "2", "3", "4"))
  ) %>%
  filter(
    !is.na(longitude),
    !is.na(latitude),
    !is.na(zone)
  ) %>%
  arrange(zone, station_code) %>%
  mutate(
    station_id = sprintf("S%02d", row_number())
  )

stations_sf <- st_as_sf(
  stations,
  coords = c("longitude", "latitude"),
  crs = 4326,
  remove = FALSE
)

station_key <- stations %>%
  select(
    station_id,
    station_code,
    station_name,
    zone,
    longitude,
    latitude,
    everything()
  )

write_csv(
  station_key,
  file.path(table_dir, "Tabla_Cap2_01D_Llave_Estaciones_Mapa.csv")
)

# ============================================================
# 3. LOAD ADMINISTRATIVE BOUNDARIES
# ============================================================

message("Cargando límites administrativos...")

colombia_admin1 <- geodata::gadm(country = "COL", level = 1, path = map_dir)
colombia_admin2 <- geodata::gadm(country = "COL", level = 2, path = map_dir)

colombia_sf <- st_as_sf(colombia_admin1)
municipios_sf <- st_as_sf(colombia_admin2)

narino_sf <- colombia_sf %>%
  filter(str_detect(str_to_lower(NAME_1), "nari"))

narino_muni_sf <- municipios_sf %>%
  filter(str_detect(str_to_lower(NAME_1), "nari"))

if (nrow(narino_sf) == 0) {
  stop("Nariño boundary was not found.")
}

if (nrow(narino_muni_sf) == 0) {
  stop("Municipal boundaries for Nariño were not found.")
}

# ============================================================
# 4. MAP EXTENT
# ============================================================

bbox_nar <- st_bbox(narino_sf)

xrange <- as.numeric(bbox_nar["xmax"] - bbox_nar["xmin"])
yrange <- as.numeric(bbox_nar["ymax"] - bbox_nar["ymin"])

xmin_ext <- as.numeric(bbox_nar["xmin"]) - 0.10 * xrange
xmax_ext <- as.numeric(bbox_nar["xmax"]) + 0.03 * xrange
ymin_ext <- as.numeric(bbox_nar["ymin"]) - 0.03 * yrange
ymax_ext <- as.numeric(bbox_nar["ymax"]) + 0.03 * yrange

# ============================================================
# 5. DEM + HILLSHADE
# ============================================================

message("Cargando datos de elevación...")

dem_colombia <- geodata::elevation_30s(country = "COL", path = map_dir)

ext_terra <- terra::ext(
  xmin_ext,
  xmax_ext,
  ymin_ext,
  ymax_ext
)

dem_crop <- terra::crop(dem_colombia, ext_terra)
names(dem_crop) <- "elevation_m"

dem_smooth <- terra::focal(
  dem_crop,
  w = matrix(1, nrow = 3, ncol = 3),
  fun = mean,
  na.policy = "omit"
)

names(dem_smooth) <- "elevation_m"

slope  <- terra::terrain(dem_smooth, v = "slope", unit = "radians")
aspect <- terra::terrain(dem_smooth, v = "aspect", unit = "radians")

hs1 <- terra::shade(slope, aspect, angle = 40, direction = 315)
hs2 <- terra::shade(slope, aspect, angle = 35, direction = 40)
hs3 <- terra::shade(slope, aspect, angle = 50, direction = 270)

hillshade <- (hs1 * 0.55) + (hs2 * 0.25) + (hs3 * 0.20)
names(hillshade) <- "hillshade"

dem_df <- terra::as.data.frame(dem_smooth, xy = TRUE, na.rm = TRUE)
shade_df <- terra::as.data.frame(hillshade, xy = TRUE, na.rm = TRUE)

shade_df <- shade_df %>%
  mutate(
    hillshade_norm =
      (hillshade - min(hillshade, na.rm = TRUE)) /
      (max(hillshade, na.rm = TRUE) - min(hillshade, na.rm = TRUE)),
    shadow = 1 - hillshade_norm
  )

contours <- terra::as.contour(
  dem_smooth,
  levels = seq(500, 4500, by = 500)
)

contours_sf <- st_as_sf(contours)

# ============================================================
# 6. ANALYTICAL ZONE ENVELOPES
# ============================================================

stations_3116 <- st_transform(stations_sf, 3116)

zone_hulls <- stations_3116 %>%
  group_by(zone) %>%
  summarise(do_union = TRUE, .groups = "drop") %>%
  st_buffer(dist = 18000) %>%
  st_convex_hull() %>%
  st_transform(4326)

zone_hulls <- suppressWarnings(
  st_intersection(zone_hulls, narino_sf)
)

zone_hulls <- zone_hulls %>%
  mutate(zone = factor(as.character(zone), levels = c("1", "2", "3", "4")))

zone_label_pts <- suppressWarnings(st_point_on_surface(zone_hulls))

zone_label_df <- cbind(
  st_drop_geometry(zone_label_pts),
  st_coordinates(zone_label_pts)
) %>%
  mutate(
    zone_label = paste0("Zona ", zone)
  )

stations_label_df <- cbind(
  st_drop_geometry(stations_sf),
  st_coordinates(stations_sf)
)

# ============================================================
# 7. COLOR PALETTES
# ============================================================

zone_palette <- c(
  "1" = "#E41A1C",
  "2" = "#377EB8",
  "3" = "#1B9E77",
  "4" = "#984EA3"
)

elevation_palette <- c(
  "#38b6c3",
  "#63c08c",
  "#b7d96b",
  "#f0d55a",
  "#e49a3a",
  "#b86f30",
  "#8b5a3c",
  "#dadada"
)

# ============================================================
# 8. MAIN MAP
# ============================================================

main_map <- ggplot() +
  
  geom_rect(
    aes(
      xmin = xmin_ext,
      xmax = xmax_ext,
      ymin = ymin_ext,
      ymax = ymax_ext
    ),
    fill = "#bfe2ef",
    color = NA
  ) +
  
  geom_raster(
    data = dem_df,
    aes(x = x, y = y, fill = elevation_m)
  ) +
  scale_fill_gradientn(
    colors = elevation_palette,
    values = scales::rescale(c(0, 300, 700, 1200, 1800, 2500, 3200, 4500)),
    name = "Elevación\n(m s.n.m.)",
    oob = squish
  ) +
  
  geom_raster(
    data = shade_df,
    aes(x = x, y = y, alpha = shadow),
    fill = "black"
  ) +
  scale_alpha_continuous(
    range = c(0.00, 0.28),
    guide = "none"
  ) +
  
  ggnewscale::new_scale_fill() +
  
  geom_sf(
    data = narino_muni_sf,
    fill = NA,
    color = alpha("grey25", 0.45),
    linewidth = 0.22
  ) +
  
  geom_sf(
    data = contours_sf,
    color = alpha("grey20", 0.13),
    linewidth = 0.10
  ) +
  
  geom_sf(
    data = zone_hulls,
    aes(fill = zone),
    color = NA,
    alpha = 0.24,
    show.legend = FALSE
  ) +
  scale_fill_manual(
    values = zone_palette,
    guide = "none"
  ) +
  
  geom_sf(
    data = zone_hulls,
    aes(color = zone),
    fill = NA,
    linewidth = 1.05,
    linetype = "solid",
    alpha = 0.98,
    show.legend = FALSE
  ) +
  
  geom_sf(
    data = narino_sf,
    fill = NA,
    color = "white",
    linewidth = 1.6
  ) +
  geom_sf(
    data = narino_sf,
    fill = NA,
    color = "black",
    linewidth = 0.95
  ) +
  
  ggnewscale::new_scale_fill() +
  
  geom_sf(
    data = stations_sf,
    shape = 21,
    aes(fill = zone),
    color = "white",
    stroke = 0.85,
    size = 4.0,
    show.legend = TRUE
  ) +
  
  geom_label_repel(
    data = stations_label_df,
    aes(
      x = X,
      y = Y,
      label = station_id,
      color = zone
    ),
    fill = alpha("white", 0.90),
    fontface = "bold",
    size = 3.0,
    label.size = 0.12,
    label.padding = unit(0.10, "lines"),
    box.padding = 0.32,
    point.padding = 0.25,
    segment.color = "grey30",
    segment.size = 0.24,
    max.overlaps = Inf,
    seed = 123,
    show.legend = FALSE
  ) +
  
  geom_label(
    data = zone_label_df,
    aes(
      x = X,
      y = Y,
      label = zone_label,
      fill = zone
    ),
    color = "white",
    fontface = "bold",
    size = 3.6,
    alpha = 0.88,
    label.size = 0.18,
    show.legend = FALSE
  ) +
  
  scale_fill_manual(
    values = zone_palette,
    name = "Zona\nanalítica",
    guide = guide_legend(
      override.aes = list(
        shape = 21,
        size = 4.5,
        color = "white"
      )
    )
  ) +
  
  scale_color_manual(
    values = zone_palette,
    guide = "none"
  ) +
  
  annotate(
    "text",
    x = xmin_ext + 0.12 * (xmax_ext - xmin_ext),
    y = ymin_ext + 0.15 * (ymax_ext - ymin_ext),
    label = "Océano Pacífico",
    fontface = "italic",
    size = 4.1,
    color = alpha("grey20", 0.85)
  ) +
  
  coord_sf(
    xlim = c(xmin_ext, xmax_ext),
    ylim = c(ymin_ext, ymax_ext),
    expand = FALSE
  ) +
  
  annotation_scale(
    location = "bl",
    width_hint = 0.12,
    text_cex = 0.82,
    line_width = 0.75
  ) +
  
  annotation_north_arrow(
    location = "tr",
    which_north = "true",
    style = north_arrow_fancy_orienteering(
      fill = c("black", "white"),
      line_col = "black"
    ),
    height = unit(0.85, "cm"),
    width = unit(0.85, "cm")
  ) +
  
  labs(
    title = "Contexto fisiográfico y zonificación analítica en Nariño, Colombia",
    subtitle = "Relieve topográfico, límites municipales y estaciones IDEAM (S01–S16) usadas para la evaluación de WPD",
    x = NULL,
    y = NULL
  ) +
  
  theme_minimal(base_size = 12) +
  theme(
    panel.background = element_rect(fill = "#bfe2ef", color = NA),
    plot.background  = element_rect(fill = "white", color = NA),
    plot.title = element_text(face = "bold", size = 15, hjust = 0.5),
    plot.subtitle = element_text(size = 10.6, hjust = 0.5),
    legend.position = "right",
    legend.box = "vertical",
    legend.title = element_text(face = "bold", size = 10.5),
    legend.text = element_text(size = 9.5),
    panel.grid.major = element_line(color = alpha("white", 0.45), linewidth = 0.22),
    panel.grid.minor = element_blank(),
    axis.text = element_text(size = 9)
  )

# ============================================================
# 9. COLOMBIA INSET
# ============================================================

map_colombia <- ggplot() +
  geom_sf(
    data = colombia_sf,
    fill = "grey88",
    color = "white",
    linewidth = 0.12
  ) +
  geom_sf(
    data = narino_sf,
    fill = "#E41A1C",
    color = "black",
    linewidth = 0.20
  ) +
  labs(title = "Colombia") +
  theme_void(base_size = 9) +
  theme(
    plot.title = element_text(face = "bold", size = 9.2, hjust = 0.5),
    plot.background = element_rect(
      fill = alpha("white", 0.92),
      color = "grey65",
      linewidth = 0.25
    )
  )

final_map <- main_map +
  patchwork::inset_element(
    map_colombia,
    left = 0.045,
    bottom = 0.70,
    right = 0.17,
    top = 0.93,
    align_to = "panel"
  )

print(final_map)

# ============================================================
# 10. EXPORT
# ============================================================

tiff_file <- file.path(
  figure_dir,
  "Fig_Cap2_01_Mapa_Zonificacion_Analitica_IDEAM_Narino_ES_FINAL.tiff"
)

png_file <- file.path(
  figure_dir,
  "Fig_Cap2_01_Mapa_Zonificacion_Analitica_IDEAM_Narino_ES_FINAL.png"
)

ggsave(
  filename = tiff_file,
  plot = final_map,
  width = 10.0,
  height = 7.4,
  units = "in",
  dpi = 600,
  compression = "lzw",
  bg = "white"
)

ggsave(
  filename = png_file,
  plot = final_map,
  width = 10.0,
  height = 7.4,
  units = "in",
  dpi = 300,
  bg = "white"
)

pdf_file <- file.path(
  figure_dir,
  "Fig_Cap2_01_Mapa_Zonificacion_Analitica_IDEAM_Narino_ES_FINAL.pdf"
)

svg_file <- file.path(
  figure_dir,
  "Fig_Cap2_01_Mapa_Zonificacion_Analitica_IDEAM_Narino_ES_FINAL.svg"
)

ggsave(
  filename = pdf_file,
  plot = final_map,
  width = 10.0,
  height = 7.4,
  units = "in",
  bg = "white",
  device = cairo_pdf
)

if (requireNamespace("svglite", quietly = TRUE)) {
  ggsave(
    filename = svg_file,
    plot = final_map,
    width = 10.0,
    height = 7.4,
    units = "in",
    bg = "white",
    device = svglite::svglite
  )
}

zone_station_summary <- stations %>%
  count(zone, name = "n_stations") %>%
  arrange(zone)

write_csv(
  zone_station_summary,
  file.path(table_dir, "Tabla_Cap2_01E_Resumen_Estaciones_por_Zona_Mapa.csv")
)

message("============================================================")
message("Mapa final en español para tesis creado correctamente.")
message("TIFF: ", tiff_file)
message("PNG : ", png_file)
message("PDF : ", pdf_file)
message("SVG : ", svg_file)
message("Llave de estaciones: ", file.path(table_dir, "Tabla_Cap2_01D_Llave_Estaciones_Mapa.csv"))
message("Resumen zonal: ", file.path(table_dir, "Tabla_Cap2_01E_Resumen_Estaciones_por_Zona_Mapa.csv"))
message("============================================================")


cat("\n============================================================\n")
cat("CAPÍTULO 2 — SCRIPT MAESTRO UNIFICADO FINALIZADO\n")
cat("Fin:", as.character(Sys.time()), "\n")
cat("============================================================\n")
