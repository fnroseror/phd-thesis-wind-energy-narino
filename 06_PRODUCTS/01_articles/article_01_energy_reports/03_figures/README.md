# Figures — Article 01 Energy Reports

## Article identification

**Provisional title:**  
Physical–statistical characterization of wind power density in complex Andean terrain: A multi-station study in Nariño, Colombia

**Target journal:** Energy Reports  
**Article type:** Research Article  

---

## Purpose

This folder contains the final figures prepared for Article 01 submission.

The figures are organized into:

```text
main_text/
supplementary/
```

---

## Folder structure

```text
03_figures/
├── README.md
├── main_text/
└── supplementary/
```

---

# 1. Main-text figures

The folder:

```text
03_figures/main_text/
```

must contain the figures used directly in the main manuscript.

Recommended final figure list:

```text
Fig_01_monthly_mean_wind_speed_by_zone_FINAL.png
Fig_02_monthly_mean_WPD_by_zone_FINAL.png
Fig_03_wind_speed_distribution_by_zone_FINAL.png
Fig_04_WPD_distribution_by_zone_FINAL.png
Fig_05_weibull_rayleigh_density_fit_by_zone_FINAL.png
Fig_06_weibull_rayleigh_CDF_fit_by_zone_FINAL.png
Fig_07_daily_WPD_ACF_by_zone_FINAL.png
Fig_08_daily_WPD_FFT_band_energy_by_zone_FINAL.png
```

---

# 2. Supplementary figures

The folder:

```text
03_figures/supplementary/
```

must contain figures used as supplementary evidence.

Recommended supplementary figure list:

```text
Fig_S1_QC_sensitivity_mean_WPD_FINAL.png
Fig_S2_delta_AIC_BIC_weibull_rayleigh_comparison_FINAL.png
Fig_S3_daily_WPD_PACF_by_zone_FINAL.png
Fig_S4_daily_VV_ACF_by_zone_FINAL.png
Fig_S5_daily_VV_PACF_by_zone_FINAL.png
Fig_S6_daily_WPD_FFT_spectrum_by_zone_FINAL.png
Fig_S7_daily_VV_FFT_spectrum_by_zone_FINAL.png
Fig_S8_daily_VV_FFT_band_energy_by_zone_FINAL.png
```

---

# 3. Main figure descriptions

## Figure 1

Monthly mean wind speed by analytical zone.

Purpose:

```text
Shows temporal variability of wind speed across zones.
```

---

## Figure 2

Monthly mean wind power density by analytical zone.

Purpose:

```text
Shows zonal contrast in available wind-energy potential.
```

---

## Figure 3

Wind-speed distribution by analytical zone.

Purpose:

```text
Supports empirical comparison of wind-speed regimes.
```

---

## Figure 4

Wind power density distribution by analytical zone.

Purpose:

```text
Shows WPD asymmetry and cubic amplification of high-wind events.
```

---

## Figure 5

Weibull and Rayleigh density fits by analytical zone.

Purpose:

```text
Supports distributional comparison between flexible Weibull and constrained Rayleigh models.
```

---

## Figure 6

Weibull and Rayleigh cumulative distribution fits by analytical zone.

Purpose:

```text
Provides full-range visual assessment of distributional fit.
```

---

## Figure 7

Daily WPD autocorrelation function by analytical zone.

Purpose:

```text
Shows temporal persistence and memory structure of daily WPD.
```

---

## Figure 8

FFT spectral-band energy of daily WPD by analytical zone.

Purpose:

```text
Shows the distribution of WPD spectral power across characteristic temporal bands.
```

---

# 4. Technical requirements

Before submission, verify that all figures are:

```text
High resolution
Readable
Properly numbered
Consistent in style
Generated from R scripts
Not modified using generative AI tools
Consistent with manuscript captions
Uploaded as separate files if required by the journal
```

---

# 5. Recommended formats

Preferred formats:

```text
TIFF
PNG
PDF
```

For journal submission, use the format requested by the submission platform.

For GitHub documentation, PNG is recommended because it is easy to preview.

For final editorial submission, TIFF may be preferred when high-resolution figure files are requested.

---

# 6. Figure traceability rule

Each figure must be traceable to:

```text
R script → output file → figure folder → manuscript caption → manuscript citation
```

Example:

```text
07J_fft_spectral_analysis.R
        ↓
Fig_10_daily_WPD_FFT_band_energy_by_zone_FINAL.png
        ↓
03_figures/main_text/Fig_08_daily_WPD_FFT_band_energy_by_zone_FINAL.png
        ↓
Figure 8 caption
        ↓
Results section 4.5
```

---

# 7. Naming convention

Use clear and stable filenames.

Recommended pattern:

```text
Fig_XX_short_description_FINAL.png
Fig_SX_short_description_FINAL.png
```

Avoid filenames with:

```text
spaces
accents
temporary words
draft labels
unclear versions
```

Do not use:

```text
figure_new.png
final_final.png
plot1.png
image.png
```

---

# 8. TDQ control note

A figure enters the manuscript only if it satisfies:

```text
1. It is scientifically necessary.
2. It supports a specific result.
3. It is readable.
4. It is traceable to a script.
5. It is cited in the manuscript.
6. It does not duplicate another figure.
7. It strengthens the article narrative.
```

---

# 9. Current status

```text
Figures folder: created
Main-text figure folder: pending population
Supplementary figure folder: pending population
Final figure numbering: drafted
Figure captions: drafted
Manuscript integration: pending
```
