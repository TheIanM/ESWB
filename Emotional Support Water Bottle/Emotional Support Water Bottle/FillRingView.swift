//
//  FillRingView.swift
//  Emotional Support Water Bottle
//
//  Circular progress ring designed to surround the water bottle.
//  Draws a thick ring with rounded end caps.
//  Designed to be placed in a ZStack behind/around the bottle view.
//

import SwiftUI

struct FillRingView: View {
    let progress: Double  // 0.0 to 1.0+
    let lineWidth: CGFloat
    
    private let bgColor = Color.white.opacity(0.12)
    private let fillColor = Color.cyan
    
    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = (min(size.width, size.height) - lineWidth) / 2
            
            // Background ring
            let bgPath = Path { p in
                p.addArc(
                    center: center,
                    radius: radius,
                    startAngle: .degrees(0),
                    endAngle: .degrees(360),
                    clockwise: false
                )
            }
            context.stroke(bgPath, with: .color(bgColor), lineWidth: lineWidth)
            
            // Filled arc — starts at top (-90°), sweeps clockwise
            let fillFraction = min(progress, 1.0)
            if fillFraction > 0 {
                let endAngle = -90 + (360 * fillFraction)
                let fillPath = Path { p in
                    p.addArc(
                        center: center,
                        radius: radius,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(endAngle),
                        clockwise: false
                    )
                }
                context.stroke(
                    fillPath,
                    with: .color(fillColor),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
            }
        }
    }
}

// MARK: - Preview

#Preview("Empty") {
    ZStack {
        Color(red: 0.06, green: 0.06, blue: 0.12)
        FillRingView(progress: 0.0, lineWidth: 12)
            .frame(width: 280, height: 350)
    }
}

#Preview("Half") {
    ZStack {
        Color(red: 0.06, green: 0.06, blue: 0.12)
        FillRingView(progress: 0.5, lineWidth: 12)
            .frame(width: 280, height: 350)
    }
}

#Preview("Full") {
    ZStack {
        Color(red: 0.06, green: 0.06, blue: 0.12)
        FillRingView(progress: 1.0, lineWidth: 12)
            .frame(width: 280, height: 350)
    }
}
