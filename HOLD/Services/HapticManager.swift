//
//  HapticManager.swift
//  HOLD
//
//  Created by Hafiz Muhammad Ali on 04/05/2025.
//

import Foundation
import CoreHaptics

class HapticManager {
    private var engine: CHHapticEngine?

    init() {
        createEngine()
    }

    private func createEngine() {
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptic Engine Start Error: \(error)")
        }
    }

    /// Plays a continuous haptic that ramps up in intensity over a duration
    func playRampUpHaptic(duration: Double, from startIntensity: Float = 0.1, to endIntensity: Float = 1.0) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)

        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [sharpness],
            relativeTime: 0,
            duration: duration
        )

        let ramp = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: [
                CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: startIntensity),
                CHHapticParameterCurve.ControlPoint(relativeTime: duration, value: endIntensity)
            ],
            relativeTime: 0
        )

        do {
            let pattern = try CHHapticPattern(events: [event], parameterCurves: [ramp])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Haptic pattern error: \(error)")
        }
    }
}
