# ASO Plan — White Noise: Sleep Sounds

Source of truth for keyword strategy, rank tracking, and market rollout.
Tool: Astro MCP (US store baseline as of 2026-04-16).

---

## 1. Targeting strategy

Four wedges, ranked by impact (popularity vs. difficulty, from Astro aggregation of 684 competitor keywords):

| # | Wedge | Why | Signature keywords |
|---|---|---|---|
| 1 | Baby / Infant | Lowest avg difficulty in the niche (~51) vs. white-noise core at 77-80 | baby, lullaby, shusher, white noise baby |
| 2 | Fan sounds | High pop, mid diff; our app has zero fan coverage today | fan, fan noise, bedtime fan, box fan |
| 3 | Rain / Thunderstorm | High pop, mid diff; nature tail | rain, thunder, rain sleep sounds, thunderstorm sounds for sleep |
| 4 | Colored noise | Growing niche; brown/green underserved by top players | brown noise, green noise, pink noise |

Deprioritised: meditation (Calm/Headspace lock), sound machine (diff ≥ 81), tinnitus (too niche), ASMR pure-play (Moongate/Endel own it).

---

## 2. US metadata

### App name
`White Noise — Sleep Sounds` — indexes: white, noise, sleep, sounds.

### Subtitle (30 char limit)
TBD — propose: `Baby Lullabies, Fan & Rain` (26 chars)
Covers three of four wedges without duplicating title terms.

### Keyword field (100 char limit)
Current (97):
```
calm,focus,baby,deep,brown,pink,green,ocean,machine,relax,nap,box,ambient,waves,study,bedtime,aid
```

Proposed v1 (97):
```
focus,baby,deep,brown,green,ocean,machine,relax,nap,bedtime,fan,rain,lullaby,shusher,asmr,thunder
```

Rationale:
- Drop `calm, aid, pink, box, ambient, waves, study` — brand-owned, low-pop, or redundant.
- Add `fan, rain, thunder, lullaby, shusher, asmr` — covers wedges 2, 3, 1.
- Keep `machine` so "sound machine" and "white noise machine" combos still form.
- Keep `bedtime` so "bedtime fan" still forms (combined with added `fan`).

---

## 3. Tracked keyword shortlist (US)

Feed these into Astro to watch ranking every 3 days.

**Baby / Infant wedge**
- baby sleep sounds (pop 23 / diff 54)
- white noise baby (21 / 54)
- white noise for babies (18 / 53)
- baby shusher (26 / 43)
- lullaby music for babies (18 / 13)

**Fan wedge**
- fan noise (55 / 64)
- bedtime fan (35 / 62)
- fan sounds for sleep (18 / 70)
- box fan noise free (28 / 58)
- hometown fan (47 / 58) — verify relevance; may be unrelated brand

**Rain / Thunder wedge**
- rain (61 / 68)
- rain sounds (40 / 65)
- thunder (47 / 72)
- thunderstorm sounds for sleep (25 / 49)
- rain sleep sounds (19 / 71)

**Colored noise wedge**
- brown noise free (33 / 67)
- brown noise for sleep free (29 / 68)
- green noise free (27 / 63)
- green noise for better sleep (21 / 65)

**Core (benchmarks; do not expect top-10)**
- white noise (66 / 80)
- sleep sounds (55 / 78)
- noise app (62 / 77)

---

## 4. Tracking cadence

| Cadence | Action |
|---|---|
| Every 3 days | `search_rankings` on all tracked keywords → log any moves of ±5 ranks into §7 Decision log |
| Every 2 weeks | Re-run `get_keyword_suggestions` → drop stale tracked keywords, promote rising ones |
| Every 30 days | `extract_competitors_keywords` on our top keyword → find new entrants |
| After any metadata change | Note the date/change in §7 so we can attribute rank shifts |

Commands (via Claude + Astro MCP):
- "List current rankings for all tracked keywords, US."
- "Which tracked keywords improved/declined vs. 2 weeks ago?"
- "Re-run keyword suggestions and show keywords we don't yet track."

---

## 5. Localisation roadmap

Order by effort/ROI. Each locale gets its own keyword field (iOS combines them, so no duplication needed across locales — keep all terms unique per locale).

| # | Locale | Why prioritise | Leading opportunity keywords |
|---|---|---|---|
| 1 | ES (Spain) | `ruido blanco` diff is only 44, avg lower than US | ruido blanco, sonidos para dormir, bebé, ventilador, lluvia |
| 2 | MX (Mexico) | Same Spanish bank, separate ASC locale | as ES + "sonidos relajantes", "dormir" |
| 3 | UK | Shares most US terms; cheap copy + tweak | same as US |
| 4 | FR | `bruit blanc` appears in analysis (pop 6, diff 56 — low diff) | bruit blanc, sons pour dormir, bébé, ventilateur, pluie |
| 5 | DE | TBD — run suggestions for DE store |
| 6 | IT | `suoni per dormire` (19/61) present | suoni per dormire, rumore bianco, bambino, ventilatore |

For each locale: repeat §1–§3 using `get_keyword_suggestions` with that store's country code, then add rows to §7 log.

---

## 6. Metadata / asset checklist (immediate pass)

- [ ] Update US keyword field to Proposed v1
- [ ] Confirm / update subtitle to include baby + fan + rain signal
- [ ] Screenshot set: add one "Baby" scene (nursery background + lullaby track selected)
- [ ] Screenshot set: add one "Fan" scene and one "Rain" scene
- [ ] App icon: review whether baby-friendly cue is missing (optional A/B test via Product Page Optimization)
- [ ] Promotional text (170 chars, not indexed): rotate monthly to highlight whichever wedge we're pushing
- [ ] Category: verify primary is Health & Fitness (not Lifestyle) — higher conversion for sleep apps

---

## 7. Decision & rank log

Append-only. Add a row each tracking cycle or metadata change.

| Date | Change / observation | Evidence |
|---|---|---|
| 2026-04-16 | Initial ASO plan created. Proposed Keyword Field v1. Baseline: my app `6762322017` has no Astro keyword suggestions yet (too new). | This document |

---

## 8. Open questions

- Current US subtitle? (need to read from App Store Connect to confirm it's not wasting overlap with title)
- Has Product Page Optimization been enabled? Lets us A/B test icon + screenshots.
- Any paid search budget planned? If yes, the wedges above double as cheap Apple Search Ads bid lists.
