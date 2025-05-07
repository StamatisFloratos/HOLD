//
//  HapticManager.swift
//  HOLD
//
//  Created by Hafiz Muhammad Ali on 04/05/2025.
//

import Foundation
import CoreHaptics
import QuartzCore

class HapticManager {
    private var engine: CHHapticEngine?
    private var activePlayer: CHHapticAdvancedPatternPlayer?
    private var pausedTime: TimeInterval = 0
    private var startTime: TimeInterval = 0
    private var totalDuration: Double = 0
    private var startIntensity: Float = 0
    private var endIntensity: Float = 0
    private var isPlaying: Bool = false
    private var currentStartTime: TimeInterval = 0

    init() {
        createEngine()
    }

    private func createEngine() {
        do {
            engine = try CHHapticEngine()
            
            // Handle engine stopping
            engine?.stoppedHandler = { [weak self] reason in
                self?.isPlaying = false
                print("Haptic engine stopped: \(reason)")
                self?.createEngine()
            }
            
            // Handle engine reset
            engine?.resetHandler = { [weak self] in
                print("Haptic engine reset")
                do {
                    try self?.engine?.start()
                } catch {
                    print("Failed to restart haptic engine: \(error)")
                }
                
                // If we had an active pattern, restart it
                if self?.isPlaying == true {
                    self?.playRampUpHaptic(duration: self?.totalDuration ?? 0,
                                          from: self?.startIntensity ?? 0.1,
                                          to: self?.endIntensity ?? 1.0)
                }
            }
            
            try engine?.start()
        } catch {
            print("Haptic Engine Start Error: \(error)")
        }
    }

    /// Plays a continuous haptic that ramps up in intensity over a duration
    func playRampUpHaptic(duration: Double, from startIntensity: Float = 0.1, to endIntensity: Float = 1.0) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        // Stop any existing haptics first
        stopHaptic()
        
        // Store parameters for potential resume
        self.totalDuration = duration
        self.startIntensity = startIntensity
        self.endIntensity = endIntensity
        self.startTime = CACurrentMediaTime()
        self.currentStartTime = self.startTime
        self.pausedTime = 0
        
        // Create sharpness parameter - adjust for different exercise types
        let sharpness: Float = startIntensity < endIntensity ? 0.5 : 0.3 // Lower sharpness for relaxation
        let sharpnessParam = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)

        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [sharpnessParam],
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
            
            // Create an advanced player for control functionality
            self.activePlayer = try engine?.makeAdvancedPlayer(with: pattern)
            
            // Set completion handler
            self.activePlayer?.completionHandler = { [weak self] _ in
                self?.isPlaying = false
                self?.activePlayer = nil
            }
            
            try self.activePlayer?.start(atTime: 0)
            self.isPlaying = true
        } catch {
            print("Haptic pattern error: \(error)")
        }
    }
    
    /// Pauses the ongoing haptic feedback
    func pauseHaptic() {
        guard isPlaying, let player = activePlayer else { return }
        
        do {
            // Calculate how much time has elapsed since our current start time
            let elapsedTime = CACurrentMediaTime() - currentStartTime
            pausedTime = elapsedTime
            
            // Pause the player
            try player.stop(atTime: 0)
            isPlaying = false
        } catch {
            print("Failed to pause haptic: \(error)")
        }
    }
    
    /// Resumes haptic feedback from where it was paused
    func resumeHaptic() {
        guard !isPlaying, pausedTime > 0, pausedTime < totalDuration else {
            // If we can't resume properly, just start a new one with default settings
            if totalDuration > 0 {
                playRampUpHaptic(duration: totalDuration, from: startIntensity, to: endIntensity)
            }
            return
        }
        
        // Calculate remaining duration
        let remainingDuration = totalDuration - pausedTime
        
        // Calculate intensity at pause point - linear interpolation
        let progressAtPause = pausedTime / totalDuration
        let intensityAtPause = startIntensity + Float(progressAtPause) * (endIntensity - startIntensity)
        
        // Create sharpness parameter - adjust for different phases
        let sharpness: Float = startIntensity < endIntensity ? 0.5 : 0.3 // Lower sharpness for relaxation
        let sharpnessParam = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)

        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [sharpnessParam],
            relativeTime: 0,
            duration: remainingDuration
        )

        let ramp = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: [
                CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: intensityAtPause),
                CHHapticParameterCurve.ControlPoint(relativeTime: remainingDuration, value: endIntensity)
            ],
            relativeTime: 0
        )

        do {
            let pattern = try CHHapticPattern(events: [event], parameterCurves: [ramp])
            
            // Create a new player for the remaining pattern
            self.activePlayer = try engine?.makeAdvancedPlayer(with: pattern)
            
            // Set completion handler
            self.activePlayer?.completionHandler = { [weak self] _ in
                self?.isPlaying = false
                self?.activePlayer = nil
            }
            
            try self.activePlayer?.start(atTime: 0)
            self.currentStartTime = CACurrentMediaTime() // Update current start time for tracking
            self.isPlaying = true
        } catch {
            print("Haptic resume error: \(error)")
        }
    }
    
    /// Stops any ongoing haptic feedback
    func stopHaptic() {
        guard let player = activePlayer else { return }
        
        do {
            try player.stop(atTime: 0)
            isPlaying = false
            activePlayer = nil
            pausedTime = 0
        } catch {
            print("Failed to stop haptic: \(error)")
        }
    }
}
