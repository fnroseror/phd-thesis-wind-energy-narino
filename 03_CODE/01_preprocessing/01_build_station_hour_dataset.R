# 01_build_station_hour_dataset.R
# Public reproducibility implementation of the approved preprocessing logic.
# It writes only to TDQ_WORK_DIR and never overwrites canonical repository outputs.

rm(list = ls()); gc()
source(file.path("03_CODE", "00_config.R"))

required <- c("data.table", "lubridate", "stringr")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Missing R packages: ", paste(missing, collapse = ", "))

suppressPackageStartupMessages({
  library(data.table); library(lubridate); library(stringr)
})

if (!file.exists(TDQ_DATA_FILE)) stop("Restricted IDEAM source not found: ", TDQ_DATA_FILE)
out_dir <- file.path(TDQ_WORK_DIR, "01_preprocessing")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

read_source <- function(path) {
  trials <- list(
    function() fread(path, sep = "\t", encoding = "UTF-8", showProgress = TRUE),
    function() fread(path, sep = ";", encoding = "UTF-8", showProgress = TRUE),
    function() fread(path, sep = ",", encoding = "UTF-8", showProgress = TRUE),
    function() fread(path, encoding = "UTF-8", showProgress = TRUE)
  )
  for (fn in trials) {
    ans <- tryCatch(fn(), error = function(e) NULL)
    if (!is.null(ans) && ncol(ans) >= 5L) return(ans)
  }
  stop("The restricted source could not be parsed.")
}

parse_time <- function(x) {
  x <- str_trim(as.character(x))
  x <- str_replace_all(x, c("a. m."="AM", "p. m."="PM", "a.m."="AM", "p.m."="PM"))
  suppressWarnings(parse_date_time(x,
    orders=c("Ymd HMS","Ymd HM","dmY HMS","dmY HM","mdY HMS","mdY HM",
             "d/m/Y I:M:S p","d/m/Y I:M p","m/d/Y I:M:S p","m/d/Y I:M p"),
    tz=TDQ_TIMEZONE))
}

norm_var <- function(x) {
  y <- toupper(gsub("\\s+", "", trimws(as.character(x))))
  map <- list(
    VV=c("VV","VELVIENTO","VELOCIDADVIENTO","WINDSPEED","WS"),
    DV=c("DV","DIRVIENTO","DIRECCIONVIENTO","DIRECCIÓNVIENTO","WINDDIR"),
    PA=c("PA","PRESION","PRESIÓN","PRESIONATM","PRESIONATMOSFERICA","PRESSURE"),
    TM=c("TM","TEMP","TEMPERATURA","TMEAN","T"),
    TMIN=c("TMIN","TEMPERATURAMINIMA","TEMPERATURAMÍNIMA"),
    HR=c("HR","HUMEDADRELATIVA","RH"), PR=c("PR","PRECIPITACION","PRECIPITACIÓN","PREC"),
    NU=c("NU","NUBOSIDAD","CLOUDINESS"), EV=c("EV","EVAPORACION","EVAPORACIÓN"),
    FA=c("FA","FENOMENOATMOSFERICO","FENÓMENOATMOSFÉRICO")
  )
  out <- y
  for (nm in names(map)) out[y %in% map[[nm]]] <- nm
  out
}

to_pa <- function(x) { x <- as.numeric(x); if (median(x, na.rm=TRUE) < 2000) x*100 else x }
to_k <- function(x) { x <- as.numeric(x); if (median(x, na.rm=TRUE) < 100) x+273.15 else x }

raw <- read_source(TDQ_DATA_FILE)
setnames(raw, trimws(names(raw)))
if (!"Estación" %in% names(raw) && "Estacion" %in% names(raw)) setnames(raw,"Estacion","Estación")
required_cols <- c("Estación","FechaYHora","Valor","Zona","Variable")
missing_cols <- setdiff(required_cols,names(raw))
if (length(missing_cols)) stop("Missing columns: ",paste(missing_cols,collapse=", "))

raw[, `:=`(
  Estacion=as.character(`Estación`),
  FechaHora=parse_time(FechaYHora),
  Valor=suppressWarnings(as.numeric(gsub(",",".",as.character(Valor)))),
  Zona=as.integer(as.character(Zona)),
  Variable=norm_var(Variable)
)]
raw <- raw[!is.na(FechaHora) & is.finite(Valor) & !is.na(Zona)]
raw <- raw[FechaHora >= as.POSIXct("2017-01-01 00:00:00",tz=TDQ_TIMEZONE) &
           FechaHora <= as.POSIXct("2022-07-01 00:00:00",tz=TDQ_TIMEZONE)]

vv <- raw[Variable=="VV" & Valor>=0 & Valor<=75]
if (uniqueN(vv$Estacion)!=16L || uniqueN(vv$Zona)!=4L) {
  stop("Canonical structural check failed: expected 16 stations and 4 zones.")
}

# Station-hour consolidation. The median is used for repeated values within a station-hour.
raw[, Hora := floor_date(FechaHora,"hour")]
hourly_long <- raw[, .(Valor=median(Valor,na.rm=TRUE)), by=.(Estacion,Zona,Hora,Variable)]
hourly <- dcast(hourly_long, Estacion+Zona+Hora~Variable, value.var="Valor")

if (!"TM" %in% names(hourly) && all(c("TMIN","TMAX") %in% names(hourly))) hourly[,TM:=(TMIN+TMAX)/2]
if (!"VV" %in% names(hourly)) stop("VV is absent after station-hour consolidation.")
hourly <- hourly[is.finite(VV) & VV>=0 & VV<=75]
if ("PA" %in% names(hourly)) hourly[,PA_Pa:=to_pa(PA)] else hourly[,PA_Pa:=NA_real_]
if ("TM" %in% names(hourly)) hourly[,T_K:=to_k(TM)] else hourly[,T_K:=NA_real_]
hourly[,rho_station_hour:=PA_Pa/(TDQ_R_DRY_AIR*T_K)]
hourly[!is.finite(rho_station_hour) | rho_station_hour<=0,rho_station_hour:=NA_real_]

rho_zone_hour <- hourly[is.finite(rho_station_hour),.(rho_zone_hour=median(rho_station_hour)),by=.(Zona,Hora)]
hourly[,Month:=floor_date(Hora,"month")]
rho_zone_month <- hourly[is.finite(rho_station_hour),.(rho_zone_month=median(rho_station_hour)),by=.(Zona,Month)]
hourly <- merge(hourly,rho_zone_hour,by=c("Zona","Hora"),all.x=TRUE)
hourly <- merge(hourly,rho_zone_month,by=c("Zona","Month"),all.x=TRUE)
hourly[,rho:=fcoalesce(rho_station_hour,rho_zone_hour,rho_zone_month,TDQ_RHO_REFERENCE)]
hourly[,rho_source:=fifelse(is.finite(rho_station_hour),"station_hour",
                     fifelse(is.finite(rho_zone_hour),"zone_hour",
                     fifelse(is.finite(rho_zone_month),"zone_month","rho_ref")))]
hourly[,WPD:=0.5*rho*(VV^3)]
hourly[,Eh:=WPD/1000]
setorder(hourly,Zona,Estacion,Hora)

fwrite(hourly,file.path(out_dir,"station_hour_vv_wpd.csv"))
fwrite(hourly[,.(n=.N),by=Zona],file.path(out_dir,"analytical_rows_by_zone.csv"))
fwrite(hourly[,.(n=.N,share=.N/nrow(hourly)),by=rho_source],file.path(out_dir,"air_density_source_global.csv"))

cat("Preprocessing completed in:",out_dir,"\n")
cat("Generated rows:",nrow(hourly),"\n")
cat("Canonical reference: 365512 station-hour rows. Differences must be investigated; never overwrite approved outputs.\n")
