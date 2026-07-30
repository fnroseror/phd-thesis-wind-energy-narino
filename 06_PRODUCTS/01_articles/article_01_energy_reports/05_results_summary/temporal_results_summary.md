# Temporal Results Summary — Article 01 Energy Reports

## Article identification

**Provisional title:**  
Physical–statistical characterization of wind power density in complex Andean terrain: A multi-station study in Nariño, Colombia

**Target journal:** Energy Reports  
**Article type:** Research Article  
**Current phase:** Manuscript construction and repository consolidation  

---

## Purpose

This file summarizes the temporal-dependence analysis of daily wind power density by analytical zone.

It supports the manuscript sections related to:

```text
Daily WPD persistence
ACF analysis
PACF analysis
Short-term autoregressive structure
Zone-level temporal memory
Physical interpretation of wind-energy continuity
```

---

# 1. Temporal analysis objective

The temporal analysis was designed to determine whether daily WPD behaves as independent random variability or as a temporally structured physical process.

The analysis focused on:

```text
Daily wind power density
Daily wind speed
Analytical zones
ACF
PACF
Temporal decay
Persistence windows
```

The main variable for the article is:

```text
WPD = wind power density
```

Wind speed is used as supporting temporal evidence.

---

# 2. Why temporal dependence matters

Wind-energy potential is not only a function of instantaneous wind speed.

For energy characterization, it is important to determine whether energetic conditions persist across time.

Temporal persistence indicates that the system has memory.

In physical terms, this suggests that WPD is influenced by atmospheric continuity, regional circulation patterns, thermal gradients, pressure fields and terrain-mediated dynamics.

Therefore, ACF and PACF help interpret WPD as a structured physical signal rather than isolated noise.

---

# 3. Daily regularized series

The temporal-dependence analysis was performed using daily regularized WPD series by analytical zone.

This daily scale was selected because it allows:

```text
1. reduction of hourly fragmentation;
2. comparison across zones;
3. stable ACF/PACF estimation;
4. connection with meteorological persistence;
5. interpretation of daily energy regimes.
```

Short gaps were treated conservatively to allow regular time-series diagnostics.

---

# 4. Main ACF result

The autocorrelation function showed relevant daily persistence in WPD.

Approximate lag-1 ACF values were:

```text
Zone 1: 0.884
Zone 2: 0.862
Zone 3: 0.757
Zone 4: 0.575
```

Interpretation:

```text
All zones show positive short-term persistence.
Zone 1 and Zone 2 show the strongest immediate temporal continuity.
Zone 3 shows intermediate persistence.
Zone 4 shows weaker persistence and must be interpreted cautiously due to lower temporal coverage.
```

---

# 5. ACF temporal decay

The first lag where absolute ACF dropped below 0.2 was:

```text
Zone 1: not below 0.2 within the 90-day lag window
Zone 2: approximately lag 54
Zone 3: approximately lag 22
Zone 4: approximately lag 13
```

This indicates that the memory structure differs strongly among zones.

Zone 1 has the longest temporal persistence.

Zone 2 also shows extended persistence.

Zones 3 and 4 show faster temporal decay.

---

# 6. Physical interpretation of ACF

The ACF result supports the idea that WPD is not a sequence of independent daily events.

Instead, WPD shows temporal continuity.

This is especially important in Zone 1, where the energy regime is both:

```text
distributionally intermittent
temporally persistent
spectrally low-frequency dominated
```

This combination suggests that Zone 1 is not only affected by isolated extreme events, but by broader temporal structures that sustain energetic conditions over longer windows.

---

# 7. PACF result

The PACF analysis showed that most direct temporal dependence was concentrated at the first lag.

Approximate PACF lag-1 values were:

```text
Zone 1: 0.884
Zone 2: 0.862
Zone 3: 0.757
Zone 4: 0.575
```

The first lag where PACF dropped below 0.2 was approximately:

```text
Zone 1: lag 4
Zone 2: lag 2
Zone 3: lag 2
Zone 4: lag 2
```

---

# 8. Physical interpretation of PACF

The PACF result indicates that direct dependence is mainly short-range.

This means:

```text
Daily WPD has strong immediate memory.
The strongest direct dependence occurs from one day to the next.
Longer ACF persistence is partly mediated through short-lag dependence.
The system behaves as a temporally structured process rather than independent noise.
```

This supports future forecasting studies using autoregressive, machine-learning or hybrid physical-statistical models.

---

# 9. Zone 1 temporal behavior

Zone 1 is the most important temporal result.

It shows:

```text
High lag-1 ACF
Slow ACF decay
PACF persistence beyond lag 1
Long memory within the 90-day window
```

Interpretation:

```text
Zone 1 has a persistent WPD structure.
Its energetic behavior is not only intermittent but temporally organized.
High-WPD events may be embedded within broader atmospheric regimes.
```

This strengthens the physical interpretation of Zone 1 as the dominant wind-energy zone.

---

# 10. Zone 2 temporal behavior

Zone 2 also shows strong lag-1 persistence.

Its ACF drops below 0.2 around lag 54.

Interpretation:

```text
Zone 2 has relevant temporal memory.
Its WPD behavior is less dominant than Zone 1 in magnitude, but still temporally structured.
It may contain medium-range persistence useful for future forecasting models.
```

---

# 11. Zone 3 temporal behavior

Zone 3 shows intermediate temporal persistence.

Its ACF drops below 0.2 around lag 22.

Interpretation:

```text
Zone 3 has meaningful but shorter WPD memory.
Its temporal structure is less persistent than Zones 1 and 2.
Its behavior may reflect more local or shorter-duration atmospheric variability.
```

---

# 12. Zone 4 temporal behavior

Zone 4 shows the weakest persistence among the zones.

Its ACF drops below 0.2 around lag 13.

However, Zone 4 must be interpreted cautiously because of lower temporal coverage and shorter continuous segments.

Interpretation:

```text
Zone 4 presents shorter WPD memory.
Its results may be affected by data coverage limitations.
Its temporal diagnostics should be treated as supporting evidence, not as the strongest article result.
```

---

# 13. Main figure links

The temporal analysis supports the following figures:

```text
Figure 7:
Daily autocorrelation function of wind power density by analytical zone.

Figure S3:
Daily partial autocorrelation function of wind power density by analytical zone.

Figure S4:
Daily autocorrelation and partial autocorrelation support for wind speed.
```

---

# 14. Main table links

The temporal analysis supports the following tables:

```text
Table 4:
Temporal and spectral summary of wind power density by analytical zone.

Table S3:
Daily ACF and PACF values by lag and analytical zone.
```

---

# 15. Results wording for manuscript

Recommended manuscript paragraph:

```text
The daily ACF analysis showed that WPD presents clear temporal persistence across analytical zones. Lag-1 autocorrelation was high in Zones 1 and 2, intermediate in Zone 3 and lower in Zone 4. Zone 1 showed the slowest temporal decay, with autocorrelation remaining above 0.2 throughout the 90-day lag window. In contrast, Zones 2, 3 and 4 crossed this threshold at approximately 54, 22 and 13 days, respectively. These results indicate that daily WPD behaves as a temporally structured physical process rather than independent random variability.
```

---

# 16. PACF wording for manuscript

Recommended manuscript paragraph:

```text
The PACF analysis showed that most direct temporal dependence was concentrated at the first lag. After lag 1, partial autocorrelation decreased rapidly, especially in Zones 2–4, where values dropped below 0.2 by lag 2. Zone 1 retained direct dependence for a longer short-lag window, dropping below 0.2 around lag 4. This behavior suggests that the longer persistence observed in the ACF is partly mediated by short-lag dependence, supporting the presence of autoregressive structure in daily WPD dynamics.
```

---

# 17. Discussion wording

Recommended discussion paragraph:

```text
The temporal-dependence results reinforce the physical interpretation of WPD as a structured atmospheric-energy signal. In particular, Zone 1 combines high energetic contribution, distributional intermittency and long temporal persistence. This combination indicates that its WPD regime is not explained only by isolated high-wind events, but also by sustained atmospheric conditions that produce memory in the daily energy-density series. From a modeling perspective, the strong ACF and short-lag PACF structure suggest that future predictive approaches should explicitly account for temporal dependence.
```

---

# 18. Conclusion wording

Recommended conclusion point:

```text
Daily WPD showed relevant temporal persistence across zones. Zone 1 exhibited the longest memory, while Zones 2–4 showed progressively faster temporal decay. PACF results indicated that direct dependence was mainly concentrated at short lags, supporting the interpretation of WPD as a structured physical process with autoregressive behavior.
```

---

# 19. Claims allowed

The article can safely claim:

```text
Daily WPD showed positive temporal persistence.
Zone 1 had the strongest and longest WPD memory.
Zone 2 also showed relevant persistence.
Zones 3 and 4 showed faster temporal decay.
PACF indicated strong short-lag direct dependence.
Temporal structure supports future forecasting-oriented modeling.
WPD should not be interpreted as independent daily noise.
```

---

# 20. Claims to avoid

The article should not claim:

```text
The ACF/PACF analysis alone proves forecast accuracy.
Zone 1 persistence guarantees turbine-level energy production.
The temporal structure is caused by one specific atmospheric mechanism without additional evidence.
Zone 4 temporal behavior is fully reliable despite lower coverage.
The study already delivers an operational forecasting model.
```

---

# 21. TDQ control rule

Temporal claims must follow this chain:

```text
Daily regularized series
        ↓
ACF/PACF estimation
        ↓
Lag-value interpretation
        ↓
Decay-window comparison
        ↓
Physical meaning
        ↓
Manuscript claim
```

No temporal conclusion should be stated without support from ACF/PACF figures or temporal summary tables.

---

# 22. Current status

```text
Daily WPD series: completed
ACF analysis: completed
PACF analysis: completed
Temporal decay summary: completed
Temporal interpretation: drafted
Manuscript integration: pending refinement
```
