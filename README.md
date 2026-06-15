Helios-Trace: Spatiotemporal Auditing of Agricultural-to-PV Land Displacement

Project Objective & Overview

Helios-Trace is a high-performance geospatial engineering pipeline designed to audit the displacement of agricultural land by photovoltaic (PV) parks across Greece. By synthesizing Greek licensing polygons with the Sentinel-2 satellite archive, the project provides a data-driven account of land-use conversion.

The mission is to move beyond "one-off" analysis toward a repeatable data engineering pipeline. Using a medallion architecture, the system transforms raw WFS streams and STAC metadata into a dual-view dashboard:

* Map View: Polygon-level granularity allowing users to inspect specific PV parks with before-and-after median composites and localized vegetation indices.
* Regional View: Executive-level aggregates (by Greek region and year) tracking total hectares converted, dominant former land use, and NDVI/NDWI trend deltas.

The system is designed for "one-command execution," abstracting complex raster-vector joins into a fully orchestrated Prefect workflow.

Locked Project Scope

The v1 release of Helios-Trace is bound by the following technical constraints to ensure baseline accuracy and architectural stability:

* Geographic Focus: Thessaly region (selected for its high density of PV licenses and clean agricultural signatures).
* Temporal Window: 2018 through 2024 (full Sentinel-2 L2A archive availability).
* Temporal Cadence: Annual median composites generated over the growing season (April–September) to minimize noise and capture peak biomass signatures.
* Land Use Baseline: Integration of auxiliary "ground truth" datasets—Fields of the World and ESA WorldCover—stacked with pre-installation spectral signatures (NDVI/NDWI) in lieu of custom ML classifiers for v1.

Technical Architecture (Medallion Pattern)

We utilize a Medallion Architecture to enforce data lineage and maintain a "single source of truth" across the pipeline. This cloud-native pattern replaces legacy monolithic spatial databases with a modular, portable stack.

The Layer Contract

* Bronze to Silver: Bronze guarantees raw, immutable source data. It utilizes watermarks to implement Change Data Capture (CDC), ensuring the pipeline only processes new or updated license polygons from the RAE GeoServer.
* Silver to Gold: Silver guarantees validated geometries and analysis-ready raster products (ARPs). All data is standardized to a common CRS and contains computed spectral indices.

Processing Logic

Layer Name	Data State	Processing Logic
Bronze	Raw / Immutable	Watermark-based WFS ingestion (RAE); STAC metadata queries for Sentinel-2; ingestion of ESA WorldCover and Fields of the World.
Silver	Cleaned / Joined	Geometry repair; SCL cloud-masking (retaining only classes 4, 5, 6, 7); annual median compositing; robust NDVI/NDWI calculation; zonal statistics.
Gold	Analysis-Ready	Spatial SQL via DuckDB; 3-year pre-installation NDVI baseline calculation; post-installation delta analysis; regional hectare aggregation.

Tech Stack

The architecture prioritizes Cloud-Native Geospatial formats (GeoParquet, COG, PMTiles). This allows the pipeline to run locally or scale to the cloud without refactoring, bypassing the overhead of PostGIS for analytical workloads.

Layer	Tool/Choice	Function
Vector Ingest	GDAL CLI / GeoPandas	Fetching, reprojecting, and partitioning license polygons.
Raster Ingest	pystac-client / stackstac	Querying STAC catalogs and loading lazy xarray objects.
Storage	GeoParquet / COG	High-performance, columnar vector storage and tiled rasters.
Compute	Xarray & Dask	Distributed raster processing and annual median compositing.
Analytical Engine	DuckDB (Spatial)	Fast raster-vector joins and complex SQL window functions.
Orchestrator	Prefect	Managing the DAG: Ingest -> Validation -> Compositing -> Stats.
Web Mapping	PMTiles	Serverless vector tiles served from a public bucket/S3.
Visualization	Streamlit & MapLibre	Dashboarding and high-performance client-side rendering.

Architectural Note: We use the formula (NIR - Red) / (NIR + Red + 1e-6) for NDVI calculation. The 1e-6 epsilon prevents divide-by-zero errors in areas of no-data or sensor saturation.

Project Structure

helios-trace/
├── bronze/         # Raw GeoJSON and STAC metadata (partitioned)
├── silver/         # Validated GeoParquet & annual median COGs
├── gold/           # Analysis-ready DuckDB tables (One row per PV)
├── scripts/        # Python/Bash logic for specific layer tasks
├── docs/           # Documentation Manifest (Scope, DAG, Data Dictionary)
└── dashboard/      # Streamlit UI and PMTiles configuration


Documentation Manifest: The docs/ directory contains the Data_Dictionary.md, which defines the source, CRS, and refresh cadence for every dataset, alongside the DAG_Specifications.md detailing the Prefect flow sequence.

Getting Started

Prerequisites

* Git and Mamba/Conda.
* The environment is designed to be cloud-native and portable across local and remote instances.

Installation

git clone https://github.com/Iason_D/helios-trace.git
cd helios-trace
mamba env create -f environment.yml
conda activate helios-trace


Usage & Execution

Helios-Trace is fully orchestrated. While individual scripts exist for debugging, the pipeline is triggered via a central flow.

1. Initial Vector Fetch: bash scripts/extract_bronze_rae.sh (Pulls current PV license state from RAE WFS).
2. Pipeline Orchestration: The pipeline executes the following sequence: Bronze Ingest -> Spatial Validation -> Compositing (SCL Masking) -> Zonal Stats -> SQL Aggregation. Run the master flow: python scripts/run_pipeline.py

Data Sources & Credits

* RAE GeoServer (WFS): Official Greek PV licensing polygons.
* Copernicus Data Space (STAC): Sentinel-2 L2A archive.
* ESA WorldCover: 10m global land cover for baseline classification.
* Fields of the World: Agricultural boundary ground-truth.

Future Work & Roadmap

* Breakpoint Detection: Implementing automated detection of the "first-disturbance" date within the annual time series.
* Custom Classifiers: Replacing ESA WorldCover with a local XGBoost model trained on Greek agricultural spectral signatures.
* Scale: Expanding beyond the Thessaly region to include the Peloponnese and Central Macedonia.
* Temporal Resolution: Shifting from annual composites to monthly tracking for active construction monitoring.
