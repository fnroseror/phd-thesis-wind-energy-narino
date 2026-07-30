# Energy Reports Format Lock — Article 01

## Article identification

**Provisional title:**  
Physical–statistical characterization of wind power density in complex Andean terrain: A multi-station study in Nariño, Colombia

**Target journal:** Energy Reports  
**Publisher:** Elsevier  
**Article type:** Research Article  
**Current phase:** Submission-package construction  

---

# 1. Purpose

This file locks the editorial and formatting requirements that must guide the final preparation of Article 01 for submission to *Energy Reports*.

The purpose is to prevent formatting drift and ensure that the manuscript, figures, tables, references, declarations and supplementary files are aligned with the journal requirements before online submission.

---

# 2. Article type

The article will be submitted as:

```text
Research Article
```

Energy Reports defines Research Articles as full-length articles presenting original, high-quality research and novel scientific findings.

Target length:

```text
5,000–7,000 words
```

The article must include:

```text
Clear research question
Methodology
Results
Implications for the field
```

---

# 3. Manuscript format

The final manuscript must be prepared as an editable file.

Recommended format:

```text
DOCX
```

The manuscript should be prepared in:

```text
single-column format
editable text
numbered sections
editable equations
editable tables
```

Avoid:

```text
PDF as the only source file
tables as images
equations as screenshots
figures embedded only in the text without separate files
```

---

# 4. Abstract

The abstract must be:

```text
concise
factual
stand-alone
maximum 250 words
```

Current article abstract:

```text
approximately 221 words
```

Status:

```text
compliant
```

The abstract should include:

```text
purpose
methodological approach
main results
major conclusion
```

The abstract should avoid:

```text
references
undefined abbreviations
overclaims
unsupported conclusions
```

---

# 5. Keywords

Energy Reports requires:

```text
1 to 7 keywords
English language
```

Current keywords:

```text
Wind power density
Wind energy
Weibull distribution
Complex terrain
Andean region
Temporal dependence
Spectral analysis
```

Status:

```text
compliant
```

---

# 6. Highlights

Energy Reports requires highlights as a separate editable file.

Requirements:

```text
3 to 5 bullet points
maximum 85 characters per bullet point, including spaces
file name must include the word "highlights"
```

Current highlights:

```text
Daily air density supported wind power density estimation.
Weibull outperformed Rayleigh in all analytical zones.
Zone 1 showed the strongest and most intermittent WPD regime.
Daily WPD showed clear temporal persistence across zones.
FFT revealed distinct temporal-energy regimes in complex terrain.
```

Status:

```text
compliant, but must be exported as separate editable file
```

Required final file:

```text
highlights.docx
```

or, for repository control:

```text
highlights.md
```

---

# 7. Article structure

The final article should use clearly numbered sections.

Recommended structure:

```text
Title page
Highlights
Abstract
Keywords

1. Introduction
2. Study area and meteorological data
3. Methodology
4. Results
5. Discussion
6. Conclusions

Data availability statement
CRediT author statement
Declaration of competing interest
Funding statement
Declaration of generative AI and AI-assisted technologies
References
```

Possible supplementary material:

```text
Supplementary figures
Supplementary tables
Reproducibility notes
```

---

# 8. Equations

Equations must be editable text.

Main equations:

```text
WPD = 0.5 * rho * v^3
rho = p / (R * T)
```

Before submission, convert to formal manuscript notation:

```text
WPD = 0.5 ρ v³
ρ = p / (R T)
```

Units:

```text
v: m s^-1
rho: kg m^-3
WPD: W m^-2
p: Pa
T: K
```

All units must follow the International System of Units.

---

# 9. Figures

Figures must be submitted as separate files when required by the online system.

Main-text figure folder:

```text
03_figures/main_text/
```

Main figure list:

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

Requirements:

```text
high resolution
readable labels
logical file names
consistent numbering
cited in manuscript
generated from R scripts
not generated or modified using AI image tools
```

Preferred formats:

```text
TIFF for submission
PNG for GitHub preview
PDF if vector format is accepted
```

---

# 10. Tables

Tables must be editable.

Main-text table folder:

```text
04_tables/main_text/
```

Main table list:

```text
Table_01_dataset_zones_temporal_coverage.xlsx
Table_02_descriptive_statistics_VV_WPD_by_zone.xlsx
Table_03_weibull_rayleigh_parameters_fit_metrics.xlsx
Table_04_temporal_spectral_summary_WPD_by_zone.xlsx
```

Requirements:

```text
editable
not screenshots
not image-based
cited in manuscript
consistent with captions
traceable to R scripts
```

---

# 11. Supplementary material

Supplementary folder:

```text
06_supplementary_material/
```

Supplementary figures:

```text
03_figures/supplementary/
```

Supplementary tables:

```text
04_tables/supplementary/
```

Recommended supplementary content:

```text
QC sensitivity figure
Delta AIC/BIC comparison
PACF WPD figure
VV temporal diagnostics
Raw FFT spectrum support
Detailed temporal tables
Detailed spectral tables
Coverage tables
```

---

# 12. References

Energy Reports uses author-year citation style.

Do not use IEEE numeric style in the article.

In-text citation examples:

```text
One author: Author (Year)
Two authors: Author and Author (Year)
Three or more authors: Author et al. (Year)
Parenthetical: (Author, Year)
```

Reference list:

```text
alphabetical order
chronological order when needed
DOI included when available
all in-text citations must appear in reference list
all references in list must be cited in text
```

Current reference status:

```text
pending
```

Required action:

```text
replace references_pending.md with verified references
```

Target number:

```text
25–35 strong references
```

Recommended reference blocks:

```text
wind power density
wind-resource assessment
Weibull distribution in wind energy
Rayleigh distribution in wind energy
complex terrain wind assessment
air density and wind-energy formulation
temporal dependence in wind series
spectral analysis / FFT in meteorological series
renewable energy in Colombia / Andean regions
research data and reproducibility
IDEAM or official meteorological data source
```

---

# 13. Data availability

A Data Availability Statement is required.

Recommended version:

```text
The meteorological records used in this study were obtained from IDEAM, the official meteorological and hydrological data source in Colombia. Due to source-data redistribution considerations, the raw observational dataset is not redistributed in this repository. The scripts, derived summary outputs, figures, tables and reproducibility documentation supporting the results of this study are available in the associated GitHub repository. Access to the original raw meteorological records should be requested or downloaded from the official IDEAM data platform.
```

Required before submission:

```text
insert final GitHub repository link
decide whether Zenodo DOI will be created
confirm whether derived datasets can be uploaded
```

---

# 14. Generative AI declaration

Because AI-assisted tools were used for manuscript organization, editorial planning, language refinement and code-review discussion, a declaration must be included.

Recommended version:

```text
During the preparation of this work, the author used ChatGPT as an AI-assisted tool to support manuscript organization, editorial planning, language refinement and code-review discussion. All scientific analyses, data processing, statistical calculations, figures and tables were generated from the author-controlled research workflow in R. After using this tool, the author reviewed, edited and verified the content as needed and takes full responsibility for the content of the manuscript.
```

Figure control:

```text
No scientific figure, plot, chart or data visualization submitted to the journal should be created or modified using generative AI image tools.
```

---

# 15. Authorship and affiliation

Before submission, define:

```text
final author list
author order
corresponding author
institutional affiliation
institutional email
ORCID
co-author approval
CRediT roles
```

Current provisional corresponding author:

```text
Favio Nicolás Rosero Rodríguez
```

Pending:

```text
institutional affiliation
official email
ORCID
co-author decision
```

---

# 16. Submission package checklist

Required before online submission:

```text
main manuscript DOCX
highlights editable file
figures as separate files
tables editable
supplementary material
cover letter
data availability statement
competing interest declaration
funding statement
CRediT author statement
generative AI declaration
references in author-year style
GitHub repository link
author metadata
ORCID
institutional email
```

---

# 17. Editorial risk control

Main risks before submission:

```text
README still showing old concept-note status
missing final figures in 03_figures/main_text/
missing final tables in 04_tables/main_text/
references not verified
manuscript not converted to DOCX
author affiliations not finalized
journal formatting not fully checked
```

---

# 18. TDQ format rule

No file enters the submission package unless it satisfies:

```text
journal requirement
scientific traceability
editorial consistency
reproducibility support
author responsibility
```

Final submission chain:

```text
R scripts
        ↓
figures and tables
        ↓
results summaries
        ↓
manuscript DOCX
        ↓
declarations
        ↓
submission package
        ↓
Editorial Manager
        ↓
submission confirmation
```

---

# 19. Current readiness

```text
Journal format lock: created
Article type: defined
Abstract: compliant
Keywords: compliant
Highlights: compliant, pending separate file
References: pending
Figures: pending final upload
Tables: pending final upload
DOCX manuscript: pending
Submission account: pending
```

---

# 20. Immediate next actions

```text
1. Update main README.md from concept note to submission workspace.
2. Copy final figures into 03_figures/main_text/ and supplementary/.
3. Copy final tables into 04_tables/main_text/ and supplementary/.
4. Build verified author-year references.
5. Convert manuscript master to DOCX.
6. Prepare highlights as separate editable file.
7. Create final submission checklist.
```
