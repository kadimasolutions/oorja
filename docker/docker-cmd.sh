#!/bin/sh

# Generate Oorja settings from template
export METEOR_SETTINGS="`cat /app/settings.json.template | gomplate`"

# Start Oorja
exec node main.js
