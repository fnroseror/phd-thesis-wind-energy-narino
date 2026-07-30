# Station and zone mapping

## Primary identifier

All joins, validations, and reproducibility checks must use the **IDEAM station code**. Names and aliases are descriptive fields and must not be used as the sole join key.

The machine-readable inventory is available in [`tables/station_inventory.csv`](tables/station_inventory.csv).

## Zone composition using the Table 2.1 aliases

### Zone 1 — five stations

| Table alias | IDEAM code | Station | Municipality |
|---|---|---|---|
| S01 | 51035020 | CCCP DL PACIFICO | Tumaco |
| S02 | 51025090 | GRANJA MIRA | Tumaco |
| S03 | 51025080 | ALTAQUER | Barbacoas |
| S04 | 51025060 | BIOTOPO | Barbacoas |
| S05 | 5102500128 | RESERVA NATURAL LA PLANADA | Ricaurte (Nariño) |

### Zone 2 — four stations

| Table alias | IDEAM code | Station | Municipality |
|---|---|---|---|
| S06 | 52055220 | EL PARAISO | Túquerres |
| S07 | 52055170 | LA JOSEFINA | Contadero |
| S08 | 52055230 | AEROPUERTO SAN LUIS | Aldana |
| S09 | 52055160 | VOLCAN CHILES | Cumbal |

### Zone 3 — five stations

| Table alias | IDEAM code | Station | Municipality |
|---|---|---|---|
| S10 | 5205500123 | LAS IGLESIAS | Pasto |
| S11 | 52045080 | UNIVERSIDAD DE NARINO | Pasto |
| S12 | 47015100 | EL ENCANO | Pasto |
| S13 | 52055210 | BOTANA | Pasto |
| S14 | 52055150 | CERRO PARAMO | Puerres |

### Zone 4 — two stations

| Table alias | IDEAM code | Station | Municipality |
|---|---|---|---|
| S15 | 52035040 | VIENTO LIBRE | Taminango |
| S16 | 52040050 | APONTE | El Tablón |

## Alias discrepancy

The corrected thesis states that IDEAM codes are primary and `S01`–`S16` are graphical aliases. However, the alias order shown in Table 2.1 differs from the alias order used by Figure 2.1/source map artifacts for several stations.

This discrepancy does **not** change the station universe, zone membership, counts, coordinates, or scientific results. It affects presentation labels only. The repository therefore preserves both fields:

- `thesis_table_alias`;
- `figure_map_alias`.

No pipeline may join or aggregate records using either alias. Use `station_code`.

## Meaning of the zones

The four zones are analytical comparison units. They do not claim:

- administrative regionalization;
- exhaustive spatial representativeness;
- interpolation of a continuous wind field;
- validation through Moran's I or another spatial-autocorrelation index;
- technical site selection for wind infrastructure.
