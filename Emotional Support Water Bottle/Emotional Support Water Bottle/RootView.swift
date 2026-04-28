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
    
    private var currentPrefs: UserPreferences? {
        preferences.first
    }
    
    var body: some View {
        Group {
            if let prefs = currentPrefs, prefs.hasCompletedOnboarding {
                MainTabView()
                    .onAppear {
                        hydrationManager.configure(preferences: prefs, context: modelContext)
                    }
            } else {
                OnboardingView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentPrefs?.hasCompletedOnboarding)
    }
}

#Preview {
    RootView()
        .modelContainer(for: [HydrationEntry.self, UserPreferences.self], inMemory: true)
        .environment(HydrationManager())
}