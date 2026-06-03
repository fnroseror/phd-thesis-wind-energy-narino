# Scientific Audit — Article 01 Energy Reports

## Manuscript

**Title:** Physical–statistical characterization of wind power density in complex Andean terrain: A multi-station study in Nariño, Colombia  
**Target journal:** Energy Reports  
**Status:** Pre-submission scientific audit  

---

## 1. General verdict

The manuscript has a solid structure, a coherent methodological sequence and a complete submission package. The article is scientifically viable because it is based on real meteorological data, reproducible R scripts, final figures, final tables, verified references and a clear physical–statistical scope.

However, the current version still requires strengthening before formal submission. The main weakness is not structural but argumentative: the Results and Discussion sections must include more numerical evidence and more explicit physical interpretation.

---

## 2. Current strengths

- The article has a clear physical descriptor: wind power density.
- The study region is relevant because Nariño is a complex Andean terrain.
- The methodology is coherent: QC, air-density-supported WPD, Weibull/Rayleigh, ACF/PACF and FFT.
- The figures and tables are already generated and organized.
- The reference list is complete and uses author-year style.
- The repository provides traceability and reproducibility.
- The scope is controlled and avoids overclaiming turbine-level feasibility.

---

## 3. Main scientific risks before submission

### 3.1 Results are still too general

The manuscript states that Zone 1 has the highest WPD, Weibull outperforms Rayleigh, WPD has temporal persistence and FFT reveals distinct regimes. These claims are correct, but they need numerical support in the main text.

### 3.2 Discussion needs stronger physical interpretation

The discussion must explain why WPD amplifies spatial contrast through the cubic dependence on wind speed and why intermittent regimes may dominate the energetic signal.

### 3.3 Internal consistency must be checked

All numerical values mentioned in the manuscript must match the final tables and figures.

### 3.4 Avoid repository-style language inside the manuscript

The manuscript should not sound like repository documentation. Scripts, paths and internal workflow details should remain in the repository, not in the scientific narrative.

---

## 4. Numerical values to insert

The following values should be incorporated into the Results and Discussion sections:

| Component | Value |
|---|---|
| Final post-QC records | 137,484 |
| Post-QC retention | 99.7562% |
| Global mean WPD | 53.81958 W m^-2 |
| Zone 1 mean WPD | 140.759 W m^-2 |
| Zone 2 mean WPD | 15.82 W m^-2 |
| Zone 3 mean WPD | 12.96 W m^-2 |
| Zone 4 mean WPD | 16.95 W m^-2 |
| Zone 1 Weibull k | 0.7880893 |
| Zone 2 Weibull k | 1.9841502 |
| Zone 3 Weibull k | 2.0888799 |
| Zone 4 Weibull k | 2.1638745 |
| Zone 1 ACF lag 1 | 0.884 |
| Zone 2 ACF lag 1 | 0.862 |
| Zone 3 ACF lag 1 | 0.757 |
| Zone 4 ACF lag 1 | 0.575 |
| Zone 1 first ACF below 0.2 | Not below within 90 days |
| Zone 2 first ACF below 0.2 | Lag 54 |
| Zone 3 first ACF below 0.2 | Lag 22 |
| Zone 4 first ACF below 0.2 | Lag 13 |
| Zone 1 spectral power >365 days | Approximately 70.23% |

---

## 5. Sections requiring revision

### 5.1 Section 3.3 Quality-control criterion

Add retention percentage and explain why QC is not aggressive.

### 5.2 Section 4.2 Zonal contrast in WPD

Add exact WPD means by zone and explicitly compare Zone 1 against Zones 2–4.

### 5.3 Section 4.3 Weibull and Rayleigh fitting

Add Weibull shape parameters by zone and explain the physical meaning of k < 1 in Zone 1.

### 5.4 Section 4.4 Temporal persistence of WPD

Add lag-1 ACF values and first lag below 0.2.

### 5.5 Section 4.5 Spectral structure of WPD

Add the percentage of Zone 1 spectral power in periods longer than 365 days.

### 5.6 Section 5.1 Physical interpretation of Zone 1 dominance

Strengthen the explanation of intermittent high-energy events and cubic amplification.

---

## 6. Recommended editorial direction

The manuscript should keep its current structure but improve its density of scientific evidence.

The preferred style is:

- concise,
- numerical,
- physically interpreted,
- free of internal workflow language,
- cautious about limitations,
- clear about what the study does and does not claim.

---

## 7. Submission-readiness estimate

| Component | Status |
|---|---|
| Structure | Strong |
| Methodology | Strong |
| Figures | Strong |
| Tables | Strong |
| References | Strong |
| Results | Needs strengthening |
| Discussion | Needs strengthening |
| Internal consistency | Needs final check |
| DOCX | Generated, pending v2 |
| Submission readiness | 85–88% |

---

## 8. Target after revision

After incorporating numerical evidence and strengthening the discussion, the manuscript should reach:

| Component | Estimate |
|---|---|
| Submission readiness | 93–95% |
| Conservative publication probability | 60–65% |
| Minimum TDQ success threshold | Above 51% |

---

## 9. Final audit decision

The manuscript should not be submitted in its current base version. It should first be upgraded to version 2 by strengthening Results and Discussion with numerical evidence and clearer physical interpretation.
