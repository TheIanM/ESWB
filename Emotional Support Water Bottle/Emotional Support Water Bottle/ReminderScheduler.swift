//
//  ReminderScheduler.swift
//  Emotional Support Water Bottle
//
//  Computes reminder times from UserPreferences and schedules them
//  via NotificationManager with personality-specific messages.
//

import Foundation

struct ReminderScheduler {
    
    private static let notificationManager = NotificationManager.shared
    private static let personalityEngine = PersonalityEngine()
    
    // MARK: - Public API
    
    /// Schedule all reminders for today based on user preferences.
    /// Cancels existing reminders first, then schedules new ones.
    static func scheduleReminders(
        personalityID: String,
        scheduleType: ScheduleType,
        intervalHours: Double,
        startHour: Int,
        endHour: Int,
        sipsRemaining: Int
    ) {
        // Cancel any existing
        notificationManager.cancelAllReminders()
        
        // Don't schedule if goal is met
        guard sipsRemaining > 0 else {
            #if DEBUG
            print("[ReminderScheduler] Goal met, no reminders scheduled")
            #endif
            return
        }
        
        // Compute reminder times
        let times = computeReminderTimes(
            scheduleType: scheduleType,
            intervalHours: intervalHours,
            startHour: startHour,
            endHour: endHour,
            count: sipsRemaining
        )
        
        // Schedule each one with a personality message
        let hkManager = HealthKitManager.shared
        for (index, date) in times.enumerated() {
            // Use mood-aware message for Emotional Support personality
            let message: String
            if personalityID == "emotional-support", let mood = hkManager.currentMood {
                message = personalityEngine.moodMessage(mood: mood)
            } else {
                message = personalityEngine.randomMessage(personalityID: personalityID)
            }
            let id = "hydration-reminder-\(index)"
            
            notificationManager.scheduleNotification(
                id: id,
                title: "💧 Time to Hydrate!",
                body: message,
                at: date
            )
        }
        
        #if DEBUG
        print("[ReminderScheduler] Scheduled \(times.count) reminders")
        #endif
    }
    
    /// Convenience: schedule from UserPreferences + remaining sip count
    static func scheduleFromPreferences(_ prefs: UserPreferences, sipsRemaining: Int) {
        scheduleReminders(
            personalityID: prefs.reminderPersonality,
            scheduleType: prefs.reminderScheduleType,
            intervalHours: prefs.reminderIntervalHours,
            startHour: prefs.reminderStartHour,
            endHour: prefs.reminderEndHour,
            sipsRemaining: sipsRemaining
        )
    }
    
    /// Schedule a test reminder with the current personality
    static func scheduleTestReminder(personalityID: String) {
        let message = personalityEngine.randomMessage(personalityID: personalityID)
        notificationManager.scheduleTestNotification(
            title: "💧 Test Reminder",
            body: message
        )
    }
    
    // MARK: - Time Computation
    
    private static func computeReminderTimes(
        scheduleType: ScheduleType,
        intervalHours: Double,
        startHour: Int,
        endHour: Int,
        count: Int
    ) -> [Date] {
        let now = Date()
        let calendar = Calendar.current
        
        switch scheduleType {
        case .smartRandom:
            // Spread reminders randomly across the active window
            return smartRandomTimes(
                from: startHour,
                to: endHour,
                count: count,
                now: now,
                calendar: calendar
            )
            
        case .fixedInterval:
            // Fixed intervals from start hour
            return fixedIntervalTimes(
                intervalHours: intervalHours,
                startHour: startHour,
                endHour: endHour,
                count: count,
                now: now,
                calendar: calendar
            )
            
        case .custom:
            // For now, fall back to smart random
            // Custom times can be added later with a time picker UI
            return smartRandomTimes(
                from: startHour,
                to: endHour,
                count: count,
                now: now,
                calendar: calendar
            )
        }
    }
    
    /// Spread reminders randomly, ensuring minimum spacing
    private static func smartRandomTimes(
        from startHour: Int,
        to endHour: Int,
        count: Int,
        now: Date,
        calendar: Calendar
    ) -> [Date] {
        let activeMinutes = (endHour - startHour) * 60
        guard activeMinutes > 0 else { return [] }
        
        // Minimum gap between reminders (30 minutes)
        let minGapMinutes = 30
        let totalSlots = activeMinutes / minGapMinutes
        
        // We can't fit more reminders than available slots
        let adjustedCount = min(count, totalSlots)
        
        // Pick random slot indices, sorted chronologically
        var slots = Array(0..<Int(totalSlots))
        slots.shuffle()
        let selectedSlots = Array(slots.prefix(adjustedCount)).sorted()
        
        // Convert slots to dates
        let today = calendar.startOfDay(for: now)
        return selectedSlots.compactMap { slot -> Date? in
            let minuteOffset = startHour * 60 + slot * minGapMinutes
            let date = calendar.date(byAdding: .minute, value: minuteOffset, to: today)!
            
            // Only schedule if it's in the future
            return date > now ? date : nil
        }
    }
    
    /// Fixed interval reminders from start hour
    private static func fixedIntervalTimes(
        intervalHours: Double,
        startHour: Int,
        endHour: Int,
        count: Int,
        now: Date,
        calendar: Calendar
    ) -> [Date] {
        let today = calendar.startOfDay(for: now)
        let intervalMinutes = Int(intervalHours * 60)
        var times: [Date] = []
        
        var minuteOffset = startHour * 60
        let endMinutes = endHour * 60
        
        while minuteOffset < endMinutes && times.count < count {
            if let date = calendar.date(byAdding: .minute, value: minuteOffset, to: today) {
                if date > now {
                    times.append(date)
                }
            }
            minuteOffset += intervalMinutes
        }
        
        return times
    }
}
