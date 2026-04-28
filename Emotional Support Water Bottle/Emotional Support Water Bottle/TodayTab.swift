//
//  TodayTab.swift
//  Emotional Support Water Bottle
//
//  Main hydration tracking screen. Shows fill ring with progress,
//  water simulation, and drink logging button.
//

import SwiftUI
import SwiftData

struct TodayTab: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(HydrationManager.self) private var hydrationManager
    @Query private var preferences: [UserPreferences]
    
    private var prefs: UserPreferences? {
        preferences.first
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let size = geo.size
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Fill ring with stats overlay
                    ZStack {
                        FillRingView(
                            progress: hydrationManager.progress,
                            line_width: size.width * 0.06
                        )
                        .frame(width: size.width * 0.7, height: size.width * 0.7)
                        
                        // Center text
                        VStack(spacing: 4) {
                            if let prefs = prefs {
                                Text(prefs.formatAmount(hydrationManager.todayIntakeML))
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                
                                Text("of \(prefs.formatAmount(prefs.dailyGoalML))")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.7))
                                
                                let pct = Int(hydrationManager.progress * 100)
                                Text("\(pct)%")
                                    .font(.caption)
                                    .foregroundStyle(.cyan)
                                    .padding(.top, 2)
                            }
                        }
                    }
                    
                    Spacer()
                        .frame(height: 20)
                    
                    // Water simulation
                    if let prefs = prefs {
                        let simProgress = min(1.0, 1.0 - hydrationManager.progress)
                        WaterSimView(progress: max(0.05, simProgress))
                            .frame(width: size.width * 0.75, height: size.height * 0.3)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    // Drink button
                    Button {
                        hydrationManager.logDrink()
                    } label: {
                        HStack {
                            Image(systemName: "drop.fill")
                            Text("Log a Sip")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.cyan)
                        )
                    }
                    .padding(.horizontal, 32)
                    
                    if hydrationManager.goalMet {
                        Text("Goal met! Great job! 💧")
                            .font(.subheadline)
                            .foregroundStyle(.cyan)
                            .padding(.top, 8)
                    } else if let prefs = prefs {
                        Text("\(hydrationManager.sipsRemaining) sips to go")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(.top, 8)
                    }
                    
                    Spacer()
                        .frame(height: 20)
                }
                .frame(width: size.width, height: size.height)
            }
            .background(Color(red: 0.06, green: 0.06, blue: 0.12))
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(red: 0.06, green: 0.06, blue: 0.12), for: .navigationBar)
        }
    }
}

#Preview {
    TodayTab()
        .modelContainer(for: [HydrationEntry.self, UserPreferences.self], inMemory: true)
        .environment(HydrationManager())
}