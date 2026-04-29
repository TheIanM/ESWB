# Task List — Emotional Support Water Bottle

## Phase 1: Proof of Concept ✅ DONE
- [x] 1. Replace template Item.swift with real SwiftData models (HydrationEntry, UserPreferences) + enums
- [x] 2. Create HydrationManager.swift — Observable service for hydration state
- [x] 3. Update app entry point — register new models, add HydrationManager environment
- [x] 4. Create MainTabView.swift — 3-tab structure
- [x] 5. Create OnboardingView.swift — 7-step onboarding flow
- [x] 6. Create FillRingView.swift — circular progress ring
- [x] 7. Create WaterBlob.swift — blob model with physics (adapted from SlimeTheme)
- [x] 8. Create WaterSimView.swift — Canvas-based metaball water simulation
- [x] 9. Create TodayTab.swift — integrates FillRingView, WaterSimView, drink logging
- [x] 10. Create SettingsTab.swift — displays/edits UserPreferences
- [x] 11. Fix ContentView.swift — removed old Item references
- [x] 12. Fix onboarding loop bug — duplicate prefs, animation flicker, save timing
- [x] 13. Fix gesture timeout — DragGesture minimumDistance + simultaneousGesture
- [x] 14. Fix water direction — starts full, empties as you drink
- [x] 15. Fix metaball position — blobs spawn at top surface of fill

## Phase 2: Stats & History ✅ DONE
- [x] 2.1 Copy DashboardDataKit.swift into project, strip unused components (Kanban, Leaderboard, DataTable, ProgressRingGroup)
  - verify: compiles with no errors ✅
- [x] 2.2 Recolor kit — swap purple accent to cyan to match water theme
  - verify: default color is now kAccent = Color(hex: "00B4D8") ✅
- [x] 2.3 Create StatsCalculator — compute streaks, 7-day totals, averages, all-time stats from SwiftData
  - verify: compiles, unit-testable static methods ✅
- [x] 2.4 Wire HydrationEntry history into StatsCalculator via @Query
  - verify: stats update when new drinks are logged ✅
- [x] 2.5 Build StatsTab layout — ScrollView with sections for KPI cards, chart, timeline
  - verify: renders in simulator ✅
- [x] 2.6 Create 7-day bar chart section using BarChartMini
  - verify: bars show real intake data for last 7 days ✅
- [x] 2.7 Create KPI stat cards using StatCard — current streak, avg daily intake, total logged, best streak
  - verify: numbers are accurate ✅
- [x] 2.8 Create today's drink timeline using VerticalTimeline component
  - verify: shows each logged drink with timestamp ✅
- [x] 2.9 Create week-over-week comparison using MetricComparison
  - verify: shows this week vs last week ✅
- [x] 2.10 Build + smoke test full stats tab
  - verify: BUILD SUCCEEDED, all sections compile ✅

## Phase 3: HealthKit Integration (NOT STARTED)
- [ ] Request HealthKit permissions (read mood, write dietary water)
- [ ] Write hydration data to HK on each log
- [ ] Read mood data for personality-aware prompts

## Phase 4: Reminder Personalities (IN PROGRESS)
- [x] 4.1 Create bundled JSON files for each personality with short notification-friendly messages
  - verify: 6 JSON files created, messages ~80 chars max ✅
- [x] 4.2 Create PersonalityEngine — loads JSON, picks random messages, mood-aware for Emotional Support
  - verify: compiles, loads personalities, avoids recent repeats ✅
- [x] 4.3 Add personality picker to Settings tab
  - verify: selection persists, shows checkmark on current personality ✅
- [x] 4.4 Add personality selection step to onboarding flow
  - verify: user picks personality during onboarding, saves to UserPreferences ✅
- [x] 4.5 Add Personalities folder to Xcode project (drag into navigator)
  - verify: JSON files included in app bundle ✅ (auto-detected)
- [x] 4.6 Build + smoke test personality flow end-to-end
  - verify: BUILD SUCCEEDED, onboarding saves selected personality ✅

## Phase 5: IAP Tip Jar (NOT STARTED)
- [ ] Set up multiple non-consumable IAP products
- [ ] Tip jar UI

## Phase 6: Polish & Watch (NOT STARTED)
- [ ] Accessibility audit
- [ ] watchOS companion app
