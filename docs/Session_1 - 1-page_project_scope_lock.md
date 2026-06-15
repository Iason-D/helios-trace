Project Scope Lock: Helios-Trace (v1)
1. Objective
Build an automated audit pipeline to identify agricultural land displacement by photovoltaic (PV) expansion in Greece. The system joins RAE license polygons with Sentinel-2 imagery to report on land use prior to construction.
2. Locked Decisions (v1)
•	Region: Thessaly (high PV density, flat terrain, clear agricultural baseline).
•	Time Window: 2018 – 2024 (full Sentinel-2 L2A archive).
•	Cadence: Annual median composites generated for the growing season (April – September).
•	Development: Local-first using cloud-native formats (GeoParquet, COG).
3. Medallion Architecture
•	Bronze: Raw, immutable ingest from RAE WFS and Copernicus STAC.
•	Silver: Validated data with cloud-masked composites and calculated indices (NDVI/NDWI).
•	Gold: Aggregated, analysis-ready tables for the dashboard.
4. Tech Stack
•	Data Ingest: GDAL CLI, GeoPandas, pystac-client.
•	Analytical Engine: DuckDB (Spatial extension).
•	Orchestration: Prefect (one-command execution).
•	Storage: GeoParquet (vector) and COG (raster).
•	Dashboard: Streamlit and MapLibre.
5. Out of Scope
•	No custom ML: Breakpoint detection and custom land-use classifiers are deferred to v2.
•	No Monthly Cadence: The audit is strictly year-over-year.
•	Scaling: Full-Greece expansion occurs only after the Thessaly v1 pilot.
