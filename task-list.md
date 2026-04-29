# Task List — Emotional Support Water Bottle

## Phase 1: Proof of Concept ✅ DONE
- [x] All 15 tasks complete

## Phase 2: Stats & History ✅ DONE
- [x] All 10 tasks complete

## Phase 4: Reminder Personalities ✅ DONE
- [x] All 6 tasks complete

## Phase 5: Local Notifications ✅ DONE
- [x] 5.1 Create NotificationManager.swift — request permissions, schedule, cancel
  - verify: compiles, permission request works ✅
- [x] 5.2 Create ReminderScheduler.swift — computes reminder times from UserPreferences
  - verify: generates correct number of reminders between start/end hours ✅
- [x] 5.3 Wire notifications to PersonalityEngine — notification body comes from personality messages
  - verify: scheduled notifications show personality-specific text ✅
- [x] 5.4 Schedule reminders on app launch + after onboarding completes
  - verify: reminders persist after app is killed ✅
- [x] 5.5 Cancel reminders when daily goal is met
  - verify: no more notifications after goal reached ✅
- [x] 5.6 Reschedule reminders when settings change (personality, schedule, hours)
  - verify: changing settings updates pending notifications ✅
- [x] 5.7 Add "Test Reminder" button in Settings (fires after 5 seconds)
  - verify: test notification fires with personality message ✅
- [x] 5.8 Build + smoke test notification flow end-to-end
  - verify: BUILD SUCCEEDED ✅

## Phase 3: HealthKit Integration ✅ DONE
- [x] 3.1 Create HealthKitManager.swift — request read/write permissions
  - verify: compiles ✅
- [x] 3.2 Write hydration data to HK on each drink log
  - verify: HydrationManager.logDrink calls HealthKitManager.logWaterIntake ✅
- [x] 3.3 Read mood data from HK for personality-aware prompts
  - verify: fetchLatestMood uses HKStateOfMind + HKSampleQueryDescriptor ✅
- [x] 3.4 Wire HealthKit toggle in Settings to enable/disable sync
  - verify: Settings healthKitSection with toggle + refresh mood button ✅
- [x] 3.5 Build + smoke test
  - verify: BUILD SUCCEEDED ✅
- [x] 3.6 NOTE: You need to add HealthKit capability in Xcode (Signing & Capabilities)
  and add NSHealthShareUsageDescription / NSHealthUpdateUsageDescription to Info.plist

## Phase 6: IAP Tip Jar ✅ DONE
- [x] 6.1 Create StoreKit product configuration (.storekit file) with 6 tip tiers
  - verify: ESWBStoreKitConfig.storekit with coffee/boba/lunch/dinner/fancy/legend ✅
- [x] 6.2 Create StoreManager.swift — load products, handle purchases, verify transactions
  - verify: StoreKit 2 async, Transaction.updates listener, verification ✅
- [x] 6.3 Create TipJarView.swift — grid of tip options with witty labels
  - verify: 2-column grid, emoji labels, purchased state, thank you alert ✅
- [x] 6.4 Wire TipJarView into Settings tab
  - verify: NavigationLink from Settings → Tip Jar ✅
- [x] 6.5 Build + smoke test
  - verify: BUILD SUCCEEDED ✅

## Phase 7: Polish & Watch (NOT STARTED)
- [ ] Accessibility audit
- [ ] watchOS companion app
