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

## Phase 3: HealthKit Integration (NOT STARTED)
- [ ] Request HealthKit permissions (read mood, write dietary water)
- [ ] Write hydration data to HK on each log
- [ ] Read mood data for personality-aware prompts

## Phase 6: IAP Tip Jar (NOT STARTED)
- [ ] Set up multiple non-consumable IAP products
- [ ] Tip jar UI

## Phase 7: Polish & Watch (NOT STARTED)
- [ ] Accessibility audit
- [ ] watchOS companion app
