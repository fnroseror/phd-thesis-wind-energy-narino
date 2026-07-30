# 02_cap3_final_diagnostics.R
# Complementary diagnostics for the frozen TDQ–PIESS/KFAS predictions.
# These diagnostics do not replace the approved thesis tables.

rm(list=ls()); gc()
source(file.path("03_CODE","00_config.R"))
required <- c("data.table","forecast")
missing <- required[!vapply(required,requireNamespace,logical(1),quietly=TRUE)]
if(length(missing)) stop("Missing R packages: ",paste(missing,collapse=", "))
suppressPackageStartupMessages({library(data.table);library(forecast)})

pred_file <- file.path(TDQ_WORK_DIR,"SALIDAS_CAP3_TDQ_PIESS","PREDICCIONES","TDQ_PIESS_PREDS_GLOBAL.csv")
if(!file.exists(pred_file)) stop("Final prediction file not found: ",pred_file)
out_dir <- file.path(TDQ_WORK_DIR,"SALIDAS_CAP3_TDQ_PIESS","DIAGNOSTICOS_COMPLEMENTARIOS")
dir.create(out_dir,recursive=TRUE,showWarnings=FALSE)
P <- fread(pred_file)
need <- c("Zona","Horizonte","h","y_true","y_pred","y_persist","PI_low90","PI_high90")
miss <- setdiff(need,names(P)); if(length(miss)) stop("Missing columns: ",paste(miss,collapse=", "))

crps_norm <- function(y,mu,sigma){
 z<-(y-mu)/sigma
 sigma*(z*(2*pnorm(z)-1)+2*dnorm(z)-1/sqrt(pi))
}

summ <- P[,{
 e_m <- y_true-y_pred; e_p <- y_true-y_persist
 keep <- is.finite(e_m)&is.finite(e_p)
 em<-e_m[keep]; ep<-e_p[keep]
 lag_use <- max(1L,min(24L,floor(length(em)/5)))
 lb <- if(length(em)>lag_use+5) Box.test(em,lag=lag_use,type="Ljung-Box") else NULL
 dm1 <- tryCatch(dm.test(em,ep,h=max(1L,unique(h)[1]),power=1),error=function(e)NULL)
 dm2 <- tryCatch(dm.test(em,ep,h=max(1L,unique(h)[1]),power=2),error=function(e)NULL)
 z90<-qnorm(0.95); sig<-(PI_high90-PI_low90)/(2*z90)
 okp<-is.finite(y_true)&is.finite(y_pred)&is.finite(sig)&sig>0
 crps<-if(any(okp)) mean(crps_norm(y_true[okp],y_pred[okp],sig[okp])) else NA_real_
 logscore<-if(any(okp)) mean(-dnorm(y_true[okp],y_pred[okp],sig[okp],log=TRUE)) else NA_real_
 .(n=length(em),residual_mean=mean(em),residual_sd=sd(em),residual_skewness=mean((em-mean(em))^3)/(sd(em)^3),
   ljung_box_lag=lag_use,ljung_box_stat=if(is.null(lb)) NA_real_ else unname(lb$statistic),ljung_box_p=if(is.null(lb)) NA_real_ else lb$p.value,
   dm_abs_stat=if(is.null(dm1)) NA_real_ else unname(dm1$statistic),dm_abs_p=if(is.null(dm1)) NA_real_ else dm1$p.value,
   dm_sq_stat=if(is.null(dm2)) NA_real_ else unname(dm2$statistic),dm_sq_p=if(is.null(dm2)) NA_real_ else dm2$p.value,
   crps_pi90_approx=crps,logscore_pi90_approx=logscore)
},by=.(Zona,Horizonte,h)]
fwrite(summ,file.path(out_dir,"cap3_final_diagnostics.csv"))
cat("Complementary diagnostics written to:",out_dir,"\n")
cat("CRPS and LogScore are approximations reconstructed from PI90, not exact scores from a full predictive distribution.\n")
