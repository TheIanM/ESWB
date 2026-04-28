//
//  StatsTab.swift
//  Emotional Support Water Bottle
//
//  Stats and history — Phase 4 implementation.
//  Placeholder for now so the tab bar builds.
//

import SwiftUI

struct StatsTab: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Stats Coming Soon",
                systemImage: "chart.bar.fill",
                description: Text("Track your hydration streaks and history here.")
            )
        }
    }
}

#Preview {
    StatsTab()
}