//
//  StatsTab.swift
//  Emotional Support Water Bottle
//
//  Hydration stats & history using DashboardDataKit components.
//

import SwiftUI
import SwiftData

struct StatsTab: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HydrationEntry.date) private var entries: [HydrationEntry]
    @Query private var preferences: [UserPreferences]
    
    private var prefs: UserPreferences? { preferences.first }
    private var unit: UnitPreference { prefs?.unitPreference ?? .ml }
    private var goalML: Double { prefs?.dailyGoalML ?? 2700 }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    
                    // MARK: - KPI Cards
                    kpiSection
                    
                    // MARK: - 7-Day Bar Chart
                    barChartSection
                    
                    // MARK: - Week Comparison
                    weekComparisonSection
                    
                    // MARK: - Today's Drinks Timeline
                    todayTimelineSection
                    
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
            .background(Color(hex: "0D1117"))
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(hex: "0D1117"), for: .navigationBar)
        }
    }
    
    // MARK: - KPI Cards
    
    private var kpiSection: some View {
        let summary = StatsCalculator.summary(entries: entries, goalML: goalML)
        
        return VStack(spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    StatCard(
                        title: "Current Streak",
                        value: "\(summary.currentStreak) day\(summary.currentStreak == 1 ? "" : "s")",
                        icon: "flame.fill",
                        color: Color(hex: "00B4D8")
                    )
                    
                    StatCard(
                        title: "Avg Daily",
                        value: StatsCalculator.formatAmount(summary.averageDailyML, unit: unit),
                        icon: "drop.fill",
                        color: Color(hex: "00CEC9")
                    )
                    
                    StatCard(
                        title: "Total Logged",
                        value: StatsCalculator.formatAmount(summary.totalLoggedML, unit: unit),
                        icon: "aqi.medium",
                        color: Color(hex: "74B9FF")
                    )
                    
                    StatCard(
                        title: "Best Streak",
                        value: "\(summary.bestStreak) day\(summary.bestStreak == 1 ? "" : "s")",
                        icon: "trophy.fill",
                        color: Color(hex: "FDCB6E")
                    )
                }
            }
        }
    }
    
    // MARK: - 7-Day Bar Chart
    
    private var barChartSection: some View {
        let history = StatsCalculator.dailyHistory(entries: entries, goalML: goalML, days: 7)
        let chartData = history.map { day in
            (label: StatsCalculator.shortDayName(for: day.date), value: CGFloat(day.totalML))
        }
        
        return sectionCard(title: "Last 7 Days", subtitle: "Daily intake vs \(StatsCalculator.formatAmount(goalML, unit: unit)) goal") {
            BarChartMini(
                data: chartData,
                color: Color(hex: "00B4D8"),
                height: 100
            )
        }
    }
    
    // MARK: - Week Comparison
    
    private var weekComparisonSection: some View {
        let comparison = StatsCalculator.weekComparison(entries: entries, goalML: goalML)
        let unitStr = unit == .ml ? "ml" : "oz"
        let thisVal = unit == .ml ? CGFloat(comparison.thisWeek) : CGFloat(comparison.thisWeek / 29.5735)
        let lastVal = unit == .ml ? CGFloat(comparison.lastWeek) : CGFloat(comparison.lastWeek / 29.5735)
        
        return sectionCard(title: "Week vs Week", subtitle: "This week compared to last week") {
            MetricComparison(
                leftLabel: "This Week",
                leftValue: thisVal,
                rightLabel: "Last Week",
                rightValue: lastVal,
                unit: unitStr
            )
        }
    }
    
    // MARK: - Today's Drinks Timeline
    
    private var todayTimelineSection: some View {
        let todayEntries = StatsCalculator.entries(for: Date(), from: entries)
            .sorted { $0.date > $1.date }
        
        let items = todayEntries.map { entry in
            TimelineItem(
                title: StatsCalculator.formatAmount(entry.amountML, unit: unit),
                subtitle: "Logged via \(entry.source.rawValue)",
                time: StatsCalculator.formatTime(entry.date),
                color: Color(hex: "00B4D8"),
                isCompleted: true
            )
        }
        
        return sectionCard(title: "Today's Drinks", subtitle: "\(todayEntries.count) logged") {
            if items.isEmpty {
                Text("No drinks logged yet today")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.white.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                VerticalTimeline(items: items)
            }
        }
    }
    
    // MARK: - Section Card Helper
    
    private func sectionCard<C: View>(title: String, subtitle: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.5))
            }
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "161B22"))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06)))
        )
    }
}

#Preview {
    StatsTab()
        .modelContainer(for: [HydrationEntry.self, UserPreferences.self], inMemory: true)
}
