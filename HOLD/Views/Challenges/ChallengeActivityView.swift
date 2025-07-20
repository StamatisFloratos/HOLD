//
//  ChallengeActivityView.swift
//  HOLD
//
//  Created by Rabbia Ijaz on 22/04/2025.
//

import SwiftUI
import UIKit

// Helper extension for safe array access (Place outside struct or in an Extensions file)
extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct ChallengeActivityView: View {
    @State private var hold = false
    @State private var holdTime: Int = 0
    @State private var timer: Timer? = nil
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var challengeViewModel: ChallengeViewModel
    var onBack: (TimeInterval) -> Void

    // Animation states from RhythmicBallView
    @State private var ballPosition: CGFloat = 0
    @State private var previousPositions: [CGFloat] = []
    @State private var animationTimer: Timer? = nil
    
    // Animation settings
    let ballSize: CGFloat = 60
    let barWidth: CGFloat = 60
    let barHeight: CGFloat = 250
    let animationSpeed: Double = 0.01
    let trailLength: Int = 20
    let trailFadeRate: Double = 0.85
    
    // --- Phase Configuration ---
    // Durations for the FIRST loop only
    let phaseTotalDurations: [TimeInterval] = [5, 10, 3, 7]
    // Toggle interval (speed) for each phase (used in ALL loops)
    let phaseToggleIntervals: [TimeInterval] = [3.0, 2.3, 1.8, 1.0]
    // Color for each phase (used in ALL loops)
    let phaseColors: [Color] = [
        Color(hex: "#95FF00"), // Phase 1 (Bright Green)
        Color(hex: "#FFDD00"), // Phase 2 (Yellow)
        Color(hex: "#FF7300"), // Phase 3 (Orange)
        Color(hex: "#FF0000")  // Phase 4 (Red)
    ]
    
    // --- State Variables ---
    @State private var currentPhaseIndex = 0
    @State private var phaseTimer: Timer? = nil // Times the duration of the current phase
    @State private var toggleTimer: Timer? = nil // Toggles the ball direction
    @State private var isFirstLoop = true          // Tracks if it's the initial loop
    @State private var totalElapsedTime: TimeInterval = 0.0 // Total time
    @State private var challengeTimer: Timer? = nil // Timer for total time
    @State private var direction: CGFloat = 1 // Direction for the sine wave animation
    @State private var time: CGFloat = 0 // Time parameter for the sine wave
    
    // --- Computed Properties for Current Phase ---
    private var currentPhaseColor: Color {
        phaseColors[safe: currentPhaseIndex] ?? phaseColors[0]
    }

    private var currentToggleInterval: TimeInterval {
        phaseToggleIntervals[safe: currentPhaseIndex] ?? phaseToggleIntervals[0]
    }

    private var currentPhaseTotalDuration: TimeInterval {
        // Safely access duration, default to first
        phaseTotalDurations[safe: currentPhaseIndex] ?? phaseTotalDurations[0]
    }

    // --- Add Completion Handler ---
    // This closure will be called when the view is dismissed via "Stop"
    var onComplete: ((_ elapsedTime: TimeInterval) -> Void)? = nil // Optional closure

    var body: some View {
        ZStack {
            // Background gradient with specified hex colors
            AppBackground()
            
            VStack(spacing: 0) {
                // Logo at the top
                HStack {
                    Spacer()
                    Image("holdIcon")
                    Spacer()
                }
                .padding(.top, 24)
                .padding(.bottom, 14)
                
                Text("Follow the Rhythm")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .padding(.top, 100)
                
                Spacer()
                
                // --- New Rhythmic Ball Animation centered on screen ---
                HStack {
                    Spacer() // Push animation to center
                    
                    ZStack {
                        // Container for visualization
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: barWidth, height: barHeight)
                        
                        // Trail segments - using previous positions for trail effect
                        ForEach(0..<min(previousPositions.count, trailLength), id: \.self) { index in
                            let opacity = 0.2 * pow(trailFadeRate, Double(index))
                            let size = ballSize * CGFloat(1.0 - (Double(index) / Double(trailLength)) * 0.5)
                            
                            Capsule()
                                .fill(currentPhaseColor.opacity(opacity))
                                .frame(width: barWidth, height: size)
                                .position(x: barWidth/2, y: previousPositions[index])
                        }
                        
                        // Main ball
                        Circle()
                            .fill(currentPhaseColor)
                            .frame(width: ballSize, height: ballSize)
                            .position(x: barWidth/2, y: ballPosition)
                    }
                    .frame(width: barWidth, height: barHeight)
                    .clipped()
                    
                    Spacer() // Push animation to center
                }
                
                Spacer()
                
                Button(action: {
                    triggerHapticForButton()
                    stopChallenge() // This now stops timers AND calls onComplete
                    onBack(totalElapsedTime)
                }) {
                    Text("Stop")
                        .font(.system(size: 16, weight: .semibold))
                        .padding()
                        .frame(maxWidth: .infinity,maxHeight: 47)
                        .background(Color(hex: "#FF5E00"))
                        .foregroundColor(.white)
                        .cornerRadius(30)
                }
                .padding(.horizontal, 50)
                .padding(.bottom, 15)
                
            }
        }
        .navigationBarHidden(true)
        .onAppear(perform: startChallenge) // Start the sequence on appear
        .onDisappear(perform: stopChallenge) // Clean up timers on disappear
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    // --- Animation Functions from RhythmicBallView ---
    
    private func startBallAnimation(preservePosition: Bool = false) {
        // Stop existing animation timer if any
        stopBallAnimation()
        
        // Initialize position only if not preserving
        if !preservePosition {
            // Initial position in the middle of the container
            ballPosition = barHeight / 2
            time = 0
            direction = 1
            previousPositions = [] // Clear previous positions
        }
        
        let amplitude: CGFloat = barHeight / 2 - ballSize / 2
        
        // Create timer for smooth animation with current phase's speed
        let adjustedSpeed = animationSpeed // Base animation speed
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: adjustedSpeed, repeats: true) { _ in
            // Store previous position for trail effect
            previousPositions.insert(ballPosition, at: 0)
            if previousPositions.count > trailLength {
                previousPositions.removeLast()
            }
            
            // Calculate new position with sine wave
            let newPosition = barHeight / 2 - amplitude * sin(time)
            
            // Only trigger haptic if we're near end points (bouncing)
            let positionThreshold: CGFloat = 5.0
            let oldPosition = ballPosition
            ballPosition = newPosition
            
            // Check if we've crossed a threshold for haptic feedback
            if (oldPosition < barHeight / 2 - amplitude + positionThreshold && newPosition >= barHeight / 2 - amplitude + positionThreshold) ||
               (oldPosition > barHeight / 2 + amplitude - positionThreshold && newPosition <= barHeight / 2 + amplitude - positionThreshold) {
                triggerHaptic()
            }
            
            // Update time for next frame - adjusted by current phase speed
            let speedMultiplier = getSpeedMultiplierForCurrentPhase()
            time += 0.05 * direction * speedMultiplier
            
            // Check for direction change based on actual position
            if newPosition <= ballSize / 2 || newPosition >= barHeight - ballSize / 2 {
                direction *= -1
            }
        }
    }
    
    private func stopBallAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    // Helper function to adjust animation speed based on current phase
    private func getSpeedMultiplierForCurrentPhase() -> CGFloat {
        // Convert toggle interval to speed multiplier - faster toggle interval means higher speed
        // Base speed (1.7s) = 1.0x multiplier
        let baseInterval: CGFloat = 1.7
        let currentInterval = CGFloat(phaseToggleIntervals[safe: currentPhaseIndex] ?? baseInterval)
        
        // Invert the relationship - smaller interval = faster animation
        return baseInterval / currentInterval // e.g. 1.7/0.5 = 3.4x faster
    }

    // --- Timer Management Functions ---

    private func startChallenge() {
        // Reset state fully
        currentPhaseIndex = 0
        isFirstLoop = true
        totalElapsedTime = 0.0 // Reset elapsed time
        previousPositions = [] // Clear previous positions

        // Start the Challenge Timer (Total Time)
        challengeTimer?.invalidate() // Ensure previous is stopped
        challengeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            totalElapsedTime += 0.1
        }

        print("Starting Challenge, Total Timer Running, First Loop, Phase \(currentPhaseIndex + 1)")
        startTimersForCurrentPhase()
    }

    private func stopChallenge() {
        print("Stopping Challenge. Total Elapsed Time: \(String(format: "%.1f", totalElapsedTime))s")
        // Stop all timers
        challengeTimer?.invalidate()
        phaseTimer?.invalidate()
        stopBallAnimation() // Stop the animation timer too
        
        challengeTimer = nil
        phaseTimer = nil
        
        // Call completion handler with the final time
        onComplete?(totalElapsedTime)
    }
    
    private func startTimersForCurrentPhase() {
        // Stop only the phase timer but not the animation timer
        phaseTimer?.invalidate()
        
        // Safely get config for current phase
        guard let toggleInterval = phaseToggleIntervals[safe: currentPhaseIndex],
              let firstLoopDuration = phaseTotalDurations[safe: currentPhaseIndex] else {
            print("Error: Invalid phase index (\(currentPhaseIndex)). Stopping.")
            stopChallenge()
            return
        }
        
        // Determine Phase Duration
        let phaseDuration: TimeInterval
        if isFirstLoop {
            phaseDuration = firstLoopDuration
            print("Phase \(currentPhaseIndex + 1) (First Loop): Toggle=\(toggleInterval)s, Duration=\(phaseDuration)s")
        } else {
            phaseDuration = TimeInterval.random(in: 5...10) // Random duration for subsequent loops
            print("Phase \(currentPhaseIndex + 1) (Loop >1): Toggle=\(toggleInterval)s, Duration=\(phaseDuration)s (Random)")
        }
        
        // If animation timer is nil (first run), start the animation
        // Otherwise, the animation continues with new color
        if animationTimer == nil {
            startBallAnimation(preservePosition: false)
        }
        
        // Start the Phase Timer (Fires once when phase duration is up)
        phaseTimer = Timer.scheduledTimer(withTimeInterval: phaseDuration, repeats: false) { _ in
            print("Phase \(self.currentPhaseIndex + 1) finished (Duration: \(phaseDuration)s).")
            self.advanceToNextPhase()
        }
    }

    private func advanceToNextPhase() {
        var nextPhaseIndex = currentPhaseIndex + 1
        
        // Check if loop completed
        if nextPhaseIndex >= phaseColors.count { // Use count of colors/speeds
            print("Loop completed. Starting next loop.")
            nextPhaseIndex = 0     // Reset index to loop
            isFirstLoop = false  // Mark subsequent loops as not the first
        }
        
        // Move to next phase
        currentPhaseIndex = nextPhaseIndex
        print("Advancing to Phase \(currentPhaseIndex + 1)")
        startTimersForCurrentPhase() // Start timers for the new/looped phase without stopping animation
    }
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func triggerHapticForButton() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}

#Preview {
    ChallengeActivityView(onBack: { _ in
        //
    })
}

