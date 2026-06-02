# Google Play — Data safety form (POHPS)

Use this guide when completing **App content → Data safety** in [Google Play Console](https://play.google.com/console) for **POHPS** (`com.logicphile.pohps`).

**Support & privacy URL (Play Console):** `https://logicphile.com/pohps/`  
**Privacy policy URL:** `https://logicphile.com/pohps/` (same page as support; privacy section is on-page only)

> Google’s UI labels change over time. Match the **intent** of each answer below to the closest option shown in Console. If wording differs, choose the option that reflects: **no off-device collection, no sharing, local-only storage**.

---

## Overview

| Console question | Answer |
|------------------|--------|
| Does your app collect or share any of the required user data types? | **No** |

**Rationale:** POHPS does not transmit user data to Logicphile Limited or any third party. All logs and settings are stored on-device via `shared_preferences` only. Release builds do not declare `INTERNET` in the main manifest.

---

## Step-by-step (typical Play Console flow)

### 1. Data collection and security

| # | Question | Select |
|---|----------|--------|
| 1.1 | Does your app collect or share any of the required user data types? | **No** |
| 1.2 | Is all of the user data collected by your app encrypted in transit? | **N/A** — skip or “No data collected” (nothing is transmitted) |
| 1.3 | Do you provide a way for users to request that their data is deleted? | **Yes** — users can **uninstall the app** or **clear app data** in Android Settings → Apps → POHPS → Storage → Clear data. (No account system.) |

---

### 2. Data types

Because you answered **No** to collection/sharing, you should **not** need to declare collected data types.

If Console still asks you to review types, confirm **none** are collected or shared for:

| Data type category | Collected? | Shared? |
|--------------------|------------|---------|
| Location | No | No |
| Personal info (name, email, user IDs, address, phone) | No | No |
| Financial info | No | No |
| Health and fitness | No *(off-device)* | No |
| Messages | No | No |
| Photos and videos | No | No |
| Audio files | No | No |
| Files and docs | No | No |
| Calendar | No | No |
| Contacts | No | No |
| App activity (in-app search, installs, etc.) | No | No |
| Web browsing | No | No |
| App info and performance (crash logs, diagnostics) | No | No |
| Device or other IDs | No | No |

**Note on “Health and fitness”:** The app stores protein/water logs **only on the device**. Google’s form treats “collected” as data **sent off the device** (or shared). Do **not** mark Health and fitness as collected unless you add cloud sync, analytics, or server upload later.

---

### 3. Data usage and handling

*(Often skipped when “No data collected.” If shown, use below.)*

| # | Question | Answer |
|---|----------|--------|
| 3.1 | Is this data processed ephemerally? | N/A |
| 3.2 | Is collection required or can users choose? | N/A |
| 3.3 | Why is this user data collected? | N/A — no off-device collection |

---

### 4. Preview / Data safety section (public store label)

Expected public summary:

| Field | Text (approximate) |
|-------|---------------------|
| Data shared with third parties | **No data shared with third parties** |
| Data collected | **No data collected** (or “No data collected See details” depending on Console version) |

---

## Other Play Console fields (related, not Data safety)

| Field | Value |
|-------|--------|
| **Privacy policy URL** | `https://logicphile.com/pohps/` |
| **Support URL** | `https://logicphile.com/pohps/` |
| **Support email** | `allan@logicphile.com` |
| **App category** | Health & fitness (or Food & drink — choose what best matches your listing) |
| **Ads** | No, contains no ads |
| **In-app purchases** | No |
| **Target audience** | Not designed primarily for children under 13 |
| **COVID-19 / medical device** | App is a diet tracker with disclaimers; **not** a medical device |

---

## What is stored locally (for your records only)

Not declared as “collected” in Play Console while it stays on-device only:

| Key / area | Content |
|------------|---------|
| `disclaimer_accepted` | Boolean |
| `daily_goal`, `daily_water_goal_ml` | Integers |
| `locale`, `theme_mode`, `measurement_system`, `diet_type`, `water_tracker_enabled` | Preferences |
| `protein_overrides` | JSON map of food ID → grams |
| `log_YYYY-MM-DD` | Daily food log entries |
| `custom_foods` | User-created foods |
| `unlocked_achievements` | Achievement IDs |

Source: `lib/storage.dart`

---

## If you change the app later

Update Data safety and `docs/support.html` if you add any of:

- Analytics (Firebase, etc.)
- Crash reporting (Sentry, Crashlytics)
- Cloud backup / sync
- Accounts or login
- Ads or in-app purchases
- `INTERNET` permission for non-debug features that send user data

---

## Checklist before submit

- [ ] Host `docs/support.html` at `https://logicphile.com/pohps/` (same content as repo file)
- [ ] Data safety answers match the **release** AAB (not debug build with extra permissions)
- [ ] Store listing does not claim medical diagnosis or guaranteed nutrition accuracy
- [ ] Release build uses **production signing**, not debug keystore

---

*Logicphile Limited — POHPS `com.logicphile.pohps`*
