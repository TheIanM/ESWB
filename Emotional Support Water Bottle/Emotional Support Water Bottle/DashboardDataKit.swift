//
//  DashboardDataKit.swift
//  Emotional Support Water Bottle
//
//  Adapted from DashboardDataKit by M.Damra.
//  Stripped to components needed for hydration stats.
//  Recolored to cyan water theme.
//
//  1. StatCard           — KPI metric card with trend arrow
//  2. MiniSparkline      — Tiny inline line chart
//  3. BarChartMini       — Compact animated bar chart
//  4. ActivityFeed       — Timeline event feed
//  5. MetricComparison   — Side-by-side metric vs metric
//  6. VerticalTimeline   — Vertical dot-connected timeline
//
//  iOS 17+ · SwiftUI 5
//

import SwiftUI

// ━━━ Shared Colors ━━━
extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var i: UInt64 = 0; Scanner(string: h).scanHexInt64(&i)
        let r, g, b: UInt64
        switch h.count {
        case 6: (r, g, b) = (i >> 16, i >> 8 & 0xFF, i & 0xFF)
        default: (r, g, b) = (0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255)
    }
}

// Theme colors — dark mode water theme
private let kBg   = Color(hex: "0D1117")
private let kCard = Color(hex: "161B22")
private let kSurf = Color(hex: "21262D")
private let kBord = Color.white.opacity(0.06)
private let kSec  = Color.white.opacity(0.5)

// Accent color — cyan water
private let kAccent = Color(hex: "00B4D8")


// ╔══════════════════════════════════════════════════════════════╗
// ║  1. StatCard — KPI card with value, trend, sparkline        ║
// ╚══════════════════════════════════════════════════════════════╝

struct StatCard: View {
    let title: String
    let value: String
    var trend: Double? = nil
    var icon: String = "chart.bar.fill"
    var color: Color = kAccent
    var sparkData: [CGFloat] = []

    private var trendColor: Color {
        guard let t = trend else { return .gray }
        return t >= 0 ? Color(hex: "00B894") : Color(hex: "FF6B6B")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(color)
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(color.opacity(0.12)))
                Spacer()
                if let trend {
                    HStack(spacing: 3) {
                        Image(systemName: trend >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 10, weight: .bold))
                        Text(String(format: "%+.1f%%", trend))
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(trendColor)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Capsule().fill(trendColor.opacity(0.1)))
                }
            }

            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(kSec)

            if !sparkData.isEmpty {
                MiniSparkline(data: sparkData, color: color, height: 32)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(kCard)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(kBord)))
    }
}


// ╔══════════════════════════════════════════════════════════════╗
// ║  2. MiniSparkline — Tiny inline line chart                  ║
// ╚══════════════════════════════════════════════════════════════╝

struct MiniSparkline: View {
    let data: [CGFloat]
    var color: Color = kAccent
    var height: CGFloat = 40
    var showGradient: Bool = true
    var animated: Bool = true

    @State private var appeared = false

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = height
            let mn = data.min() ?? 0
            let mx = data.max() ?? 1
            let range = mx - mn == 0 ? 1 : mx - mn

            ZStack {
                // Gradient fill
                if showGradient {
                    Path { path in
                        for (i, val) in data.enumerated() {
                            let x = w * CGFloat(i) / CGFloat(data.count - 1)
                            let y = h - ((val - mn) / range) * h
                            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                            else { path.addLine(to: CGPoint(x: x, y: y)) }
                        }
                        path.addLine(to: CGPoint(x: w, y: h))
                        path.addLine(to: CGPoint(x: 0, y: h))
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(colors: [color.opacity(0.3), color.opacity(0)],
                                       startPoint: .top, endPoint: .bottom)
                    )
                }

                // Line
                Path { path in
                    for (i, val) in data.enumerated() {
                        let x = w * CGFloat(i) / CGFloat(data.count - 1)
                        let y = h - ((val - mn) / range) * h
                        if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                        else { path.addLine(to: CGPoint(x: x, y: y)) }
                    }
                }
                .trim(from: 0, to: appeared ? 1 : 0)
                .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .shadow(color: color.opacity(0.4), radius: 4)

                // End dot
                if let last = data.last {
                    let x = w
                    let y = h - ((last - mn) / range) * h
                    Circle().fill(color).frame(width: 6, height: 6)
                        .shadow(color: color.opacity(0.6), radius: 4)
                        .position(x: x, y: y)
                        .opacity(appeared ? 1 : 0)
                }
            }
        }
        .frame(height: height)
        .onAppear {
            if animated {
                withAnimation(.easeOut(duration: 0.8).delay(0.2)) { appeared = true }
            } else { appeared = true }
        }
    }
}


// ╔══════════════════════════════════════════════════════════════╗
// ║  3. BarChartMini — Compact animated bar chart               ║
// ╚══════════════════════════════════════════════════════════════╝

struct BarChartMini: View {
    let data: [(label: String, value: CGFloat)]
    var color: Color = kAccent
    var height: CGFloat = 120
    var showValues: Bool = true

    @State private var appeared = false

    private var maxVal: CGFloat { data.map(\.value).max() ?? 1 }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(Array(data.enumerated()), id: \.offset) { i, item in
                VStack(spacing: 6) {
                    if showValues {
                        Text(String(format: "%.0f", item.value))
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundStyle(kSec)
                    }

                    RoundedRectangle(cornerRadius: 5)
                        .fill(
                            LinearGradient(colors: [color, color.opacity(0.5)],
                                           startPoint: .top, endPoint: .bottom)
                        )
                        .frame(height: appeared ? height * (item.value / maxVal) : 4)
                        .shadow(color: color.opacity(0.2), radius: 4, y: 2)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.7)
                            .delay(Double(i) * 0.08),
                            value: appeared
                        )

                    Text(item.label)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(kSec)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: height + 36)
        .onAppear { appeared = true }
    }
}


// ╔══════════════════════════════════════════════════════════════╗
// ║  4. ActivityFeed — Recent event list                        ║
// ╚══════════════════════════════════════════════════════════════╝

struct ActivityFeedItem: Identifiable {
    let id = UUID()
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    let time: String
}

struct ActivityFeed: View {
    let items: [ActivityFeedItem]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { i, item in
                HStack(spacing: 12) {
                    VStack(spacing: 0) {
                        ZStack {
                            Circle().fill(item.color.opacity(0.12)).frame(width: 34, height: 34)
                            Image(systemName: item.icon).font(.system(size: 13)).foregroundStyle(item.color)
                        }
                        if i < items.count - 1 {
                            Rectangle().fill(kBord).frame(width: 1.5).frame(maxHeight: .infinity)
                        }
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.title)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                        Text(item.subtitle)
                            .font(.system(size: 11))
                            .foregroundStyle(kSec)
                    }

                    Spacer()

                    Text(item.time)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(kSec)
                }
                .padding(.vertical, 10)
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════════╗
// ║  5. MetricComparison — Side-by-side A vs B                  ║
// ╚══════════════════════════════════════════════════════════════╝

struct MetricComparison: View {
    let leftLabel: String
    let leftValue: CGFloat
    let rightLabel: String
    let rightValue: CGFloat
    var leftColor: Color = kAccent
    var rightColor: Color = Color(hex: "00CEC9")
    var unit: String = ""

    private var total: CGFloat { leftValue + rightValue }

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(leftLabel).font(.system(size: 11, weight: .medium)).foregroundStyle(kSec)
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(String(format: "%.0f", leftValue))
                            .font(.system(size: 22, weight: .bold, design: .rounded)).foregroundStyle(leftColor)
                        if !unit.isEmpty { Text(unit).font(.system(size: 11)).foregroundStyle(kSec) }
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 3) {
                    Text(rightLabel).font(.system(size: 11, weight: .medium)).foregroundStyle(kSec)
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(String(format: "%.0f", rightValue))
                            .font(.system(size: 22, weight: .bold, design: .rounded)).foregroundStyle(rightColor)
                        if !unit.isEmpty { Text(unit).font(.system(size: 11)).foregroundStyle(kSec) }
                    }
                }
            }

            GeometryReader { geo in
                HStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(leftColor)
                        .frame(width: total > 0 ? geo.size.width * (leftValue / total) : geo.size.width * 0.5)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(rightColor)
                }
            }
            .frame(height: 10)
            .clipShape(Capsule())
        }
    }
}


// ╔══════════════════════════════════════════════════════════════╗
// ║  6. VerticalTimeline — Dot-connected timeline               ║
// ╚══════════════════════════════════════════════════════════════╝

struct TimelineItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let time: String
    var color: Color = kAccent
    var isCompleted: Bool = false
}

struct VerticalTimeline: View {
    let items: [TimelineItem]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { i, item in
                HStack(alignment: .top, spacing: 14) {
                    VStack(spacing: 0) {
                        ZStack {
                            Circle()
                                .fill(item.isCompleted ? item.color : kSurf)
                                .frame(width: 14, height: 14)
                                .overlay(
                                    Circle()
                                        .stroke(item.isCompleted ? item.color : Color.gray.opacity(0.3), lineWidth: 2)
                                )
                            if item.isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 7, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .shadow(color: item.isCompleted ? item.color.opacity(0.4) : .clear, radius: 4)

                        if i < items.count - 1 {
                            Rectangle()
                                .fill(items[i].isCompleted ? item.color.opacity(0.3) : kBord)
                                .frame(width: 1.5, height: 40)
                        }
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Text(item.title)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(item.isCompleted ? .white : kSec)
                            Spacer()
                            Text(item.time)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(kSec)
                        }
                        Text(item.subtitle)
                            .font(.system(size: 11))
                            .foregroundStyle(kSec)
                    }
                    .padding(.bottom, i < items.count - 1 ? 20 : 0)
                }
            }
        }
    }
}
