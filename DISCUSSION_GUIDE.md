# Storm discussion: how it's written

The discussion in `discussion.json` is written by a scheduled Claude task from the latest `snapshot.json` on the
`data` branch (hourly snapshot of Open-Meteo HRRR / RRFS / NBM / ECMWF / GFS rain, HRRR 15-min, NWS San Francisco
Area Forecast Discussion, NWS alerts for the neighborhood, Redwood City tide predictions + NOAA SF Bay model, and the
county Atherton Channel gauges).

## When to update (task runs every 3 hours)
- **Storm on the horizon** = any model's wettest 3 hours ≥ 0.25 in within the next 72 h, or an NWS watch/warning/advisory
  for rain, flooding or wind. Then update if the current discussion is ≥ 11 h old (about twice a day), **or** there is a
  major change: HRRR or the model consensus wettest-3-hours changed by ≥ 30 % (and ≥ 0.2 in), peak timing moved ≥ 3 h,
  a new NWS watch/warning, or the channel at Caltrain passed a county level.
- **No storm in 72 h**: if the current discussion still describes a storm, replace it once with a short "quiet" discussion
  (outlook = "quiet"). Otherwise leave it alone.

## Format (`discussion.json`)
`issued` (ISO time with offset), `next` (plain words), `headline` (1 sentence), `summary` (4–6 items, shown in a color-coded box visible without expanding; see below), `outlook` ("storm" | "quiet"),
`sections` [{title, text}] — usually Synopsis, Model trends, Tide and the channel, Current observations, Uncertainty,
What to do — and `sources` [strings]. Plain text only (no ** or other markup); use "\n• " for bullet lists.

## The summary box (most people read only this)
Flood-focused, not a general weather synopsis. Each item is `{"type", "text"}` with text under ~30 words:
- `change` + `"dir": "up" | "down" | "shift"` — **lead with this whenever the forecast moved meaningfully** since the last
  discussion (which model, from what to what, and what that means for the street). Shown as ▲ red / ▼ green / ◆ orange.
- `risk` + `"level": "none" | "sidewalk" | "yard" | "garage" | "garageplus" | "structure"` — the most likely street level
  at the peak (optional `"level_low"` for a range, e.g. yard–garage), and what it would take to reach the next level. Colored with the dashboard's level color; also colors the box.
- `models` — agreement or spread (the wettest-3-hour numbers per model), and which model is the outlier.
- `timing` — when the burst most likely hits, and any second round.
- `tide` — high tide/surge overlap with the burst, and the channel's current state.
- `obs` — what's happening right now (only if notable).
- `action` — the one or two things the street should do, with a time.
Include one `risk` item whenever outlook is "storm". Order: change (if any), models, risk, timing, tide, action.

## Content rules
- Write like an NWS forecaster explaining to neighbors: trends, observations, uncertainty, plain words.
- The dashboard's rating uses the model consensus: each model's hardest 3 h (HRRR × 1.25, RRFS and NBM × 1.00), then the
  middle value. Compute the same consensus so the discussion's `risk` item matches what neighbors see on the rating card,
  and say so when you think the consensus is too low or too high (e.g. HRRR under-forecast history, RRFS over-intense
  convection).
- Use the dashboard's scale and numbers: wettest 3 hours (in) vs thresholds — Yellow (garage) ~0.75, Red (garage +)
  ≥ 1.18, Purple (structure) ≥ 1.43 in per 3 h with the 1.25 HRRR bias; 1-hour burst ≥ 0.40 in → at least Yellow.
  HRRR has under-forecast big local bursts by ~3×. Morning high tides with surge slow channel drainage.
- Say clearly what changed since the last discussion and why it matters.
- Practical directions where relevant, written for the whole street, never for one particular house (cars out of the
  cul-de-sac, clear street drain grates and yard drains, sandbags, power outages can slow the pumps, timestamped photos
  at the peak, keep the page open, don't walk or drive through moving water).
- **Privacy: never name a house number, a person, or exact coordinates.** Say "Athlone Terrace" or "the street".
- Never invent numbers. If a source is missing from the snapshot, say so.
- Not an official forecast; defer to NWS warnings.
