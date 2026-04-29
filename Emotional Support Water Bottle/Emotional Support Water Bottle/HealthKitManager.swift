//
//  HealthKitManager.swift
//  Emotional Support Water Bottle
//
//  Handles all HealthKit interactions:
//  - Request permission to read mood (StateOfMind) and write dietary water
//  - Write hydration entries to Apple Health
//  - Read latest mood state for personality-aware reminders
//

import HealthKit
import Foundation

@Observable
final class HealthKitManager {
    
    static let shared = HealthKitManager()
    
    /// Whether HealthKit is available on this device
    let isAvailable: Bool
    
    /// Whether we currently have permission
    var isAuthorized: Bool = false
    
    /// Latest mood state detected from HealthKit (nil if no data or not authorized)
    var currentMood: String? = nil
    
    private let healthStore = HKHealthStore()
    
    private init() {
        isAvailable = HKHealthStore.isHealthDataAvailable()
    }
    
    // MARK: - Types
    
    /// Dietary water — we WRITE this
    private var waterType: HKQuantityType {
        HKQuantityType(.dietaryWater)
    }
    
    /// State of mind (mood) — we READ this
    private var stateOfMindType: HKStateOfMindType {
        HKObjectType.stateOfMindType()
    }
    
    // MARK: - Permission
    
    /// Request HealthKit authorization for reading mood and writing water
    @discardableResult
    func requestAuthorization() async -> Bool {
        guard isAvailable else {
            print("[HealthKitManager] Not available on this device")
            return false
        }
        
        let readTypes: Set<HKObjectType> = [stateOfMindType]
        let writeTypes: Set<HKSampleType> = [waterType]
        
        do {
            try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
            isAuthorized = true
            print("[HealthKitManager] Authorization granted")
            
            await fetchLatestMood()
            return true
        } catch {
            print("[HealthKitManager] Authorization failed: \(error)")
            isAuthorized = false
            return false
        }
    }
    
    // MARK: - Write Water
    
    /// Log a water intake entry to Apple Health
    func logWaterIntake(amountML: Double, date: Date = .now) {
        guard isAuthorized else { return }
        
        let quantity = HKQuantity(unit: .liter(), doubleValue: amountML / 1000.0)
        
        let sample = HKQuantitySample(
            type: waterType,
            quantity: quantity,
            start: date,
            end: date
        )
        
        healthStore.save(sample) { success, error in
            if success {
                print("[HealthKitManager] Logged \(amountML)mL water to HealthKit")
            } else if let error = error {
                print("[HealthKitManager] Failed to log water: \(error)")
            }
        }
    }
    
    // MARK: - Read Mood
    
    /// Fetch the latest mood entry and update currentMood
    func fetchLatestMood() async {
        guard isAuthorized else { return }
        
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.stateOfMind()],
            sortDescriptors: [SortDescriptor(\.startDate, order: .reverse)],
            limit: 1
        )
        
        do {
            let results = try await descriptor.result(for: healthStore)
            if let latest = results.first {
                currentMood = moodClassificationToString(latest.valenceClassification)
                print("[HealthKitManager] Latest mood: \(currentMood ?? "unknown")")
            }
        } catch {
            print("[HealthKitManager] Failed to fetch mood: \(error)")
        }
    }
    
    /// Convert HKStateOfMind valence classification to personality engine mood key
    private func moodClassificationToString(_ classification: HKStateOfMind.ValenceClassification) -> String {
        switch classification {
        case .veryPleasant, .pleasant:
            return "happy"
        case .slightlyPleasant, .neutral:
            return "neutral"
        case .slightlyUnpleasant:
            return "anxious"
        case .unpleasant, .veryUnpleasant:
            return "down"
        @unknown default:
            return "neutral"
        }
    }
}
