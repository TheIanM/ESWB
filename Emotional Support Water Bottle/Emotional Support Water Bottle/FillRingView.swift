//
//  FillRingView.swift
//  Emotional Support Water Bottle
//
//  Circular progress ring showing daily hydration progress.
//  Draws two arcs (background + filled) in a Canvas.
//

import SwiftUI

struct FillRingView: View {
    let progress: Double  // 0.0 to 1.0+
    let line_width: CGFloat
    
    private let background_color = Color.white.opacity(0.15)
    private let fill_color = Color.cyan
    
    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = (min(size.width, size.height) - line_width) / 2
            
            // Background ring
            let bg_path = Path { p in
                p.addArc(
                    center: center,
                    radius: radius,
                    startAngle: .degrees(0),
                    endAngle: .degrees(360),
                    clockwise: false
                )
            }
            context.stroke(bg_path, with: .color(background_color), lineWidth: line_width)
            
            // Filled arc — clamped to 1.0 for display
            let fillFraction = min(progress, 1.0)
            if fillFraction > 0 {
                let endAngle = -90 + (360 * fillFraction)
                let fill_path = Path { p in
                    p.addArc(
                        center: center,
                        radius: radius,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(endAngle),
                        clockwise: false
                    )
                }
                context.stroke(
                    fill_path,
                    with: .color(fill_color),
                    style: StrokeStyle(lineWidth: line_width, lineCap: .round)
                )
            }
        }
    }
}

// MARK: - Preview

#Preview("Empty") {
    FillRingView(progress: 0.0, line_width: 20)
        .frame(width: 250, height: 250)
}

#Preview("Half") {
    FillRingView(progress: 0.5, line_width: 20)
        .frame(width: 250, height: 250)
}

#Preview("Full") {
    FillRingView(progress: 1.0, line_width: 20)
        .frame(width: 250, height: 250)
}