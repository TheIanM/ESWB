//
//  WaterSimView.swift
//  Emotional Support Water Bottle
//
//  Water bottle simulation with metaball surface.
//  Static gradient fill for the body, metaball blobs only along the
//  top edge for organic sloshing. Much more performant than filling
//  the whole bottle with blobs.
//
//  Tilt: Uses CoreMotion on device, drag gesture as fallback
//  (and for simulator / accessibility).
//

import SwiftUI
import CoreMotion

struct WaterSimView: View {
    let progress: Double   // 0.0–1.0, how full the bottle is
    
    @State private var blobs: [WaterBlob] = []
    @State private var isInitialized = false
    @State private var tiltX: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    private let motionManager = CMMotionManager()
    
    // Colors
    private let waterColor = Color(red: 0.25, green: 0.72, blue: 0.97)
    private let waterColorDeep = Color(red: 0.12, green: 0.48, blue: 0.82)
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0 / 24.0)) { timeline in
            Canvas { context, size in
                guard progress > 0.01 else { return }
                
                let waterHeight = size.height * CGFloat(min(progress, 1.0))
                let waterTop = size.height - waterHeight
                
                // 1) Static water body — gradient fill (cheap)
                let bodyRect = CGRect(x: 0, y: waterTop, width: size.width, height: waterHeight)
                context.fill(
                    Rectangle().path(in: bodyRect),
                    with: .linearGradient(
                        Gradient(colors: [waterColor, waterColorDeep]),
                        startPoint: CGPoint(x: size.width / 2, y: waterTop),
                        endPoint: CGPoint(x: size.width / 2, y: size.height)
                    )
                )
                
                // 2) Metaball surface blobs along the water line
                var blobCtx = context
                blobCtx.addFilter(.alphaThreshold(min: 0.45, color: waterColor))
                blobCtx.addFilter(.blur(radius: 14))
                
                blobCtx.drawLayer { layer in
                    for blob in blobs {
                        let r = blob.currentRadius
                        layer.fill(
                            Circle().path(in: CGRect(
                                x: blob.x - r,
                                y: blob.y - r,
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
        .clipShape(Circle())
        // Drag to slosh (only activates for real drags, taps pass through)
        .simultaneousGesture(
            reduceMotion ? nil :
            DragGesture(minimumDistance: 20)
                .onChanged { value in
                    tiltX = tiltX * 0.5 + CGFloat(value.translation.width) * 0.02
                }
        )
        .onAppear {
            guard !isInitialized else { return }
            blobs = WaterBlob.makeSurfaceBlobs(
                count: 4,
                boundsSize: CGSize(width: 300, height: 300)
            )
            isInitialized = true
            startMotionUpdates()
        }
        .task {
            let bounds = CGSize(width: 300, height: 300)
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1.0 / 24.0))
                guard isInitialized else { continue }
                WaterBlob.stepSurfaceBlobs(&blobs, boundsSize: bounds, tiltX: tiltX, waterLevel: progress)
            }
        }
        .onDisappear {
            #if !targetEnvironment(simulator)
            motionManager.stopAccelerometerUpdates()
            #endif
        }
    }
    
    private func startMotionUpdates() {
        #if targetEnvironment(simulator)
        return
        #else
        guard !reduceMotion, motionManager.isAccelerometerAvailable else { return }
        motionManager.accelerometerUpdateInterval = 1.0 / 10.0
        motionManager.startAccelerometerUpdates(to: .main) { data, _ in
            guard let data = data else { return }
            tiltX = tiltX * 0.7 + CGFloat(data.acceleration.x) * 0.3
        }
        #endif
    }
}

// MARK: - Preview

#Preview("Full") {
    WaterSimView(progress: 0.85)
        .frame(width: 250, height: 350)
        .preferredColorScheme(.dark)
}

#Preview("Half") {
    WaterSimView(progress: 0.5)
        .frame(width: 250, height: 350)
        .preferredColorScheme(.dark)
}

#Preview("Low") {
    WaterSimView(progress: 0.2)
        .frame(width: 250, height: 350)
        .preferredColorScheme(.dark)
}
