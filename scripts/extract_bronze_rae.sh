#!/bin/bash

WFS_URL="https://geo.rae.gr/geoserver/wfs?service=WFS&version=2.0.0&request=GetFeature&typeName=rae_status:V_SDI_R_PHOTOVOLTAICS_ALL&outputFormat=application/json"

# Create the Bronze directory structure if it doesn't exist
mkdir -p bronze/rae_pv/

# rm -f bronze/rae_pv/raw_solar_parks.json 

ogr2ogr -f "GeoJSON" \
        bronze/rae_pv/raw_solar_parks.json \
        "WFS:$WFS_URL" \
        -nln rae_photovoltaics 

echo "Extraction Complete: File saved to bronze/rae_pv/raw_solar_parks.json"
