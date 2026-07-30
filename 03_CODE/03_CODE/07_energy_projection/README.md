# Separate quarterly energy scenario

This folder intentionally excludes the obsolete direct-extension script. The retained workflow aggregates WPD quarterly and forecasts from 2022-Q3 to 2028-Q4 in a second methodological stage. FNRR uses quarterly WPD median and P90 with logarithmic compression, common `W0 = 1 W/m²`, clipping to `[0,1]`, and annual hour weighting. `E_free` and `E_usable` are indicators, not actual generation or guaranteed energy.
