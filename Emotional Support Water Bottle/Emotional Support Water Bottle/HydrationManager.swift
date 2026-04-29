//
//  HydrationManager.swift
//  Emotional Support Water Bottle
//
//  Central manager for hydration state: logging drinks,
//  computing daily progress, and querying history.
//

import Foundation
import SwiftData
import Observation

@Observable
final class HydrationManager {
    
    /// Today's total intake in mL
    var todayIntakeML: Double = 0
    
    /// Percentage of daily goal achieved (0.0–1.0+)
    var progress: Double {
        guard let prefs = preferences, prefs.dailyGoalML > 0 else { return 0 }
        return todayIntakeML / prefs.dailyGoalML
    }
    
    /// How many sips worth are remaining today
    var sipsRemaining: Int {
        guard let prefs = preferences else { return 0 }
        let remaining = max(0, prefs.dailyGoalML - todayIntakeML)
        return Int(ceil(remaining / prefs.sipSizeML))
    }
    
    /// Whether today's goal is met
    var goalMet: Bool {
        progress >= 1.0
    }
    
    /// Reschedule reminders based on current state
    private func rescheduleReminders() {
        guard let prefs = preferences else { return }
        ReminderScheduler.scheduleFromPreferences(prefs, sipsRemaining: sipsRemaining)
    }
    
    /// Remaining mL to hit goal
    var remainingML: Double {
        guard let prefs = preferences else { return 0 }
        return max(0, prefs.dailyGoalML - todayIntakeML)
    }
    
    private var preferences: UserPreferences?
    private var modelContext: ModelContext?
    
    func configure(preferences: UserPreferences, context: ModelContext) {
        self.preferences = preferences
        self.modelContext = context
        refreshTodayIntake()
    }
    
    // MARK: - Logging
    
    func logDrink(amountML: Double? = nil, source: EntrySource = .manual) {
        guard let prefs = preferences, let ctx = modelContext else { return }
        let amount = amountML ?? prefs.sipSizeML
        
        let entry = HydrationEntry(date: .now, amountML: amount, source: source)
        ctx.insert(entry)
        
        todayIntakeML += amount
        
        // Reschedule reminders (fewer remaining now, or cancel if goal met)
        rescheduleReminders()
    }
    
    // MARK: - Queries
    
    /// Refresh today's intake from the database
    func refreshTodayIntake() {
        guard let ctx = modelContext else { return }
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: .now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let descriptor = FetchDescriptor<HydrationEntry>(
            predicate: #Predicate { $0.date >= startOfDay && $0.date < endOfDay }
        )
        
        do {
            let entries = try ctx.fetch(descriptor)
            todayIntakeML = entries.reduce(0) { $0 + $1.amountML }
        } catch {
            print("Failed to fetch today's entries: \(error)")
        }
    }
    
    /// Get intake totals for the last N days (including today)
    func intakeForLast(days: Int) -> [(date: Date, amountML: Double)] {
        guard let ctx = modelContext else { return [] }
        let calendar = Calendar.current
        
        var results: [(date: Date, amountML: Double)] = []
        
        for i in (0..<days).reversed() {
            let date = calendar.date(byAdding: .day, value: -i, to: .now)!
            let start = calendar.startOfDay(for: date)
            let end = calendar.date(byAdding: .day, value: 1, to: start)!
            
            let descriptor = FetchDescriptor<HydrationEntry>(
                predicate: #Predicate { $0.date >= start && $0.date < end }
            )
            
            do {
                let entries = try ctx.fetch(descriptor)
                let total = entries.reduce(0) { $0 + $1.amountML }
                results.append((date: start, amountML: total))
            } catch {
                results.append((date: start, amountML: 0))
            }
        }
        
        return results
    }
}