# 02_packages_setup.R
# Package declaration only; the script never installs software automatically.
TDQ_REQUIRED_PACKAGES <- c("data.table","lubridate","stringr","forecast","ggplot2","scales","zoo","KFAS")
TDQ_OPTIONAL_PACKAGES <- c("xgboost","ranger","keras","tensorflow","WaveletComp","sf","terra","openxlsx","ragg","svglite")
check_tdq_packages <- function(packages=TDQ_REQUIRED_PACKAGES){
 missing<-packages[!vapply(packages,requireNamespace,logical(1),quietly=TRUE)]
 if(length(missing)) stop("Missing R packages: ",paste(missing,collapse=", "),". Install them in a controlled environment.")
 invisible(TRUE)
}
