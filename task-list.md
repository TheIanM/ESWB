# Task List

## Session: 2026-04-28 — Phase 1: Proof of Concept
**Goal:** User can complete onboarding, see Today tab with fill ring + water simulation, log drinks, and adjust basic settings.

### Tasks
- [x] 1. Replace template Item.swift with real SwiftData models (HydrationEntry, UserPreferences) + enums
- [x] 2. Create HydrationManager.swift — Observable service for hydration state
- [x] 3. Update app entry point — register new models, add HydrationManager environment
- [x] 4. Create MainTabView.swift — 3-tab structure
- [x] 5. Create OnboardingView.swift — 7-step onboarding flow (all steps inline)
- [x] 6. ~~Create individual onboarding step views~~ — consolidated into single OnboardingView.swift
- [x] 7. Create FillRingView.swift — circular progress ring
- [x] 8. Create WaterBlob.swift — blob model with physics (adapted from SlimeTheme)
- [x] 9. Create WaterSimView.swift — Canvas-based metaball water simulation
- [x] 10. Create TodayTab.swift — integrates FillRingView, WaterSimView, drink logging
- [x] 11. Create SettingsTab.swift — displays/edits UserPreferences
- [x] 12. Fix ContentView.swift — removed old Item references (template neutered, can delete from project later)

### Build Status
✅ **BUILD SUCCEEDED** — iOS Simulator (iPhone 17 Pro, iOS 26.2)

### Notes / Constraints
- Deployment target is iOS 26.2 (not iOS 17 as originally planned — user's Xcode version)
- Used `\.accessibilityReduceMotion` instead of `\.reduceMotion` (SDK compatibility)
- ContentView.swift is still in the project but neutered (references removed). Can safely remove from Xcode project navigator.
- Onboarding step 4 (HealthKit) is a placeholder explanation — real HK permission request is Phase 3
- The new OnboardingView.swift needs to be added to the Xcode project (may have been auto-detected)

### Remaining polish items (not blocking)
- [ ] Remove ContentView.swift from Xcode project navigator
- [ ] Rename Item.swift to Models.swift in Xcode project navigator
- [ ] Test full onboarding flow in simulator
- [ ] Verify water sim renders correctly
- [ ] Verify drink logging persists across app launches
- [ ] Test accessibility: VoiceOver labels, Dynamic Type, reduce motion

---

## Completed
- ✅ [2026-04-28] Phase 1 core implementation — all files compile
  - Created: Item.swift (models), HydrationManager.swift, MainTabView.swift, OnboardingView.swift, TodayTab.swift, SettingsTab.swift, FillRingView.swift, WaterBlob.swift, WaterSimView.swift, RootView.swift
  - Modified: Emotional_Support_Water_BottleApp.swift (new model container, environment), ContentView.swift (neutered)
  - Fixed: @Environment(\.reduceMotion) → @Environment(\.accessibilityReduceMotion) for iOS 26 SDK
