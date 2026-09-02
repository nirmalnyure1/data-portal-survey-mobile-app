# Syanko Mobile App — Development Effort Analytics

**Repository:** [cliffByte/syanko-mobile-app](https://github.com/cliffByte/syanko-mobile-app)  
**Stack:** Flutter (Dart) — iOS / Android customer app  
**Report generated:** 3 August 2026  
**Data source:** Local `git` history (`git log --numstat --date=local`)  
**Nature of figures:** Informed estimate from commit telemetry — **not** a timesheet measurement.

---

## 1. Executive summary

| Metric | Value |
|--------|------:|
| First commit | 5 Apr 2026 |
| Latest commit (at report time) | 3 Aug 2026 |
| Calendar span | **121 days** (~17.3 weeks) |
| Days with ≥1 commit (working days) | **61** |
| Total commits | **343** |
| Commits per working day | **~5.6** |
| Lines added | **102,403** |
| Lines deleted | **30,592** |
| Gross churn (add + delete) | **132,995** |
| File touch events | **2,848** |
| Approx. Dart files under `lib/` | **408** |
| Approx. LOC in `lib/` (`.dart`) | **~53,500** |
| Feature modules under `lib/features/` | **18** |

### Effort estimate (informed)

| Estimate band | Hours | Basis |
|---------------|------:|-------|
| Conservative | **260–320 h** | ~4.5–5.0 focused hours × 61 active days (primary) + light secondary |
| Mid (recommended) | **340–420 h** | ~5.5–6.5 h × active days + secondary + integration/QA buffer ~15% |
| Upper (dense sprints) | **450–520 h** | Peak months (esp. July) treated as near full-time + review/QA |

**Recommended planning / documentation figure:** **~380 hours** of development effort  
**Suggested billable band (if invoicing with contingency):** **400–450 hours**

> These hours estimate *hands-on product engineering* inferred from git intensity. They do not include uncommitted work, design-only days, meetings without commits, or backend work in other repos.

---

## 2. Timeline & intensity

### 2.1 Calendar overview

```text
Apr 2026 ████████████████████░░░░  98 commits  (foundation + auth/API)
May 2026 ███░░░░░░░░░░░░░░░░░░░░░  16 commits  (lighter / gaps)
Jun 2026 ████████████░░░░░░░░░░░░  61–62 commits
Jul 2026 ████████████████████████ 166–167 commits  (peak delivery)
Aug 2026 █░░░░░░░░░░░░░░░░░░░░░░░   1+ commits   (ongoing)
```

| Month | Commits | Share of total | Notes |
|-------|--------:|---------------:|-------|
| 2026-04 | 98 | 28.6% | Scaffold, Dio, auth, navigation |
| 2026-05 | 16 | 4.7% | Sparse — possible pause / parallel work |
| 2026-06 | 62 | 18.1% | Feature build-up |
| 2026-07 | 167 | 48.7% | Highest intensity (orders, sockets, cart, reviews, etc.) |
| 2026-08 | 1+ | &lt;1% | Continues from prior sprint |

**Active development period (days with commits):** 61  
**Idle calendar days (span − working days):** 60  

### 2.2 Peak days (commit count)

| Date | Commits | Interpretation |
|------|--------:|----------------|
| 2026-07-15 | 35 | Extreme sprint day |
| 2026-07-17 | 21 | Heavy delivery |
| 2026-07-06 | 18 | Heavy delivery |
| 2026-07-10 | 14 | Strong day |
| Several Apr/Jul days | 8–11 | Sustained cadence |

### 2.3 Time-of-day pattern (author local time, +05:45)

Most commits cluster **late morning → evening**:

| Hour (local) | Approx. commits | Band |
|-------------:|----------------:|------|
| 09–12 | High | Core morning block |
| 14–17 | Highest | Core afternoon block |
| 18–23 | Moderate | Extended evenings |
| 00–02 | Low | Occasional late work |

**Inference:** Typical pattern is **business-day + evening** work, not round-the-clock; supports ~5–7 focused hours on active days rather than 10–12.

### 2.4 Weekday pattern

| Weekday | Commits (approx.) |
|---------|------------------:|
| Mon | 60 |
| Tue | 35 |
| Wed | 90 |
| Thu | 56 |
| Fri | 68 |
| Sat | 6 |
| Sun | 28 |

**Inference:** Mostly weekday-driven; some Sunday catch-up; Saturdays light.

---

## 3. Contributors (resource use)

| Author (git identity) | Commits | Approx. share |
|-----------------------|--------:|--------------:|
| nirmalnyure1 / nirmal nyure | ~306–308 | **~89–90%** |
| aasyushsubedi-55 | ~33–37 | **~10%** |
| gaurab paudyal | 4 | **~1%** |

### Resource interpretation

| Role (inferred) | Effort share | Est. hours (mid band 380 h) |
|-----------------|-------------:|----------------------------:|
| Primary engineer | ~90% | **~340 h** |
| Secondary engineer | ~10% | **~35–40 h** |
| Occasional contributor | ~1% | **~5 h** |

This is commit-count weighted, not line-ownership weighted. Primary author drove architecture and most feature depth.

---

## 4. Codebase & change volume

| Signal | Value | How to read it |
|--------|------:|----------------|
| Gross churn | 132,995 lines | Includes refactors, renames, assets, lockfiles, generated noise |
| Net growth (add − del) | ~71,811 | Order of magnitude of retained code |
| `lib/` Dart LOC | ~53,500 | Better proxy for product surface than raw churn |
| Dart file touches | Dominant among 2,291 dart path events | Confirms Flutter-first repo |
| Assets (png/svg/ttf) | Present in stats | Inflates “lines” slightly; ignore for hour math |

**Rule used for hours:** Prefer **active days × intensity** and **module breadth**, not “lines ÷ N”. Large churn days (lockfiles, mass renames) would otherwise overstate effort.

---

## 5. Product surface (what the hours bought)

Feature areas under `lib/features/` (18 modules):

| Domain | Modules (examples) |
|--------|--------------------|
| Identity | `auth`, `onboard`, `profile` |
| Commerce | `product`, `cart`, `checkout`, `promo`, `combo_offer` |
| Fulfillment | `order` (history, track, receipt, sockets), `shipping_address` |
| Engagement | `loyalty`, `rewards`, `engagement`, `review`, `notification` |
| Shell | `home`, `media`, `support` |

High-complexity themes visible in recent history:

- Order realtime (Socket.IO): live home bar, track, history, payment status  
- Cart / checkout / loyalty & promo discounts  
- Order reviews  
- Receipt / PDF flows  

These areas justify the **July spike** and the mid-to-upper hour band.

---

## 6. Estimation methodology

### Inputs used

- First / last commit dates  
- Commit count & unique commit days  
- Monthly & daily frequency  
- Hour-of-day and weekday distributions  
- Numstat add/delete totals  
- Contributor split  
- Project type (Flutter mobile) and feature count  

### Formulae applied

1. **Active-day model**  
   `hours ≈ working_days × hours_per_active_day`  
   with `hours_per_active_day ∈ [4.5, 7]` from time-of-day span.

2. **Commit-density cross-check**  
   `hours ≈ commits × 0.6–1.0 h` (Flutter feature commits often batch; not 1 commit = 1 hour).  
   → 343 × 0.75 ≈ **257 h** (floor; underweights long uncommitted sessions).

3. **Blend**  
   Weight active-day model higher; use commit model as floor; add **10–20%** for testing, device QA, store/config, and coordination.

### What this does *not* capture

- Work without commits (local spikes, debugging)  
- Design / product / PM time  
- Backend / admin / POS repos  
- App Store / Play Console ops  
- Waiting on API / review blockers  

---

## 7. Suggested use for documentation / invoicing

| Use case | Suggested figure |
|----------|------------------|
| Internal effort log | **380 h** mid estimate |
| Client report (transparent) | **340–420 h** band + methodology note |
| Invoice with contingency | **400–450 h** or fixed milestone pricing |
| Primary resource allocation | ~**0.9 FTE** over 4 months calendar, burst to ~**1.2–1.5 FTE** in July |

### Sample narrative (copy-ready)

> Development of the Syanko Flutter mobile app ran from **5 April 2026 to early August 2026** (121 calendar days), with commits on **61 working days** and **343** recorded commits (~**133k** lines of churn; ~**53.5k** LOC in `lib/`). Activity peaked in **July 2026** (~49% of commits), covering order tracking, sockets, cart/checkout, and reviews. Based on commit cadence, time-of-day patterns, and feature breadth, estimated engineering effort is **approximately 340–420 hours**, with a planning midpoint of **~380 hours**. Primary authorship accounts for ~90% of commits.

---

## 8. Refreshing this report

Re-run from repo root:

```bash
# Span & volume
git log --reverse --format='%aI' | head -1
git log -1 --format='%aI'
git rev-list --count HEAD
git log --format='%ad' --date=short | sort -u | wc -l

# Churn
git log --numstat --pretty=format: | awk 'NF==3 && $1!="-" {a+=$1;d+=$2} END{print a,d}'

# Authors
git shortlog -sn --all

# Daily intensity
git log --format='%ad' --date=short | sort | uniq -c
```

Update section 1–3 after major milestones.

---

## 9. Disclaimer

This document is an **analytics-backed estimate** derived from version-control metadata. It is suitable for project retrospectives, capacity planning, and approximate billing discussions. For contractual billing, prefer agreed milestones, timesheets, or ticket-based logging in addition to (or instead of) git-derived hours.

---

*End of report.*
