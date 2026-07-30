# Final hourly TDQ–PIESS/KFAS stage

`01_cap3_tdq_piess_kfas.R` contains the final state-space/KFAS integration. The former internal hourly variable label `FNRR` was corrected to `I_TDQ` without altering its numerical definition. `I_TDQ` is not the Chapter 4 FNRR and does not modulate energy. `02_cap3_final_diagnostics.R` reproduces complementary residual, Ljung–Box, Diebold–Mariano and approximate PI90-score diagnostics.
