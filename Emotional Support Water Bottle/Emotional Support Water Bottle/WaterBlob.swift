//
//  WaterBlob.swift
//  Emotional Support Water Bottle
//
//  Model for a single metaball blob in the water simulation.
//  Adapted from SlimeTheme.swift's SlimeBlob physics.
//  Blobs are positioned in absolute coordinates and clamped
//  to the water region (lower portion of the bottle based on fill level).
//

import Foundation

struct WaterBlob {
    var x: CGFloat            // absolute position
    var y: CGFloat            // absolute position
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
            // Start blobs centered in the lower portion of the view
            let cx = boundsSize.width / 2
            let cy = boundsSize.height * 0.7  // lower third
            return WaterBlob(
                x: cx + cos(angle) * distance,
                y: cy + sin(angle) * distance,
                baseRadius: baseR,
                currentRadius: baseR,
                vx: CGFloat.random(in: -0.3...0.3),
                vy: CGFloat.random(in: -0.3...0.3),
                breathingPhase: CGFloat.random(in: 0...(2 * .pi)),
                breathingSpeed: 0.012 + CGFloat.random(in: 0...0.02)
            )
        }
    }
    
    /// Advance blob physics one frame.
    /// Blobs are constrained to the water region: the lower portion
    /// of the view proportional to `waterLevel` (0.0–1.0).
    static func stepBlobs(_ blobs: inout [WaterBlob], boundsSize: CGSize, tiltX: CGFloat, tiltY: CGFloat, waterLevel: Double) {
        let cx = boundsSize.width / 2
        
        // The water region: from waterTop to bottom
        let waterHeight = boundsSize.height * CGFloat(min(waterLevel, 1.0))
        let waterTop = boundsSize.height - waterHeight
        let waterBottom = boundsSize.height - 10  // small padding
        
        // Horizontal bounds (roughly the bottle body width)
        let halfW = boundsSize.width * 0.35
        
        for i in blobs.indices {
            // Breathing animation
            blobs[i].breathingPhase += blobs[i].breathingSpeed * 2.5
            let breathOffset = sin(blobs[i].breathingPhase) * 4
            blobs[i].currentRadius = blobs[i].baseRadius + breathOffset
            
            // Tilt influence
            blobs[i].vx += tiltX * 0.15
            blobs[i].vy += tiltY * 0.15
            
            // Gentle drift
            blobs[i].x += sin(blobs[i].breathingPhase) * 0.35
            blobs[i].y += cos(blobs[i].breathingPhase * 0.7) * 0.3
            
            // Apply velocity
            blobs[i].x += blobs[i].vx
            blobs[i].y += blobs[i].vy
            
            // Clamp to water region
            let r = blobs[i].currentRadius * 0.8
            
            // Horizontal bounds
            if blobs[i].x - r < cx - halfW {
                blobs[i].vx *= -0.5
                blobs[i].x = cx - halfW + r
            }
            if blobs[i].x + r > cx + halfW {
                blobs[i].vx *= -0.5
                blobs[i].x = cx + halfW - r
            }
            
            // Vertical: keep within water region
            if blobs[i].y - r < waterTop {
                blobs[i].vy *= -0.5
                blobs[i].y = waterTop + r
            }
            if blobs[i].y + r > waterBottom {
                blobs[i].vy *= -0.5
                blobs[i].y = waterBottom - r
            }
            
            // Damping
            blobs[i].vx *= 0.96
            blobs[i].vy *= 0.96
        }
    }
    
    // MARK: - Surface Blobs
    
    /// Create blobs positioned along the water surface (top edge).
    /// These create the organic sloshing effect while the water body
    /// below is just a static fill.
    static func makeSurfaceBlobs(count: Int, boundsSize: CGSize) -> [WaterBlob] {
        let cx = boundsSize.width / 2
        // Start near the top — water begins full, so surface is near top of circle
        let waterLine = boundsSize.height * 0.05
        let spread = boundsSize.width * 0.6
        
        return (0..<count).map { i in
            let fraction = CGFloat(i) / CGFloat(count - 1)  // 0...1 evenly spaced
            let x = cx - spread / 2 + fraction * spread
            let baseR: CGFloat = CGFloat.random(in: 35...55)
            return WaterBlob(
                x: x,
                y: waterLine + CGFloat.random(in: -5...10),
                baseRadius: baseR,
                currentRadius: baseR,
                vx: CGFloat.random(in: -0.2...0.2),
                vy: CGFloat.random(in: -0.1...0.1),
                breathingPhase: CGFloat.random(in: 0...(2 * .pi)),
                breathingSpeed: 0.015 + CGFloat.random(in: 0...0.015)
            )
        }
    }
    
    /// Step surface blobs — they live along the water line and slosh horizontally.
    /// Only horizontal tilt matters for surface sloshing.
    static func stepSurfaceBlobs(_ blobs: inout [WaterBlob], boundsSize: CGSize, tiltX: CGFloat, waterLevel: Double) {
        let cx = boundsSize.width / 2
        
        // Water line Y position (top of the water)
        let waterHeight = boundsSize.height * CGFloat(min(waterLevel, 1.0))
        let waterLine = boundsSize.height - waterHeight
        
        // Horizontal bounds for the bottle body
        let halfW = boundsSize.width * 0.35
        
        for i in blobs.indices {
            // Breathing
            blobs[i].breathingPhase += blobs[i].breathingSpeed * 2.5
            let breathOffset = sin(blobs[i].breathingPhase) * 3
            blobs[i].currentRadius = blobs[i].baseRadius + breathOffset
            
            // Tilt sloshes horizontally
            blobs[i].vx += tiltX * 0.2
            
            // Gentle wave drift
            blobs[i].x += sin(blobs[i].breathingPhase) * 0.4
            
            // Apply velocity
            blobs[i].x += blobs[i].vx
            blobs[i].y += blobs[i].vy
            
            // Keep Y pinned to the water line (with small oscillation)
            blobs[i].y = waterLine + sin(blobs[i].breathingPhase * 0.8) * 3
            
            // Horizontal bounds
            let r = blobs[i].currentRadius * 0.6
            if blobs[i].x - r < cx - halfW {
                blobs[i].vx *= -0.5
                blobs[i].x = cx - halfW + r
            }
            if blobs[i].x + r > cx + halfW {
                blobs[i].vx *= -0.5
                blobs[i].x = cx + halfW - r
            }
            
            // Damping
            blobs[i].vx *= 0.95
            blobs[i].vy *= 0.90
        }
    }
}
