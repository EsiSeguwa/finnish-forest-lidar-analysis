# finnish-forest-lidar-analysis
# Exploratory Analysis of a Finnish Forest Point Cloud Using R

## Project overview

This project demonstrates a reproducible workflow for inspecting and analysing a forest point cloud from Hyytiälä, Finland. The analysis uses R to summarise point-cloud characteristics, examine spatial point distribution, visualise recorded elevations, and export summary tables and figures.

This is an exploratory demonstration of R-based point-cloud analysis. It does not estimate validated tree heights, canopy heights, or biodiversity indicators.

## Dataset

The analysis uses `cloud7_clip.las`, a clipped forest point cloud from Hyytiälä, SMEAR II, Finland, collected in 2025.

**Source:** atherton, J., & Miettinen, I. E. (2026). *Hyytiälä UAV Point Cloud Demo Dataset - 2025* [Dataset]. Zenodo. https://doi.org/10.5281/zenodo.20793895

- Format: LAS 1.2
- Coordinate reference system: WGS 84 / UTM zone 35N (EPSG:32635)
- Point count: 2,631,977
- Processing workflow: DJI L2 workflow processed with DJI Terra
- Licence: CC BY 4.0

The publisher states that the dataset has not undergone formal quality assessment. Users should validate the data before relying on it for scientific or operational applications.

## Methods

1. Loading and inspecting the LAS point cloud using `lidR`.
2. Summarising recorded elevation values and point classifications.
3. Visualising the spatial distribution of points and recorded elevations.
4. Dividing the scan into 5 m × 5 m grid cells to examine point counts and the lowest observed elevation in each cell.
5. Calculating summary metrics and exporting CSV tables.

## Preliminary results

| Metric | Result |
|---|---:|
| Total points | 2,631,977 |
| Bounding-box area | 7,104.83 m² |
| Average point density across bounding box | 370.45 points/m² |
| Observed elevation range | 42.81 m |
| Occupied 5 m grid cells | 282 |
| Median points per occupied cell | 9,292.5 |
| Cells below half the median point count | 57 (20.21%) |

The low-density threshold is exploratory and is not a measure of missing forest coverage.

## Limitations

All points in the supplied file are unclassified. The available documentation does not establish that reliable ground returns are present throughout the scan. The recorded elevation range therefore cannot be interpreted as tree height or canopy height.

Point counts vary spatially, but differences in point counts do not necessarily indicate differences in vegetation density. The dataset is a demonstration sample without formal quality assessment, so the findings should be treated as exploratory.

Ground classification, height normalisation, and ecological interpretation require additional validation before supporting scientific conclusions.

## Reproducibility

The analysis script is `analysis.R`.

The input LAS file should be placed in `data/raw/cloud7_clip.las`. Generated figures and tables are saved in `outputs/figures/` and `outputs/tables/`.

The analysis uses R and the `lidR`, `ggplot2`, and `dplyr` packages.

## Future work

Potential extensions include validating ground classification, assessing point-cloud quality, deriving defensible forest-structure metrics, and relating those metrics to independent ecological observations when suitable data become available.

