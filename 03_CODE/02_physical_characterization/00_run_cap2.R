# 00_run_cap2.R
# Execute from repository root with the restricted source configured.
source(file.path("03_CODE","00_config.R"))
if (!file.exists(TDQ_DATA_FILE)) stop("Restricted data source not found: ",TDQ_DATA_FILE)
source(file.path("03_CODE","02_physical_characterization","01_cap2_data_zoning_qc.R"))
source(file.path("03_CODE","02_physical_characterization","02_cap2_distributional_analysis.R"))
source(file.path("03_CODE","02_physical_characterization","03_cap2_temporal_spectral_wavelet.R"))
