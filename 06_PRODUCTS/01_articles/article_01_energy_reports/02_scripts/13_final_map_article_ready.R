# ============================================================
# FIGURE 1 — FINAL ARTICLE-READY MAP
# Physiographic setting, analytical zoning and IDEAM stations
# Nariño, Colombia
# Article 01 — Energy Reports
# ============================================================

required_packages <- c(
  "sf", "terra", "geodata", "ggplot2", "dplyr", "readr",
  "ggrepel", "ggspatial", "patchwork", "stringr",
  "grid", "scales", "ggnewscale"
)

installed_packages <- rownames(installed.packages())

for (pkg in required_packages) {
  if (!pkg %in% installed_packages) {
    install.packages(pkg, dependencies = TRUE)
  }
}

library(sf)
library(terra)
library(geodata)
library(ggplot2)
library(dplyr)
library(readr)
library(ggrepel)
library(ggspatial)
library(patchwork)
library(stringr)
library(grid)
library(scales)
library(ggnewscale)

# ============================================================
# 1. PATHS
# ============================================================

base_dir <- "E:/Academia/UNAL/DOCTORADO/Productos/Articulo 1"

input_dir  <- file.path(base_dir, "01_data_processed")
figure_dir <- file.path(base_dir, "03_figures", "publication_ready_final")
map_dir    <- file.path(base_dir, "02_results", "map_boundaries")

dir.create(input_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(map_dir, recursive = TRUE, showWarnings = FALSE)

stations_file <- file.path(input_dir, "stations_zones_narino.csv")

if (!file.exists(stations_file)) {
  stop("stations_zones_narino.csv was not found in 01_data_processed.")
}

# ============================================================
# 2. LOAD STATIONS
# ============================================================

stations <- read_csv(stations_file, show_col_types = FALSE)

required_cols <- c("station_code", "station_name", "longitude", "latitude", "zone")
missing_cols <- setdiff(required_cols, names(stations))

if (length(missing_cols) > 0) {
  stop(paste("Missing columns:", paste(missing_cols, collapse = ", ")))
}

stations <- stations %>%
  mutate(
    station_code = as.character(station_code),
    station_name = as.character(station_name),
    longitude    = as.numeric(longitude),
    latitude     = as.numeric(latitude),
    zone         = factor(as.character(zone), levels = c("1", "2", "3", "4"))
  ) %>%
  filter(
    !is.na(longitude),
    !is.na(latitude),
    !is.na(zone)
  ) %>%
  arrange(zone, station_code) %>%
  mutate(
    station_id = sprintf("S%02d", row_number())
  )

stations_sf <- st_as_sf(
  stations,
  coords = c("longitude", "latitude"),
  crs = 4326,
  remove = FALSE
)

station_key <- stations %>%
  select(
    station_id,
    station_code,
    station_name,
    zone,
    longitude,
    latitude,
    everything()
  )

write_csv(
  station_key,
  file.path(figure_dir, "Fig_01_station_key_for_map.csv")
)

# ============================================================
# 3. LOAD ADMINISTRATIVE BOUNDARIES
# ============================================================

message("Loading administrative boundaries...")

colombia_admin1 <- geodata::gadm(country = "COL", level = 1, path = map_dir)
colombia_admin2 <- geodata::gadm(country = "COL", level = 2, path = map_dir)

colombia_sf <- st_as_sf(colombia_admin1)
municipios_sf <- st_as_sf(colombia_admin2)

narino_sf <- colombia_sf %>%
  filter(str_detect(str_to_lower(NAME_1), "nari"))

narino_muni_sf <- municipios_sf %>%
  filter(str_detect(str_to_lower(NAME_1), "nari"))

if (nrow(narino_sf) == 0) {
  stop("Nariño boundary was not found.")
}

if (nrow(narino_muni_sf) == 0) {
  stop("Municipal boundaries for Nariño were not found.")
}

# ============================================================
# 4. MAP EXTENT
# ============================================================

bbox_nar <- st_bbox(narino_sf)

xrange <- as.numeric(bbox_nar["xmax"] - bbox_nar["xmin"])
yrange <- as.numeric(bbox_nar["ymax"] - bbox_nar["ymin"])

xmin_ext <- as.numeric(bbox_nar["xmin"]) - 0.10 * xrange
xmax_ext <- as.numeric(bbox_nar["xmax"]) + 0.03 * xrange
ymin_ext <- as.numeric(bbox_nar["ymin"]) - 0.03 * yrange
ymax_ext <- as.numeric(bbox_nar["ymax"]) + 0.03 * yrange

# ============================================================
# 5. DEM + HILLSHADE
# ============================================================

message("Loading elevation data...")

dem_colombia <- geodata::elevation_30s(country = "COL", path = map_dir)

ext_terra <- terra::ext(
  xmin_ext,
  xmax_ext,
  ymin_ext,
  ymax_ext
)

dem_crop <- terra::crop(dem_colombia, ext_terra)
names(dem_crop) <- "elevation_m"

dem_smooth <- terra::focal(
  dem_crop,
  w = matrix(1, nrow = 3, ncol = 3),
  fun = mean,
  na.policy = "omit"
)

names(dem_smooth) <- "elevation_m"

slope  <- terra::terrain(dem_smooth, v = "slope", unit = "radians")
aspect <- terra::terrain(dem_smooth, v = "aspect", unit = "radians")

hs1 <- terra::shade(slope, aspect, angle = 40, direction = 315)
hs2 <- terra::shade(slope, aspect, angle = 35, direction = 40)
hs3 <- terra::shade(slope, aspect, angle = 50, direction = 270)

hillshade <- (hs1 * 0.55) + (hs2 * 0.25) + (hs3 * 0.20)
names(hillshade) <- "hillshade"

dem_df <- terra::as.data.frame(dem_smooth, xy = TRUE, na.rm = TRUE)
shade_df <- terra::as.data.frame(hillshade, xy = TRUE, na.rm = TRUE)

shade_df <- shade_df %>%
  mutate(
    hillshade_norm =
      (hillshade - min(hillshade, na.rm = TRUE)) /
      (max(hillshade, na.rm = TRUE) - min(hillshade, na.rm = TRUE)),
    shadow = 1 - hillshade_norm
  )

contours <- terra::as.contour(
  dem_smooth,
  levels = seq(500, 4500, by = 500)
)

contours_sf <- st_as_sf(contours)

# ============================================================
# 6. ANALYTICAL ZONE ENVELOPES
# ============================================================

stations_3116 <- st_transform(stations_sf, 3116)

zone_hulls <- stations_3116 %>%
  group_by(zone) %>%
  summarise(do_union = TRUE, .groups = "drop") %>%
  st_buffer(dist = 18000) %>%
  st_convex_hull() %>%
  st_transform(4326)

zone_hulls <- suppressWarnings(
  st_intersection(zone_hulls, narino_sf)
)

zone_hulls <- zone_hulls %>%
  mutate(zone = factor(as.character(zone), levels = c("1", "2", "3", "4")))

zone_label_pts <- st_point_on_surface(zone_hulls)

zone_label_df <- cbind(
  st_drop_geometry(zone_label_pts),
  st_coordinates(zone_label_pts)
) %>%
  mutate(
    zone_label = paste0("Zone ", zone)
  )

stations_label_df <- cbind(
  st_drop_geometry(stations_sf),
  st_coordinates(stations_sf)
)

# ============================================================
# 7. COLOR PALETTES
# ============================================================

zone_palette <- c(
  "1" = "#E41A1C",
  "2" = "#377EB8",
  "3" = "#1B9E77",
  "4" = "#984EA3"
)

elevation_palette <- c(
  "#38b6c3",
  "#63c08c",
  "#b7d96b",
  "#f0d55a",
  "#e49a3a",
  "#b86f30",
  "#8b5a3c",
  "#dadada"
)

# ============================================================
# 8. MAIN MAP
# ============================================================

main_map <- ggplot() +

  geom_rect(
    aes(
      xmin = xmin_ext,
      xmax = xmax_ext,
      ymin = ymin_ext,
      ymax = ymax_ext
    ),
    fill = "#bfe2ef",
    color = NA
  ) +

  geom_raster(
    data = dem_df,
    aes(x = x, y = y, fill = elevation_m)
  ) +
  scale_fill_gradientn(
    colors = elevation_palette,
    values = rescale(c(0, 300, 700, 1200, 1800, 2500, 3200, 4500)),
    name = "Elevation\n(m a.s.l.)",
    oob = squish
  ) +

  geom_raster(
    data = shade_df,
    aes(x = x, y = y, alpha = shadow),
    fill = "black"
  ) +
  scale_alpha_continuous(
    range = c(0.00, 0.28),
    guide = "none"
  ) +

  ggnewscale::new_scale_fill() +

  geom_sf(
    data = narino_muni_sf,
    fill = NA,
    color = alpha("grey25", 0.45),
    linewidth = 0.22
  ) +

  geom_sf(
    data = contours_sf,
    color = alpha("grey20", 0.13),
    linewidth = 0.10
  ) +

  geom_sf(
    data = zone_hulls,
    aes(fill = zone),
    color = NA,
    alpha = 0.24,
    show.legend = FALSE
  ) +
  scale_fill_manual(
    values = zone_palette,
    guide = "none"
  ) +

  geom_sf(
    data = zone_hulls,
    aes(color = zone),
    fill = NA,
    linewidth = 1.05,
    linetype = "solid",
    alpha = 0.98,
    show.legend = FALSE
  ) +

  geom_sf(
    data = narino_sf,
    fill = NA,
    color = "white",
    linewidth = 1.6
  ) +
  geom_sf(
    data = narino_sf,
    fill = NA,
    color = "black",
    linewidth = 0.95
  ) +

  ggnewscale::new_scale_fill() +

  geom_sf(
    data = stations_sf,
    shape = 21,
    aes(fill = zone),
    color = "white",
    stroke = 0.85,
    size = 4.0,
    show.legend = TRUE
  ) +

  geom_label_repel(
    data = stations_label_df,
    aes(
      x = X,
      y = Y,
      label = station_id,
      color = zone
    ),
    fill = alpha("white", 0.90),
    fontface = "bold",
    size = 3.0,
    label.size = 0.12,
    label.padding = unit(0.10, "lines"),
    box.padding = 0.32,
    point.padding = 0.25,
    segment.color = "grey30",
    segment.size = 0.24,
    max.overlaps = Inf,
    seed = 123,
    show.legend = FALSE
  ) +

  geom_label(
    data = zone_label_df,
    aes(
      x = X,
      y = Y,
      label = zone_label,
      fill = zone
    ),
    color = "white",
    fontface = "bold",
    size = 3.6,
    alpha = 0.88,
    label.size = 0.18,
    show.legend = FALSE
  ) +

  scale_fill_manual(
    values = zone_palette,
    name = "Analytical\nzone",
    guide = guide_legend(
      override.aes = list(
        shape = 21,
        size = 4.5,
        color = "white"
      )
    )
  ) +

  scale_color_manual(
    values = zone_palette,
    guide = "none"
  ) +

  annotate(
    "text",
    x = xmin_ext + 0.12 * (xmax_ext - xmin_ext),
    y = ymin_ext + 0.15 * (ymax_ext - ymin_ext),
    label = "Pacific Ocean",
    fontface = "italic",
    size = 4.1,
    color = alpha("grey20", 0.85)
  ) +

  coord_sf(
    xlim = c(xmin_ext, xmax_ext),
    ylim = c(ymin_ext, ymax_ext),
    expand = FALSE
  ) +

  annotation_scale(
    location = "bl",
    width_hint = 0.12,
    text_cex = 0.82,
    line_width = 0.75
  ) +

  annotation_north_arrow(
    location = "tr",
    which_north = "true",
    style = north_arrow_fancy_orienteering(
      fill = c("black", "white"),
      line_col = "black"
    ),
    height = unit(0.85, "cm"),
    width = unit(0.85, "cm")
  ) +

  labs(
    title = "Physiographic setting and analytical zoning in Nariño, Colombia",
    subtitle = "Topographic context, municipal boundaries and IDEAM stations (S01–S16) used for WPD assessment",
    x = NULL,
    y = NULL
  ) +

  theme_minimal(base_size = 12) +
  theme(
    panel.background = element_rect(fill = "#bfe2ef", color = NA),
    plot.background  = element_rect(fill = "white", color = NA),
    plot.title = element_text(face = "bold", size = 15, hjust = 0.5),
    plot.subtitle = element_text(size = 10.6, hjust = 0.5),
    legend.position = "right",
    legend.box = "vertical",
    legend.title = element_text(face = "bold", size = 10.5),
    legend.text = element_text(size = 9.5),
    panel.grid.major = element_line(color = alpha("white", 0.45), linewidth = 0.22),
    panel.grid.minor = element_blank(),
    axis.text = element_text(size = 9)
  )

# ============================================================
# 9. COLOMBIA INSET
# ============================================================

map_colombia <- ggplot() +
  geom_sf(
    data = colombia_sf,
    fill = "grey88",
    color = "white",
    linewidth = 0.12
  ) +
  geom_sf(
    data = narino_sf,
    fill = "#E41A1C",
    color = "black",
    linewidth = 0.20
  ) +
  labs(title = "Colombia") +
  theme_void(base_size = 9) +
  theme(
    plot.title = element_text(face = "bold", size = 9.2, hjust = 0.5),
    plot.background = element_rect(
      fill = alpha("white", 0.92),
      color = "grey65",
      linewidth = 0.25
    )
  )

final_map <- main_map +
  patchwork::inset_element(
    map_colombia,
    left = 0.045,
    bottom = 0.70,
    right = 0.17,
    top = 0.93,
    align_to = "panel"
  )

print(final_map)

# ============================================================
# 10. EXPORT
# ============================================================

tiff_file <- file.path(
  figure_dir,
  "Fig_01_final_article_ready_map_narino.tiff"
)

png_file <- file.path(
  figure_dir,
  "Fig_01_final_article_ready_map_narino.png"
)

ggsave(
  filename = tiff_file,
  plot = final_map,
  width = 10.0,
  height = 7.4,
  units = "in",
  dpi = 600,
  compression = "lzw",
  bg = "white"
)

ggsave(
  filename = png_file,
  plot = final_map,
  width = 10.0,
  height = 7.4,
  units = "in",
  dpi = 300,
  bg = "white"
)

zone_station_summary <- stations %>%
  count(zone, name = "n_stations") %>%
  arrange(zone)

write_csv(
  zone_station_summary,
  file.path(figure_dir, "Fig_01_zone_station_summary.csv")
)

message("============================================================")
message("Final article-ready map created successfully.")
message("TIFF: ", tiff_file)
message("PNG : ", png_file)
message("Station key: ", file.path(figure_dir, "Fig_01_station_key_for_map.csv"))
message("Zone summary: ", file.path(figure_dir, "Fig_01_zone_station_summary.csv"))
message("============================================================")
