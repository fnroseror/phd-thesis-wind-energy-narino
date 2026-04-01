# Station–Zone Mapping

## Purpose

This document defines the spatial organization of the meteorological station network used in the doctoral thesis:

**“Estudio de la velocidad de viento e inclusión de parámetros físicos para la predicción de energía eléctrica producida por fuentes eólicas”**

Its purpose is to document the correspondence between the observational stations and the four geographic zones used as the regional analysis structure of the thesis.

This zoning is consistent with the methodological design of the doctoral work, where physical characterization, predictive modeling, uncertainty analysis, and energetic projection are carried out at the **zonal level**.

---

## General mapping principle

The doctoral research is based on approximately **8 million hourly meteorological records** corresponding to the period **2017–2022**, obtained from **16 meteorological stations** and grouped into **four geographic zones** in the department of **Nariño, Colombia**.

The grouping by zone was adopted in order to ensure:

- spatial representativeness,
- regional analytical coherence,
- variable completeness as far as possible,
- and structural consistency in physical and predictive interpretation.

The **zone** is therefore the operational spatial unit of the doctoral framework.

---

## Source station inventory

The following table presents the full station inventory used as the observational basis of the study.

| Station code | Source station name |
|---|---|
| 52055230 | AEROPUERTO SAN LUIS - AUT |
| 51025060 | BIOTOPO - AUT |
| 52055210 | BOTANA - AUT |
| 51025080 | ALTAQUER - AUT |
| 52040050 | APONTE |
| 51035020 | CCCP DL PACIFICO |
| 52055150 | CERRO PARAMO - AUT |
| 52055220 | EL PARAISO - AUT |
| 47015100 | EL ENCANO - AUT |
| 51025090 | GRANJA MIRA |
| 5205500123 | LAS IGLESIAS - AUT |
| 52055160 | VOLCAN CHILES - AUT |
| 52055170 | LA JOSEFINA - AUT |
| 52045080 | UNIVERSIDAD DE NARINO - AUT |
| 5102500128 | RESERVA NATURAL LA PLANADA - AUT |
| 52035040 | VIENTO LIBRE - AUT |

**Total stations:** 16

---

## Zonal organization used in the thesis

The following mapping corresponds to the zonal organization actually used in the consolidated doctoral dataset.

### Zone 1

**Scientific role in the thesis**
- Zone 1 is used as a representative zone for the most detailed physical characterization.
- It is associated with strong dispersion, structural asymmetry, and marked intermittency in wind dynamics.
- It supports the detailed illustration of ACF, PACF, FFT, and Wavelet analysis in the physical characterization stage.

**Stations**

| Zone | Station code | Normalized station name | Source station name |
|---|---|---|---|
| 1 | 51035020 | CCCP DL PACIFICO | CCCP DL PACIFICO |
| 1 | 51025090 | GRANJA MIRA | GRANJA MIRA |
| 1 | 51025080 | ALTAQUER | ALTAQUER - AUT |
| 1 | 51025060 | BIOTOPO | BIOTOPO - AUT |
| 1 | 5102500128 | RESERVA NATURAL LA PLANADA | RESERVA NATURAL LA PLANADA - AUT |

**Total stations in Zone 1:** 5

---

### Zone 2

**Scientific role in the thesis**
- Zone 2 is one of the most energetically relevant zones of the regional system.
- It exhibits strong predictive structure in several forecasting horizons.
- In the projection stage, it emerges as a region of high energetic relevance.

**Stations**

| Zone | Station code | Normalized station name | Source station name |
|---|---|---|---|
| 2 | 52055220 | EL PARAISO | EL PARAISO - AUT |
| 2 | 52055170 | LA JOSEFINA | LA JOSEFINA - AUT |
| 2 | 52055230 | AEROPUERTO SAN LUIS | AEROPUERTO SAN LUIS - AUT |
| 2 | 52055160 | VOLCAN CHILES | VOLCAN CHILES - AUT |

**Total stations in Zone 2:** 4

---

### Zone 3

**Scientific role in the thesis**
- Zone 3 represents an intermediate regional regime with relevant predictive structure.
- It contributes to the comparative interpretation of physical variability, predictive behavior, and energetic heterogeneity.
- It is part of the regional contrast discussed in the doctoral framework.

**Stations**

| Zone | Station code | Normalized station name | Source station name |
|---|---|---|---|
| 3 | 5205500123 | LAS IGLESIAS | LAS IGLESIAS - AUT |
| 3 | 52045080 | UNIVERSIDAD DE NARINO | UNIVERSIDAD DE NARINO - AUT |
| 3 | 47015100 | EL ENCANO | EL ENCANO - AUT |
| 3 | 52055210 | BOTANA | BOTANA - AUT |
| 3 | 52055150 | CERRO PARAMO | CERRO PARAMO - AUT |

**Total stations in Zone 3:** 5

---

### Zone 4

**Scientific role in the thesis**
- Zone 4 is associated with a comparatively more regular and stable regional regime.
- It is relevant for the interpretation of structural stability and energetic persistence.
- It remains important in the projected energetic stage of the thesis.

**Stations**

| Zone | Station code | Normalized station name | Source station name |
|---|---|---|---|
| 4 | 52035040 | VIENTO LIBRE | VIENTO LIBRE - AUT |
| 4 | 52040050 | APONTE | APONTE |

**Total stations in Zone 4:** 2

---

## Global zonal summary

| Zone | Number of stations |
|---|---:|
| 1 | 5 |
| 2 | 4 |
| 3 | 5 |
| 4 | 2 |
| **Total** | **16** |

---

## Normalization note

The master station inventory includes source names exactly as registered in the downloaded records. Several of these names contain the suffix **“- AUT”**, which likely indicates automated stations.

For repository consistency, this document preserves:

- the **source station name** exactly as registered in the original inventory,
- and a **normalized station name** without the “- AUT” suffix, matching the naming convention used in the zonal organization of the doctoral dataset.

This allows both traceability to source metadata and coherence with the regional analytical workflow.

---

## Interpretation within the repository

This file acts as the formal bridge between:

- the original observational station network,
- the zonal aggregation strategy,
- and the regional scientific logic of the thesis.

Although the repository is organized by methodological stages, the doctoral work interprets the atmospheric system primarily through **regional zonal regimes** rather than isolated stations. For that reason, this mapping is essential to preserve the spatial provenance of the observational basis.

---

## Final note

This document defines the validated station-to-zone structure used in the repository.

It should be interpreted as the formal spatial reference of the observational system supporting the thesis, ensuring coherence between:

- the original meteorological sources,
- the zonal analytical framework,
- the predictive architecture,
- and the regional energetic interpretation developed in the doctoral work.
