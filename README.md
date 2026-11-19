# Athlone Terrace Flood Monitor

A flood-risk dashboard for the Athlone Terrace neighborhood (North Fair Oaks, San Mateo County).
Live page: https://jasondahui.github.io/Athlone-Flood-Monitor/

It combines the county's Atherton Channel gauges, NOAA's HRRR rain forecast, NWS alerts and Bay tides
into one risk rating, with a storm library of past events. **It is not an official warning. Follow NWS and SMC Alert.**

## What's here

| Path | What it is |
|---|---|
| `index.html` | The dashboard (single self-contained page). |
| `discussion.json` | The current written storm discussion shown under the title. Updated automatically when storms are coming. |
| `scripts/snapshot.sh` + `.github/workflows/snapshot.yml` | Every hour, GitHub saves a snapshot of public forecast, alert, tide and gauge data to the `data` branch (`snapshot.json`). The discussion writer reads it. |
| `DISCUSSION_GUIDE.md` | How the discussion is written and when it's updated. |

All data sources are free and public; no keys are stored here.
