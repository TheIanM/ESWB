//
//  SettingsTab.swift
//  Emotional Support Water Bottle
//
//  Basic settings — bottle size, goal, unit preference.
//  Full settings (reminders, personality, tip jar) in later phases.
//

import SwiftUI
import SwiftData

struct SettingsTab: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(HydrationManager.self) private var hydrationManager
    @Query private var preferences: [UserPreferences]
    
    private var prefs: UserPreferences? {
        preferences.first
    }
    
    var body: some View {
        NavigationStack {
            Form {
                if let prefs = prefs {
                    Section("Units") {
                        Picker("Display Unit", selection: bind(prefs, \.unitPreference)) {
                            ForEach(UnitPreference.allCases, id: \.self) { unit in
                                Text(unit.displayName).tag(unit)
                            }
                        }
                    }
                    
                    Section("Water Bottle") {
                        HStack {
                            Text("Bottle Size")
                            Spacer()
                            TextField("Size", value: bind(prefs, \.bottleSizeML), format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                            Text(prefs.unitPreference == .ml ? "ml" : "oz")
                        }
                        
                        Stepper("Sips per bottle: \(prefs.sipsPerBottle)", value: bind(prefs, \.sipsPerBottle), in: 2...12)
                    }
                    
                    Section("Daily Goal") {
                        Picker("Activity Level", selection: bind(prefs, \.activityLevel)) {
                            ForEach(ActivityLevel.allCases, id: \.self) { level in
                                VStack(alignment: .leading) {
                                    Text(level.displayName)
                                    Text(level.description).font(.caption).foregroundStyle(.secondary)
                                }
                                .tag(level)
                            }
                        }
                        
                        HStack {
                            Text("Daily Goal")
                            Spacer()
                            TextField("Goal", value: bind(prefs, \.dailyGoalML), format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                            Text(prefs.unitPreference == .ml ? "ml" : "oz")
                        }
                        
                        // Show the derived info
                        let goalML = prefs.dailyGoalML
                        let bottleML = prefs.bottleSizeML
                        if bottleML > 0 {
                            let bottles = goalML / bottleML
                            let sips = Int(ceil(bottles * Double(prefs.sipsPerBottle)))
                            HStack {
                                Text("That's about")
                                Spacer()
                                Text("\(String(format: "%.1f", bottles)) bottles (\(sips) sips)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    Section {
                        Button("Redo Onboarding", role: .destructive) {
                            prefs.hasCompletedOnboarding = false
                        }
                    }
                } else {
                    ContentUnavailableView("No Preferences", systemImage: "gearshape")
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    /// Helper to create a binding to a SwiftData model property
    /// (SwiftData models are observable, but Form controls need explicit bindings)
    private func bind<T>(_ prefs: UserPreferences, _ keyPath: ReferenceWritableKeyPath<UserPreferences, T>) -> Binding<T> {
        Binding(
            get: { prefs[keyPath: keyPath] },
            set: { prefs[keyPath: keyPath] = $0 }
        )
    }
}

#Preview {
    SettingsTab()
        .modelContainer(for: [HydrationEntry.self, UserPreferences.self], inMemory: true)
        .environment(HydrationManager())
}