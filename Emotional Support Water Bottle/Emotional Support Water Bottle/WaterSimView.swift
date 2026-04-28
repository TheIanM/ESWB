//
//  WaterSimView.swift
//  Emotional Support Water Bottle
//
//  Metaball water simulation — the virtual water bottle.
//  Uses the alphaThreshold + blur technique from SlimeTheme.swift
//  for organic blobby merging. Responds to device tilt for sloshing.
//

import SwiftUI
import CoreMotion

struct WaterSimView: View {
    let progress: Double   // 0.0–1.0, how full the bottle is
    
    @State private var blobs: [WaterBlob] = []
    @State private var isInitialized = false
    @State private var tiltX: CGFloat = 0
    @State private var tiltY: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // CMMotionManager stored outside @State to avoid Equatable issues
    private let motionManager = CMMotionManager()
    
    /// Water blue color palette
    private let waterColor = Color(
        red: 0.25, green: 0.72, blue: 0.97
    )
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0 / 6.0)) { timeline in
            Canvas { context, size in
                let waterHeight = size.height * CGFloat(min(progress, 1.0))
                let waterTop = size.height - waterHeight
                
                // 1) Glow layer behind the blobs
                context.drawLayer { glow in
                    glow.addFilter(.blur(radius: 14))
                    glow.opacity = 0.35
                    
                    let center = CGPoint(x: size.width / 2, y: waterTop + waterHeight / 2)
                    for blob in blobs {
                        let pos = CGPoint(x: center.x + blob.x, y: center.y + blob.y)
                        let glowR = blob.currentRadius * 2.0
                        glow.fill(
                            Circle().path(in: CGRect(
                                x: pos.x - glowR,
                                y: pos.y - glowR,
                                width: glowR * 2,
                                height: glowR * 2
                            )),
                            with: .radialGradient(
                                Gradient(colors: [waterColor.opacity(0.7), waterColor.opacity(0)]),
                                center: pos,
                                startRadius: 0,
                                endRadius: glowR
                            )
                        )
                    }
                }
                
                // 2) Merged blob layer — white circles → blur → alphaThreshold → water blue
                var blobCtx = context
                blobCtx.addFilter(.alphaThreshold(min: 0.45, color: waterColor))
                blobCtx.addFilter(.blur(radius: 14))
                
                blobCtx.drawLayer { layer in
                    let center = CGPoint(x: size.width / 2, y: waterTop + waterHeight / 2)
                    for blob in blobs {
                        let pos = CGPoint(x: center.x + blob.x, y: center.y + blob.y)
                        let r = blob.currentRadius
                        layer.fill(
                            Circle().path(in: CGRect(
                                x: pos.x - r,
                                y: pos.y - r,
                                width: r * 2,
                                height: r * 2
                            )),
                            with: .color(.white)
                        )
                    }
                }
            }
            .drawingGroup()
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(.white.opacity(0.2), lineWidth: 2)
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            guard !isInitialized else { return }
            blobs = WaterBlob.makeBlobs(
                count: 6,
                boundsSize: CGSize(width: 300, height: 400),
                baseRadiusRange: 25...50
            )
            isInitialized = true
            startMotionUpdates()
        }
        .task {
            // Physics loop — 6 fps like SlimeTheme
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1.0 / 6.0))
                guard isInitialized else { continue }
                let bounds = CGSize(width: 300, height: 400)
                WaterBlob.stepBlobs(&blobs, boundsSize: bounds, tiltX: tiltX, tiltY: tiltY)
            }
        }
        .onDisappear {
            motionManager.stopAccelerometerUpdates()
        }
    }
    
    // MARK: - Motion
    
    private func startMotionUpdates() {
        guard !reduceMotion, motionManager.isAccelerometerAvailable else { return }
        motionManager.accelerometerUpdateInterval = 1.0 / 10.0
        motionManager.startAccelerometerUpdates(to: .main) { data, _ in
            guard let data = data else { return }
            // Smooth the tilt values to avoid jitter
            tiltX = tiltX * 0.7 + CGFloat(data.acceleration.x) * 0.3
            tiltY = tiltY * 0.7 + CGFloat(data.acceleration.y) * 0.3
        }
    }
}

// MARK: - Preview

#Preview("Full") {
    WaterSimView(progress: 0.85)
        .frame(width: 300, height: 400)
        .preferredColorScheme(.dark)
}

#Preview("Half") {
    WaterSimView(progress: 0.5)
        .frame(width: 300, height: 400)
        .preferredColorScheme(.dark)
}

#Preview("Low") {
    WaterSimView(progress: 0.2)
        .frame(width: 300, height: 400)
        .preferredColorScheme(.dark)
}
