//
//  OnboardingView.swift
//  Emotional Support Water Bottle
//
//  Multi-step onboarding flow. Collects user preferences before
//  showing the main app. Steps based on onboarding.md spec.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(HydrationManager.self) private var hydrationManager
    
    @State private var currentStep = 0
    
    // Step 0: Unit preference
    @State private var unitPreference: UnitPreference = .ml
    
    // Step 1: Bottle size (in mL internally, displayed in chosen unit)
    @State private var bottleSizeML: Double = 750
    
    // Step 2: Activity level
    @State private var activityLevel: ActivityLevel = .moderate
    
    // Step3: Daily goal (defaults based on activity, adjustable)
    @State private var dailyGoalML: Double = 3200
    
    // Step 4: HealthKit
    @State private var healthKitEnabled = false
    
    // Step 5: Logging method
    @State private var loggingMethod: LoggingMethod = .button
    
    // Step 6: Personality
    @State private var selectedPersonality: String = "excited-dog"
    private let personalityEngine = PersonalityEngine()
    
    // Step 7: Reminder schedule
    @State private var scheduleType: ScheduleType = .smartRandom
    @State private var reminderStartHour: Int = 7
    @State private var reminderEndHour: Int = 22
    
    private let totalSteps = 8  // 0 through 7
    
    var body: some View {
        ZStack {
            // Dark background
            Color(red: 0.06, green: 0.06, blue: 0.12)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress bar
                ProgressView(value: Double(currentStep), total: Double(totalSteps))
                    .tint(.cyan)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                
                // Step content
                TabView(selection: $currentStep) {
                    unitStep.tag(0)
                    bottleStep.tag(1)
                    activityStep.tag(2)
                    goalStep.tag(3)
                    healthKitStep.tag(4)
                    loggingStep.tag(5)
                    personalityStep.tag(6)
                    reminderStep.tag(7)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
                
                // Navigation buttons
                HStack(spacing: 16) {
                    if currentStep > 0 {
                        Button("Back") {
                            withAnimation { currentStep -= 1 }
                        }
                        .foregroundStyle(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    if currentStep < totalSteps {
                        Button {
                            withAnimation { currentStep += 1 }
                        } label: {
                            HStack {
                                Text("Next")
                                Image(systemName: "arrow.right")
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .background(Capsule().fill(.cyan))
                        }
                    } else {
                        Button {
                            saveAndFinish()
                        } label: {
                            HStack {
                                Text("Get Started")
                                Image(systemName: "drop.fill")
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .background(Capsule().fill(.cyan))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
    
    // MARK: - Step 0: Unit Preference
    
    private var unitStep: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: "ruler")
                .font(.system(size: 56))
                .foregroundStyle(.cyan)
            
            Text("What units do you prefer?")
                .font(.title.bold())
                .foregroundStyle(.white)
            
            Text("You can change this later in Settings.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
            
            VStack(spacing: 12) {
                ForEach(UnitPreference.allCases, id: \.self) { unit in
                    Button {
                        unitPreference = unit
                    } label: {
                        HStack {
                            Text(unit.displayName)
                                .foregroundStyle(.white)
                            Spacer()
                            if unitPreference == unit {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.cyan)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(unitPreference == unit ? Color.cyan.opacity(0.2) : Color.white.opacity(0.08))
                        )
                    }
                    // Accessibility: announce selected state
                    .accessibilityAddTraits(unitPreference == unit ? .isSelected : [])
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
    
    // MARK: - Step 1: Bottle Size
    
    private var bottleStep: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "waterbottle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.cyan)
            
            Text("How big is your water bottle?")
                .font(.title.bold())
                .foregroundStyle(.white)
            
            // Size display
            Text(formatBottleSize(bottleSizeML))
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(.cyan)
            
            // Slider
            VStack(spacing: 8) {
                Slider(
                    value: $bottleSizeML,
                    in: 300...3000,
                    step: unitPreference == .oz ? 30 : 50
                ) {
                    Text("Bottle size")
                }
                .tint(.cyan)
                .accessibilityValue(Text(formatBottleSize(bottleSizeML)))
                .padding(.horizontal, 24)
                
                // Common sizes as quick picks
                HStack(spacing: 8) {
                    ForEach(commonBottleSizes, id: \.self) { size in
                        Button {
                            bottleSizeML = size
                        } label: {
                            Text(formatBottleSize(size))
                                .font(.caption)
                                .foregroundStyle(abs(bottleSizeML - size) < 25 ? .cyan : .white.opacity(0.6))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule().fill(
                                        abs(bottleSizeML - size) < 25 ? Color.cyan.opacity(0.2) : Color.white.opacity(0.08)
                                    )
                                )
                        }
                    }
                }
            }
            
            Spacer()
        }
    }
    
    private var commonBottleSizes: [Double] {
        // Common sizes in mL
        [350, 500, 750, 1000, 1500]
    }
    
    // MARK: - Step 2: Activity Level
    
    private var activityStep: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "figure.run")
                .font(.system(size: 56))
                .foregroundStyle(.cyan)
            
            Text("How active are you?")
                .font(.title.bold())
                .foregroundStyle(.white)
            
            Text("This helps us set your daily goal.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
            
            VStack(spacing: 12) {
                ForEach(ActivityLevel.allCases, id: \.self) { level in
                    Button {
                        activityLevel = level
                        dailyGoalML = level.recommendedML
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(level.displayName)
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Text(level.description)
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.7))
                                Text("~\(formatBottleSize(level.recommendedML))/day")
                                    .font(.caption)
                                    .foregroundStyle(.cyan)
                            }
                            Spacer()
                            if activityLevel == level {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.cyan)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(activityLevel == level ? Color.cyan.opacity(0.2) : Color.white.opacity(0.08))
                        )
                    }
                    // Accessibility: announce selected state
                    .accessibilityAddTraits(activityLevel == level ? .isSelected : [])
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
    
    // MARK: - Step 3: Goal Confirmation
    
    private var goalStep: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "target")
                .font(.system(size: 56))
                .foregroundStyle(.cyan)
            
            Text("Your Daily Goal")
                .font(.title.bold())
                .foregroundStyle(.white)
            
            // Derived info
            let bottlesNeeded = bottleSizeML > 0 ? dailyGoalML / bottleSizeML : 0
            let totalSips = Int(ceil(bottlesNeeded * 6))
            
            VStack(spacing: 16) {
                Text(formatBottleSize(dailyGoalML))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.cyan)
                
                Text("That's about \(String(format: "%.1f", bottlesNeeded)) bottles")
                    .font(.title3)
                    .foregroundStyle(.white)
                
                Text("\(totalSips) sips throughout the day")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            // Adjustable goal
            VStack(spacing: 8) {
                Slider(
                    value: $dailyGoalML,
                    in: 1500...5000,
                    step: 100
                )
                .tint(.cyan)
                .accessibilityValue(Text(formatBottleSize(dailyGoalML)))
                .padding(.horizontal, 24)
                
                HStack {
                    Text(formatBottleSize(1500))
                    Spacer()
                    Text(formatBottleSize(5000))
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
                .padding(.horizontal, 24)
            }
            
            Text("Based on Mayo Clinic guidelines: 2.7–3.7L/day")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.7))
            
            Spacer()
        }
    }
    
    // MARK: - Step 4: HealthKit
    
    private var healthKitStep: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "heart.circle")
                .font(.system(size: 56))
                .foregroundStyle(.cyan)
            
            Text("Apple Health")
                .font(.title.bold())
                .foregroundStyle(.white)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "drop.circle.fill")
                        .foregroundStyle(.cyan)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Log Hydration")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text("Write your water intake to Apple Health so other apps can see it.")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "brain.head.profile.fill")
                        .foregroundStyle(.cyan)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Read Mood Data")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text("Read your mood logs to send you emotionally supportive reminders.")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
            )
            .padding(.horizontal, 24)
            
            // Actual permission request happens on save.
            // This is just the explanation screen.
            
            Text("You'll be prompted to grant permissions on the next screen.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
                .padding(.horizontal, 24)
            
            Spacer()
        }
    }
    
    // MARK: - Step 5: Logging Method
    
    private var loggingStep: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "hand.tap")
                .font(.system(size: 56))
                .foregroundStyle(.cyan)
            
            Text("How do you want to log drinks?")
                .font(.title.bold())
                .foregroundStyle(.white)
            
            VStack(spacing: 12) {
                // Button option
                Button {
                    loggingMethod = .button
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "hand.tap")
                                Text("Tap to Drink")
                                    .font(.headline)
                            }
                            .foregroundStyle(.white)
                            Text("Simple button press to log each sip. Always accessible.")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        Spacer()
                        if loggingMethod == .button {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.cyan)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(loggingMethod == .button ? Color.cyan.opacity(0.2) : Color.white.opacity(0.08))
                    )
                }
                .accessibilityAddTraits(loggingMethod == .button ? .isSelected : [])
                
                // Tilt option
                Button {
                    loggingMethod = .tilt
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "iphone.radiowaves.left.and.right")
                                Text("Tilt to Drink")
                                    .font(.headline)
                            }
                            .foregroundStyle(.white)
                            Text("Tilt your phone like a bottle. Fun but optional — button is always available.")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        Spacer()
                        if loggingMethod == .tilt {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.cyan)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(loggingMethod == .tilt ? Color.cyan.opacity(0.2) : Color.white.opacity(0.08))
                    )
                }
                .accessibilityAddTraits(loggingMethod == .tilt ? .isSelected : [])
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
    
    // MARK: - Step 6: Personality
    
    private var personalityStep: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "bubble.left.fill")
                .font(.system(size: 56))
                .foregroundStyle(.cyan)
            
            Text("Reminder Personality")
                .font(.title.bold())
                .foregroundStyle(.white)
            
            Text("How should your reminders talk to you?")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
            
            ScrollView {
                VStack(spacing: 12) {
                    let personalities = personalityEngine.loadAll()
                    ForEach(personalities) { personality in
                        Button {
                            selectedPersonality = personality.id
                        } label: {
                            HStack {
                                Image(systemName: personality.icon)
                                    .foregroundStyle(Color(hex: "00B4D8"))
                                    .frame(width: 28)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(personality.name)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.white)
                                    Text(personality.description)
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.7))
                                        .lineLimit(1)
                                }
                                Spacer()
                                if selectedPersonality == personality.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.cyan)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedPersonality == personality.id ? Color.cyan.opacity(0.2) : Color.white.opacity(0.08))
                            )
                        }
                        .accessibilityAddTraits(selectedPersonality == personality.id ? .isSelected : [])
                    }
                }
                .padding(.horizontal, 24)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Step 7: Reminders
    
    private var reminderStep: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "bell.badge")
                .font(.system(size: 56))
                .foregroundStyle(.cyan)
            
            Text("Reminder Schedule")
                .font(.title.bold())
                .foregroundStyle(.white)
            
            VStack(spacing: 12) {
                ForEach(ScheduleType.allCases, id: \.self) { type in
                    Button {
                        scheduleType = type
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(type.displayName)
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Text(type.description)
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                            Spacer()
                            if scheduleType == type {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.cyan)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(scheduleType == type ? Color.cyan.opacity(0.2) : Color.white.opacity(0.08))
                        )
                    }
                    .accessibilityAddTraits(scheduleType == type ? .isSelected : [])
                }
            }
            .padding(.horizontal, 24)
            
            // Wake / sleep hours
            VStack(spacing: 8) {
                HStack {
                    Text("Reminders from")
                        .foregroundStyle(.white.opacity(0.7))
                    Spacer()
                    Picker("From", selection: $reminderStartHour) {
                        ForEach(5..<12, id: \.self) { h in
                            Text("\(h):00 AM").tag(h)
                        }
                    }
                    .tint(.cyan)
                    
                    Text("to")
                        .foregroundStyle(.white.opacity(0.7))
                    
                    Picker("To", selection: $reminderEndHour) {
                        ForEach(18..<24, id: \.self) { h in
                            Text("\(h - 12):00 PM").tag(h)
                        }
                    }
                    .tint(.cyan)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
    
    // MARK: - Helpers
    
    private func formatBottleSize(_ ml: Double) -> String {
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
    
    private func saveAndFinish() {
        // Always fetch all existing prefs — there should only ever be one
        let existing = (try? modelContext.fetch(FetchDescriptor<UserPreferences>())) ?? []
        
        // Use the first existing, or create new
        let prefs: UserPreferences
        if let first = existing.first {
            prefs = first
            // Delete any duplicates from previous buggy runs
            for extra in existing.dropFirst() {
                modelContext.delete(extra)
            }
        } else {
            prefs = UserPreferences()
            modelContext.insert(prefs)
        }
        
        // Apply all values
        prefs.unitPreference = unitPreference
        prefs.activityLevel = activityLevel
        prefs.bottleSizeML = bottleSizeML
        prefs.dailyGoalML = dailyGoalML
        prefs.reminderPersonality = selectedPersonality
        prefs.reminderScheduleType = scheduleType
        prefs.reminderIntervalHours = 1.0
        prefs.reminderStartHour = reminderStartHour
        prefs.reminderEndHour = reminderEndHour
        prefs.healthKitEnabled = healthKitEnabled
        prefs.hasCompletedOnboarding = true
        prefs.preferredLoggingMethod = loggingMethod
        prefs.sipsPerBottle = 6
        
        // Force persist
        try? modelContext.save()
        
        hydrationManager.configure(preferences: prefs, context: modelContext)
        
        // Request notification permission and schedule initial reminders
        Task {
            let granted = await NotificationManager.shared.requestPermission()
            if granted {
                ReminderScheduler.scheduleFromPreferences(prefs, sipsRemaining: hydrationManager.sipsRemaining)
            }
            
            // Request HealthKit permission if enabled
            if healthKitEnabled {
                await HealthKitManager.shared.requestAuthorization()
            }
        }
    }
}

#Preview {
    OnboardingView()
        .modelContainer(for: [HydrationEntry.self, UserPreferences.self], inMemory: true)
        .environment(HydrationManager())
}
