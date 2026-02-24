# ============================================================
# CAP4 – TDQ_PIESS Projection 2017–2028
# PURPOSE: Projection using TDQ-PIESS global predictions table; produces Cap 4 outputs
# INPUTS: TDQ_PIESS_PREDS_GLOBAL.csv (or equivalent) with FechaHora, y_true, PI_low90, PI_high90, FNRR
# OUTPUTS: Cap 4 figures + tables under SALIDAS_CAP4_FINAL/
# NOTE: This script was extracted from the working thesis pipeline and
#       lightly cleaned for GitHub (paths made configurable, unicode normalized).
# ============================================================

inal Cap 4


# ============================================================
# CAPÍTULO 4 - TDQ_PIESS
# Proyección estructural 2017-2028
# Universidad Nacional de Colombia
# ============================================================

library(data.table)
library(lubridate)
library(ggplot2)

# -------------------------------
# 1. Rutas
# -------------------------------

BASE_FILE <- file.path("data","TDQ_PIESS_PREDS_GLOBAL.csv")  # <-- set your local path

stopifnot(file.exists(BASE_FILE))

OUT_DIR <- file.path(getwd(), "SALIDAS_CAP4_FINAL")
dir.create(OUT_DIR, showWarnings=FALSE, recursive=TRUE)

# -------------------------------
# 2. Cargar datos
# -------------------------------

P <- fread(BASE_FILE)
P[, FechaHora := as.POSIXct(FechaHora, tz="America/Bogota")]

P <- P[is.finite(y_true) & is.finite(PI_low90) &
         is.finite(PI_high90) & is.finite(FNRR)]

P[, Year := year(FechaHora)]

# -------------------------------
# 3. Energía anual histórica
# -------------------------------

ENERG_HIST <- P[, .(
  E_true_kWh_m2 = sum(y_true)/1000,
  E_low_kWh_m2  = sum(PI_low90)/1000,
  E_high_kWh_m2 = sum(PI_high90)/1000,
  FNRR_mean_year = mean(FNRR)
), by=.(Zona, Horizonte, Year)]

# -------------------------------
# 4. Resumen estructural 2017-2022
# -------------------------------

RES_STRUCT <- ENERG_HIST[, .(
  E_mean_2017_2022 = mean(E_true_kWh_m2),
  E_sd_2017_2022   = sd(E_true_kWh_m2),
  E_p05_2017_2022  = quantile(E_true_kWh_m2, 0.05),
  E_p95_2017_2022  = quantile(E_true_kWh_m2, 0.95),
  FNRR_structural  = mean(FNRR_mean_year)
), by=.(Zona, Horizonte)]

# -------------------------------
# 5. Proyección estructural 2023-2028
# -------------------------------

YEARS_FUT <- 2023:2028

PROY_LIST <- list()

for (yy in YEARS_FUT) {
  tmp <- RES_STRUCT[, .(
    Zona, Horizonte,
    Year = yy,
    E_proj_kWh_m2 = E_mean_2017_2022,
    E_p05_kWh_m2  = E_p05_2017_2022,
    E_p95_kWh_m2  = E_p95_2017_2022,
    FNRR_mean_year = FNRR_structural
  )]
  PROY_LIST[[length(PROY_LIST)+1]] <- tmp
}

ENERG_PROY <- rbindlist(PROY_LIST)

# -------------------------------
# 6. Exportar tablas
# -------------------------------

fwrite(ENERG_HIST, file.path(OUT_DIR, "01_ENERGIA_ANUAL_HISTORICA.csv"))
fwrite(RES_STRUCT, file.path(OUT_DIR, "02_RESUMEN_ESTRUCTURAL_2017_2022.csv"))
fwrite(ENERG_PROY, file.path(OUT_DIR, "03_PROYECCION_ESTRUCTURAL_2023_2028.csv"))

# -------------------------------
# 7. Figuras Publicables
# -------------------------------

theme_pub <- theme_minimal(base_size = 12) +
  theme(
    panel.grid.major = element_line(color="grey90"),
    panel.grid.minor = element_blank(),
    plot.title = element_text(face="bold"),
    legend.position = "bottom"
  )

# ---- Figura Energía ----

p_energy <- ggplot() +
  geom_line(data=ENERG_HIST,
            aes(x=Year, y=E_true_kWh_m2, color=factor(Zona)),
            linewidth=0.8) +
  geom_line(data=ENERG_PROY,
            aes(x=Year, y=E_proj_kWh_m2, color=factor(Zona)),
            linetype="dashed", linewidth=0.8) +
  facet_wrap(~Horizonte, scales="free_y") +
  labs(title="Energía Eólica Anual: Histórico vs Proyección Estructural",
       y="Energía (kWh/m2)", x="Año",
       color="Zona") +
  theme_pub

ggsave(file.path(OUT_DIR, "04_FIG_ENERGIA_HIST_PROY.png"),
       p_energy, width=10, height=6, dpi=300)

# ---- Figura FNRR ----

p_fnrr <- ggplot() +
  geom_line(data=ENERG_HIST,
            aes(x=Year, y=FNRR_mean_year, color=factor(Zona)),
            linewidth=0.8) +
  geom_line(data=ENERG_PROY,
            aes(x=Year, y=FNRR_mean_year, color=factor(Zona)),
            linetype="dashed", linewidth=0.8) +
  facet_wrap(~Horizonte) +
  labs(title="FNRR Anual: Firma Regional Estructural",
       y="FNRR", x="Año",
       color="Zona") +
  theme_pub

ggsave(file.path(OUT_DIR, "05_FIG_FNRR_HIST_PROY.png"),
       p_fnrr, width=10, height=6, dpi=300)

cat("\nCAPÍTULO 4 COMPLETADO\n")
cat("Resultados en:", OUT_DIR, "\n")




suppressPackageStartupMessages({
  library(data.table); library(lubridate)
})

DATA_FILE <- ""  # <-- set path
OUT_DIR   <- file.path(getwd(), "SALIDAS_CAP4_CACHE")
dir.create(OUT_DIR, showWarnings=FALSE, recursive=TRUE)

logi <- function(...) cat(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "|", ..., "\n")

parse_dt <- function(x) {
  x <- trimws(as.character(x))
  x <- gsub("a\\.?\\s*m\\.?","AM", x, ignore.case=TRUE)
  x <- gsub("p\\.?\\s*m\\.?","PM", x, ignore.case=TRUE)
  suppressWarnings(parse_date_time(
    x,
    orders=c("Y-m-d H:M:S","Y-m-d H:M",
             "d/m/Y H:M:S","d/m/Y H:M",
             "m/d/Y H:M:S","m/d/Y H:M",
             "d-m-Y H:M:S","d-m-Y H:M",
             "Ymd HMS","Ymd HM",
             "d/m/Y I:M:S p","d/m/Y I:M p",
             "m/d/Y I:M:S p","m/d/Y I:M p"),
    tz="UTC"
  ))
}

norm_var <- function(v){
  v <- toupper(trimws(as.character(v))); v <- gsub("\\s+","", v)
  if (v %in% c("VV","VELVIENTO","VELOCIDADVIENTO","WINDSPEED","WS")) return("VV")
  if (v %in% c("PA","PRESION","PRESIONATM","PRESIONATMOSFERICA","PRESSURE")) return("PA")
  if (v %in% c("TM","TEMP","TEMPERATURA","TMEAN","T")) return("TM")
  if (v %in% c("TMIN","TEMPERATURAMINIMA")) return("TMIN")
  if (v %in% c("TMAX","TEMPERATURAMAXIMA")) return("TMAX")
  v
}

to_pa <- function(p){
  p <- as.numeric(p); med <- median(p, na.rm=TRUE)
  if (is.finite(med) && med < 2000) p*100 else p
}
to_kelvin <- function(t){
  t <- as.numeric(t); med <- median(t, na.rm=TRUE)
  if (is.finite(med) && med < 100) t+273.15 else t
}

logi("Leyendo:", DATA_FILE)
DT <- fread(DATA_FILE, showProgress=TRUE)
if (!("Estación" %in% names(DT)) && ("Estacion" %in% names(DT))) setnames(DT, "Estacion","Estación")

need <- c("FechaYHora","Valor","Zona","Variable")
miss <- setdiff(need, names(DT))
if (length(miss)>0) stop("Faltan columnas: ", paste(miss, collapse=", "))

DT[, Zona := as.integer(Zona)]
DT[, Variable := vapply(Variable, norm_var, character(1))]
DT <- DT[Variable %in% c("VV","PA","TM","TMIN","TMAX")]
DT[, Valor := suppressWarnings(as.numeric(Valor))]
DT[, Fecha := parse_dt(FechaYHora)]
DT <- DT[!is.na(Zona) & !is.na(Fecha)]
DT[, FechaHora := floor_date(Fecha, "hour")]

logi("Agregando a hourly por Zona-FechaHora...")
H <- DT[, .(Valor = mean(Valor, na.rm=TRUE)), by=.(Zona, FechaHora, Variable)]
W <- dcast(H, Zona + FechaHora ~ Variable, value.var="Valor")
setorder(W, Zona, FechaHora)

if (!("TM" %in% names(W))) {
  if (all(c("TMIN","TMAX") %in% names(W))) W[, TM := (TMIN+TMAX)/2]
  else stop("No encontré TM ni TMIN/TMAX.")
}
if (!("PA" %in% names(W))) stop("No encontré PA.")
if (!("VV" %in% names(W))) stop("No encontré VV.")

W[, PA := to_pa(PA)]
W[, TM := to_kelvin(TM)]
W[, VV := pmax(as.numeric(VV), 0)]

R <- 287.05
W[, rho := PA/(R*TM)]
W[, WPD := 0.5 * rho * (VV^3)]
W[, Eh  := WPD/1000]

OUT_FILE <- file.path(OUT_DIR, "WPD_Eh_hourly_por_zona.csv")
fwrite(W[, .(Zona, FechaHora, VV, PA, TM, rho, WPD, Eh)], OUT_FILE)

logi("OK cache:", OUT_FILE)


# ============================================================
# CAP4 - TDQ CIERRE FINAL (ANTI-ERRORES DEFINITIVO) | WPD + Eh + PI90 + FNRR
# SIN lubridate (evita tz(x)->as.POSIXlt.default)
# Trimestral + Anual, Forecast 2022Q3-2028Q4
# Regularización física Zona 1 (Weibull mu + 2sd) + coherencia energía
# FIX: Deduplicación (Zona,time) para evitar cartesian join
# ============================================================

req <- c("data.table","forecast","ggplot2","scales")
for (p in req) if (!requireNamespace(p, quietly=TRUE)) install.packages(p, dependencies=TRUE)
suppressPackageStartupMessages({
  library(data.table); library(forecast); library(ggplot2); library(scales)
})

# -------------------------
# 1) Rutas
# -------------------------
ROOT <- ""  # <-- set path
OUT  <- file.path(ROOT, "SALIDAS_CAP4_TDQ_FINAL")
dir.create(OUT, showWarnings=FALSE, recursive=TRUE)

CACHE_FILE <- file.path(ROOT, "SALIDAS_CAP4_CACHE", "WPD_Eh_hourly_por_zona.csv")
if (!file.exists(CACHE_FILE)) stop("No existe CACHE_FILE: ", CACHE_FILE)

# -------------------------
# 2) Parámetros
# -------------------------
LEVEL_PI <- 90
START_DT   <- as.POSIXct("2017-01-01 00:00:00", tz="UTC")
CUTOFF_END <- as.POSIXct("2022-06-30 23:00:00", tz="UTC")

LAST_OBS_Y <- 2022
LAST_OBS_Q <- 2
END_Y <- 2028
END_Q <- 4

WEIBULL_PARAMS <- data.table(
  Zona = c(1,2,3,4),
  c_w  = c(1.90, 3.20, 2.80, 3.85),
  k_w  = c(0.60, 1.35, 1.35, 1.95)
)

weibull_mu_sd <- function(c_w, k_w) {
  mu  <- c_w * gamma(1 + 1/k_w)
  var <- c_w^2 * (gamma(1 + 2/k_w) - (gamma(1 + 1/k_w))^2)
  sd  <- sqrt(pmax(var, 0))
  list(mu=mu, sd=sd)
}
cap_struct <- function(x, cap) pmin(x, cap)
clamp01 <- function(x) pmax(0, pmin(1, x))
fnrr_from_p <- function(p50, p90) {
  a <- log1p(p90); b <- log1p(p50)
  clamp01((a - b) / (a + 1e-12))
}

hours_in_q <- function(y, q) {
  m0 <- (q-1L)*3L + 1L
  st <- as.POSIXct(sprintf("%04d-%02d-01 00:00:00", y, m0), tz="UTC")
  y2 <- y + (q==4L)
  q2 <- if (q==4L) 1L else (q+1L)
  m1 <- (q2-1L)*3L + 1L
  en <- as.POSIXct(sprintf("%04d-%02d-01 00:00:00", y2, m1), tz="UTC")
  as.integer(difftime(en, st, units="hours"))
}

# -------------------------
# 3) Leer cache y CREAR time (parser multi-formato, sin tz(x))
# -------------------------
cat(format(Sys.time(), "%F %T"), "| Leyendo:", CACHE_FILE, "\n")
dt <- fread(CACHE_FILE, showProgress=TRUE)

clean_names <- function(x){
  x <- gsub("^\ufeff","", x)
  x <- gsub("[\r\n\t]","", x)
  trimws(x)
}
setnames(dt, clean_names(names(dt)))
nms_low <- tolower(names(dt))

time_idx <- which(nms_low %in% c("fechahora","fechayhora","fecha_hora","datetime","date_time","timestamp","time"))
if (length(time_idx) == 0) time_idx <- which(grepl("fecha", nms_low) & grepl("hora", nms_low))
if (length(time_idx) == 0) time_idx <- which(grepl("datetime|timestamp", nms_low))
if (length(time_idx) == 0) stop("No detecté columna tiempo. Columnas: ", paste(names(dt), collapse=", "))
TIME_COL <- names(dt)[time_idx[1]]

parse_time_base <- function(x, tz_out="UTC") {
  if (inherits(x,"POSIXct")) return(as.POSIXct(x, tz=tz_out))
  if (inherits(x,"POSIXlt")) return(as.POSIXct(x, tz=tz_out))
  if (inherits(x,"Date"))   return(as.POSIXct(x, tz=tz_out))
  if (is.factor(x) || is.ordered(x)) x <- as.character(x)

  if (!is.numeric(x) && !is.character(x)) {
    x <- tryCatch(as.character(x), error=function(e) rep(NA_character_, length(x)))
  }

  # epoch numérico
  if (is.numeric(x)) {
    xx <- x[is.finite(x)]
    if (length(xx)==0) return(as.POSIXct(rep(NA, length(x)), origin="1970-01-01", tz=tz_out))
    med <- median(xx, na.rm=TRUE)
    div <- if (med > 1e14) 1e6 else if (med > 1e11) 1e3 else 1
    return(as.POSIXct(x/div, origin="1970-01-01", tz=tz_out))
  }

  # character multi-format
  x <- as.character(x)
  x <- gsub("^\ufeff","", x)
  x <- trimws(gsub("[\r\n\t]", " ", x))
  x[x==""] <- NA_character_

  fmts <- c(
    "%Y-%m-%d %H:%M:%S", "%Y-%m-%d %H:%M",
    "%Y/%m/%d %H:%M:%S", "%Y/%m/%d %H:%M",
    "%Y%m%d %H:%M:%S",   "%Y%m%d %H:%M",
    "%d/%m/%Y %H:%M:%S", "%d/%m/%Y %H:%M",
    "%m/%d/%Y %H:%M:%S", "%m/%d/%Y %H:%M",
    "%d-%m-%Y %H:%M:%S", "%d-%m-%Y %H:%M",
    "%Y-%m-%d %I:%M:%S %p", "%Y-%m-%d %I:%M %p",
    "%d/%m/%Y %I:%M:%S %p", "%d/%m/%Y %I:%M %p",
    "%m/%d/%Y %I:%M:%S %p", "%m/%d/%Y %I:%M %p"
  )

  out <- rep(as.POSIXct(NA, tz=tz_out), length(x))
  for (fmt in fmts) {
    idx <- which(is.na(out) & !is.na(x))
    if (length(idx)==0) break
    tt <- suppressWarnings(as.POSIXct(strptime(x[idx], format=fmt, tz=tz_out), tz=tz_out))
    ok <- !is.na(tt)
    if (any(ok)) out[idx[ok]] <- tt[ok]
  }
  out
}

dt[, time := parse_time_base(dt[[TIME_COL]], tz_out="UTC")]
if (!inherits(dt$time, "POSIXct")) stop("time NO es POSIXct. class=", paste(class(dt$time), collapse=", "))

na_rate <- mean(is.na(dt$time))
if (!is.finite(na_rate)) na_rate <- 1
if (na_rate > 0.05) {
  bad <- unique(as.character(dt[is.na(time), ..TIME_COL][[1]]))
  bad <- bad[1:min(25, length(bad))]
  stop(
    "Fallo parseo time: NA rate=", round(100*na_rate,2), "% | TIME_COL=", TIME_COL, "\n",
    "Ejemplos que NO parsean:\n- ", paste(bad, collapse="\n- ")
  )
}

# Normalizar Zona/WPD/Eh
if (!"Zona" %in% names(dt)) stop("Falta 'Zona'.")
dt[, Zona := as.integer(Zona)]

if (!"WPD" %in% names(dt)) {
  widx <- which(tolower(names(dt)) %in% c("wpd","wpd_w_m2","wpd_wm2","wpd_tdq","wpd_mean"))
  if (length(widx)==0) stop("No detecté WPD. Columnas: ", paste(names(dt), collapse=", "))
  setnames(dt, names(dt)[widx[1]], "WPD")
}
dt[, WPD := pmax(as.numeric(WPD), 0)]

if (!"Eh" %in% names(dt)) {
  eidx <- which(tolower(names(dt)) %in% c("eh","eh_kwh_m2","eh_kwhm2","eh_tdq","energy"))
  if (length(eidx)==0) stop("No detecté Eh. Columnas: ", paste(names(dt), collapse=", "))
  setnames(dt, names(dt)[eidx[1]], "Eh")
}
dt[, Eh := pmax(as.numeric(Eh), 0)]

# ventana observada
dt <- dt[!is.na(Zona) & !is.na(time)]
dt <- dt[time >= START_DT & time <= CUTOFF_END]
dt <- dt[is.finite(WPD) & is.finite(Eh)]
setorder(dt, Zona, time)

zones <- sort(unique(dt$Zona))
if (length(zones) < 1) stop("No hay datos en 2017-01 a 2022-06.")
cat(format(Sys.time(), "%F %T"), "| OK | zones:", paste(zones, collapse=", "), "| rows:", nrow(dt), "\n")

# -------------------------
# 3.1) FIX CRÍTICO: eliminar duplicados (Zona,time) para evitar cartesian join
# -------------------------
dupN <- dt[, .N, by=.(Zona, time)][N > 1]
if (nrow(dupN) > 0) {
  cat("⚠️ Duplicados detectados en (Zona,time):", nrow(dupN), "claves con repetición.\n")
  print(head(dupN, 10))
  fwrite(dupN, file.path(OUT, "DEBUG_DUPLICADOS_Zona_time.csv"))

  dt <- dt[, .(
    WPD = mean(WPD, na.rm=TRUE),
    Eh  = mean(Eh , na.rm=TRUE)
  ), by=.(Zona, time)]
  setorder(dt, Zona, time)
  cat("✅ dt colapsado: filas =", nrow(dt), "y claves únicas (Zona,time).\n")
} else {
  cat("✅ No hay duplicados en (Zona,time).\n")
}

# -------------------------
# 4) TDQ orden: grilla completa + imputación Month-Hour
# -------------------------
full_grid <- rbindlist(lapply(zones, function(z){
  data.table(Zona=z, time=seq(START_DT, CUTOFF_END, by="hour"))
}))

setkey(full_grid, Zona, time)
setkey(dt, Zona, time)

obs <- copy(dt)

# join SEGURO (evita cartesian): grilla recibe observados
dt2 <- dt[full_grid, on=.(Zona, time)]

# blindajes post-join
dt2[, time := as.POSIXct(time, tz="UTC")]
obs[, time := as.POSIXct(time, tz="UTC")]

stopifnot(inherits(dt2$time, "POSIXct"))
stopifnot(length(dt2$time) == nrow(dt2))

# Month/Hour vectorizado real
dt2[, `:=`(
  Month = as.integer(format(time, "%m", tz="UTC")),
  Hour  = as.integer(format(time, "%H", tz="UTC"))
)]

prof_mh <- dt2[!is.na(WPD), .(
  WPD_med = median(WPD, na.rm=TRUE),
  Eh_med  = median(Eh , na.rm=TRUE)
), by=.(Zona, Month, Hour)]
setkey(prof_mh, Zona, Month, Hour)

prof_h <- dt2[!is.na(WPD), .(
  WPD_med2 = median(WPD, na.rm=TRUE),
  Eh_med2  = median(Eh , na.rm=TRUE)
), by=.(Zona, Hour)]
setkey(prof_h, Zona, Hour)

glob_wpd <- median(dt2$WPD, na.rm=TRUE); if (!is.finite(glob_wpd)) glob_wpd <- 0
glob_eh  <- median(dt2$Eh , na.rm=TRUE); if (!is.finite(glob_eh )) glob_eh  <- 0

dt2 <- prof_mh[dt2, on=.(Zona, Month, Hour)]
dt2 <- prof_h[dt2,  on=.(Zona, Hour)]

dt2[is.na(WPD), WPD := fifelse(!is.na(WPD_med), WPD_med,
                               fifelse(!is.na(WPD_med2), WPD_med2, glob_wpd))]
dt2[is.na(Eh),  Eh  := fifelse(!is.na(Eh_med),  Eh_med,
                               fifelse(!is.na(Eh_med2), Eh_med2,  glob_eh ))]
dt2[, c("WPD_med","Eh_med","WPD_med2","Eh_med2") := NULL]

# Regularización física Zona 1 (Weibull mu+2sd) + coherencia energía
row_w1 <- WEIBULL_PARAMS[Zona==1]
if (1 %in% zones && nrow(row_w1)==1 && row_w1$c_w>0 && row_w1$k_w>0) {
  ws1 <- weibull_mu_sd(row_w1$c_w, row_w1$k_w)
  cap1 <- ws1$mu + 2*ws1$sd
  dt2[Zona==1, WPD := cap_struct(WPD, cap1)]
  dt2[Zona==1, Eh  := WPD/1000]  # kWh/m2 por hora coherente
}

# -------------------------
# 5) Trimestral observado + coverage
# -------------------------
dt2[, `:=`(
  Year  = as.integer(format(time, "%Y", tz="UTC")),
  Month = as.integer(format(time, "%m", tz="UTC"))
)]
dt2[, Q  := ((Month - 1L) %/% 3L) + 1L]
dt2[, YQ := paste0(Year, " Q", Q)]

obs[, `:=`(
  Year  = as.integer(format(time, "%Y", tz="UTC")),
  Month = as.integer(format(time, "%m", tz="UTC"))
)]
obs[, Q  := ((Month - 1L) %/% 3L) + 1L]
obs[, YQ := paste0(Year, " Q", Q)]

obs_cov <- obs[, .(horas_obs=.N), by=.(Zona,Year,Q,YQ)]
obs_cov[, horas_teo := mapply(hours_in_q, Year, Q)]
obs_cov[, coverage  := pmin(1, horas_obs/horas_teo)]

tri <- dt2[, .(
  horas_teo = .N,
  WPD_p50   = as.numeric(quantile(WPD, 0.50, na.rm=TRUE)),
  WPD_p90   = as.numeric(quantile(WPD, 0.90, na.rm=TRUE)),
  WPD_mean  = mean(WPD, na.rm=TRUE),
  E_free    = sum(Eh, na.rm=TRUE)     # kWh/m2 por trimestre
), by=.(Zona,Year,Q,YQ)]

tri <- merge(tri, obs_cov[,.(Zona,Year,Q,YQ,horas_obs,coverage)],
             by=c("Zona","Year","Q","YQ"), all.x=TRUE)
tri[is.na(horas_obs), `:=`(horas_obs=0L, coverage=0)]

tri[, FNRR := fnrr_from_p(WPD_p50, WPD_p90)]
tri[, coh  := 1 - FNRR]
tri[, E_usable := E_free * coh]

# -------------------------
# 6) Forecast trimestral 2022Q3-2028Q4 (ARIMA estacional en log1p)
# -------------------------
future_yq <- c()
for (y in LAST_OBS_Y:END_Y) for (q in 1:4)
  if (y > LAST_OBS_Y || (y==LAST_OBS_Y && q > LAST_OBS_Q)) future_yq <- c(future_yq, paste0(y," Q",q))
h <- length(future_yq)

fit_fc <- function(x, h, level=90){
  x <- pmax(as.numeric(x), 0)
  lx <- log1p(x)
  if (anyNA(lx)) lx <- as.numeric(na.interp(ts(lx, frequency=4, start=c(2017,1))))
  tsx <- ts(lx, frequency=4, start=c(2017,1))
  fit <- auto.arima(tsx, seasonal=TRUE, stepwise=TRUE, approximation=TRUE)
  forecast(fit, h=h, level=level)
}
back <- function(fc){
  list(
    mean = pmax(expm1(as.numeric(fc$mean)), 0),
    lo   = pmax(expm1(as.numeric(fc$lower[,1])), 0),
    hi   = pmax(expm1(as.numeric(fc$upper[,1])), 0)
  )
}

future_list <- list()

for (z in zones) {
  tri_z <- tri[Zona==z][order(Year,Q)]

  base_yq <- c()
  for (y in 2017:LAST_OBS_Y) for (q in 1:4)
    if (y < LAST_OBS_Y || (y==LAST_OBS_Y && q<=LAST_OBS_Q)) base_yq <- c(base_yq, paste0(y," Q",q))

  base_dt <- data.table(YQ=base_yq)
  tri_z <- merge(base_dt, tri_z[,.(YQ, WPD_p50, WPD_p90, E_free)], by="YQ", all.x=TRUE)

  fc50 <- back(fit_fc(tri_z$WPD_p50, h=h, level=LEVEL_PI))
  fc90 <- back(fit_fc(tri_z$WPD_p90, h=h, level=LEVEL_PI))
  fcE  <- back(fit_fc(tri_z$E_free , h=h, level=LEVEL_PI))

  fut <- data.table(
    Zona=z,
    YQ=future_yq,
    Year=as.integer(substr(future_yq,1,4)),
    Q=as.integer(sub(".*Q","",future_yq)),
    horas_teo=mapply(hours_in_q,
                     as.integer(substr(future_yq,1,4)),
                     as.integer(sub(".*Q","",future_yq))),
    horas_obs=0L,
    coverage=1,

    WPD_p50=fc50$mean,
    WPD_p90=fc90$mean,
    E_free=fcE$mean,

    E_free_lo=fcE$lo,
    E_free_hi=fcE$hi
  )

  fut[, WPD_mean := 0.6*WPD_p50 + 0.4*WPD_p90]
  fut[, FNRR := fnrr_from_p(WPD_p50, WPD_p90)]
  fut[, coh  := 1 - FNRR]
  fut[, E_usable := E_free * coh]

  # Regularización física Zona 1 + coherencia física energía
  if (z==1 && nrow(row_w1)==1 && row_w1$c_w>0 && row_w1$k_w>0) {
    ws1 <- weibull_mu_sd(row_w1$c_w, row_w1$k_w)
    cap1 <- ws1$mu + 2*ws1$sd
    fut[, WPD_p50  := cap_struct(WPD_p50 , cap1)]
    fut[, WPD_p90  := cap_struct(WPD_p90 , cap1)]
    fut[, WPD_mean := cap_struct(WPD_mean, cap1)]
    fut[, E_free   := (WPD_mean/1000) * horas_teo]
    fut[, E_usable := E_free * (1 - FNRR)]
  }

  future_list[[as.character(z)]] <- fut
}

future_tri <- rbindlist(future_list, fill=TRUE)

tri_all <- rbindlist(list(
  tri[, .(Zona,Year,Q,YQ,horas_teo,horas_obs,coverage,WPD_p50,WPD_p90,WPD_mean,E_free,E_usable,FNRR,coh)],
  future_tri[, .(Zona,Year,Q,YQ,horas_teo,horas_obs,coverage,WPD_p50,WPD_p90,WPD_mean,E_free,E_usable,FNRR,coh,E_free_lo,E_free_hi)]
), fill=TRUE)
setorder(tri_all, Zona, Year, Q)

# -------------------------
# 7) Anual
# -------------------------
ann <- tri_all[, .(
  horas_teo = sum(horas_teo),
  horas_obs = sum(horas_obs),
  coverage  = weighted.mean(coverage, w=horas_teo),

  WPD_mean  = weighted.mean(WPD_mean, w=horas_teo),
  WPD_p50   = weighted.mean(WPD_p50 , w=horas_teo),
  WPD_p90   = weighted.mean(WPD_p90 , w=horas_teo),

  E_free    = sum(E_free),
  E_usable  = sum(E_usable),

  FNRR      = weighted.mean(FNRR, w=horas_teo),
  coh       = weighted.mean(coh , w=horas_teo),

  E_free_lo = sum(E_free_lo, na.rm=TRUE),
  E_free_hi = sum(E_free_hi, na.rm=TRUE)
), by=.(Zona,Year)]
ann[, E_usable_lo := E_free_lo * (1 - FNRR)]
ann[, E_usable_hi := E_free_hi * (1 - FNRR)]
setorder(ann, Zona, Year)

# -------------------------
# 8) Export
# -------------------------
fwrite(tri_all, file.path(OUT, "CAP4_TDQ_TRIMESTRAL_2017_2028.csv"))
fwrite(ann,     file.path(OUT, "CAP4_TDQ_ANUAL_2017_2028.csv"))

# -------------------------
# 9) Figuras publicables
# -------------------------
theme_pub <- theme_bw(base_size=12) +
  theme(panel.grid.minor=element_blank(),
        legend.position="bottom",
        plot.title=element_text(face="bold"),
        axis.title=element_text(face="bold"))

tri_plot <- copy(tri_all)
tri_plot[, t_index := as.Date(sprintf("%04d-%02d-01", Year, (Q-1L)*3L + 1L))]

p1 <- ggplot(tri_plot, aes(t_index, WPD_mean, color=factor(Zona), group=factor(Zona))) +
  geom_line(linewidth=0.9) + geom_point(size=1.2) +
  geom_vline(xintercept=as.Date("2022-04-01"), linetype="dashed") +
  labs(title="WPD trimestral TDQ (2017-2028)", x="Inicio de trimestre", y="WPD (W/m2)", color="Zona") +
  theme_pub
ggsave(file.path(OUT, "FIG_CAP4_WPD_TRIMESTRAL_TDQ_2017_2028.png"), p1, width=12, height=5, dpi=300)

p2 <- ggplot(ann, aes(Year)) +
  geom_ribbon(aes(ymin=E_free_lo, ymax=E_free_hi, fill=factor(Zona), group=factor(Zona)), alpha=0.15, color=NA) +
  geom_line(aes(y=E_free,   color=factor(Zona), group=factor(Zona)), linewidth=0.9) +
  geom_line(aes(y=E_usable, color=factor(Zona), group=factor(Zona)), linewidth=0.9, linetype="dotted") +
  geom_point(aes(y=E_free,   color=factor(Zona)), size=1.1) +
  geom_point(aes(y=E_usable, color=factor(Zona)), size=1.0, shape=1) +
  labs(title="Energía anual (kWh/m2): libre vs usable + PI90", x="Año", y="Energía (kWh/m2)", color="Zona", fill="Zona") +
  theme_pub
ggsave(file.path(OUT, "FIG_CAP4_ENERGIA_ANUAL_LIBRE_USABLE_PI90.png"), p2, width=12, height=5, dpi=300)

p3 <- ggplot(ann, aes(Year, FNRR, color=factor(Zona), group=factor(Zona))) +
  geom_line(linewidth=0.9) + geom_point(size=1.2) +
  scale_y_continuous(limits=c(0,1)) +
  labs(title="FNRR anual TDQ (2017-2028)", x="Año", y="FNRR (0-1)", color="Zona") +
  theme_pub
ggsave(file.path(OUT, "FIG_CAP4_FNRR_ANUAL_TDQ_2017_2028.png"), p3, width=12, height=5, dpi=300)

cat("\n==============================================\n")
cat("OK ✅ CAP4 TDQ FINAL (SIN lubridate)\nOUT:", OUT, "\n")
cat("Tablas: CAP4_TDQ_TRIMESTRAL_2017_2028.csv | CAP4_TDQ_ANUAL_2017_2028.csv\n")
cat("Figuras: WPD trimestral | Energía anual + PI90 | FNRR anual\n")
cat("==============================================\n")





# ============================================================
# CAP4 - TDQ CIERRE FINAL (ANTI-ERRORES + AJUSTE FINO) | WPD + Eh + PI90 + FNRR
# SIN lubridate
# Trimestral + Anual, Forecast 2022Q3-2028Q4
# Regularización física Zona 1 (Weibull mu + 2sd)
# PI90 ANUAL: por simulación (Monte Carlo) en log1p (nivel doctoral)
# ============================================================

req <- c("data.table","forecast","ggplot2","scales")
for (p in req) if (!requireNamespace(p, quietly=TRUE)) install.packages(p, dependencies=TRUE)
suppressPackageStartupMessages({
  library(data.table); library(forecast); library(ggplot2); library(scales)
})

# -------------------------
# 1) Rutas
# -------------------------
ROOT <- ""  # <-- set path
OUT  <- file.path(ROOT, "SALIDAS_CAP4_TDQ_FINAL")
dir.create(OUT, showWarnings=FALSE, recursive=TRUE)

CACHE_FILE <- file.path(ROOT, "SALIDAS_CAP4_CACHE", "WPD_Eh_hourly_por_zona.csv")
if (!file.exists(CACHE_FILE)) stop("No existe CACHE_FILE: ", CACHE_FILE)

# -------------------------
# 2) Parámetros
# -------------------------
LEVEL_PI <- 90
START_DT   <- as.POSIXct("2017-01-01 00:00:00", tz="UTC")
CUTOFF_END <- as.POSIXct("2022-06-30 23:00:00", tz="UTC")

LAST_OBS_Y <- 2022
LAST_OBS_Q <- 2
END_Y <- 2028
END_Q <- 4

# Simulación PI anual (sube a 5000 si quieres más suave)
NSIM_PI_ANUAL <- 3000

WEIBULL_PARAMS <- data.table(
  Zona = c(1,2,3,4),
  c_w  = c(1.90, 3.20, 2.80, 3.85),
  k_w  = c(0.60, 1.35, 1.35, 1.95)
)

weibull_mu_sd <- function(c_w, k_w) {
  mu  <- c_w * gamma(1 + 1/k_w)
  var <- c_w^2 * (gamma(1 + 2/k_w) - (gamma(1 + 1/k_w))^2)
  sd  <- sqrt(pmax(var, 0))
  list(mu=mu, sd=sd)
}
cap_struct <- function(x, cap) pmin(x, cap)
clamp01 <- function(x) pmax(0, pmin(1, x))
fnrr_from_p <- function(p50, p90) {
  a <- log1p(p90); b <- log1p(p50)
  clamp01((a - b) / (a + 1e-12))
}

hours_in_q <- function(y, q) {
  m0 <- (q-1L)*3L + 1L
  st <- as.POSIXct(sprintf("%04d-%02d-01 00:00:00", y, m0), tz="UTC")
  y2 <- y + (q==4L)
  q2 <- if (q==4L) 1L else (q+1L)
  m1 <- (q2-1L)*3L + 1L
  en <- as.POSIXct(sprintf("%04d-%02d-01 00:00:00", y2, m1), tz="UTC")
  as.integer(difftime(en, st, units="hours"))
}

# -------------------------
# 3) Leer cache y CREAR time (parser multi-formato)
# -------------------------
cat(format(Sys.time(), "%F %T"), "| Leyendo:", CACHE_FILE, "\n")
dt <- fread(CACHE_FILE, showProgress=TRUE)

clean_names <- function(x){
  x <- gsub("^\ufeff","", x)
  x <- gsub("[\r\n\t]","", x)
  trimws(x)
}
setnames(dt, clean_names(names(dt)))
nms_low <- tolower(names(dt))

time_idx <- which(nms_low %in% c("fechahora","fechayhora","fecha_hora","datetime","date_time","timestamp","time"))
if (length(time_idx) == 0) time_idx <- which(grepl("fecha", nms_low) & grepl("hora", nms_low))
if (length(time_idx) == 0) time_idx <- which(grepl("datetime|timestamp", nms_low))
if (length(time_idx) == 0) stop("No detecté columna tiempo. Columnas: ", paste(names(dt), collapse=", "))
TIME_COL <- names(dt)[time_idx[1]]

parse_time_base <- function(x, tz_out="UTC") {
  if (inherits(x,"POSIXct")) return(as.POSIXct(x, tz=tz_out))
  if (inherits(x,"POSIXlt")) return(as.POSIXct(x, tz=tz_out))
  if (inherits(x,"Date"))   return(as.POSIXct(x, tz=tz_out))
  if (is.factor(x) || is.ordered(x)) x <- as.character(x)

  if (!is.numeric(x) && !is.character(x)) {
    x <- tryCatch(as.character(x), error=function(e) rep(NA_character_, length(x)))
  }

  if (is.numeric(x)) {
    xx <- x[is.finite(x)]
    if (length(xx)==0) return(as.POSIXct(rep(NA, length(x)), origin="1970-01-01", tz=tz_out))
    med <- median(xx, na.rm=TRUE)
    div <- if (med > 1e14) 1e6 else if (med > 1e11) 1e3 else 1
    return(as.POSIXct(x/div, origin="1970-01-01", tz=tz_out))
  }

  x <- as.character(x)
  x <- gsub("^\ufeff","", x)
  x <- trimws(gsub("[\r\n\t]", " ", x))
  x[x==""] <- NA_character_

  fmts <- c(
    "%Y-%m-%d %H:%M:%S", "%Y-%m-%d %H:%M",
    "%Y/%m/%d %H:%M:%S", "%Y/%m/%d %H:%M",
    "%Y%m%d %H:%M:%S",   "%Y%m%d %H:%M",
    "%d/%m/%Y %H:%M:%S", "%d/%m/%Y %H:%M",
    "%m/%d/%Y %H:%M:%S", "%m/%d/%Y %H:%M",
    "%d-%m-%Y %H:%M:%S", "%d-%m-%Y %H:%M",
    "%Y-%m-%d %I:%M:%S %p", "%Y-%m-%d %I:%M %p",
    "%d/%m/%Y %I:%M:%S %p", "%d/%m/%Y %I:%M %p",
    "%m/%d/%Y %I:%M:%S %p", "%m/%d/%Y %I:%M %p"
  )

  out <- rep(as.POSIXct(NA, tz=tz_out), length(x))
  for (fmt in fmts) {
    idx <- which(is.na(out) & !is.na(x))
    if (length(idx)==0) break
    tt <- suppressWarnings(as.POSIXct(strptime(x[idx], format=fmt, tz=tz_out), tz=tz_out))
    ok <- !is.na(tt)
    if (any(ok)) out[idx[ok]] <- tt[ok]
  }
  out
}

dt[, time := parse_time_base(dt[[TIME_COL]], tz_out="UTC")]
if (!inherits(dt$time, "POSIXct")) stop("time NO es POSIXct. class=", paste(class(dt$time), collapse=", "))

na_rate <- mean(is.na(dt$time))
if (!is.finite(na_rate)) na_rate <- 1
if (na_rate > 0.05) {
  bad <- unique(as.character(dt[is.na(time), ..TIME_COL][[1]]))
  bad <- bad[1:min(25, length(bad))]
  stop(
    "Fallo parseo time: NA rate=", round(100*na_rate,2), "% | TIME_COL=", TIME_COL, "\n",
    "Ejemplos que NO parsean:\n- ", paste(bad, collapse="\n- ")
  )
}

# Normalizar Zona/WPD/Eh
if (!"Zona" %in% names(dt)) stop("Falta 'Zona'.")
dt[, Zona := as.integer(Zona)]

if (!"WPD" %in% names(dt)) {
  widx <- which(tolower(names(dt)) %in% c("wpd","wpd_w_m2","wpd_wm2","wpd_tdq","wpd_mean"))
  if (length(widx)==0) stop("No detecté WPD. Columnas: ", paste(names(dt), collapse=", "))
  setnames(dt, names(dt)[widx[1]], "WPD")
}
dt[, WPD := pmax(as.numeric(WPD), 0)]

if (!"Eh" %in% names(dt)) {
  eidx <- which(tolower(names(dt)) %in% c("eh","eh_kwh_m2","eh_kwhm2","eh_tdq","energy"))
  if (length(eidx)==0) stop("No detecté Eh. Columnas: ", paste(names(dt), collapse=", "))
  setnames(dt, names(dt)[eidx[1]], "Eh")
}
dt[, Eh := pmax(as.numeric(Eh), 0)]

# ventana observada
dt <- dt[!is.na(Zona) & !is.na(time)]
dt <- dt[time >= START_DT & time <= CUTOFF_END]
dt <- dt[is.finite(WPD) & is.finite(Eh)]
setorder(dt, Zona, time)

zones <- sort(unique(dt$Zona))
if (length(zones) < 1) stop("No hay datos en 2017-01 a 2022-06.")
cat(format(Sys.time(), "%F %T"), "| OK | zones:", paste(zones, collapse=", "), "| rows:", nrow(dt), "\n")

# -------------------------
# 3.1) FIX CRÍTICO: eliminar duplicados (Zona,time)
# -------------------------
dupN <- dt[, .N, by=.(Zona, time)][N > 1]
if (nrow(dupN) > 0) {
  cat("⚠️ Duplicados detectados en (Zona,time):", nrow(dupN), "claves con repetición.\n")
  print(head(dupN, 10))
  fwrite(dupN, file.path(OUT, "DEBUG_DUPLICADOS_Zona_time.csv"))

  dt <- dt[, .(
    WPD = mean(WPD, na.rm=TRUE),
    Eh  = mean(Eh , na.rm=TRUE)
  ), by=.(Zona, time)]
  setorder(dt, Zona, time)
  cat("✅ dt colapsado: filas =", nrow(dt), "y claves únicas (Zona,time).\n")
} else {
  cat("✅ No hay duplicados en (Zona,time).\n")
}

# -------------------------
# 4) TDQ orden: grilla completa + imputación Month-Hour
# -------------------------
full_grid <- rbindlist(lapply(zones, function(z){
  data.table(Zona=z, time=seq(START_DT, CUTOFF_END, by="hour"))
}))

setkey(full_grid, Zona, time)
setkey(dt, Zona, time)

obs <- copy(dt)

# join seguro: grilla recibe observados
dt2 <- dt[full_grid, on=.(Zona, time)]

dt2[, time := as.POSIXct(time, tz="UTC")]
obs[, time := as.POSIXct(time, tz="UTC")]

stopifnot(inherits(dt2$time, "POSIXct"))
stopifnot(length(dt2$time) == nrow(dt2))

dt2[, `:=`(
  Month = as.integer(format(time, "%m", tz="UTC")),
  Hour  = as.integer(format(time, "%H", tz="UTC"))
)]

prof_mh <- dt2[!is.na(WPD), .(
  WPD_med = median(WPD, na.rm=TRUE),
  Eh_med  = median(Eh , na.rm=TRUE)
), by=.(Zona, Month, Hour)]
setkey(prof_mh, Zona, Month, Hour)

prof_h <- dt2[!is.na(WPD), .(
  WPD_med2 = median(WPD, na.rm=TRUE),
  Eh_med2  = median(Eh , na.rm=TRUE)
), by=.(Zona, Hour)]
setkey(prof_h, Zona, Hour)

glob_wpd <- median(dt2$WPD, na.rm=TRUE); if (!is.finite(glob_wpd)) glob_wpd <- 0
glob_eh  <- median(dt2$Eh , na.rm=TRUE); if (!is.finite(glob_eh )) glob_eh  <- 0

dt2 <- prof_mh[dt2, on=.(Zona, Month, Hour)]
dt2 <- prof_h[dt2,  on=.(Zona, Hour)]

dt2[is.na(WPD), WPD := fifelse(!is.na(WPD_med), WPD_med,
                               fifelse(!is.na(WPD_med2), WPD_med2, glob_wpd))]
dt2[is.na(Eh),  Eh  := fifelse(!is.na(Eh_med),  Eh_med,
                               fifelse(!is.na(Eh_med2), Eh_med2,  glob_eh ))]
dt2[, c("WPD_med","Eh_med","WPD_med2","Eh_med2") := NULL]

# Regularización física Zona 1 (Weibull mu+2sd) + coherencia energía
row_w1 <- WEIBULL_PARAMS[Zona==1]
if (1 %in% zones && nrow(row_w1)==1 && row_w1$c_w>0 && row_w1$k_w>0) {
  ws1 <- weibull_mu_sd(row_w1$c_w, row_w1$k_w)
  cap1 <- ws1$mu + 2*ws1$sd
  dt2[Zona==1, WPD := cap_struct(WPD, cap1)]
  dt2[Zona==1, Eh  := WPD/1000]
}

# -------------------------
# 5) Trimestral observado + coverage
# -------------------------
dt2[, `:=`(
  Year  = as.integer(format(time, "%Y", tz="UTC")),
  Month = as.integer(format(time, "%m", tz="UTC"))
)]
dt2[, Q  := ((Month - 1L) %/% 3L) + 1L]
dt2[, YQ := paste0(Year, " Q", Q)]

obs[, `:=`(
  Year  = as.integer(format(time, "%Y", tz="UTC")),
  Month = as.integer(format(time, "%m", tz="UTC"))
)]
obs[, Q  := ((Month - 1L) %/% 3L) + 1L]
obs[, YQ := paste0(Year, " Q", Q)]

obs_cov <- obs[, .(horas_obs=.N), by=.(Zona,Year,Q,YQ)]
obs_cov[, horas_teo := mapply(hours_in_q, Year, Q)]
obs_cov[, coverage  := pmin(1, horas_obs/horas_teo)]

tri <- dt2[, .(
  horas_teo = .N,
  WPD_p50   = as.numeric(quantile(WPD, 0.50, na.rm=TRUE)),
  WPD_p90   = as.numeric(quantile(WPD, 0.90, na.rm=TRUE)),
  WPD_mean  = mean(WPD, na.rm=TRUE),
  E_free    = sum(Eh, na.rm=TRUE)
), by=.(Zona,Year,Q,YQ)]

tri <- merge(tri, obs_cov[,.(Zona,Year,Q,YQ,horas_obs,coverage)],
             by=c("Zona","Year","Q","YQ"), all.x=TRUE)
tri[is.na(horas_obs), `:=`(horas_obs=0L, coverage=0)]

tri[, FNRR := fnrr_from_p(WPD_p50, WPD_p90)]
tri[, coh  := 1 - FNRR]
tri[, E_usable := E_free * coh]

# -------------------------
# 5.1) CAP físico suave para E_free (p99.5 histórico por zona)
# -------------------------
E_CAP <- tri[, .(
  E_cap_p995 = as.numeric(quantile(E_free, 0.995, na.rm=TRUE))
), by=Zona]

cap_soft <- function(x, cap_hi) pmin(x, cap_hi)

# -------------------------
# 6) Forecast trimestral 2022Q3-2028Q4 (ARIMA estacional en log1p)
# -------------------------
future_yq <- c()
for (y in LAST_OBS_Y:END_Y) for (q in 1:4)
  if (y > LAST_OBS_Y || (y==LAST_OBS_Y && q > LAST_OBS_Q)) future_yq <- c(future_yq, paste0(y," Q",q))
h <- length(future_yq)

fit_fc <- function(x, h, level=90){
  x <- pmax(as.numeric(x), 0)
  lx <- log1p(x)
  if (anyNA(lx)) lx <- as.numeric(na.interp(ts(lx, frequency=4, start=c(2017,1))))
  tsx <- ts(lx, frequency=4, start=c(2017,1))
  fit <- auto.arima(tsx, seasonal=TRUE, stepwise=TRUE, approximation=TRUE)
  forecast(fit, h=h, level=level)
}
back <- function(fc){
  list(
    mean = pmax(expm1(as.numeric(fc$mean)), 0),
    lo   = pmax(expm1(as.numeric(fc$lower[,1])), 0),
    hi   = pmax(expm1(as.numeric(fc$upper[,1])), 0)
  )
}

future_list <- list()

for (z in zones) {
  tri_z <- tri[Zona==z][order(Year,Q)]

  base_yq <- c()
  for (y in 2017:LAST_OBS_Y) for (q in 1:4)
    if (y < LAST_OBS_Y || (y==LAST_OBS_Y && q<=LAST_OBS_Q)) base_yq <- c(base_yq, paste0(y," Q",q))

  base_dt <- data.table(YQ=base_yq)
  tri_z <- merge(base_dt, tri_z[,.(YQ, WPD_p50, WPD_p90, E_free)], by="YQ", all.x=TRUE)

  fc50 <- back(fit_fc(tri_z$WPD_p50, h=h, level=LEVEL_PI))
  fc90 <- back(fit_fc(tri_z$WPD_p90, h=h, level=LEVEL_PI))
  fcE  <- back(fit_fc(tri_z$E_free , h=h, level=LEVEL_PI))

  fut <- data.table(
    Zona=z,
    YQ=future_yq,
    Year=as.integer(substr(future_yq,1,4)),
    Q=as.integer(sub(".*Q","",future_yq)),
    horas_teo=mapply(hours_in_q,
                     as.integer(substr(future_yq,1,4)),
                     as.integer(sub(".*Q","",future_yq))),
    horas_obs=0L,
    coverage=1,

    WPD_p50=fc50$mean,
    WPD_p90=fc90$mean,
    E_free=fcE$mean,

    E_free_lo=fcE$lo,
    E_free_hi=fcE$hi
  )

  # cap suave energía futuro (evita explosión)
  capz <- E_CAP[Zona==z]$E_cap_p995
  if (length(capz)==1 && is.finite(capz) && capz>0) {
    fut[, E_free := cap_soft(E_free, capz)]
    fut[, E_free_lo := pmin(E_free_lo, capz)]
    fut[, E_free_hi := pmin(E_free_hi, capz)]
  }

  fut[, WPD_mean := 0.6*WPD_p50 + 0.4*WPD_p90]
  fut[, FNRR := fnrr_from_p(WPD_p50, WPD_p90)]
  fut[, coh  := 1 - FNRR]
  fut[, E_usable := E_free * coh]

  # Regularización física Zona 1 + coherencia energía
  if (z==1 && nrow(row_w1)==1 && row_w1$c_w>0 && row_w1$k_w>0) {
    ws1 <- weibull_mu_sd(row_w1$c_w, row_w1$k_w)
    cap1 <- ws1$mu + 2*ws1$sd
    fut[, WPD_p50  := cap_struct(WPD_p50 , cap1)]
    fut[, WPD_p90  := cap_struct(WPD_p90 , cap1)]
    fut[, WPD_mean := cap_struct(WPD_mean, cap1)]
    fut[, E_free   := (WPD_mean/1000) * horas_teo]
    # cap también aquí
    capz2 <- E_CAP[Zona==z]$E_cap_p995
    if (length(capz2)==1 && is.finite(capz2) && capz2>0) {
      fut[, E_free := cap_soft(E_free, capz2)]
    }
    fut[, E_usable := E_free * (1 - FNRR)]
  }

  future_list[[as.character(z)]] <- fut
}

future_tri <- rbindlist(future_list, fill=TRUE)

tri_all <- rbindlist(list(
  tri[, .(Zona,Year,Q,YQ,horas_teo,horas_obs,coverage,WPD_p50,WPD_p90,WPD_mean,E_free,E_usable,FNRR,coh)],
  future_tri[, .(Zona,Year,Q,YQ,horas_teo,horas_obs,coverage,WPD_p50,WPD_p90,WPD_mean,E_free,E_usable,FNRR,coh,E_free_lo,E_free_hi)]
), fill=TRUE)
setorder(tri_all, Zona, Year, Q)

# -------------------------
# 7) Anual (PI90 por simulación Monte Carlo en log1p) - NIVEL DOCTORAL
# -------------------------

# simulación desde forecast (en log1p), devuelve en escala original
sim_from_fc_log <- function(fc, nsim=2000){
  mu <- as.numeric(fc$mean)
  z  <- 1.64485362695147  # PI90
  lo <- as.numeric(fc$lower[,1])
  hi <- as.numeric(fc$upper[,1])
  sd <- (hi - lo) / (2*z)
  sd[!is.finite(sd) | sd<=0] <- median(sd[is.finite(sd) & sd>0], na.rm=TRUE)
  if (!is.finite(sd[1])) sd <- rep(0.0, length(mu))

  sims <- matrix(rnorm(length(mu)*nsim, mean=rep(mu, nsim), sd=rep(sd, nsim)),
                 nrow=length(mu), ncol=nsim)
  pmax(expm1(sims), 0)
}

# anual histórico: sin PI (observado)
ann_hist <- tri_all[Year <= LAST_OBS_Y, .(
  horas_teo = sum(horas_teo),
  horas_obs = sum(horas_obs),
  coverage  = weighted.mean(coverage, w=horas_teo),

  WPD_mean  = weighted.mean(WPD_mean, w=horas_teo),
  WPD_p50   = weighted.mean(WPD_p50 , w=horas_teo),
  WPD_p90   = weighted.mean(WPD_p90 , w=horas_teo),

  E_free    = sum(E_free),
  E_usable  = sum(E_usable),

  FNRR      = weighted.mean(FNRR, w=horas_teo),
  coh       = weighted.mean(coh , w=horas_teo),

  E_free_lo = NA_real_,
  E_free_hi = NA_real_
), by=.(Zona,Year)]

# mapa de trimestres futuros -> año
fut_map <- data.table(
  YQ=future_yq,
  Year=as.integer(substr(future_yq,1,4)),
  Q=as.integer(sub(".*Q","",future_yq))
)
years_fut <- sort(unique(fut_map$Year))

ann_fut_list <- list()

for (z in zones) {

  # reconstruir serie E_free trimestral observada (hasta 2022Q2)
  tri_z <- tri[Zona==z][order(Year,Q)]
  base_yq <- c()
  for (y in 2017:LAST_OBS_Y) for (q in 1:4)
    if (y < LAST_OBS_Y || (y==LAST_OBS_Y && q<=LAST_OBS_Q)) base_yq <- c(base_yq, paste0(y," Q",q))
  base_dt <- data.table(YQ=base_yq)
  tri_z <- merge(base_dt, tri_z[,.(YQ, E_free)], by="YQ", all.x=TRUE)

  x <- pmax(as.numeric(tri_z$E_free), 0)
  lx <- log1p(x)
  if (anyNA(lx)) lx <- as.numeric(na.interp(ts(lx, frequency=4, start=c(2017,1))))
  tsx <- ts(lx, frequency=4, start=c(2017,1))
  fit <- auto.arima(tsx, seasonal=TRUE, stepwise=TRUE, approximation=TRUE)
  fc  <- forecast(fit, h=h, level=LEVEL_PI)

  # sim trimestral futuro
  sim_q <- sim_from_fc_log(fc, nsim=NSIM_PI_ANUAL)  # (h x nsim)

  # cap físico suave aplicado a simulación
  capz <- E_CAP[Zona==z]$E_cap_p995
  if (length(capz)==1 && is.finite(capz) && capz>0) {
    sim_q <- pmin(sim_q, capz)
  }

  # anual por suma de 4 trimestres, por simulación
  rows <- list()
  for (yy in years_fut) {
    idx <- which(fut_map$Year == yy)
    if (length(idx)==0) next
    sY <- colSums(sim_q[idx, , drop=FALSE])
    rows[[as.character(yy)]] <- data.table(
      Zona=z,
      Year=yy,
      E_free_lo = as.numeric(quantile(sY, 0.05, na.rm=TRUE)),
      E_free_hi = as.numeric(quantile(sY, 0.95, na.rm=TRUE))
    )
  }
  ann_fut_list[[as.character(z)]] <- rbindlist(rows, fill=TRUE)
}

ann_fut_pi <- rbindlist(ann_fut_list, fill=TRUE)

# anual base (incluye futuro) desde tri_all (mean)
ann_base <- tri_all[, .(
  horas_teo = sum(horas_teo),
  horas_obs = sum(horas_obs),
  coverage  = weighted.mean(coverage, w=horas_teo),

  WPD_mean  = weighted.mean(WPD_mean, w=horas_teo),
  WPD_p50   = weighted.mean(WPD_p50 , w=horas_teo),
  WPD_p90   = weighted.mean(WPD_p90 , w=horas_teo),

  E_free    = sum(E_free),
  E_usable  = sum(E_usable),

  FNRR      = weighted.mean(FNRR, w=horas_teo),
  coh       = weighted.mean(coh , w=horas_teo)
), by=.(Zona,Year)]

ann <- merge(ann_base, ann_fut_pi, by=c("Zona","Year"), all.x=TRUE)

# usable bounds por coherencia anual
ann[, E_usable_lo := E_free_lo * (1 - FNRR)]
ann[, E_usable_hi := E_free_hi * (1 - FNRR)]

# unir histórico (para dejar PI NA donde no aplica) + base con PI (futuro)
ann <- rbindlist(list(ann_hist, ann[Year > LAST_OBS_Y]), fill=TRUE)
setorder(ann, Zona, Year)

# -------------------------
# 8) Export
# -------------------------
fwrite(tri_all, file.path(OUT, "CAP4_TDQ_TRIMESTRAL_2017_2028.csv"))
fwrite(ann,     file.path(OUT, "CAP4_TDQ_ANUAL_2017_2028.csv"))

# -------------------------
# 9) Figuras publicables
# -------------------------
theme_pub <- theme_bw(base_size=12) +
  theme(panel.grid.minor=element_blank(),
        legend.position="bottom",
        plot.title=element_text(face="bold"),
        axis.title=element_text(face="bold"))

tri_plot <- copy(tri_all)
tri_plot[, t_index := as.Date(sprintf("%04d-%02d-01", Year, (Q-1L)*3L + 1L))]

p1 <- ggplot(tri_plot, aes(t_index, WPD_mean, color=factor(Zona), group=factor(Zona))) +
  geom_line(linewidth=0.9) + geom_point(size=1.2) +
  geom_vline(xintercept=as.Date("2022-04-01"), linetype="dashed") +
  labs(title="WPD trimestral TDQ (2017-2028)", x="Inicio de trimestre", y="WPD (W/m2)", color="Zona") +
  theme_pub
ggsave(file.path(OUT, "FIG_CAP4_WPD_TRIMESTRAL_TDQ_2017_2028.png"), p1, width=12, height=5, dpi=300)

ann_plot <- copy(ann)
ann_plot[, is_fc := Year > 2022]  # forecast desde 2023

p2 <- ggplot() +
  # PI90 solo futuro
  geom_ribbon(
    data = ann_plot[is_fc==TRUE],
    aes(x=Year, ymin=E_free_lo, ymax=E_free_hi, fill=factor(Zona), group=factor(Zona)),
    alpha=0.15, color=NA
  ) +
  # líneas
  geom_line(
    data=ann_plot,
    aes(x=Year, y=E_free, color=factor(Zona), group=factor(Zona)),
    linewidth=0.9
  ) +
  geom_line(
    data=ann_plot,
    aes(x=Year, y=E_usable, color=factor(Zona), group=factor(Zona)),
    linewidth=0.9, linetype="dotted"
  ) +
  # corte
  geom_vline(xintercept=2022.5, linetype="dashed") +
  labs(
    title="Energía anual (kWh/m2): libre vs usable + PI90",
    x="Año", y="Energía (kWh/m2)", color="Zona", fill="Zona"
  ) +
  theme_pub +
  scale_y_continuous(labels=scales::comma)

ggsave(file.path(OUT, "FIG_CAP4_ENERGIA_ANUAL_LIBRE_USABLE_PI90.png"),
       p2, width=12, height=5, dpi=300)
p3 <- ggplot(ann, aes(Year, FNRR, color=factor(Zona), group=factor(Zona))) +
  geom_line(linewidth=0.9) + geom_point(size=1.2) +
  scale_y_continuous(limits=c(0,1)) +
  labs(title="FNRR anual TDQ (2017-2028)", x="Año", y="FNRR (0-1)", color="Zona") +
  theme_pub
ggsave(file.path(OUT, "FIG_CAP4_FNRR_ANUAL_TDQ_2017_2028.png"), p3, width=12, height=5, dpi=300)

cat("\n==============================================\n")
cat("OK ✅ CAP4 TDQ FINAL + AJUSTE FINO\nOUT:", OUT, "\n")
cat("Tablas: CAP4_TDQ_TRIMESTRAL_2017_2028.csv | CAP4_TDQ_ANUAL_2017_2028.csv\n")
cat("Figuras: WPD trimestral | Energía anual + PI90 (sim) | FNRR anual\n")
cat("==============================================\n")



# ============================================================
# CAP4 - TDQ CIERRE FINAL (ANTI-ERRORES + AJUSTE FINO) | WPD + Eh + PI90 + FNRR
# SIN lubridate
# Trimestral + Anual, Forecast 2022Q3-2028Q4
# Regularización física Zona 1 (Weibull mu + 2sd)
# PI90 ANUAL: por simulación (Monte Carlo) en log1p (nivel doctoral)
# ============================================================

req <- c("data.table","forecast","ggplot2","scales")
for (p in req) if (!requireNamespace(p, quietly=TRUE)) install.packages(p, dependencies=TRUE)
suppressPackageStartupMessages({
  library(data.table); library(forecast); library(ggplot2); library(scales)
})

# -------------------------
# 1) Rutas
# -------------------------
ROOT <- ""  # <-- set path
OUT  <- file.path(ROOT, "SALIDAS_CAP4_TDQ_FINAL")
dir.create(OUT, showWarnings=FALSE, recursive=TRUE)

CACHE_FILE <- file.path(ROOT, "SALIDAS_CAP4_CACHE", "WPD_Eh_hourly_por_zona.csv")
if (!file.exists(CACHE_FILE)) stop("No existe CACHE_FILE: ", CACHE_FILE)

# -------------------------
# 2) Parámetros
# -------------------------
LEVEL_PI <- 90
START_DT   <- as.POSIXct("2017-01-01 00:00:00", tz="UTC")
CUTOFF_END <- as.POSIXct("2022-06-30 23:00:00", tz="UTC")

LAST_OBS_Y <- 2022
LAST_OBS_Q <- 2
END_Y <- 2028
END_Q <- 4

# Simulación PI anual (sube a 5000 si quieres más suave)
NSIM_PI_ANUAL <- 3000

WEIBULL_PARAMS <- data.table(
  Zona = c(1,2,3,4),
  c_w  = c(1.90, 3.20, 2.80, 3.85),
  k_w  = c(0.60, 1.35, 1.35, 1.95)
)

weibull_mu_sd <- function(c_w, k_w) {
  mu  <- c_w * gamma(1 + 1/k_w)
  var <- c_w^2 * (gamma(1 + 2/k_w) - (gamma(1 + 1/k_w))^2)
  sd  <- sqrt(pmax(var, 0))
  list(mu=mu, sd=sd)
}
cap_struct <- function(x, cap) pmin(x, cap)
clamp01 <- function(x) pmax(0, pmin(1, x))
fnrr_from_p <- function(p50, p90) {
  a <- log1p(p90); b <- log1p(p50)
  clamp01((a - b) / (a + 1e-12))
}

hours_in_q <- function(y, q) {
  m0 <- (q-1L)*3L + 1L
  st <- as.POSIXct(sprintf("%04d-%02d-01 00:00:00", y, m0), tz="UTC")
  y2 <- y + (q==4L)
  q2 <- if (q==4L) 1L else (q+1L)
  m1 <- (q2-1L)*3L + 1L
  en <- as.POSIXct(sprintf("%04d-%02d-01 00:00:00", y2, m1), tz="UTC")
  as.integer(difftime(en, st, units="hours"))
}

# -------------------------
# 3) Leer cache y CREAR time (parser multi-formato)
# -------------------------
cat(format(Sys.time(), "%F %T"), "| Leyendo:", CACHE_FILE, "\n")
dt <- fread(CACHE_FILE, showProgress=TRUE)

clean_names <- function(x){
  x <- gsub("^\ufeff","", x)
  x <- gsub("[\r\n\t]","", x)
  trimws(x)
}
setnames(dt, clean_names(names(dt)))
nms_low <- tolower(names(dt))

time_idx <- which(nms_low %in% c("fechahora","fechayhora","fecha_hora","datetime","date_time","timestamp","time"))
if (length(time_idx) == 0) time_idx <- which(grepl("fecha", nms_low) & grepl("hora", nms_low))
if (length(time_idx) == 0) time_idx <- which(grepl("datetime|timestamp", nms_low))
if (length(time_idx) == 0) stop("No detecté columna tiempo. Columnas: ", paste(names(dt), collapse=", "))
TIME_COL <- names(dt)[time_idx[1]]

parse_time_base <- function(x, tz_out="UTC") {
  if (inherits(x,"POSIXct")) return(as.POSIXct(x, tz=tz_out))
  if (inherits(x,"POSIXlt")) return(as.POSIXct(x, tz=tz_out))
  if (inherits(x,"Date"))   return(as.POSIXct(x, tz=tz_out))
  if (is.factor(x) || is.ordered(x)) x <- as.character(x)

  if (!is.numeric(x) && !is.character(x)) {
    x <- tryCatch(as.character(x), error=function(e) rep(NA_character_, length(x)))
  }

  if (is.numeric(x)) {
    xx <- x[is.finite(x)]
    if (length(xx)==0) return(as.POSIXct(rep(NA, length(x)), origin="1970-01-01", tz=tz_out))
    med <- median(xx, na.rm=TRUE)
    div <- if (med > 1e14) 1e6 else if (med > 1e11) 1e3 else 1
    return(as.POSIXct(x/div, origin="1970-01-01", tz=tz_out))
  }

  x <- as.character(x)
  x <- gsub("^\ufeff","", x)
  x <- trimws(gsub("[\r\n\t]", " ", x))
  x[x==""] <- NA_character_

  fmts <- c(
    "%Y-%m-%d %H:%M:%S", "%Y-%m-%d %H:%M",
    "%Y/%m/%d %H:%M:%S", "%Y/%m/%d %H:%M",
    "%Y%m%d %H:%M:%S",   "%Y%m%d %H:%M",
    "%d/%m/%Y %H:%M:%S", "%d/%m/%Y %H:%M",
    "%m/%d/%Y %H:%M:%S", "%m/%d/%Y %H:%M",
    "%d-%m-%Y %H:%M:%S", "%d-%m-%Y %H:%M",
    "%Y-%m-%d %I:%M:%S %p", "%Y-%m-%d %I:%M %p",
    "%d/%m/%Y %I:%M:%S %p", "%d/%m/%Y %I:%M %p",
    "%m/%d/%Y %I:%M:%S %p", "%m/%d/%Y %I:%M %p"
  )

  out <- rep(as.POSIXct(NA, tz=tz_out), length(x))
  for (fmt in fmts) {
    idx <- which(is.na(out) & !is.na(x))
    if (length(idx)==0) break
    tt <- suppressWarnings(as.POSIXct(strptime(x[idx], format=fmt, tz=tz_out), tz=tz_out))
    ok <- !is.na(tt)
    if (any(ok)) out[idx[ok]] <- tt[ok]
  }
  out
}

dt[, time := parse_time_base(dt[[TIME_COL]], tz_out="UTC")]
if (!inherits(dt$time, "POSIXct")) stop("time NO es POSIXct. class=", paste(class(dt$time), collapse=", "))

na_rate <- mean(is.na(dt$time))
if (!is.finite(na_rate)) na_rate <- 1
if (na_rate > 0.05) {
  bad <- unique(as.character(dt[is.na(time), ..TIME_COL][[1]]))
  bad <- bad[1:min(25, length(bad))]
  stop(
    "Fallo parseo time: NA rate=", round(100*na_rate,2), "% | TIME_COL=", TIME_COL, "\n",
    "Ejemplos que NO parsean:\n- ", paste(bad, collapse="\n- ")
  )
}

# Normalizar Zona/WPD/Eh
if (!"Zona" %in% names(dt)) stop("Falta 'Zona'.")
dt[, Zona := as.integer(Zona)]

if (!"WPD" %in% names(dt)) {
  widx <- which(tolower(names(dt)) %in% c("wpd","wpd_w_m2","wpd_wm2","wpd_tdq","wpd_mean"))
  if (length(widx)==0) stop("No detecté WPD. Columnas: ", paste(names(dt), collapse=", "))
  setnames(dt, names(dt)[widx[1]], "WPD")
}
dt[, WPD := pmax(as.numeric(WPD), 0)]

if (!"Eh" %in% names(dt)) {
  eidx <- which(tolower(names(dt)) %in% c("eh","eh_kwh_m2","eh_kwhm2","eh_tdq","energy"))
  if (length(eidx)==0) stop("No detecté Eh. Columnas: ", paste(names(dt), collapse=", "))
  setnames(dt, names(dt)[eidx[1]], "Eh")
}
dt[, Eh := pmax(as.numeric(Eh), 0)]

# ventana observada
dt <- dt[!is.na(Zona) & !is.na(time)]
dt <- dt[time >= START_DT & time <= CUTOFF_END]
dt <- dt[is.finite(WPD) & is.finite(Eh)]
setorder(dt, Zona, time)

zones <- sort(unique(dt$Zona))
if (length(zones) < 1) stop("No hay datos en 2017-01 a 2022-06.")
cat(format(Sys.time(), "%F %T"), "| OK | zones:", paste(zones, collapse=", "), "| rows:", nrow(dt), "\n")

# -------------------------
# 3.1) FIX CRÍTICO: eliminar duplicados (Zona,time)
# -------------------------
dupN <- dt[, .N, by=.(Zona, time)][N > 1]
if (nrow(dupN) > 0) {
  cat("⚠️ Duplicados detectados en (Zona,time):", nrow(dupN), "claves con repetición.\n")
  print(head(dupN, 10))
  fwrite(dupN, file.path(OUT, "DEBUG_DUPLICADOS_Zona_time.csv"))

  dt <- dt[, .(
    WPD = mean(WPD, na.rm=TRUE),
    Eh  = mean(Eh , na.rm=TRUE)
  ), by=.(Zona, time)]
  setorder(dt, Zona, time)
  cat("✅ dt colapsado: filas =", nrow(dt), "y claves únicas (Zona,time).\n")
} else {
  cat("✅ No hay duplicados en (Zona,time).\n")
}

# -------------------------
# 4) TDQ orden: grilla completa + imputación Month-Hour
# -------------------------
full_grid <- rbindlist(lapply(zones, function(z){
  data.table(Zona=z, time=seq(START_DT, CUTOFF_END, by="hour"))
}))

setkey(full_grid, Zona, time)
setkey(dt, Zona, time)

obs <- copy(dt)

# join seguro: grilla recibe observados
dt2 <- dt[full_grid, on=.(Zona, time)]

dt2[, time := as.POSIXct(time, tz="UTC")]
obs[, time := as.POSIXct(time, tz="UTC")]

stopifnot(inherits(dt2$time, "POSIXct"))
stopifnot(length(dt2$time) == nrow(dt2))

dt2[, `:=`(
  Month = as.integer(format(time, "%m", tz="UTC")),
  Hour  = as.integer(format(time, "%H", tz="UTC"))
)]

prof_mh <- dt2[!is.na(WPD), .(
  WPD_med = median(WPD, na.rm=TRUE),
  Eh_med  = median(Eh , na.rm=TRUE)
), by=.(Zona, Month, Hour)]
setkey(prof_mh, Zona, Month, Hour)

prof_h <- dt2[!is.na(WPD), .(
  WPD_med2 = median(WPD, na.rm=TRUE),
  Eh_med2  = median(Eh , na.rm=TRUE)
), by=.(Zona, Hour)]
setkey(prof_h, Zona, Hour)

glob_wpd <- median(dt2$WPD, na.rm=TRUE); if (!is.finite(glob_wpd)) glob_wpd <- 0
glob_eh  <- median(dt2$Eh , na.rm=TRUE); if (!is.finite(glob_eh )) glob_eh  <- 0

dt2 <- prof_mh[dt2, on=.(Zona, Month, Hour)]
dt2 <- prof_h[dt2,  on=.(Zona, Hour)]

dt2[is.na(WPD), WPD := fifelse(!is.na(WPD_med), WPD_med,
                               fifelse(!is.na(WPD_med2), WPD_med2, glob_wpd))]
dt2[is.na(Eh),  Eh  := fifelse(!is.na(Eh_med),  Eh_med,
                               fifelse(!is.na(Eh_med2), Eh_med2,  glob_eh ))]
dt2[, c("WPD_med","Eh_med","WPD_med2","Eh_med2") := NULL]

# Regularización física Zona 1 (Weibull mu+2sd) + coherencia energía
row_w1 <- WEIBULL_PARAMS[Zona==1]
if (1 %in% zones && nrow(row_w1)==1 && row_w1$c_w>0 && row_w1$k_w>0) {
  ws1 <- weibull_mu_sd(row_w1$c_w, row_w1$k_w)
  cap1 <- ws1$mu + 2*ws1$sd
  dt2[Zona==1, WPD := cap_struct(WPD, cap1)]
  dt2[Zona==1, Eh  := WPD/1000]
}

# -------------------------
# 5) Trimestral observado + coverage
# -------------------------
dt2[, `:=`(
  Year  = as.integer(format(time, "%Y", tz="UTC")),
  Month = as.integer(format(time, "%m", tz="UTC"))
)]
dt2[, Q  := ((Month - 1L) %/% 3L) + 1L]
dt2[, YQ := paste0(Year, " Q", Q)]

obs[, `:=`(
  Year  = as.integer(format(time, "%Y", tz="UTC")),
  Month = as.integer(format(time, "%m", tz="UTC"))
)]
obs[, Q  := ((Month - 1L) %/% 3L) + 1L]
obs[, YQ := paste0(Year, " Q", Q)]

obs_cov <- obs[, .(horas_obs=.N), by=.(Zona,Year,Q,YQ)]
obs_cov[, horas_teo := mapply(hours_in_q, Year, Q)]
obs_cov[, coverage  := pmin(1, horas_obs/horas_teo)]

tri <- dt2[, .(
  horas_teo = .N,
  WPD_p50   = as.numeric(quantile(WPD, 0.50, na.rm=TRUE)),
  WPD_p90   = as.numeric(quantile(WPD, 0.90, na.rm=TRUE)),
  WPD_mean  = mean(WPD, na.rm=TRUE),
  E_free    = sum(Eh, na.rm=TRUE)
), by=.(Zona,Year,Q,YQ)]

tri <- merge(tri, obs_cov[,.(Zona,Year,Q,YQ,horas_obs,coverage)],
             by=c("Zona","Year","Q","YQ"), all.x=TRUE)
tri[is.na(horas_obs), `:=`(horas_obs=0L, coverage=0)]

tri[, FNRR := fnrr_from_p(WPD_p50, WPD_p90)]
tri[, coh  := 1 - FNRR]
tri[, E_usable := E_free * coh]

# -------------------------
# 5.1) CAP físico suave para E_free (p99.5 histórico por zona)
# -------------------------
E_CAP <- tri[, .(
  E_cap_p995 = as.numeric(quantile(E_free, 0.995, na.rm=TRUE))
), by=Zona]

cap_soft <- function(x, cap_hi) pmin(x, cap_hi)

# -------------------------
# 6) Forecast trimestral 2022Q3-2028Q4 (ARIMA estacional en log1p)
# -------------------------
future_yq <- c()
for (y in LAST_OBS_Y:END_Y) for (q in 1:4)
  if (y > LAST_OBS_Y || (y==LAST_OBS_Y && q > LAST_OBS_Q)) future_yq <- c(future_yq, paste0(y," Q",q))
h <- length(future_yq)

fit_fc <- function(x, h, level=90){
  x <- pmax(as.numeric(x), 0)
  lx <- log1p(x)
  if (anyNA(lx)) lx <- as.numeric(na.interp(ts(lx, frequency=4, start=c(2017,1))))
  tsx <- ts(lx, frequency=4, start=c(2017,1))
  fit <- auto.arima(tsx, seasonal=TRUE, stepwise=TRUE, approximation=TRUE)
  forecast(fit, h=h, level=level)
}
back <- function(fc){
  list(
    mean = pmax(expm1(as.numeric(fc$mean)), 0),
    lo   = pmax(expm1(as.numeric(fc$lower[,1])), 0),
    hi   = pmax(expm1(as.numeric(fc$upper[,1])), 0)
  )
}

future_list <- list()

for (z in zones) {
  tri_z <- tri[Zona==z][order(Year,Q)]

  base_yq <- c()
  for (y in 2017:LAST_OBS_Y) for (q in 1:4)
    if (y < LAST_OBS_Y || (y==LAST_OBS_Y && q<=LAST_OBS_Q)) base_yq <- c(base_yq, paste0(y," Q",q))

  base_dt <- data.table(YQ=base_yq)
  tri_z <- merge(base_dt, tri_z[,.(YQ, WPD_p50, WPD_p90, E_free)], by="YQ", all.x=TRUE)

  fc50 <- back(fit_fc(tri_z$WPD_p50, h=h, level=LEVEL_PI))
  fc90 <- back(fit_fc(tri_z$WPD_p90, h=h, level=LEVEL_PI))
  fcE  <- back(fit_fc(tri_z$E_free , h=h, level=LEVEL_PI))

  fut <- data.table(
    Zona=z,
    YQ=future_yq,
    Year=as.integer(substr(future_yq,1,4)),
    Q=as.integer(sub(".*Q","",future_yq)),
    horas_teo=mapply(hours_in_q,
                     as.integer(substr(future_yq,1,4)),
                     as.integer(sub(".*Q","",future_yq))),
    horas_obs=0L,
    coverage=1,

    WPD_p50=fc50$mean,
    WPD_p90=fc90$mean,
    E_free=fcE$mean,

    E_free_lo=fcE$lo,
    E_free_hi=fcE$hi
  )

  # cap suave energía futuro (evita explosión)
  capz <- E_CAP[Zona==z]$E_cap_p995
  if (length(capz)==1 && is.finite(capz) && capz>0) {
    fut[, E_free := cap_soft(E_free, capz)]
    fut[, E_free_lo := pmin(E_free_lo, capz)]
    fut[, E_free_hi := pmin(E_free_hi, capz)]
  }

  fut[, WPD_mean := 0.6*WPD_p50 + 0.4*WPD_p90]
  fut[, FNRR := fnrr_from_p(WPD_p50, WPD_p90)]
  fut[, coh  := 1 - FNRR]
  fut[, E_usable := E_free * coh]

  # Regularización física Zona 1 + coherencia energía
  if (z==1 && nrow(row_w1)==1 && row_w1$c_w>0 && row_w1$k_w>0) {
    ws1 <- weibull_mu_sd(row_w1$c_w, row_w1$k_w)
    cap1 <- ws1$mu + 2*ws1$sd
    fut[, WPD_p50  := cap_struct(WPD_p50 , cap1)]
    fut[, WPD_p90  := cap_struct(WPD_p90 , cap1)]
    fut[, WPD_mean := cap_struct(WPD_mean, cap1)]
    fut[, E_free   := (WPD_mean/1000) * horas_teo]
    # cap también aquí
    capz2 <- E_CAP[Zona==z]$E_cap_p995
    if (length(capz2)==1 && is.finite(capz2) && capz2>0) {
      fut[, E_free := cap_soft(E_free, capz2)]
    }
    fut[, E_usable := E_free * (1 - FNRR)]
  }

  future_list[[as.character(z)]] <- fut
}

future_tri <- rbindlist(future_list, fill=TRUE)

tri_all <- rbindlist(list(
  tri[, .(Zona,Year,Q,YQ,horas_teo,horas_obs,coverage,WPD_p50,WPD_p90,WPD_mean,E_free,E_usable,FNRR,coh)],
  future_tri[, .(Zona,Year,Q,YQ,horas_teo,horas_obs,coverage,WPD_p50,WPD_p90,WPD_mean,E_free,E_usable,FNRR,coh,E_free_lo,E_free_hi)]
), fill=TRUE)
setorder(tri_all, Zona, Year, Q)

# -------------------------
# 7) Anual (PI90 por simulación Monte Carlo en log1p) - NIVEL DOCTORAL
# -------------------------

# simulación desde forecast (en log1p), devuelve en escala original
sim_from_fc_log <- function(fc, nsim=2000){
  mu <- as.numeric(fc$mean)
  z  <- 1.64485362695147  # PI90
  lo <- as.numeric(fc$lower[,1])
  hi <- as.numeric(fc$upper[,1])
  sd <- (hi - lo) / (2*z)
  sd[!is.finite(sd) | sd<=0] <- median(sd[is.finite(sd) & sd>0], na.rm=TRUE)
  if (!is.finite(sd[1])) sd <- rep(0.0, length(mu))

  sims <- matrix(rnorm(length(mu)*nsim, mean=rep(mu, nsim), sd=rep(sd, nsim)),
                 nrow=length(mu), ncol=nsim)
  pmax(expm1(sims), 0)
}

# anual histórico: sin PI (observado)
ann_hist <- tri_all[Year <= LAST_OBS_Y, .(
  horas_teo = sum(horas_teo),
  horas_obs = sum(horas_obs),
  coverage  = weighted.mean(coverage, w=horas_teo),

  WPD_mean  = weighted.mean(WPD_mean, w=horas_teo),
  WPD_p50   = weighted.mean(WPD_p50 , w=horas_teo),
  WPD_p90   = weighted.mean(WPD_p90 , w=horas_teo),

  E_free    = sum(E_free),
  E_usable  = sum(E_usable),

  FNRR      = weighted.mean(FNRR, w=horas_teo),
  coh       = weighted.mean(coh , w=horas_teo),

  E_free_lo = NA_real_,
  E_free_hi = NA_real_
), by=.(Zona,Year)]

# mapa de trimestres futuros -> año
fut_map <- data.table(
  YQ=future_yq,
  Year=as.integer(substr(future_yq,1,4)),
  Q=as.integer(sub(".*Q","",future_yq))
)
years_fut <- sort(unique(fut_map$Year))

ann_fut_list <- list()

for (z in zones) {

  # reconstruir serie E_free trimestral observada (hasta 2022Q2)
  tri_z <- tri[Zona==z][order(Year,Q)]
  base_yq <- c()
  for (y in 2017:LAST_OBS_Y) for (q in 1:4)
    if (y < LAST_OBS_Y || (y==LAST_OBS_Y && q<=LAST_OBS_Q)) base_yq <- c(base_yq, paste0(y," Q",q))
  base_dt <- data.table(YQ=base_yq)
  tri_z <- merge(base_dt, tri_z[,.(YQ, E_free)], by="YQ", all.x=TRUE)

  x <- pmax(as.numeric(tri_z$E_free), 0)
  lx <- log1p(x)
  if (anyNA(lx)) lx <- as.numeric(na.interp(ts(lx, frequency=4, start=c(2017,1))))
  tsx <- ts(lx, frequency=4, start=c(2017,1))
  fit <- auto.arima(tsx, seasonal=TRUE, stepwise=TRUE, approximation=TRUE)
  fc  <- forecast(fit, h=h, level=LEVEL_PI)

  # sim trimestral futuro
  sim_q <- sim_from_fc_log(fc, nsim=NSIM_PI_ANUAL)  # (h x nsim)

  # cap físico suave aplicado a simulación
  capz <- E_CAP[Zona==z]$E_cap_p995
  if (length(capz)==1 && is.finite(capz) && capz>0) {
    sim_q <- pmin(sim_q, capz)
  }

  # anual por suma de 4 trimestres, por simulación
  rows <- list()
  for (yy in years_fut) {
    idx <- which(fut_map$Year == yy)
    if (length(idx)==0) next
    sY <- colSums(sim_q[idx, , drop=FALSE])
    rows[[as.character(yy)]] <- data.table(
      Zona=z,
      Year=yy,
      E_free_lo = as.numeric(quantile(sY, 0.05, na.rm=TRUE)),
      E_free_hi = as.numeric(quantile(sY, 0.95, na.rm=TRUE))
    )
  }
  ann_fut_list[[as.character(z)]] <- rbindlist(rows, fill=TRUE)
}

ann_fut_pi <- rbindlist(ann_fut_list, fill=TRUE)

# anual base (incluye futuro) desde tri_all (mean)
ann_base <- tri_all[, .(
  horas_teo = sum(horas_teo),
  horas_obs = sum(horas_obs),
  coverage  = weighted.mean(coverage, w=horas_teo),

  WPD_mean  = weighted.mean(WPD_mean, w=horas_teo),
  WPD_p50   = weighted.mean(WPD_p50 , w=horas_teo),
  WPD_p90   = weighted.mean(WPD_p90 , w=horas_teo),

  E_free    = sum(E_free),
  E_usable  = sum(E_usable),

  FNRR      = weighted.mean(FNRR, w=horas_teo),
  coh       = weighted.mean(coh , w=horas_teo)
), by=.(Zona,Year)]

ann <- merge(ann_base, ann_fut_pi, by=c("Zona","Year"), all.x=TRUE)

# usable bounds por coherencia anual
ann[, E_usable_lo := E_free_lo * (1 - FNRR)]
ann[, E_usable_hi := E_free_hi * (1 - FNRR)]

# unir histórico (para dejar PI NA donde no aplica) + base con PI (futuro)
ann <- rbindlist(list(ann_hist, ann[Year > LAST_OBS_Y]), fill=TRUE)
setorder(ann, Zona, Year)

# -------------------------
# 8) Export
# -------------------------
fwrite(tri_all, file.path(OUT, "CAP4_TDQ_TRIMESTRAL_2017_2028.csv"))
fwrite(ann,     file.path(OUT, "CAP4_TDQ_ANUAL_2017_2028.csv"))

# -------------------------
# -------------------------
# 9) Figuras publicables (FINAL - paper-ready)
# -------------------------
theme_pub <- theme_bw(base_size=12) +
  theme(panel.grid.minor=element_blank(),
        legend.position="bottom",
        plot.title=element_text(face="bold"),
        axis.title=element_text(face="bold"))

# =========
# FIG 1 - WPD trimestral
# =========
tri_plot <- copy(tri_all)
tri_plot[, t_index := as.Date(sprintf("%04d-%02d-01", Year, (Q-1L)*3L + 1L))]

p1 <- ggplot(tri_plot, aes(t_index, WPD_mean, color=factor(Zona), group=factor(Zona))) +
  geom_line(linewidth=0.9) +
  geom_point(size=1.2) +
  geom_vline(xintercept=as.Date("2022-04-01"), linetype="dashed") +
  labs(title="WPD trimestral TDQ (2017-2028)",
       x="Inicio de trimestre", y="WPD (W/m2)", color="Zona") +
  theme_pub

ggsave(file.path(OUT, "FIG_CAP4_WPD_TRIMESTRAL_TDQ_2017_2028.png"),
       p1, width=12, height=5, dpi=300)

# =========
# FIG 2 - Energía anual: libre vs usable + PI90 (PI SOLO FUTURO + puntos SOLO OBS)
# =========
ann_plot <- copy(ann)
ann_plot[, is_fc := Year > 2022]  # pronóstico desde 2023

# Para ubicar etiquetas arriba sin depender del rango exacto:
y_top <- max(ann_plot$E_free, ann_plot$E_free_hi, na.rm=TRUE)
if (!is.finite(y_top)) y_top <- 1

p2 <- ggplot() +
  # PI90 solo futuro
  geom_ribbon(
    data = ann_plot[is_fc==TRUE],
    aes(x=Year, ymin=E_free_lo, ymax=E_free_hi, fill=factor(Zona), group=factor(Zona)),
    alpha=0.15, color=NA
  ) +
  # líneas energía libre
  geom_line(
    data=ann_plot,
    aes(x=Year, y=E_free, color=factor(Zona), group=factor(Zona)),
    linewidth=0.95
  ) +
  # líneas energía usable (penalizada por FNRR)
  geom_line(
    data=ann_plot,
    aes(x=Year, y=E_usable, color=factor(Zona), group=factor(Zona)),
    linewidth=0.95, linetype="dotted"
  ) +
  # puntos SOLO en observado (limpio, editorial)
  geom_point(
    data=ann_plot[is_fc==FALSE],
    aes(x=Year, y=E_free, color=factor(Zona)),
    size=1.2
  ) +
  geom_point(
    data=ann_plot[is_fc==FALSE],
    aes(x=Year, y=E_usable, color=factor(Zona)),
    size=1.1, shape=1
  ) +
  # corte observado/pronóstico
  geom_vline(xintercept=2022.5, linetype="dashed") +
  # etiquetas observado/pronóstico
  annotate("text", x=2019.5, y=y_top, label="Observado", vjust=-0.6, fontface="bold") +
  annotate("text", x=2025.5, y=y_top, label="Pronóstico", vjust=-0.6, fontface="bold") +
  labs(title="Energía anual (kWh/m2): libre vs usable + PI90",
       x="Año", y="Energía (kWh/m2)", color="Zona", fill="Zona") +
  theme_pub +
  scale_y_continuous(labels=scales::comma)

# Si quieres lectura tipo Nature (opcional): descomenta
# p2 <- p2 + scale_y_continuous(trans="log1p", labels=scales::comma)

ggsave(file.path(OUT, "FIG_CAP4_ENERGIA_ANUAL_LIBRE_USABLE_PI90.png"),
       p2, width=12, height=5, dpi=300)

# =========
# FIG 3 - FNRR anual
# =========
p3 <- ggplot(ann, aes(Year, FNRR, color=factor(Zona), group=factor(Zona))) +
  geom_line(linewidth=0.9) +
  geom_point(size=1.2) +
  scale_y_continuous(limits=c(0,1)) +
  labs(title="FNRR anual TDQ (2017-2028)",
       x="Año", y="FNRR (0-1)", color="Zona") +
  theme_pub

ggsave(file.path(OUT, "FIG_CAP4_FNRR_ANUAL_TDQ_2017_2028.png"),
       p3, width=12, height=5, dpi=300)

cat("\n==============================================\n")
cat("OK ✅ FIGURAS CAP4 TDQ FINAL (paper-ready)\nOUT:", OUT, "\n")
cat("Exportadas:\n")
cat("- FIG_CAP4_WPD_TRIMESTRAL_TDQ_2017_2028.png\n")
cat("- FIG_CAP4_ENERGIA_ANUAL_LIBRE_USABLE_PI90.png\n")
cat("- FIG_CAP4_FNRR_ANUAL_TDQ_2017_2028.png\n")
cat("==============================================\n")