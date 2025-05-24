//
//  TryExerciseView.swift
//  HOLD
//
//  Created by Rabbia Ijaz on 06/05/2025.
//

import SwiftUI

struct TryExerciseView: View {
    
    @State private var showNextView = false
    @State private var showFinishView = false
    
    @State private var isFirstView = true
    @State private var currentView = 1
    @State private var isPaused: Bool = false
    
    @State private var isExpanded = false
    @State private var isTrembling = false
    @State private var trembleOffset: CGFloat = 0
    @State private var progress: CGFloat = 0
    @State private var totalTimeRemaining: Double = 0 // Time in seconds
    @State private var totalRepsRemaining: Int = 0
    
    @State private var contractOrExpandText = "Contract"
    @State private var holdTimer: Timer?
    @State private var holdDuration = 0
    @State private var currentHoldTime = 0
    @State private var holdProgress: Double = 0 // Track progress within hold (0.0-1.0)
    
    // Rep tracking
    @State private var currentRep = 0
    @State private var totalReps = 0
    @State private var repDuration = 0.0
    @State private var repTimer: Timer?
    @State private var repPhase: RepPhase = .contract // Track whether we're in contract or relax phase
    @State private var repProgress: Double = 0 // Track progress within current rep (0.0-1.0)
    
    
    @State private var timers: [Timer] = []

    
    @State private var isHoldExercise = true
    
    let haptics = HapticManager()
    
    @State private var shakeTrigger: CGFloat = 0
    @State private var trembleTimer: Timer?
    
    var body: some View {
        ZStack {
            AppBackground()
            if showNextView {
                HoldOnboardingTutorial()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                    .zIndex(1)
            }
            else {
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Image("holdIcon")
                        Spacer()
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 14)
                    
                    Spacer()
                    
                    switch currentView {
                    case 1:
                        firstView
                        
                    case 2:
                        secondView
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .leading)
                            ))
                        
                    default:
                        firstView
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .leading)
                            ))
                    }
                    
                    
                    Spacer()
                    
                    Button(action: {
                        triggerHapticOnButton()
                        if currentView == 2 {
                            withAnimation {
                                showNextView = true
                            }
                        } else {
                            currentView += 1
                        }
                    }) {
                        if currentView == 1 {
                            Text("Learn Exercises")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity, maxHeight: 47)
                                .background(Color(hex: "#FF1919"))
                                .foregroundColor(.white)
                                .cornerRadius(30)
                                .padding(.horizontal, 56)
                        } else {
                            Text("Show Me")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity, maxHeight: 47)
                                .background(Color(hex: "#FF1919"))
                                .foregroundColor(.white)
                                .cornerRadius(30)
                                .padding(.horizontal, 56)
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
        }
        .animation(.easeInOut, value: showNextView)
        .animation(.easeInOut, value: currentView)
    }
    
    var firstView: some View {
        VStack(spacing: 45) {
            Image("workoutIconLarge")
                .resizable()
                .frame(width: 77,height: 77)
            
            Text("Try the Exercises")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("You've learned what PF muscles are and how to contract them.\n\nSo, it's the right time to try to 2 simple exercises that will be part of your training.")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal,35)
        .padding(.bottom, 50)
        .onAppear {
            track("ob_try_exercise_step1")
        }
    }
    
    var secondView: some View {
        VStack(spacing: 45) {
            
            Text("✊")
                .font(.system(size: 64, weight: .regular))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            
            VStack(spacing: 0) {
                Text("New Exercise")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Hold")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            
            Text("**Contract** your pelvic floor muscle and hold it steady while the timer **counts down.**")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal,35)
        .padding(.bottom, 50)
        .onAppear {
            track("ob_try_exercise_step2")
        }
    }
    
    // MARK: Haptic feedback
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func triggerHapticOnButton() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}

#Preview {
    TryExerciseView()
}
