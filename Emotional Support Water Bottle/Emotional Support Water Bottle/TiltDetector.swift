//
//  TiltDetector.swift
//  Emotional Support Water Bottle
//
//  Detects a "drinking tilt" gesture via accelerometer.
//  When the phone is tilted forward (top down) for ~1.5s,
//  triggers a callback to log a sip.
//

import CoreMotion
import Observation
import UIKit

@Observable
class TiltDetector {

    var onTiltDetected: (() -> Void)?

    private let motionManager = CMMotionManager()
    private var tiltStartTime: Date?
    private var lastTriggerTime: Date?
    private let sustainDuration: TimeInterval = 1.5
    private let cooldownDuration: TimeInterval = 3.0

    private(set) var isMonitoring = false

    func start() {
        guard !isMonitoring else { return }
        guard motionManager.isAccelerometerAvailable else { return }
        guard !UIAccessibility.isReduceMotionEnabled else { return }

        isMonitoring = true
        motionManager.accelerometerUpdateInterval = 0.1

        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            guard let self, let data else { return }
            self.processAcceleration(data.acceleration)
        }
    }

    func stop() {
        guard isMonitoring else { return }
        motionManager.stopAccelerometerUpdates()
        isMonitoring = false
        tiltStartTime = nil
    }

    private func processAcceleration(_ acceleration: CMAcceleration) {
        let isTilted = acceleration.y < -0.5 && acceleration.z > 0.5

        if isTilted {
            if tiltStartTime == nil {
                tiltStartTime = Date()
            }

            guard let start = tiltStartTime,
                  Date().timeIntervalSince(start) >= sustainDuration else { return }

            // Check cooldown
            if let last = lastTriggerTime,
               Date().timeIntervalSince(last) < cooldownDuration {
                return
            }

            lastTriggerTime = Date()
            tiltStartTime = nil
            onTiltDetected?()
        } else {
            tiltStartTime = nil
        }
    }
}
