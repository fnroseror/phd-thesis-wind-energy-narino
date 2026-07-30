# Distribution Results Summary — Article 01 Energy Reports

## Article identification

**Provisional title:**  
Physical–statistical characterization of wind power density in complex Andean terrain: A multi-station study in Nariño, Colombia

**Target journal:** Energy Reports  
**Article type:** Research Article  
**Current phase:** Manuscript construction and repository consolidation  

---

## Purpose

This file summarizes the distributional analysis of wind speed and wind power density by analytical zone.

It supports the manuscript sections related to:

```text
Descriptive statistics
Wind-speed distribution
Wind power density distribution
Weibull fitting
Rayleigh comparison
AIC/BIC model selection
Physical interpretation of intermittency
```

---

# 1. Distributional analysis objective

The objective of the distributional analysis was to determine whether the wind-speed regimes in the analytical zones could be adequately represented by standard probability distributions and whether the resulting distributional behavior supports the physical interpretation of wind power density.

The analysis focused on two variables:

```text
VV  = wind speed
WPD = wind power density
```

Wind speed was used for Weibull/Rayleigh fitting.

WPD was used to evaluate the energetic consequence of wind-speed variability.

---

# 2. Why wind speed and WPD behave differently

Wind speed and WPD do not have the same distributional behavior because WPD depends on the cube of wind speed:

```text
WPD = 0.5 * rho * v^3
```

Therefore, moderate differences in wind speed can produce large differences in WPD.

This explains why WPD distributions are more asymmetric and more sensitive to high-wind events than wind-speed distributions.

---

# 3. Main empirical distribution result

The empirical distributions showed that the analytical zones do not share the same wind regime.

The main contrast was observed in Zone 1.

Zone 1 showed:

```text
Higher WPD
Greater asymmetry
Stronger intermittency
Greater energetic contribution from high-wind events
```

Zones 2–4 showed:

```text
Lower WPD
More regular wind-speed behavior
Less energetic asymmetry
More compact distributions
```

---

# 4. Weibull and Rayleigh comparison

Two models were compared:

```text
Weibull distribution
Rayleigh distribution
```

The Rayleigh distribution was used as a constrained reference model.

The Weibull distribution was used as the flexible model because it allows different shape regimes.

The main result was:

```text
Weibull outperformed Rayleigh in all analytical zones.
```

This supports the use of Weibull as the preferred distributional model for the article.

---

# 5. Weibull parameters by zone

The fitted Weibull parameters were:

```text
Zone 1:
shape k  = 0.7880893
scale λ  = 2.058123

Zone 2:
shape k  = 1.9841502
scale λ  = 2.967818

Zone 3:
shape k  = 2.0888799
scale λ  = 2.831368

Zone 4:
shape k  = 2.1638745
scale λ  = 3.051806
```

---

# 6. Physical interpretation of Weibull shape parameter

The Weibull shape parameter `k` provides physical information about wind-regime structure.

General interpretation:

```text
k < 1:
Highly asymmetric regime.
High frequency of low wind-speed states.
Intermittent occurrence of energetic wind events.

k ≈ 2:
More regular wind-speed regime.
Closer to Rayleigh-like behavior.
Less extreme asymmetry.

k > 2:
More concentrated wind-speed regime.
Lower relative intermittency.
```

Application to this study:

```text
Zone 1:
k = 0.7880893
Interpretation: strongly intermittent wind-speed regime.

Zones 2–4:
k ≈ 2
Interpretation: more regular regimes, closer to Rayleigh-like behavior.
```

However, even in Zones 2–4, Weibull remained superior to Rayleigh.

---

# 7. Interpretation of Zone 1

Zone 1 is the key distributional result of the article.

Its Weibull shape parameter below 1 indicates a highly asymmetric regime.

This means that Zone 1 has many low-wind states but also a set of energetic events that strongly influence WPD.

Because WPD depends on `v^3`, these high-wind events generate a disproportionate energetic effect.

Therefore, Zone 1 should be interpreted as:

```text
Not simply a zone with uniformly high wind speed.
Rather, a zone with intermittent energetic wind events.
```

This distinction is central for the Discussion section.

---

# 8. Interpretation of Zones 2–4

Zones 2–4 showed Weibull shape parameters close to 2.

This indicates more regular wind-speed regimes and behavior closer to the Rayleigh assumption.

However, the Weibull model still outperformed Rayleigh.

This means that even when the wind regime appears more regular, the flexibility of Weibull remains necessary for accurate representation.

Interpretation:

```text
Zones 2–4 are more regular than Zone 1.
They are less energetically intermittent.
They show lower WPD levels.
They are closer to Rayleigh-like behavior, but not fully Rayleigh.
```

---

# 9. Density fit interpretation

The density-fit figures support the following message:

```text
The Weibull model follows the empirical wind-speed distribution more closely than Rayleigh across the analytical zones.
```

The density plots are useful for showing:

```text
1. distributional shape;
2. peak location;
3. asymmetry;
4. tail behavior;
5. differences among zones.
```

Main manuscript use:

```text
Figure 5. Weibull and Rayleigh density fits by analytical zone.
```

---

# 10. CDF fit interpretation

The cumulative distribution function provides a complementary evaluation of fit.

The CDF comparison is useful because it evaluates the complete wind-speed range.

Main manuscript use:

```text
Figure 6. Weibull and Rayleigh cumulative distribution fits by analytical zone.
```

Interpretation:

```text
The Weibull model better reproduces the empirical cumulative behavior across the complete wind-speed range.
```

---

# 11. AIC/BIC interpretation

AIC and BIC were used to compare the relative performance of Weibull and Rayleigh models.

The main result was:

```text
Weibull showed better information-criterion performance than Rayleigh in all zones.
```

This confirms that the improvement is not only visual but also supported by quantitative model-selection criteria.

Supplementary use:

```text
Figure S2. Delta AIC/BIC comparison between Weibull and Rayleigh models.
```

---

# 12. WPD distribution interpretation

WPD distributions were more asymmetric than wind-speed distributions because of the cubic amplification of wind speed.

This is especially important for Zone 1.

Key interpretation:

```text
Small differences in wind speed can become large differences in WPD.
High-wind events can dominate the energetic signal.
Mean WPD can be strongly influenced by the upper tail.
Median WPD may remain much lower than mean WPD in intermittent regimes.
```

This supports the need to analyze WPD directly instead of relying only on wind-speed summaries.

---

# 13. Main figure links

The distributional analysis supports the following figures:

```text
Figure 3:
Wind-speed distribution by analytical zone.

Figure 4:
Wind power density distribution by analytical zone.

Figure 5:
Weibull and Rayleigh density fits by analytical zone.

Figure 6:
Weibull and Rayleigh cumulative distribution fits by analytical zone.

Figure S2:
Delta AIC/BIC comparison between Weibull and Rayleigh models.
```

---

# 14. Main table links

The distributional analysis supports the following tables:

```text
Table 2:
Descriptive statistics of wind speed and wind power density by analytical zone.

Table 3:
Weibull and Rayleigh distribution parameters and goodness-of-fit metrics by analytical zone.

Table S2:
Full Weibull/Rayleigh fitting metrics.
```

---

# 15. Results wording for manuscript

Recommended manuscript paragraph:

```text
The distributional analysis showed marked differences among analytical zones. Zone 1 exhibited the most asymmetric and intermittent wind-speed regime, with a Weibull shape parameter below unity. This behavior indicates the coexistence of frequent low-wind states and occasional energetic wind events. Because WPD scales with the cube of wind speed, these events produced a disproportionate effect on the energy-density distribution. In contrast, Zones 2–4 showed Weibull shape parameters close to two, suggesting more regular wind-speed regimes closer to the Rayleigh assumption. Nevertheless, Weibull outperformed Rayleigh in all zones, confirming that the additional flexibility of the Weibull model was necessary to represent the observed wind-speed behavior.
```

---

# 16. Discussion wording

Recommended discussion paragraph:

```text
The superiority of Weibull over Rayleigh indicates that wind-speed behavior in complex Andean terrain cannot be reduced to a single constrained distributional form. This is particularly evident in Zone 1, where the Weibull shape parameter below unity reveals a strongly intermittent regime. From an energy perspective, this intermittency is critical because the cubic dependence of WPD on wind speed amplifies the contribution of high-wind events. Therefore, the energetic relevance of Zone 1 is not explained only by average wind speed, but by the distributional structure of the wind regime and the presence of events located in the upper tail of the distribution.
```

---

# 17. Conclusion wording

Recommended conclusion point:

```text
Weibull was the preferred distributional model in all analytical zones. Zone 1 presented a strongly intermittent wind regime, while Zones 2–4 showed more regular behavior closer to the Rayleigh assumption. The distributional structure confirms that WPD-based assessment provides stronger physical insight than wind-speed-only characterization.
```

---

# 18. Claims allowed

The article can safely claim:

```text
Weibull outperformed Rayleigh in all zones.
Zone 1 showed the most intermittent regime.
Zone 1 had a Weibull shape parameter below 1.
Zones 2–4 had Weibull shape parameters close to 2.
WPD distributions were more asymmetric than wind-speed distributions.
The cubic dependence of WPD amplifies high-wind events.
Distributional analysis supports zone-level wind-energy characterization.
```

---

# 19. Claims to avoid

The article should not claim:

```text
Zone 1 is immediately suitable for wind-farm installation.
The region is economically viable for wind-energy production.
The analysis identifies exact turbine production.
The Weibull model proves turbine-level feasibility.
Rayleigh is invalid in all possible contexts.
The distributional fit alone is sufficient for energy planning.
```

---

# 20. TDQ control rule

Distributional claims must follow this chain:

```text
Empirical distribution
        ↓
Fitted model
        ↓
Parameter interpretation
        ↓
Information criterion support
        ↓
Physical meaning for WPD
        ↓
Manuscript claim
```

No distributional conclusion should be stated without support from figures, tables or fitted parameters.

---

# 21. Current status

```text
Wind-speed distributions: completed
WPD distributions: completed
Weibull fitting: completed
Rayleigh fitting: completed
AIC/BIC comparison: completed
Distributional summary: drafted
Manuscript integration: pending refinement
```
