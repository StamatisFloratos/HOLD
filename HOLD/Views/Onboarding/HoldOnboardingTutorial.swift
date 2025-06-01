//
//  HoldOnboardingTutorial.swift
//  HOLD
//
//  Created by Hafiz Muhammad Ali on 20/05/2025.
//

import SwiftUI

struct HoldOnboardingTutorial: View {
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
    
    @State private var showText = false
    @State private var buttonOpacity = 0.0
    @State private var showOverlay = false
    
    var body: some View {
        ZStack {
            AppBackground()
            
            if showNextView {
                RapidFireOnboardingTutorial()
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
                    case 1:
                        tutorialStepOne
                    case 2:
                        tutorialStepTwo
                    case 3:
                        tutorialStepThree
                    case 4:
                        tutorialStepFour
                    default:
                        holdMainView
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
                                
                                Text("When the circle expands start contracting your PF Muscle as hard as you can.")
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
                                
                                Text("Don’t let go, keep holding  while the timer goes down!")
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
                                
                                Text("Once the timer finishes and the circle shrinks, relax your PF muscle, you’ve done it! Are you ready to try it?")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 30)
                            }
                            
                            Spacer().frame(height: 160)
                        }
                    }
                    
                    if currentView < 5 {
                        Button(action: {
                            triggerHapticOnButton()
                            currentView += 1
                            showText = false
                            buttonOpacity = 0.0
                        }) {
                            if currentView == 1 || currentView == 2 || currentView == 3 {
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
                                pauseHoldAnimation()
                            } else {
                                startTimer()
                                resumeHoldAnimation()
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
    
    var holdMainView: some View {
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
                        
                        Text("Contract & Hold")
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
                Text("Hold")
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
            trackOnboarding("ob_try_exercise_step7", variant: UserStorage.onboarding)
            
            withAnimation(.easeIn(duration: 0.2)) {
                buttonOpacity = 1.0
            }
            
            stopTimer()
            stopHoldTimer()
            
            isExpanded = false
            isTrembling = false
            trembleOffset = 0
            currentHoldTime = 0
            currentRep = 0
            repProgress = 0
            holdProgress = 0
            
            holdDuration = 10
            holdProgress = 0
            
            progress = 0
            totalTimeRemaining = 10.5
            
            startTimer()
            startHoldAnimation()
        }
        .onChange(of: totalTimeRemaining, {
            if (totalTimeRemaining < Double(1) && currentView == 5) {
                stopTimer()
                stopHoldTimer()
                withAnimation(.easeIn(duration: 0.5)) {
                    isExpanded = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                    withAnimation {
                        showNextView = true
                    }
                })
            }
        })
        .onChange(of: shakeTrigger, {
            triggerHaptic()
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
                        Text("30")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Contract & Hold")
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
                Text("Hold")
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
            trackOnboarding("ob_try_exercise_step3", variant: UserStorage.onboarding)
            
            isExpanded = false
            isTrembling = false
            trembleOffset = 0
            
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
                        Text("30")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Contract & Hold")
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
                Text("Hold")
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
            trackOnboarding("ob_try_exercise_step4", variant: UserStorage.onboarding)
            
            isExpanded = true
            isTrembling = false
            trembleOffset = 0
            
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
                        
                        Text("Contract & Hold")
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
                Text("Hold")
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
            trackOnboarding("ob_try_exercise_step5", variant: UserStorage.onboarding)
            
            isTrembling = false
            trembleOffset = 0
            currentHoldTime = 0
            currentRep = 0
            repProgress = 0
            holdProgress = 0
            
            // Reset progress
            progress = 0.0
            totalTimeRemaining = 30
            
            holdDuration = 30
            holdProgress = 0
            
            startTimer()
            startHoldAnimation()
            
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
            stopTimer()
            stopHoldTimer()
        }
        .onChange(of: totalTimeRemaining, {
            if (totalTimeRemaining < Double(1)) && currentView == 3 {
                stopTimer()
                stopHoldTimer()
                
                currentHoldTime = 0
                progress = 0.0
                totalTimeRemaining = 30
                
                holdDuration = 30
                holdProgress = 0
                
                startTimer()
                startHoldAnimation()
            }
        })
    }
    
    var tutorialStepFour: some View {
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
                        .trim(from: 0, to: 1)
                        .stroke(
                            Color.white, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        .frame(width: 152, height: 152)
                        .rotationEffect(.degrees(90))
                        .position(x: centerX, y: centerY)
                    
                    // Counter and text - explicitly positioned
                    VStack(spacing: 5) {
                        Text("0")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Contract & Hold")
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
                Text("Hold")
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
            trackOnboarding("ob_try_exercise_step6", variant: UserStorage.onboarding)
            
            withAnimation(.easeOut(duration: 0.5)) {
                isExpanded = false
            }
            
            isTrembling = false
            trembleOffset = 0
            
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
    }
    
    func startHoldAnimation() {
        stopRepTimer()
        stopHoldTimer()

        withAnimation(.easeOut(duration: 0.5)) {
            isExpanded = true
        }

        startTrembleLoop()

        holdTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard totalTimeRemaining > 0 else {
                stopHoldTimer()
                stopTrembleLoop()
                return
            }

            currentHoldTime += 1
            holdProgress = Double(currentHoldTime) / Double(holdDuration)
        }
    }
    
    func stopHoldTimer() {
        holdTimer?.invalidate()
        holdTimer = nil
        stopTrembleLoop()
    }
    
    func startTrembleLoop() {
        trembleTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation(.linear(duration: 0.1)) {
                shakeTrigger += 1
            }
        }
    }

    func stopTrembleLoop() {
        shakeTrigger = 0
        trembleTimer?.invalidate()
        trembleTimer = nil
    }
    
    func resumeHoldAnimation() {
        startTrembleLoop()

        holdTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard totalTimeRemaining > 0 else {
                stopHoldTimer()
                stopTrembleLoop()
                return
            }

            currentHoldTime += 1
            holdProgress = Double(currentHoldTime) / Double(holdDuration)
        }
    }
    
    func pauseHoldAnimation() {
        stopHoldTimer()
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
                    let totalDuration = Double(8)
                    withAnimation {
                        self.progress = 1.0 - ((self.totalTimeRemaining - 1) / Double(totalDuration - 1))
                    }
                    
                    // Calculate remaining reps properly
                    let completedTime = totalDuration - self.totalTimeRemaining
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
    HoldOnboardingTutorial()
}
