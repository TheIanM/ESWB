//
//  SettingsTab.swift
//  Emotional Support Water Bottle
//
//  Settings — bottle size, goal, units, personality picker, redo onboarding.
//

import SwiftUI
import SwiftData

struct SettingsTab: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(HydrationManager.self) private var hydrationManager
    @Query private var preferences: [UserPreferences]
    @State private var personalities: [Personality] = []
    
    private let personalityEngine = PersonalityEngine()
    
    private var prefs: UserPreferences? {
        preferences.first
    }
    
    var body: some View {
        NavigationStack {
            Form {
                if let prefs = prefs {
                    unitsSection(prefs)
                    bottleSection(prefs)
                    goalSection(prefs)
                    personalitySection(prefs)
                    
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
            .onAppear {
                personalities = personalityEngine.loadAll()
            }
        }
    }
    
    // MARK: - Units
    
    private func unitsSection(_ prefs: UserPreferences) -> some View {
        Section("Units") {
            Picker("Display Unit", selection: bind(prefs, \.unitPreference)) {
                ForEach(UnitPreference.allCases, id: \.self) { unit in
                    Text(unit.displayName).tag(unit)
                }
            }
        }
    }
    
    // MARK: - Bottle
    
    private func bottleSection(_ prefs: UserPreferences) -> some View {
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
    }
    
    // MARK: - Goal
    
    private func goalSection(_ prefs: UserPreferences) -> some View {
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
    }
    
    // MARK: - Personality
    
    private func personalitySection(_ prefs: UserPreferences) -> some View {
        Section("Reminder Personality") {
            ForEach(personalities) { personality in
                Button {
                    prefs.reminderPersonality = personality.id
                } label: {
                    HStack {
                        Image(systemName: personality.icon)
                            .foregroundStyle(Color(hex: "00B4D8"))
                            .frame(width: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(personality.name)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.primary)
                            Text(personality.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        Spacer()
                        if prefs.reminderPersonality == personality.id {
                            Image(systemName: "checkmark")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color(hex: "00B4D8"))
                        }
                    }
                }
            }
            
            Button {
                ReminderScheduler.scheduleTestReminder(personalityID: prefs.reminderPersonality)
            } label: {
                HStack {
                    Label("Send Test Reminder", systemImage: "bell.badge")
                    Spacer()
                    Text("5 sec")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    // MARK: - Binding Helper
    
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
