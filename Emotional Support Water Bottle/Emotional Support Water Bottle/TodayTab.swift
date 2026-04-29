//
//  TodayTab.swift
//  Emotional Support Water Bottle
//
//  Main hydration tracking screen.
//  Hero: water bottle with metaball water inside, surrounded by a progress ring.
//  Stats below the bottle. Drink button at the bottom.
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
                let circleSize = min(size.width * 0.55, size.height * 0.4)
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // MARK: - Hero: Ring + Water Circle
                    ZStack {
                        // Progress ring surrounds the water circle
                        FillRingView(
                            progress: hydrationManager.progress,
                            lineWidth: 10
                        )
                        .frame(width: circleSize + 32, height: circleSize + 32)
                        
                        // Metaball water inside a circle, slightly inset from ring
                        // WaterSimView shows remaining water — starts full, empties as you drink
        WaterSimView(progress: 1.0 - hydrationManager.progress)
                            .frame(width: circleSize, height: circleSize)
                    }
                    
                    // MARK: - Stats
                    VStack(spacing: 6) {
                        if let prefs = prefs {
                            Text(prefs.formatAmount(hydrationManager.todayIntakeML))
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            
                            Text("of \(prefs.formatAmount(prefs.dailyGoalML))")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        
                        let pct = Int(hydrationManager.progress * 100)
                        Text("\(pct)%")
                            .font(.title3.monospacedDigit().bold())
                            .foregroundStyle(.cyan)
                            .padding(.top, 2)
                        
                        if hydrationManager.goalMet {
                            Text("Goal met! Great job! 💧")
                                .font(.subheadline.bold())
                                .foregroundStyle(.cyan)
                                .transition(.opacity)
                        } else {
                            Text("\(hydrationManager.sipsRemaining) sips to go")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.5))
                                .transition(.opacity)
                        }
                    }
                    .padding(.top, 20)
                    .animation(.easeInOut(duration: 0.3), value: hydrationManager.goalMet)
                    
                    Spacer()
                    
                    // MARK: - Drink Button
                    Button {
                        hydrationManager.logDrink()
                    } label: {
                        HStack(spacing: 8) {
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
                    
                    Spacer()
                        .frame(height: 24)
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
