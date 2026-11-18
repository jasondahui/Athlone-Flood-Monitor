#!/usr/bin/env bash
# Hourly data snapshot for the storm discussion. Runs on GitHub's servers (see .github/workflows/snapshot.yml).
# Saves the inputs the discussion writer needs into data/snapshot.json. No keys, all public sources.
set -uo pipefail
LAT=37.477; LON=-122.192
get() { curl -sS -L --max-time 45 --retry 1 -A "athlone-flood-monitor (github.com/jasondahui/athlone-flood-monitor)" "$1" || echo 'null'; }
asjson() { jq -c . 2>/dev/null || echo 'null'; }
NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
TODAY=$(TZ=America/Los_Angeles date +%Y%m%d); END=$(TZ=America/Los_Angeles date -d '+3 day' +%Y%m%d)

models=$(for m in ncep_hrrr_conus ncep_rrfs_conus ncep_nbm_conus ecmwf_ifs025 gfs_seamless; do
  get "https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LON&hourly=precipitation&precipitation_unit=inch&timezone=America%2FLos_Angeles&past_days=1&forecast_days=4&models=$m" \
    | jq -c --arg m "$m" '{($m): (if .hourly then {time: .hourly.time, precip_in: .hourly.precipitation} else {error: (.reason // "no data")} end)}' 2>/dev/null || echo "{\"$m\": {\"error\": \"fetch failed\"}}"
done | jq -s -c 'add')
hrrr15=$(get "https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LON&minutely_15=precipitation&precipitation_unit=inch&timezone=America%2FLos_Angeles&forecast_days=2&models=ncep_hrrr_conus" | asjson)
runs=$(for m in ncep_hrrr_conus ncep_rrfs_conus; do get "https://api.open-meteo.com/data/$m/static/meta.json" | jq -c --arg m "$m" '{($m): {init: .last_run_initialisation_time, available: .last_run_availability_time}}' 2>/dev/null; done | jq -s 'add // {}')
afd_id=$(get "https://api.weather.gov/products/types/AFD/locations/MTR" | jq -r '."@graph"[0]."@id" // empty')
afd=$( [ -n "$afd_id" ] && get "$afd_id" | jq -c '{issued: .issuanceTime, text: .productText}' || echo null)
alerts=$(get "https://api.weather.gov/alerts/active?point=$LAT,$LON" | jq -c '[.features[]?.properties | {event, headline, onset, ends, expires, severity, description: (.description // "" | .[0:1500])}]' 2>/dev/null || echo '[]')
tides=$(get "https://api.tidesandcurrents.noaa.gov/api/prod/datagetter?station=9414523&product=predictions&interval=hilo&datum=MLLW&time_zone=lst_ldt&units=english&format=json&begin_date=$TODAY&end_date=$END&application=athlone" | jq -c '.predictions // null' 2>/dev/null || echo null)
ofs=$(get "https://api.tidesandcurrents.noaa.gov/api/prod/datagetter?station=9414523&product=ofs_water_level&datum=MLLW&time_zone=lst_ldt&units=english&format=json&begin_date=$TODAY&end_date=$END&application=athlone" | jq -c '[.data[]? | {t, v}]' 2>/dev/null || echo null)
gauges=$(get "https://raw.githubusercontent.com/OneShorelineSMC/oneshorelinefews/data/sites.json" | jq -c '{generated, sites: [.sites[]? | select(.name | test("Atherton|CalTrain"; "i"))]}' 2>/dev/null || echo null)
jq -n --arg now "$NOW" --argjson models "${models:-null}" --argjson hrrr15 "${hrrr15:-null}" --argjson runs "${runs:-null}" \
  --argjson afd "${afd:-null}" --argjson alerts "${alerts:-[]}" --argjson tides "${tides:-null}" --argjson ofs "${ofs:-null}" \
  --argjson gauges "${gauges:-null}"\
  '{fetched: $now, location: "Athlone Terrace, North Fair Oaks (approx.)", models: $models, hrrr_15min: $hrrr15, model_runs: $runs,
    nws_afd: $afd, nws_alerts: $alerts, tide_hilo_redwood_city: $tides, tide_ofs_redwood_city: $ofs, county_gauges: $gauges}' > data/snapshot.json
echo "snapshot written: $(wc -c < data/snapshot.json) bytes"
