#!/bin/bash

# Define paths relative to the project root
INPUT="bronze/rae_pv/all_solar_parks.json"
OUTPUT="bronze/rae_pv/operating_solar_parks.json"


# Use GDAL to filter based on the 'katastash_descr' property
ogr2ogr -f GeoJSON "$OUTPUT" "$INPUT" \
    -where "katastash_descr IN ('ΑΔΕΙΑ ΛΕΙΤΟΥΡΓΙΑΣ', 'ΑΔΕΙΑ ΠΑΡΑΓΩΓΗΣ')"

echo "Success! Filtered polygons saved to $OUTPUT"

