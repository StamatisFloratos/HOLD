//
//  ChallengeActivityView.swift
//  HOLD
//
//  Created by Rabbia Ijaz on 22/04/2025.
//

import SwiftUI

// Helper extension for safe array access (Place outside struct or in an Extensions file)
extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct ChallengeActivityView: View {
    @State private var hold = false
    @State private var finish = false
    @State private var holdTime: Int = 0
    @State private var timer: Timer? = nil
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var viewModel: ProgressViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingChallengeResultView = false

    
    // State for the animation
    @State private var isBallUp = false
    @State private var animationTimer: Timer? = nil
    // Define the gradient colors
        let lightGreen = Color(hex: "#7FFF00") // Bright green
        let trailEndColor = Color.clear       // Fade trail to transparent
    
    // Constants for styling/layout
    let barWidth: CGFloat = 40
    let barHeight: CGFloat = 250
    let ballDiameter: CGFloat = 40 // Should match barWidth for cylinder top
    let animationDuration: TimeInterval = 0.8
    
    // --- Phase Configuration ---
    // Durations for the FIRST loop only
    let phaseTotalDurations: [TimeInterval] = [5, 7, 7, 7]
    // Toggle interval (speed) for each phase (used in ALL loops)
    let phaseToggleIntervals: [TimeInterval] = [1.7, 1.3, 0.8, 0.5]
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
    @State private var toggleTimer: Timer? = nil // Toggles the ball up/down
    @State private var isFirstLoop = true          // Tracks if it's the initial loop
    @State private var totalElapsedTime: TimeInterval = 0.0 // <<< Add state for total time
    @State private var challengeTimer: Timer? = nil // <<< Add timer for total time
    
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
            LinearGradient(
                colors: [
                    Color(hex:"#10171F"),
                    Color(hex:"#466085")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            
            VStack(spacing: 0) {
                // Logo at the top
                HStack {
                    Spacer()
                    Image("holdIcon")
                    Spacer()
                }
                .padding(.top, 40)
                
                Spacer()
                
                if !finish {
                    Text("Follow the Rhythm")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .frame(height: 100)
                        .padding(.bottom, 60)
                    
                    // --- Animation Element ---
                    ZStack {
                        // --- Trail Gradient - Uses currentPhaseColor ---
                        LinearGradient(
                            gradient: Gradient(colors: [currentPhaseColor, trailEndColor]), // Dynamic color
                            startPoint: isBallUp ? .top : .bottom,
                            endPoint: isBallUp ? .bottom : .top
                        )
                        .clipShape(Capsule())
                        .frame(width: barWidth, height: barHeight)
                        // Animate gradient change with currentToggleInterval
                        .animation(.easeInOut(duration: currentToggleInterval), value: isBallUp)
                        
                        
                        // --- Moving Ball - Uses currentPhaseColor ---
                        Circle()
                            .fill(currentPhaseColor) // Dynamic color
                            .frame(width: ballDiameter, height: ballDiameter)
                            .offset(y: isBallUp ? -(barHeight / 2) + (ballDiameter / 2) : (barHeight / 2) - (ballDiameter / 2))
                        // Animate position change with currentToggleInterval
                            .animation(.easeInOut(duration: currentToggleInterval), value: isBallUp)
                        
                    } // End ZStack for Animation
                    .frame(height: barHeight)
                    .padding(.bottom, 60)
                    // --- End Animation Element ---
                    
                    Spacer()
                    
                    Button(action: {
                        stopChallenge() // This now stops timers AND calls onComplete
                        finish = true
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
                else {
                    VStack(spacing: 10) {
                        Spacer()
                        let result = ChallengeResult(duration: totalElapsedTime)
                        Text("You lasted for:")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.top,6)
                        Text(result.durationDisplay)
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.top,6)
                        Spacer()
                        Text("You Are in The Top:")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.top)
                        
                        
                        Text(result.percentileDisplay)
                            .font(.system(size: 64, weight: .semibold))
                            .foregroundStyle(LinearGradient(
                                colors: [
                                    Color(hex:"#16D700"),
                                    Color(hex:"#0B7100")
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ))
                            .padding(.top,19)
                        
                        Text("of Men Globally")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)

                        Spacer()
                        Text("😧 That's really impressive! ")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.top,6)
                        Spacer()
                        Button(action: {
                            showingChallengeResultView = true
                        }) {
                            Text("Continue")
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
            }
            
            
        }
        .navigationBarHidden(true)
        .onAppear(perform: startChallenge) // Start the sequence on appear
        .onDisappear(perform: stopChallenge) // Clean up timers on disappear
        .fullScreenCover(isPresented: $showingChallengeResultView,
                         onDismiss: {
            print("ChallengeActivityView dismissed, now dismissing ChallengeSheetView.")
            self.presentationMode.wrappedValue.dismiss()
        }) {
            ChallengeRankView(challengeResult: ChallengeResult(duration: totalElapsedTime))
        }
    }
    
    private func startAnimationTimer() {
        stopAnimationTimer()
        animationTimer = Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: true) { _ in
            self.isBallUp.toggle()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if animationTimer != nil {
                self.isBallUp.toggle()
            }
        }
    }
    
    private func stopAnimationTimer() {
        animationTimer?.invalidate()
        animationTimer = nil
        print("Animation timer stopped.")
    }

    // --- Timer Management Functions ---

    private func startChallenge() {
        // Reset state fully
        currentPhaseIndex = 0
        isBallUp = false
        isFirstLoop = true
        totalElapsedTime = 0.0 // <<< Reset elapsed time

        // --- Start the Challenge Timer (Total Time) ---
        challengeTimer?.invalidate() // Ensure previous is stopped
        challengeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            totalElapsedTime += 0.1
        }
        // --- End Start Challenge Timer ---

        print("Starting Challenge, Total Timer Running, First Loop, Phase \(currentPhaseIndex + 1)")
        startTimersForCurrentPhase()
    }

    private func stopChallenge() {
        print("Stopping Challenge. Total Elapsed Time: \(String(format: "%.1f", totalElapsedTime))s")
        // Stop all timers
        challengeTimer?.invalidate()
        phaseTimer?.invalidate()
        toggleTimer?.invalidate()
        challengeTimer = nil
        phaseTimer = nil
        toggleTimer = nil

        // Call completion handler with the final time
        onComplete?(totalElapsedTime) // <<< This passes the time back
    }

    private func startTimersForCurrentPhase() {
        // Stop existing timers before starting new ones
        phaseTimer?.invalidate()
        toggleTimer?.invalidate()

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

        // 1. Start the Toggle Timer (Repeats to move ball)
        toggleTimer = Timer.scheduledTimer(withTimeInterval: toggleInterval, repeats: true) { _ in
            self.isBallUp.toggle()
        }
        // Perform initial toggle slightly delayed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
             if toggleTimer != nil { // Ensure timer actually started
                 self.isBallUp.toggle()
             }
        }

        // 2. Start the Phase Timer (Fires once when phase duration is up)
        phaseTimer = Timer.scheduledTimer(withTimeInterval: phaseDuration, repeats: false) { _ in
            print("Phase \(self.currentPhaseIndex + 1) finished (Duration: \(phaseDuration)s).")
            self.advanceToNextPhase()
        }
    }

    private func advanceToNextPhase() {
        // Stop the toggle timer for the completed phase
        toggleTimer?.invalidate()
        toggleTimer = nil

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
        startTimersForCurrentPhase() // Start timers for the new/looped phase
    }
}

#Preview {
    ChallengeActivityView()
}

