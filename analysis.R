
# Finnish Forest LiDAR: A Reproducible R Workflow
# Practice analysis using the MixedConifer sample included with lidR
# Author: Esi Yawson

# 1. Load packages
library(lidR)
library(ggplot2)

# 2. Create output folders
dir.create("outputs/figures", recursive = TRUE,
           showWarnings = FALSE)
dir.create("outputs/tables", recursive = TRUE,
           showWarnings = FALSE)
dir.create("data/raw", recursive = TRUE,
           showWarnings = FALSE)
dir.create("data/processed", recursive = TRUE,
           showWarnings = FALSE)

# ============================================================
# PRACTICE ANALYSIS: MixedConifer sample dataset
# These results are for practice, not the Finnish study.
# ============================================================

# 3. Locate and load the practice point cloud
sample_file <- system.file(
  "extdata",
  "MixedConifer.laz",
  package = "lidR"
)

if (!file.exists(sample_file)) {
  stop("The MixedConifer sample file was not found.")
}

las <- readLAS(sample_file)

# 4. Inspect the point cloud
print(las)
print(names(las@data))
print(table(las@data$Classification, useNA = "ifany"))

# 5. Create a reproducible sample for plotting
set.seed(123)

plot_data <- las@data[
  sample(seq_len(nrow(las@data)),
         min(10000, nrow(las@data))),
]

# 6. Plot point locations coloured by original Z values
p <- ggplot(
  plot_data,
  aes(x = X, y = Y, colour = Z)
) +
  geom_point(size = 0.5) +
  coord_equal() +
  scale_colour_viridis_c(name = "Z value (m)") +
  labs(
    title = "LiDAR Point Cloud: Mixed Conifer Sample",
    subtitle = "Sampled points coloured by their Z values",
    x = "X coordinate",
    y = "Y coordinate"
  ) +
  theme_minimal()

print(p)

# 7. Save the figure
ggsave(
  "outputs/figures/mixed_conifer_point_cloud.png",
  p,
  width = 8,
  height = 6,
  dpi = 300
)

# 8. Summarise the original Z values
z_summary <- data.frame(
  metric = c(
    "Minimum Z",
    "Median Z",
    "Mean Z",
    "90th percentile Z",
    "95th percentile Z",
    "Maximum Z",
    "Standard deviation Z"
  ),
  value = c(
    min(las@data$Z, na.rm = TRUE),
    median(las@data$Z, na.rm = TRUE),
    mean(las@data$Z, na.rm = TRUE),
    quantile(las@data$Z, 0.90, na.rm = TRUE),
    quantile(las@data$Z, 0.95, na.rm = TRUE),
    max(las@data$Z, na.rm = TRUE),
    sd(las@data$Z, na.rm = TRUE)
  )
)

print(z_summary)

write.csv(
  z_summary,
  "outputs/tables/original_z_summary.csv",
  row.names = FALSE
)

# 9. Compare ground and non-ground Z values

ground_points <- las@data[
  las@data$Classification == 2
]

non_ground_points <- las@data[
  las@data$Classification != 2
]

cat("Ground points:", nrow(ground_points), "\n")
cat("Non-ground points:", nrow(non_ground_points), "\n")

cat("\nGround Z values:\n")
print(summary(ground_points$Z))

cat("\nNon-ground Z values:\n")
print(summary(non_ground_points$Z))

# 10. Inspect LiDAR file metadata

header <- las@header

print(header)

# Check the coordinate reference system
st_crs(las)


# 11. Plot the distribution of original Z values

# Plot 1: Full distribution, including values near zero
p_height_all <- ggplot(las@data, aes(x = Z)) +
  geom_histogram(
    bins = 40,
    fill = "#287D8E",
    colour = "white",
    linewidth = 0.2
  ) +
  labs(
    title = "Distribution of LiDAR Z Values",
    subtitle = "All points in the MixedConifer practice sample",
    x = "Original Z value (m)",
    y = "Number of points",
    caption = "Source: lidR package example dataset"
  ) +
  theme_minimal(base_size = 12)

print(p_height_all)

ggsave(
  "outputs/figures/original_z_distribution.png",
  p_height_all,
  width = 9,
  height = 5.5,
  dpi = 300
)

# Plot 2: Zoomed distribution above 1 metre
p_height_zoom <- ggplot(
  las@data[las@data$Z > 1, ],
  aes(x = Z)
) +
  geom_histogram(
    bins = 35,
    fill = "#D18F43",
    colour = "white",
    linewidth = 0.2
  ) +
  labs(
    title = "Distribution of LiDAR Z Values Above 1 m",
    subtitle = "Zoomed view of the higher Z values",
    x = "Original Z value (m)",
    y = "Number of points",
    caption = "Values at or below 1 m are excluded from this visualisation only"
  ) +
  theme_minimal(base_size = 12)

print(p_height_zoom)

ggsave(
  "outputs/figures/z_distribution_above_1m.png",
  p_height_zoom,
  width = 9,
  height = 5.5,
  dpi = 300
)


# 12. Explore the distribution of points across Z-value bands

las_data <- las@data

las_data$z_band <- cut(
  las_data$Z,
  breaks = c(-Inf, 0.5, 2, 5, 10, 20, Inf),
  labels = c(
    "0-0.5 m",
    "0.5-2 m",
    "2-5 m",
    "5-10 m",
    "10-20 m",
    "Above 20 m"
  ),
  right = TRUE
)

z_band_summary <- as.data.frame(
  table(las_data$z_band)
)

names(z_band_summary) <- c("z_band", "number_of_points")

z_band_summary$percentage <- 100 *
  z_band_summary$number_of_points / nrow(las_data)

print(z_band_summary)

write.csv(
  z_band_summary,
  "outputs/tables/z_band_summary.csv",
  row.names = FALSE
)


# 13. Plot the percentage of points in each Z-value band

p_z_bands <- ggplot(
  z_band_summary,
  aes(x = z_band, y = percentage)
) +
  geom_col(fill = "#287D8E", width = 0.7) +
  geom_text(
    aes(label = sprintf("%.1f%%", percentage)),
    vjust = -0.4,
    size = 3.5
  ) +
  labs(
    title = "Distribution of LiDAR Points Across Z-Value Bands",
    subtitle = "MixedConifer practice sample",
    x = "Original Z-value band",
    y = "Points (%)",
    caption = "Bands describe original Z values, not confirmed canopy heights."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 30, hjust = 1)
  ) +
  expand_limits(y = max(z_band_summary$percentage) * 1.12)

print(p_z_bands)

ggsave(
  "outputs/figures/z_band_distribution.png",
  p_z_bands,
  width = 9,
  height = 5.5,
  dpi = 300
)


# 14. Compare Z-value distributions by classification

p_class_z <- ggplot(
  las@data,
  aes(x = factor(Classification), y = Z)
) +
  geom_boxplot(
    fill = "#287D8E",
    alpha = 0.8,
    outlier.size = 0.4
  ) +
  labs(
    title = "Z-Value Distribution by Point Classification",
    subtitle = "MixedConifer practice sample",
    x = "LAS classification code",
    y = "Original Z value (m)"
  ) +
  theme_minimal(base_size = 12)

print(p_class_z)

ggsave(
  "outputs/figures/z_by_classification.png",
  p_class_z,
  width = 8,
  height = 5.5,
  dpi = 300
)
# ============================================================
# FINNISH FOREST POINT-CLOUD ANALYSIS
# Main analysis for this GitHub project
# ============================================================

# 15. Load the Finnish forest LiDAR dataset

finnish_file <- "data/raw/cloud7_clip.las"

finnish_las <- readLAS(finnish_file)

print(finnish_las)

# 16. Inspect the Finnish LiDAR point cloud

summary(finnish_las@data$Z)

# Plot a sample of 10,000 points
set.seed(42)

sample_points <- finnish_las@data[
  sample(nrow(finnish_las@data), 10000),
]

plot(
  sample_points$X,
  sample_points$Z,
  pch = 16,
  cex = 0.3,
  col = "darkgreen",
  xlab = "X coordinate (m)",
  ylab = "Z coordinate (m)",
  main = "Finnish Forest LiDAR Profile"
)
# 17. Inspect available LiDAR attributes

names(finnish_las@data)

# Check the distribution of point classifications
table(finnish_las@data$Classification)

# 18. Check elevation and return information

summary(finnish_las@data$Z)

table(finnish_las@data$ReturnNumber)

table(finnish_las@data$NumberOfReturns)

# 19. Inspect the LAS file header

finnish_las@header

# 20. Inspect RGB colour values

summary(finnish_las@data$R)
summary(finnish_las@data$G)
summary(finnish_las@data$B)

# 21. Visualise a sample using RGB colours

set.seed(42)

idx <- sample(nrow(finnish_las@data), 10000)
pts <- finnish_las@data[idx, ]

rgb_colours <- rgb(
  pts$R / 65535,
  pts$G / 65535,
  pts$B / 65535
)

plot(
  pts$X,
  pts$Z,
  col = rgb_colours,
  pch = 16,
  cex = 0.4,
  xlab = "X coordinate (m)",
  ylab = "Z coordinate (m)",
  main = "Finnish Forest Point Cloud by RGB Colour"
)
# 22. Create a summary table for the Finnish LiDAR dataset

z <- finnish_las@data$Z

lidar_summary <- data.frame(
  Metric = c(
    "Total points",
    "Area (m2)",
    "Point density (points/m2)",
    "Minimum Z (m)",
    "Median Z (m)",
    "Maximum Z (m)"
  ),
  Value = c(
    nrow(finnish_las@data),
    (max(finnish_las@data$X) - min(finnish_las@data$X)) *
      (max(finnish_las@data$Y) - min(finnish_las@data$Y)),
    nrow(finnish_las@data) /
      ((max(finnish_las@data$X) - min(finnish_las@data$X)) *
         (max(finnish_las@data$Y) - min(finnish_las@data$Y))),
    min(z),
    median(z),
    max(z)
  )
)

print(lidar_summary)

write.csv(
  lidar_summary,
  "outputs/tables/finnish_lidar_summary.csv",
  row.names = FALSE
)

# 23. Summarise the vertical distribution of points

z <- finnish_las@data$Z

z_summary <- data.frame(
  Statistic = c(
    "5th percentile",
    "25th percentile",
    "50th percentile (median)",
    "75th percentile",
    "95th percentile"
  ),
  Z_value_m = as.numeric(
    quantile(z, probs = c(0.05, 0.25, 0.50, 0.75, 0.95))
  )
)

print(z_summary)

write.csv(
  z_summary,
  "outputs/tables/finnish_z_percentiles.csv",
  row.names = FALSE
)

# 24. Plot the vertical distribution of points

library(ggplot2)

p_z <- ggplot(
  data.frame(Z = finnish_las@data$Z),
  aes(x = Z)
) +
  geom_histogram(
    bins = 60,
    fill = "darkgreen",
    colour = "white"
  ) +
  labs(
    title = "Vertical Distribution of Finnish Forest LiDAR Points",
    subtitle = "Exploratory elevation profile",
    x = "Z coordinate (m)",
    y = "Number of points"
  ) +
  theme_minimal(base_size = 12)

print(p_z)

ggsave(
  "outputs/figures/finnish_z_distribution.png",
  p_z,
  width = 8,
  height = 5,
  dpi = 300
)

# 25. Summarise point counts by elevation band

z <- finnish_las@data$Z

z_band <- cut(
  z,
  breaks = seq(194, 240, by = 2),
  right = FALSE
)

z_band_summary <- as.data.frame(
  table(z_band)
)

names(z_band_summary) <- c(
  "Elevation_band",
  "Number_of_points"
)

z_band_summary$Percentage <- round(
  100 * z_band_summary$Number_of_points /
    sum(z_band_summary$Number_of_points),
  2
)

print(z_band_summary)

write.csv(
  z_band_summary,
  "outputs/tables/finnish_elevation_band_summary.csv",
  row.names = FALSE
)

# 26. Plot point counts by elevation band

p_bands <- ggplot(
  z_band_summary,
  aes(x = Elevation_band, y = Number_of_points)
) +
  geom_col(fill = "darkgreen") +
  labs(
    title = "LiDAR Point Distribution by Elevation Band",
    subtitle = "Hyytiälä, Finland, exploratory sample",
    x = "Elevation band (m)",
    y = "Number of points"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    axis.text.x = element_text(
      angle = 60,
      hjust = 1
    )
  )

print(p_bands)

ggsave(
  "outputs/figures/finnish_elevation_bands.png",
  p_bands,
  width = 10,
  height = 6,
  dpi = 300
)

# 27. Map the point cloud from above

set.seed(42)

idx <- sample(
  nrow(finnish_las@data),
  min(20000, nrow(finnish_las@data))
)

map_points <- finnish_las@data[idx, ]

p_map <- ggplot(
  map_points,
  aes(x = X, y = Y, colour = Z)
) +
  geom_point(size = 0.35) +
  scale_colour_viridis_c(name = "Z (m)") +
  coord_equal() +
  labs(
    title = "Top-Down Map of Finnish Forest LiDAR",
    subtitle = "Random sample of up to 20,000 points",
    x = "Easting (m)",
    y = "Northing (m)"
  ) +
  theme_minimal(base_size = 12)

print(p_map)

ggsave(
  "outputs/figures/finnish_lidar_topdown.png",
  p_map,
  width = 8,
  height = 7,
  dpi = 300
)

# 29. Inspect low points across the scan

las_data <- finnish_las@data

cell_size <- 5

las_data$cell_x <- floor(
  (las_data$X - min(las_data$X)) / cell_size
)

las_data$cell_y <- floor(
  (las_data$Y - min(las_data$Y)) / cell_size
)

library(dplyr)

lowest_points <- las_data |>
  group_by(cell_x, cell_y) |>
  summarise(
    lowest_Z = min(Z),
    number_of_points = n(),
    .groups = "drop"
  )

print(summary(lowest_points$lowest_Z))
print(nrow(lowest_points))

# 30. Map the lowest observed elevation in each cell

ggplot(lowest_points, aes(
  x = cell_x,
  y = cell_y,
  fill = lowest_Z
)) +
  geom_tile() +
  scale_fill_viridis_c(name = "Lowest Z (m)") +
  coord_equal() +
  labs(
    title = "Lowest Observed Elevation Across the Finnish Scan",
    x = "5 m cell column",
    y = "5 m cell row"
  ) +
  theme_minimal()

ggsave(
  "outputs/figures/finnish_lowest_points_by_cell.png",
  width = 8,
  height = 6,
  dpi = 300
)


# 31. Calculate basic point-cloud metrics

# Total number of points
total_points <- nrow(finnish_las@data)

# Area covered by the point-cloud bounding box
scan_area_m2 <- 
  (max(finnish_las@data$X) - min(finnish_las@data$X)) *
  (max(finnish_las@data$Y) - min(finnish_las@data$Y))

# Average point density within the bounding box
point_density <- total_points / scan_area_m2

# Vertical variation in the recorded elevations
vertical_range_m <- 
  max(finnish_las@data$Z) - min(finnish_las@data$Z)

# Display the results
cat("Total points:", total_points, "\n")
cat("Bounding-box area (m2):", round(scan_area_m2, 2), "\n")
cat("Average point density (points/m2):", round(point_density, 2), "\n")
cat("Observed elevation range (m):", round(vertical_range_m, 2), "\n")


# 32. Examine point density across the scan

library(dplyr)
library(ggplot2)

cell_density <- finnish_las@data |>
  mutate(
    cell_x = floor(
      (X - min(X)) / 5
    ),
    cell_y = floor(
      (Y - min(Y)) / 5
    )
  ) |>
  group_by(cell_x, cell_y) |>
  summarise(
    number_of_points = n(),
    .groups = "drop"
  )

ggplot(cell_density, aes(
  x = cell_x,
  y = cell_y,
  fill = number_of_points
)) +
  geom_tile() +
  scale_fill_viridis_c(name = "Point count") +
  coord_equal() +
  labs(
    title = "Point Distribution Across the Finnish Scan",
    x = "5 m cell column",
    y = "5 m cell row"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 12),
    legend.position = "right"
  )

ggsave(
  "outputs/figures/finnish_point_density_by_cell.png",
  width = 8,
  height = 6,
  dpi = 300
)


# 33. Summarise point distribution across cells

total_cells <- nrow(cell_density)

median_cell_points <- median(
  cell_density$number_of_points
)

low_density_cells <- sum(
  cell_density$number_of_points <
    median_cell_points * 0.5
)

low_density_percent <- 
  low_density_cells / total_cells * 100

cat("Number of occupied cells:", total_cells, "\n")
cat("Median points per occupied cell:", median_cell_points, "\n")
cat("Cells with fewer than half the median point count:",
    low_density_cells, "\n")
cat("Percentage of occupied cells below this threshold:",
    round(low_density_percent, 2), "%\n")


# 34. Save the point-cloud summary

point_cloud_summary <- data.frame(
  metric = c(
    "Total points",
    "Bounding-box area (m2)",
    "Average point density (points/m2)",
    "Observed elevation range (m)",
    "Occupied 5 m cells",
    "Median points per occupied cell",
    "Low-density cells",
    "Low-density cells (%)"
  ),
  value = c(
    total_points,
    round(scan_area_m2, 2),
    round(point_density, 2),
    round(vertical_range_m, 2),
    total_cells,
    median_cell_points,
    low_density_cells,
    round(low_density_percent, 2)
  )
)

write.csv(
  point_cloud_summary,
  "outputs/tables/finnish_point_cloud_summary.csv",
  row.names = FALSE
)

print(point_cloud_summary)
