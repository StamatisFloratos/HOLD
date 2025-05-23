//
//  RapidFireOnboardingTutorial.swift
//  HOLD
//
//  Created by Hafiz Muhammad Ali on 21/05/2025.
//

import SwiftUI

struct RapidFireOnboardingTutorial: View {
    @State private var showNextView = false
    @State private var showFinishView = false
    
    @State private var isFirstView = true
    @State private var currentView = 0
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
    
    @State private var showText = false
    @State private var buttonOpacity = 1.0
    @State private var showOverlay = false
    
    var body: some View {
        ZStack {
            AppBackground()
            
            if showNextView {
                TutorialWorkoutDetailView(selectedWorkout: Workout(
                    name: "Daily Maintenance",
                    difficulty: .medium,
                    durationMinutes: 10,
                    description: "Regular practice to maintain pelvic floor strength",
                    exercises: [
                        Exercise.hold(seconds: 5),
                        Exercise.rapidFire(reps: 10),
                        Exercise.hold(seconds: 5),
                        Exercise.rapidFire(reps: 10),
                        Exercise.hold(seconds: 5)
                    ]
                ))
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
                .zIndex(1)
            } else {
                if showOverlay {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                        .transition(.opacity)
                        .zIndex(1)
                }
                
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
                    case 0:
                        rapidFireOnboardingView
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .leading)
                            ))
                    case 1:
                        tutorialStepOne
                    case 2:
                        tutorialStepTwo
                    case 3:
                        tutorialStepThree
                    case 4:
                        tutorialStepFour
                    case 5:
                        rapidFireMainView
                    case 6:
                        tryExercisesOnboardingView
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .leading)
                            ))
                    default:
                        rapidFireMainView
                    }
                    
                    Spacer().frame(height: 140)
                }
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    if showText {
                        if currentView == 1 {
                            VStack(spacing: 13) {
                                Text("Step 1/4")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Start from a relaxed position do not contract your PF Muscle at all.")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 30)
                            }
                            
                            Spacer().frame(height: 160)
                        } else if currentView == 2 {
                            VStack(spacing: 13) {
                                Text("Step 2/4")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("When the circle expands quickly contract your PF muscle. Follow the rhythm.")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 30)
                            }
                            
                            Spacer().frame(height: 160)
                        } else if currentView == 3 {
                            VStack(spacing: 13) {
                                Text("Step 3/4")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("When the circle shrinks, relax your PF muscle. Follow the rhythm.")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 30)
                            }
                            
                            Spacer().frame(height: 160)
                        } else if currentView == 4 {
                            VStack(spacing: 13) {
                                Text("Step 4/4")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Keep up. This is a fast exercise so contract quickly and let go quickly. Are you ready to give it a try?")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 30)
                            }
                            
                            Spacer().frame(height: 160)
                        }
                    }
                    
                    if currentView < 5 || currentView > 5 {
                        Button(action: {
                            triggerHapticOnButton()
                            showText = false
                            buttonOpacity = 0.0
                            
                            if currentView == 6 {
                                withAnimation {
                                    showNextView = true
                                }
                            } else if currentView == 0 {
                                withAnimation {
                                    currentView += 1
                                }
                            } else {
                                currentView += 1
                            }
                        }) {
                            if currentView == 0 {
                                Text("Show Me")
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(maxWidth: .infinity, maxHeight: 47)
                                    .background(Color(hex: "#FF1919"))
                                    .foregroundColor(.white)
                                    .cornerRadius(30)
                                    .padding(.horizontal, 56)
                            } else if currentView == 1 || currentView == 2 || currentView == 3 {
                                Text("I got it")
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(maxWidth: .infinity, maxHeight: 47)
                                    .background(Color(hex: "#FF1919"))
                                    .foregroundColor(.white)
                                    .cornerRadius(30)
                                    .padding(.horizontal, 56)
                            } else if currentView == 4 {
                                Text("Let's go")
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(maxWidth: .infinity, maxHeight: 47)
                                    .background(Color(hex: "#FF1919"))
                                    .foregroundColor(.white)
                                    .cornerRadius(30)
                                    .padding(.horizontal, 56)
                            } else if currentView == 6 {
                                Text("Start Workout")
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(maxWidth: .infinity, maxHeight: 47)
                                    .background(Color(hex: "#FF1919"))
                                    .foregroundColor(.white)
                                    .cornerRadius(30)
                                    .padding(.horizontal, 56)
                            }
                        }
                        .padding(.bottom, 32)
                        .opacity(buttonOpacity)
                        .disabled(buttonOpacity < 1.0)
                    } else {
                        Button(action: {
                            triggerHapticOnButton()
                            isPaused.toggle()
                            if isPaused {
                                stopTimer()
                                pauseRepetitionAnimation()
                            } else {
                                startTimer()
                                resumeRepetitionAnimation()
                            }
                        }) {
                            HStack {
                                Image(systemName: isPaused == false ? "pause.fill" : "play.fill")
                                    .font(.system(size: 20))
                                Text(isPaused == false ? "Pause" : "Continue")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 56)
                            .frame(maxWidth: 282,maxHeight: 47)
                            .background(Color(hex: "#2C2C2C"))
                            .cornerRadius(30)
                        }
                        .padding(.bottom, 32)
                        .opacity(buttonOpacity)
                        .disabled(buttonOpacity < 1.0)
                    }
                }
                .zIndex(2)
            }
        }
        .animation(.easeInOut, value: showNextView)
    }
    
    var rapidFireOnboardingView: some View {
        VStack(spacing: 45) {
            
            Text("⚡")
                .font(.system(size: 64, weight: .regular))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 0) {
                Text("New Exercise")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Rapid Fire")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            
            Text("Follow the **rhythm** on screen. **Quick.**\n**Controlled. Sharp.**")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal,35)
        .padding(.bottom, 100)
        .onAppear{
            track("ob_try_exercise_step8")
            
            withAnimation(.easeIn(duration: 1.0)) {
                buttonOpacity = 1.0
            }
        }
    }
    
    var tryExercisesOnboardingView: some View {
        VStack(spacing: 45) {
            Image("workoutIconLarge")
                .resizable()
                .frame(width: 77,height: 77)
            
            Text("You're about to start a\nworkout.")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            VStack(alignment:.leading,spacing:0) {
                Text("Instructions")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom,8)
                HStack(alignment: .top) {
                    Text("1.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    Text("Follow the rhythm, when the red circle expands flex your PF muscle.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                }
                
                HStack(alignment: .top) {
                    Text("2.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    Text("When the red circle contracts, relax.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                }
                
                HStack(alignment: .top) {
                    Text("3.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    Text("This will last about 2 minutes")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .padding(.horizontal,35)
        .padding(.bottom, 100)
        .onAppear{
            track("ob_try_exercise_step14")
            
            withAnimation(.easeIn(duration: 1.0)) {
                buttonOpacity = 1.0
            }
        }
    }
    
    var rapidFireMainView: some View {
        // Progress circle with counter
        VStack(spacing:0) {
            GeometryReader { geometry in
                ZStack(alignment: .center) {
                    // Center point for reference
                    let centerX = geometry.size.width / 2
                    let centerY = geometry.size.height / 2
                    
                    // Outer glow circle
                    Circle()
                        .fill(
                            EllipticalGradient(
                                stops: [
                                    Gradient.Stop(color: Color(red: 0.6, green: 0.06, blue: 0.06).opacity(0), location: 0.51),
                                    Gradient.Stop(color: Color(red: 1, green: 0.1, blue: 0.1), location: 1.00),
                                ],
                                center: UnitPoint(x: 0.5, y: 0.5)
                            )
                        )
                        .frame(width: 152, height: 152)
                        .position(x: centerX, y: centerY)
                        .scaleEffect(isExpanded ? 1.7 : 1)
                        .animation(.easeInOut(duration: 0.5), value: isExpanded)
                    
                    // Inner dark circle - explicitly positioned
                    Circle()
                        .fill(Color(hex: "#111720"))
                        .frame(width: 152, height: 152)
                        .position(x: centerX, y: centerY)
                    
                    // Progress arc - explicitly positioned
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        .frame(width: 152, height: 152)
                        .rotationEffect(.degrees(-90))
                        .position(x: centerX, y: centerY)
                    
                    // Counter and text - explicitly positioned
                    VStack(spacing: 5) {
                        Text("\(Int(totalTimeRemaining))")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(contractOrExpandText)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .transaction { transaction in
                                transaction.disablesAnimations = true
                            }
                    }
                    .position(x: centerX, y: centerY)
                }
            }
            .padding(.bottom, 120)
            
            Spacer()
            
            VStack(spacing: 5) {
                Text("Rapid Fire")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white)
                    .frame(height: 4)
                    .frame(width: 60)
            }
        }
        .onAppear{
            // Reset animation states
            track("ob_try_exercise_step13")
            
            isExpanded = false
            isTrembling = false
            trembleOffset = 0
            currentHoldTime = 0
            currentRep = 0
            repProgress = 0
            holdProgress = 0
            
            // Reset progress
            progress = 0.0
            totalTimeRemaining = Double(40) * 0.5
            totalRepsRemaining = 5
            contractOrExpandText = "Contract"
            repPhase = .contract
            
            totalReps = 20
            repProgress = 0
            
            isHoldExercise = false
            
            startRepetitionAnimation()
            
            withAnimation(.easeIn(duration: 0.2)) {
                buttonOpacity = 1.0
            }
            
            haptics.playRampUpHaptic(duration: repDuration)
        }
        .onChange(of: totalTimeRemaining, {
            if (totalTimeRemaining < Double(1) && currentView == 5) {
                stopTimer()
                stopRepTimer()
                haptics.stopHaptic()
                
                withAnimation(.easeIn(duration: 0.5)) {
                    isExpanded = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                    withAnimation {
                        currentView += 1
                    }
                    showText = false
                    buttonOpacity = 0.0
                })
            }
        })
        .onChange(of: currentRep, {
            if currentRep > 0 && currentView == 5{
                haptics.playRampUpHaptic(duration: repDuration)
            }
        })
    }
    
    var tutorialStepOne: some View {
        VStack(spacing:0) {
            GeometryReader { geometry in
                ZStack(alignment: .center) {
                    // Center point for reference
                    let centerX = geometry.size.width / 2
                    let centerY = geometry.size.height / 2
                    
                    // Inner dark circle - explicitly positioned
                    Circle()
                        .fill(Color(hex: "#111720"))
                        .frame(width: 152, height: 152)
                        .position(x: centerX, y: centerY)
                    
                    // Progress arc - explicitly positioned
                    Circle()
                        .trim(from: 0, to: 1)
                        .stroke(Color(hex: "#FF1919"), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        .frame(width: 152, height: 152)
                        .rotationEffect(.degrees(90))
                        .position(x: centerX, y: centerY)
                    
                    // Counter and text - explicitly positioned
                    VStack(spacing: 5) {
                        Text("20")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Contract")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .transaction { transaction in
                                transaction.disablesAnimations = true
                            }
                    }
                    .position(x: centerX, y: centerY)
                }
            }
            .padding(.bottom, 120)
            
            Spacer()
            
            VStack(spacing: 5) {
                Text("Rapid Fire")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white)
                    .frame(height: 4)
                    .frame(width: 60)
            }
        }
        .onAppear{
            // Reset animation states
            track("ob_try_exercise_step9")
            
            isExpanded = false
            
            withAnimation(.easeIn(duration: 0.5)) {
                showText = true
                showOverlay = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeIn(duration: 1.0)) {
                    buttonOpacity = 1.0
                }
            }
        }
    }
    
    var tutorialStepTwo: some View {
        VStack(spacing:0) {
            GeometryReader { geometry in
                ZStack(alignment: .center) {
                    // Center point for reference
                    let centerX = geometry.size.width / 2
                    let centerY = geometry.size.height / 2
                    
                    Circle()
                        .fill(
                            EllipticalGradient(
                                stops: [
                                    Gradient.Stop(color: Color(red: 0.6, green: 0.06, blue: 0.06).opacity(0), location: 0.51),
                                    Gradient.Stop(color: Color(red: 1, green: 0.1, blue: 0.1), location: 1.00),
                                ],
                                center: UnitPoint(x: 0.5, y: 0.5)
                            )
                        )
                        .frame(width: 152, height: 152)
                        .position(x: centerX, y: centerY)
                        .scaleEffect(isExpanded ? 1.7 : 1)
                        .modifier(ShakeEffect(animatableData: shakeTrigger))
                        .animation(.easeInOut(duration: 0.5), value: isExpanded)
                    
                    // Inner dark circle - explicitly positioned
                    Circle()
                        .fill(Color(hex: "#111720"))
                        .frame(width: 152, height: 152)
                        .position(x: centerX, y: centerY)
                    
                    // Progress arc - explicitly positioned
                    Circle()
                        .trim(from: 0, to: 0.1)
                        .stroke(
                            Color.white, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        .frame(width: 152, height: 152)
                        .rotationEffect(.degrees(90))
                        .position(x: centerX, y: centerY)
                    
                    // Counter and text - explicitly positioned
                    VStack(spacing: 5) {
                        Text("20")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Contract")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .transaction { transaction in
                                transaction.disablesAnimations = true
                            }
                    }
                    .position(x: centerX, y: centerY)
                }
            }
            .padding(.bottom, 120)
            
            Spacer()
            
            VStack(spacing: 5) {
                Text("Rapid Fire")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white)
                    .frame(height: 4)
                    .frame(width: 60)
            }
        }
        .onAppear{
            // Reset animation states
            track("ob_try_exercise_step10")
            
            isExpanded = true
            
            withAnimation(.easeIn(duration: 0.5)) {
                showText = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeIn(duration: 1.0)) {
                    buttonOpacity = 1.0
                }
            }
        }
    }
    
    var tutorialStepThree: some View {
        VStack(spacing:0) {
            GeometryReader { geometry in
                ZStack(alignment: .center) {
                    // Center point for reference
                    let centerX = geometry.size.width / 2
                    let centerY = geometry.size.height / 2
                    
                    Circle()
                        .fill(
                            EllipticalGradient(
                                stops: [
                                    Gradient.Stop(color: Color(red: 0.6, green: 0.06, blue: 0.06).opacity(0), location: 0.51),
                                    Gradient.Stop(color: Color(red: 1, green: 0.1, blue: 0.1), location: 1.00),
                                ],
                                center: UnitPoint(x: 0.5, y: 0.5)
                            )
                        )
                        .frame(width: 152, height: 152)
                        .position(x: centerX, y: centerY)
                        .scaleEffect(isExpanded ? 1.7 : 1)
                        .modifier(ShakeEffect(animatableData: shakeTrigger))
                        .animation(.easeInOut(duration: 0.5), value: isExpanded)
                    
                    // Inner dark circle - explicitly positioned
                    Circle()
                        .fill(Color(hex: "#111720"))
                        .frame(width: 152, height: 152)
                        .position(x: centerX, y: centerY)
                    
                    // Progress arc - explicitly positioned
                    Circle()
                        .trim(from: 0, to: 0.25)
                        .stroke(
                            Color.white, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        .frame(width: 152, height: 152)
                        .rotationEffect(.degrees(90))
                        .position(x: centerX, y: centerY)
                    
                    // Counter and text - explicitly positioned
                    VStack(spacing: 5) {
                        Text("15")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Relax")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .transaction { transaction in
                                transaction.disablesAnimations = true
                            }
                    }
                    .position(x: centerX, y: centerY)
                }
            }
            .padding(.bottom, 120)
            
            Spacer()
            
            VStack(spacing: 5) {
                Text("Rapid Fire")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white)
                    .frame(height: 4)
                    .frame(width: 60)
            }
        }
        .onAppear{
            // Reset animation states
            track("ob_try_exercise_step11")
            
            withAnimation(.easeOut(duration: 0.5)) {
                isExpanded = false
            }
            
            withAnimation(.easeIn(duration: 0.5)) {
                showText = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeIn(duration: 1.0)) {
                    buttonOpacity = 1.0
                }
            }
        }
    }
    
    var tutorialStepFour: some View {
        // Progress circle with counter
        VStack(spacing:0) {
            GeometryReader { geometry in
                ZStack(alignment: .center) {
                    // Center point for reference
                    let centerX = geometry.size.width / 2
                    let centerY = geometry.size.height / 2
                    
                    // Outer glow circle
                    Circle()
                        .fill(
                            EllipticalGradient(
                                stops: [
                                    Gradient.Stop(color: Color(red: 0.6, green: 0.06, blue: 0.06).opacity(0), location: 0.51),
                                    Gradient.Stop(color: Color(red: 1, green: 0.1, blue: 0.1), location: 1.00),
                                ],
                                center: UnitPoint(x: 0.5, y: 0.5)
                            )
                        )
                        .frame(width: 152, height: 152)
                        .position(x: centerX, y: centerY)
                        .scaleEffect(isExpanded ? 1.7 : 1)
                        .modifier(ShakeEffect(animatableData: shakeTrigger))
                        .animation(.easeInOut(duration: 0.5), value: isExpanded)
                    
                    // Inner dark circle - explicitly positioned
                    Circle()
                        .fill(Color(hex: "#111720"))
                        .frame(width: 152, height: 152)
                        .position(x: centerX, y: centerY)
                    
                    // Progress arc - explicitly positioned
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        .frame(width: 152, height: 152)
                        .rotationEffect(.degrees(90))
                        .position(x: centerX, y: centerY)
                    
                    // Counter and text - explicitly positioned
                    VStack(spacing: 5) {
                        Text("\(Int(totalTimeRemaining))")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(contractOrExpandText)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .transaction { transaction in
                                transaction.disablesAnimations = true
                            }
                    }
                    .position(x: centerX, y: centerY)
                }
            }
            .padding(.bottom, 120)
            
            Spacer()
            
            VStack(spacing: 5) {
                Text("Rapid Fire")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white)
                    .frame(height: 4)
                    .frame(width: 60)
            }
        }
        .onAppear{
            // Reset animation states
            track("ob_try_exercise_step12")
            
            isExpanded = false
            isTrembling = false
            trembleOffset = 0
            currentHoldTime = 0
            currentRep = 0
            repProgress = 0
            holdProgress = 0
            
            // Reset progress
            progress = 0.0
            totalTimeRemaining = Double(40) * 0.5
            totalRepsRemaining = 20
            contractOrExpandText = "Contract"
            repPhase = .contract
            
            totalReps = 20
            repProgress = 0
            
            isHoldExercise = false
            
            startRepetitionAnimation()
            
            withAnimation(.easeIn(duration: 0.5)) {
                showText = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeIn(duration: 1.0)) {
                    buttonOpacity = 1.0
                }
            }
        }
        .onDisappear {
            withAnimation(.easeIn(duration: 0.5)) {
                showOverlay = false
            }
        }
        .onChange(of: totalTimeRemaining, {
            if (totalTimeRemaining < Double(1) && currentView == 4) {
                stopTimer()
                stopRepTimer()
                withAnimation(.easeIn(duration: 0.5)) {
                    isExpanded = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    isExpanded = false
                    isTrembling = false
                    trembleOffset = 0
                    currentHoldTime = 0
                    currentRep = 0
                    repProgress = 0
                    holdProgress = 0
                    
                    // Reset progress
                    progress = 0.0
                    totalTimeRemaining = Double(40) * 0.5
                    totalRepsRemaining = 20
                    contractOrExpandText = "Contract"
                    repPhase = .contract
                    
                    totalReps = 20
                    repProgress = 0
                    
                    isHoldExercise = false
                    
                    startRepetitionAnimation()
                })
            }
        })
    }
    
    func startRepetitionAnimation() {
        stopRepTimer()

        currentRep = 0
        repDuration = 1
        
        repPhase = .contract
        contractOrExpandText = "Contract" // Ensure we start with contract
        
        // Immediately start the first rep
        startTimer()
        startNextRep()
    }
    
    func startNextRep() {
        let halfDuration = repDuration / 2
        
        // Contract phase
        contractOrExpandText = "Contract"
        repPhase = .contract
        

        withAnimation(.easeInOut(duration: halfDuration)) {
            isExpanded = true
        }
        
        // Schedule relax phase
        repTimer = Timer.scheduledTimer(withTimeInterval: halfDuration, repeats: false) { _ in
            // Relax phase
            self.contractOrExpandText = "Relax"
            self.repPhase = .relax
            
            withAnimation(.easeInOut(duration: halfDuration)) {
                self.isExpanded = false
            }
            
            // Schedule next rep
            self.repTimer = Timer.scheduledTimer(withTimeInterval: halfDuration, repeats: false) { _ in
                self.currentRep += 1
                
                if self.totalTimeRemaining > 0 {
                    self.startNextRep()
                }
            }
        }
    }
    
    func pauseRepetitionAnimation() {
        stopRepTimer()
        haptics.pauseHaptic()
    }
    
    func resumeRepetitionAnimation() {
        let halfDuration = repDuration / 2
        
        // Calculate how much time should be spent in the current phase
        let currentPhaseTimeRemaining: Double
        let totalPhaseTime = halfDuration
        
        haptics.resumeHaptic()
        
        if repPhase == .contract {
            // If we're in contract phase, calculate remaining time in this phase
            
            let contractProgress = repProgress * 2 // Scale to get progress within just this phase (0-1)
            currentPhaseTimeRemaining = totalPhaseTime * (1 - contractProgress)
        } else {
            // If we're in relax phase, calculate remaining time in this phase
            let relaxProgress = (repProgress - 0.5) * 2 // Scale to get progress within just this phase (0-1)
            currentPhaseTimeRemaining = totalPhaseTime * (1 - relaxProgress)
        }
        
        // Resume from current phase with adjusted timing
        if repPhase == .contract {
            // Continue the contract phase from current expansion state
            // Use linear animation for smooth transition from paused state
            
            withAnimation(.linear(duration: currentPhaseTimeRemaining)) {
                isExpanded = true // Complete the expansion
            }
            
            // Schedule the relax phase
            repTimer = Timer.scheduledTimer(withTimeInterval: currentPhaseTimeRemaining, repeats: false) { _ in
                // Start relax phase
                self.contractOrExpandText = "Relax"
                self.repPhase = .relax
                
                withAnimation(.linear(duration: halfDuration)) {
                    self.isExpanded = false
                }
                
                // Schedule next rep
                self.repTimer = Timer.scheduledTimer(withTimeInterval: halfDuration, repeats: false) { _ in
                    self.currentRep += 1
                    
                    if self.totalTimeRemaining > 0 {
                        self.startNextRep()
                    }
                }
            }
        } else {
            // Continue the relax phase from current state
            
            withAnimation(.linear(duration: currentPhaseTimeRemaining)) {
                isExpanded = false // Complete the contraction
            }
            
            // Schedule next rep
            repTimer = Timer.scheduledTimer(withTimeInterval: currentPhaseTimeRemaining, repeats: false) { _ in
                self.currentRep += 1
                
                if self.totalTimeRemaining > 0 {
                    self.startNextRep()
                }
            }
        }
    }
    
    func stopRepTimer() {
        repTimer?.invalidate()
        repTimer = nil
    }
    
    func startTimer() {
//        let exercise = currentExercise
        
        stopTimer()
        
        // Get rhythm parameters
        
        // Timer for updating the overall time remaining (runs every 0.1 seconds)
        let timeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if self.totalTimeRemaining > 0 {
                self.totalTimeRemaining -= 0.1
                
                // Update the progress based on time remaining
                switch isHoldExercise {
                case true:
                    withAnimation {
                        self.progress = 1.0 - ((self.totalTimeRemaining - 1) / Double(holdDuration - 1))
                    }
                case false:
                    let totalDuration = totalReps
                    withAnimation {
                        self.progress = 1.0 - ((self.totalTimeRemaining - 1) / Double(totalDuration - 1))
                    }
                    
                    // Calculate remaining reps properly
                    let completedTime = Double(totalDuration) - self.totalTimeRemaining
                    let completedReps = Int(floor(completedTime / 1))
                    self.totalRepsRemaining = max(0, 8 - completedReps)
                    
                    // Update rep progress for pause/resume functionality
                    let currentRepTime = completedTime
                    self.repProgress = currentRepTime / 1
                }
                
                // If time is up (exactly zero or less), complete exercise
                if self.totalTimeRemaining <= 0.05 { // Use small threshold to prevent
                    self.totalTimeRemaining = 0
                }
            }
        }
        
        timers = [timeTimer]
    }
    
    func stopTimer() {
        for timer in timers {
            timer.invalidate()
        }
        timers.removeAll()
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
    RapidFireOnboardingTutorial()
}
