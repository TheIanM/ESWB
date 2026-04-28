//
//  WaterBlob.swift
//  Emotional Support Water Bottle
//
//  Model for a single metaball blob in the water simulation.
//  Adapted from SlimeTheme.swift's SlimeBlob physics.
//

import Foundation

struct WaterBlob {
    var x: CGFloat            // offset from center
    var y: CGFloat            // offset from center
    var baseRadius: CGFloat
    var currentRadius: CGFloat
    var vx: CGFloat
    var vy: CGFloat
    var breathingPhase: CGFloat
    var breathingSpeed: CGFloat
    
    static func makeBlobs(count: Int, boundsSize: CGSize, baseRadiusRange: ClosedRange<CGFloat>) -> [WaterBlob] {
        let scale = min(boundsSize.width, boundsSize.height) / 400.0
        return (0..<count).map { i in
            let angle = CGFloat(i) * (2 * .pi / CGFloat(count)) + CGFloat.random(in: -0.5...0.5)
            let distance = CGFloat.random(in: 0...20)
            let baseR = CGFloat.random(in: baseRadiusRange) * scale
            return WaterBlob(
                x: cos(angle) * distance,
                y: sin(angle) * distance,
                baseRadius: baseR,
                currentRadius: baseR,
                vx: CGFloat.random(in: -0.3...0.3),
                vy: CGFloat.random(in: -0.3...0.3),
                breathingPhase: CGFloat.random(in: 0...(2 * .pi)),
                breathingSpeed: 0.012 + CGFloat.random(in: 0...0.02)
            )
        }
    }
    
    /// Advance blob physics one frame
    static func stepBlobs(_ blobs: inout [WaterBlob], boundsSize: CGSize, tiltX: CGFloat, tiltY: CGFloat) {
        let center = CGPoint(x: boundsSize.width / 2, y: boundsSize.height / 2)
        let boundsScale: CGFloat = 0.45
        
        for i in blobs.indices {
            // Breathing animation
            blobs[i].breathingPhase += blobs[i].breathingSpeed * 2.5
            let breathOffset = sin(blobs[i].breathingPhase) * 4
            blobs[i].currentRadius = blobs[i].baseRadius + breathOffset
            
            // Tilt influence — accelerometer shifts blobs in tilt direction
            blobs[i].vx += tiltX * 0.15
            blobs[i].vy += tiltY * 0.15
            
            // Gentle drift
            blobs[i].x += sin(blobs[i].breathingPhase) * 0.35
            blobs[i].y += cos(blobs[i].breathingPhase * 0.7) * 0.3
            
            // Apply velocity
            blobs[i].x += blobs[i].vx
            blobs[i].y += blobs[i].vy
            
            // Bounds clamping
            let halfW = center.x * boundsScale
            let halfH = center.y * boundsScale
            let r = blobs[i].currentRadius * 0.8
            
            if abs(blobs[i].x) + r > halfW {
                blobs[i].vx *= -0.5
                blobs[i].x = blobs[i].x > 0 ? halfW - r : -(halfW - r)
            }
            if abs(blobs[i].y) + r > halfH {
                blobs[i].vy *= -0.5
                blobs[i].y = blobs[i].y > 0 ? halfH - r : -(halfH - r)
            }
            
            // Damping
            blobs[i].vx *= 0.96
            blobs[i].vy *= 0.96
        }
    }
}