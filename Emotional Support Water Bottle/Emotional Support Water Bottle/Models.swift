//
//  Models.swift
//  Emotional Support Water Bottle
//
//  Core data models for hydration tracking.
//

import Foundation
import SwiftData

// MARK: - Enums

/// Unit preference for displaying volumes
enum UnitPreference: String, Codable, CaseIterable {
    case oz
    case ml
    
    var displayName: String {
        switch self {
        case .oz: return "Ounces (oz)"
        case .ml: return "Milliliters (ml)"
        }
    }
}

/// Activity level — determines daily hydration goal
enum ActivityLevel: String, Codable, CaseIterable {
    case sedentary
    case moderate
    case veryActive
    
    var displayName: String {
        switch self {
        case .sedentary: return "Sedentary"
        case .moderate: return "Moderately Active"
        case .veryActive: return "Very Active"
        }
    }
    
    var description: String {
        switch self {
        case .sedentary: return "Mostly sitting, light movement"
        case .moderate: return "Regular exercise 3-5x per week"
        case .veryActive: return "Daily intense exercise or physical job"
        }
    }
    
    /// Recommended daily intake in mL based on Mayo Clinic guidelines
    var recommendedML: Double {
        switch self {
        case .sedentary: return 2700   // 2.7L
        case .moderate: return 3200    // 3.2L
        case .veryActive: return 3700  // 3.7L
        }
    }
}

/// How the user prefers to log drinks
enum LoggingMethod: String, Codable {
    case button
    case tilt
}

/// Reminder schedule type
enum ScheduleType: String, Codable, CaseIterable {
    case smartRandom
    case fixedInterval
    case custom
    
    var displayName: String {
        switch self {
        case .smartRandom: return "Smart Random"
        case .fixedInterval: return "Fixed Interval"
        case .custom: return "Custom Times"
        }
    }
    
    var description: String {
        switch self {
        case .smartRandom: return "Random reminders at least once per hour until goal is met"
        case .fixedInterval: return "Reminders at regular intervals"
        case .custom: return "Set specific reminder times"
        }
    }
}

/// Source of a hydration entry
enum EntrySource: String, Codable {
    case manual
    case tilt
    case notification
}

// MARK: - SwiftData Models

@Model
final class HydrationEntry {
    var date: Date
    var amountML: Double
    var source: EntrySource
    
    init(date: Date = .now, amountML: Double, source: EntrySource = .manual) {
        self.date = date
        self.amountML = amountML
        self.source = source
    }
}

@Model
final class UserPreferences {
    var unitPreference: UnitPreference
    var activityLevel: ActivityLevel
    var bottleSizeML: Double
    var dailyGoalML: Double
    var reminderPersonality: String
    var reminderScheduleType: ScheduleType
    var reminderIntervalHours: Double
    var reminderStartHour: Int    // 0-23
    var reminderEndHour: Int      // 0-23
    var healthKitEnabled: Bool
    var hasCompletedOnboarding: Bool
    var preferredLoggingMethod: LoggingMethod
    var sipsPerBottle: Int
    
    init(
        unitPreference: UnitPreference = .ml,
        activityLevel: ActivityLevel = .moderate,
        bottleSizeML: Double = 750,
        dailyGoalML: Double = 3200,
        reminderPersonality: String = "excited-dog",
        reminderScheduleType: ScheduleType = .smartRandom,
        reminderIntervalHours: Double = 1.0,
        reminderStartHour: Int = 7,
        reminderEndHour: Int = 22,
        healthKitEnabled: Bool = false,
        hasCompletedOnboarding: Bool = false,
        preferredLoggingMethod: LoggingMethod = .button,
        sipsPerBottle: Int = 6
    ) {
        self.unitPreference = unitPreference
        self.activityLevel = activityLevel
        self.bottleSizeML = bottleSizeML
        self.dailyGoalML = dailyGoalML
        self.reminderPersonality = reminderPersonality
        self.reminderScheduleType = reminderScheduleType
        self.reminderIntervalHours = reminderIntervalHours
        self.reminderStartHour = reminderStartHour
        self.reminderEndHour = reminderEndHour
        self.healthKitEnabled = healthKitEnabled
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.preferredLoggingMethod = preferredLoggingMethod
        self.sipsPerBottle = sipsPerBottle
    }
    
    // MARK: - Computed helpers
    
    /// How many full bottles needed to hit daily goal
    var bottlesPerDay: Double {
        guard bottleSizeML > 0 else { return 0 }
        return dailyGoalML / bottleSizeML
    }
    
    /// Amount per sip in mL
    var sipSizeML: Double {
        guard sipsPerBottle > 0 else { return bottleSizeML }
        return bottleSizeML / Double(sipsPerBottle)
    }
    
    /// Convert mL to user's preferred unit
    func formatAmount(_ ml: Double) -> String {
        switch unitPreference {
        case .ml:
            if ml >= 1000 {
                return String(format: "%.1fL", ml / 1000)
            }
            return String(format: "%.0fml", ml)
        case .oz:
            return String(format: "%.1foz", ml * 0.033814)
        }
    }
}
