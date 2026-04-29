//
//  RootView.swift
//  Emotional Support Water Bottle
//
//  Decides whether to show onboarding or main tabs.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(HydrationManager.self) private var hydrationManager
    @Query private var preferences: [UserPreferences]
    
    /// Whether onboarding has been completed — checks ALL prefs, not just .first
    private var isOnboarded: Bool {
        preferences.contains { $0.hasCompletedOnboarding }
    }
    
    private var activePrefs: UserPreferences? {
        preferences.first { $0.hasCompletedOnboarding }
    }
    
    var body: some View {
        let _ = print("[RootView] prefs count: \(preferences.count), isOnboarded: \(isOnboarded), flags: \(preferences.map(\.hasCompletedOnboarding))")
        Group {
            if isOnboarded, let prefs = activePrefs {
                MainTabView()
                    .onAppear {
                        hydrationManager.configure(preferences: prefs, context: modelContext)
                        // Schedule today's reminders
                        ReminderScheduler.scheduleFromPreferences(prefs, sipsRemaining: hydrationManager.sipsRemaining)
                    }
            } else {
                OnboardingView()
            }
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: [HydrationEntry.self, UserPreferences.self], inMemory: true)
        .environment(HydrationManager())
}