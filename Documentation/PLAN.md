# Emotional Support Water Bottle — Project Plan

## Overview
A hydration tracking app for iOS (watchOS later) with a tiltable metaball water simulation, mood-aware reminders, Apple Health integration, and basic stats.

---

## Key Decisions (Locked)

| Decision | Choice | Rationale |
|---|---|---|
| **UI Framework** | SwiftUI | Everything is SwiftUI-native |
| **Metaball Rendering** | SwiftUI Canvas + `.alphaThreshold` + `.blur` | Proven technique from SlimeTheme.swift — no Metal needed, fully SwiftUI, great performance |
| **Persistence** | SwiftData | New app, no migration baggage |
| **Min Target** | iOS 17 | SwiftData is stable enough, wider device reach |
| **HealthKit** | Read mood (`HKCategoryType(.mood)`), write water (`HKQuantityType(.dietaryWater)`) | Two types, single capability |
| **IAP** | Multiple non-consumables at $0.99–$49.99 price tiers | Tip jar model, no subscriptions, app is fully free |
| **Watch** | Phase 2 | After iOS proof of concept |
| **Reminder Scheduling** | `UNUserNotificationCenter` local notifications | No server needed |
| **Stats** | SwiftUI Charts + local SwiftData | No third-party deps |

---

## Daily Goal Model

Based on Mayo Clinic guidelines:
- **Sedentary:** 2.7L/day
- **Moderately active:** 3.2L/day  
- **Very active:** 3.7L/day

The user's flow:
```
Daily Goal = X liters (based on activity level, adjustable)
Bottle Size = Y liters (user input)
Bottles Per Day = ⌈X / Y⌉
Sips Per Bottle = configurable (default ~6-8)
Sip Size = Y / Sips Per Bottle
```

Example: 3.2L goal, 750ml bottle → need ~4.3 bottles → 5 bottles, ~33 sips of ~96ml each.

---

## Onboarding Flow (from onboarding.md)

```
Step 0: Unit preference — oz or ml/L?
Step 1: How big is your water bottle?
Step 2: How active are you? (sedentary / moderate / very active)
Step 3: Based on your activity you likely need X liters. Want to adjust?
Step 4: HealthKit permission request (log hydration + read mood)
Step 5: Tilt-to-drink demo / button demo (accessibility)
Step 6: Reminder frequency preference
         - Smart Random: ≥1x/hour at random times until goal met
         - Fixed Interval: every N hours at the top of the hour
         - Custom times
```

---

## Reminder Personalities

Each personality is a bundled JSON file with `prompts[]` and `mood_responses{}`.

| Personality | Vibe | Example |
|---|---|---|
| **Quotable Water** | Water-themed movie/TV quotes | "I drink your milkshake!" — There Will Be Blood |
| **Gentle Parenting** | Kind, nurturing | "You're doing great. Small sip, big love. 💧" |
| **Excited Dog** | HYPER ENTHUSIASM | "WATER!! OH BOY!! DRINK TIME!! 🐕💦" |
| **Passive Aggressive** | Backhanded encouragement | "Oh you're too busy for water? Must be nice." |
| **Emotional Support** | Mood-aware (reads HealthKit) | "You seem down — let's hydrate together 💙" |
| **Water Facts** | Real water science facts | "Your brain is 75% water. Refill it!" |

Sources: curated JSON files, Water Facts can pull from public domain/Wikimedia.

---

## App Structure (Tabs)

```
Tab 1: Today (drop.fill)
  - Circular fill ring showing % of daily goal
  - "Your bottle" metaball water simulation
  - Quick log button (+ sip amount)
  - Next reminder countdown
  
Tab 2: Stats (chart.bar.fill)
  - Current streak (consecutive days at goal)
  - 7-day bar chart (intake vs goal) — SwiftUI Charts
  - Calendar heat map (daily hydration intensity)
  - All-time stats: total logged, avg/day, best streak

Tab 3: Settings (gearshape.fill)
  - Bottle size
  - Daily goal (with activity preset)
  - Reminder personality
  - Reminder schedule (smart random / fixed / custom)
  - Unit preference (oz / ml)
  - HealthKit connection status
  - Tip Jar (IAP)
  - About
```

---

## Metaball Water Simulation Design

**Rendering:** Adapted from SlimeTheme.swift technique:
- SwiftUI `Canvas` draws white circles for blobs
- `.blur(radius:)` softens edges  
- `.alphaThreshold(min: 0.5, color: waterBlue)` snaps merged regions to solid color
- Result: organic metaball merging, 100% SwiftUI, no Metal

**Interaction model:**
- Blobs represent remaining water, positioned at bottom of a "bottle" shape
- Core Motion accelerometer provides X/Y/Z tilt → blobs shift laterally (water sloshes)
- **Primary logging:** "Drink" button (always accessible, accessibility-friendly)
- **Secondary logging:** Tilt interaction — blobs animate/shift when device tilts, visually satisfying
- Water level decreases when a drink is logged (blobs shrink/disappear from top)
- `@Environment(\.reduceMotion)` disables tilt animation when user prefers

**Blob physics** (adapted from SlimeBlob):
- Breathing animation (sinusoidal radius oscillation)
- Drift movement tied to device tilt
- Bounds clamping within the "bottle" shape
- Count proportional to remaining water

---

## Data Models (SwiftData)

```
@Model HydrationEntry
  - date: Date
  - amountML: Double
  - source: EntrySource (.manual, .tilt, .notification)

@Model DailyGoal
  - date: Date
  - targetML: Double
  - activityLevel: ActivityLevel
  - bottleSizeML: Double

@Model UserPreferences
  - unitPreference: UnitPreference (.oz, .ml)
  - activityLevel: ActivityLevel
  - bottleSizeML: Double
  - dailyGoalML: Double
  - reminderPersonality: String
  - reminderScheduleType: ScheduleType (.smartRandom, .fixedInterval, .custom)
  - reminderIntervalHours: Double
  - reminderStartTime: Date // hour component only
  - reminderEndTime: Date
  - healthKitEnabled: Bool
  - hasCompletedOnboarding: Bool
  - preferredLoggingMethod: LoggingMethod (.button, .tilt)
```

---

## HealthKit Integration

```
User logs a drink in app
       │
       ▼
┌──────────────┐     ┌──────────────────┐
│  SwiftData   │────▶│  HealthKit        │
│  (source of  │     │  WRITE:           │
│   truth for  │     │  dietaryWater     │
│   stats +    │     │  (in liters)      │
│   history)   │     │                   │
└──────────────┘     │  READ:            │
       │             │  mood category    │
       │             └──────────────────┘
       │                     │
       ▼                     ▼
  Stats tab           Mood-aware reminder
  (charts,            personality picks
   streaks)           prompt based on
                      latest mood state
```

- We never read our own water data back from HealthKit
- HealthKit is a sync destination + mood source, not our primary data store
- Permission requested during onboarding Step 4
- Graceful degradation if user denies HealthKit — app works fine without it

---

## IAP Tip Jar

- 6 non-consumable products at price tiers: $0.99, $2.99, $4.99, $9.99, $24.99, $49.99
- Displayed as: "Coffee ☕" → "Nice Dinner 🍽️" → etc.
- All unlock the same thing (warm fuzzy feeling + optional supporter badge in settings)
- Uses StoreKit 2 (`Product.products(for:)`, `purchase()`)
- No subscriptions, no server validation needed

---

## Project Structure

```
ESWB/
├── ESWB.xcodeproj
├── ESWB/                          # iOS app target
│   ├── ESWBApp.swift
│   ├── Views/
│   │   ├── Onboarding/
│   │   │   ├── OnboardingView.swift
│   │   │   ├── BottleSizeStep.swift
│   │   │   ├── ActivityLevelStep.swift
│   │   │   ├── GoalStep.swift
│   │   │   ├── HealthKitStep.swift
│   │   │   ├── DrinkDemoStep.swift
│   │   │   └── ReminderStep.swift
│   │   ├── Today/
│   │   │   ├── TodayTab.swift
│   │   │   ├── FillRingView.swift
│   │   │   └── WaterSimView.swift
│   │   ├── Stats/
│   │   │   ├── StatsTab.swift
│   │   │   ├── WeekChartView.swift
│   │   │   ├── CalendarHeatView.swift
│   │   │   └── StreakView.swift
│   │   ├── Settings/
│   │   │   ├── SettingsTab.swift
│   │   │   └── TipJarView.swift
│   │   └── Shared/
│   │       └── Components (reusable UI)
│   ├── Assets.xcassets
│   └── Info.plist
├── ESWBKit/                       # Shared logic (Swift package or framework)
│   ├── Models/
│   │   ├── HydrationEntry.swift
│   │   ├── DailyGoal.swift
│   │   ├── UserPreferences.swift
│   │   └── ActivityLevel.swift
│   ├── Services/
│   │   ├── HealthKitManager.swift
│   │   ├── ReminderManager.swift
│   │   ├── PersonalityEngine.swift
│   │   ├── HydrationLogger.swift
│   │   └── StoreManager.swift (IAP)
│   ├── Rendering/
│   │   ├── WaterBlob.swift (blob model + physics)
│   │   └── WaterSimRenderer.swift (Canvas-based metaball)
│   └── Personalities/
│       ├── quotable-water.json
│       ├── gentle-parenting.json
│       ├── excited-dog.json
│       ├── passive-aggressive.json
│       ├── emotional-support.json
│       └── water-facts.json
└── ESWBTests/
```

---

## Build Phases

### Phase 1: Proof of Concept (Start Here)
1. Xcode project scaffold (iOS app target)
2. SwiftData models (UserPreferences, HydrationEntry, DailyGoal)
3. Onboarding flow (all 6 steps)
4. Today tab with fill ring + basic drink logging
5. Water simulation view (metaball blobs with tilt, adapted from SlimeTheme)
6. Settings tab (bottle size, goal, units)
7. **Verify:** User can complete onboarding, log drinks, see fill ring update

### Phase 2: Reminders + Personality
1. Reminder scheduling engine (`UNUserNotificationCenter`)
2. Personality engine (loads JSON, picks prompt)
3. All 6 personality JSON files
4. Settings UI for personality picker + schedule config
5. **Verify:** Reminders fire at configured times with correct personality voice

### Phase 3: HealthKit + Mood
1. HealthKitManager (request permissions, write water, read mood)
2. Mood-aware prompt selection for Emotional Support personality
3. **Verify:** Drinks log to Apple Health, mood influences Emotional Support prompts

### Phase 4: Stats
1. Stats calculator service
2. 7-day bar chart (Chartkit see examples )
3. Streak calculation + display
4. Calendar heat map
5. All-time stats summary
6. **Verify:** Stats accurately reflect logged data

### Phase 5: Tip Jar + Polish
1. StoreKit 2 IAP setup (App Store Connect config)
2. Tip Jar UI
3. Accessibility audit (reduce motion, VoiceOver)
4. App icon + launch screen
5. **Verify:** Tip jar shows products, purchase flow works in sandbox

### Phase 6: Watch App (Post-Launch)
1. WatchOS target
2. Quick log complication
3. Haptic notifications
4. Watch Connectivity sync
