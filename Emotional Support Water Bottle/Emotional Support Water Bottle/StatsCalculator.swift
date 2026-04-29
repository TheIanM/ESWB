//
//  StatsCalculator.swift
//  Emotional Support Water Bottle
//
//  Computes streaks, averages, and totals from HydrationEntry history.
//  All methods are static for easy testing.
//

import Foundation

struct DailyHydration: Identifiable {
    let id = UUID()
    let date: Date
    let totalML: Double
    let goalML: Double
    
    var progress: Double {
        guard goalML > 0 else { return 0 }
        return min(totalML / goalML, 1.0)
    }
    
    var goalMet: Bool {
        totalML >= goalML
    }
}

struct StatsSummary {
    let currentStreak: Int
    let bestStreak: Int
    let totalLoggedML: Double
    let averageDailyML: Double
    let totalDays: Int
    let daysGoalMet: Int
}

struct StatsCalculator {
    
    /// Get daily hydration totals for the last N days
    static func dailyHistory(entries: [HydrationEntry], goalML: Double, days: Int = 7) -> [DailyHydration] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return (0..<days).reversed().map { offset in
            let dayStart = calendar.date(byAdding: .day, value: -offset, to: today)!
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            
            let dayTotal = entries
                .filter { $0.date >= dayStart && $0.date < dayEnd }
                .reduce(0) { $0 + $1.amountML }
            
            return DailyHydration(date: dayStart, totalML: dayTotal, goalML: goalML)
        }
    }
    
    /// Get entries for a specific date
    static func entries(for date: Date, from allEntries: [HydrationEntry]) -> [HydrationEntry] {
        let calendar = Calendar.current
        return allEntries.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    /// Compute all-time stats summary
    static func summary(entries: [HydrationEntry], goalML: Double) -> StatsSummary {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Group entries by day
        let grouped = Dictionary(grouping: entries) { calendar.startOfDay(for: $0.date) }
        
        // Sort days chronologically (oldest first)
        let sortedDays = grouped.keys.sorted()
        
        // Calculate streaks — only count days up to and including today
        var currentStreak = 0
        var bestStreak = 0
        var tempStreak = 0
        
        // Walk backwards from today to find current streak
        var checkDate = today
        while true {
            let dayTotal = (grouped[checkDate] ?? []).reduce(0) { $0 + $1.amountML }
            if dayTotal >= goalML {
                currentStreak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                // If today has no entries yet, don't break the streak from yesterday
                if currentStreak == 0 && calendar.isDate(checkDate, inSameDayAs: today) {
                    checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
                    continue
                }
                break
            }
        }
        
        // Walk forward from oldest to find best streak
        for day in sortedDays {
            guard day <= today else { continue }
            let dayTotal = (grouped[day] ?? []).reduce(0) { $0 + $1.amountML }
            if dayTotal >= goalML {
                tempStreak += 1
                bestStreak = max(bestStreak, tempStreak)
            } else {
                tempStreak = 0
            }
        }
        // Also check today if it's not in sortedDays
        bestStreak = max(bestStreak, currentStreak)
        
        let totalLoggedML = entries.reduce(0) { $0 + $1.amountML }
        let totalDays = max(grouped.keys.filter { $0 <= today }.count, 1)
        let daysGoalMet = grouped.keys.filter { day in
            day <= today && (grouped[day] ?? []).reduce(0) { $0 + $1.amountML } >= goalML
        }.count
        
        return StatsSummary(
            currentStreak: currentStreak,
            bestStreak: bestStreak,
            totalLoggedML: totalLoggedML,
            averageDailyML: totalLoggedML / Double(totalDays),
            totalDays: totalDays,
            daysGoalMet: daysGoalMet
        )
    }
    
    /// Week-over-week comparison
    static func weekComparison(entries: [HydrationEntry], goalML: Double) -> (thisWeek: Double, lastWeek: Double) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        let lastWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: weekStart)!
        
        let thisWeekTotal = entries
            .filter { $0.date >= weekStart && $0.date < today + 86400 }
            .reduce(0) { $0 + $1.amountML }
        
        let lastWeekTotal = entries
            .filter { $0.date >= lastWeekStart && $0.date < weekStart }
            .reduce(0) { $0 + $1.amountML }
        
        return (thisWeekTotal, lastWeekTotal)
    }
    
    /// Format day label for bar chart
    static func shortDayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    /// Format time for timeline
    static func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    /// Format mL amount for display
    static func formatAmount(_ ml: Double, unit: UnitPreference) -> String {
        switch unit {
        case .ml:
            if ml >= 1000 {
                return String(format: "%.1fL", ml / 1000)
            }
            return String(format: "%.0fml", ml)
        case .oz:
            let oz = ml / 29.5735
            return String(format: "%.1foz", oz)
        }
    }
}
