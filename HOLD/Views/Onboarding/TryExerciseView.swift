//
//  TryExerciseView.swift
//  HOLD
//
//  Created by Rabbia Ijaz on 06/05/2025.
//

import SwiftUI

struct TryExerciseView: View {
    
    @State private var showNextView = false
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
    
    
    
    
    var body: some View {
        ZStack {
            AppBackground()
            if showNextView {
                MainTabView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                    .zIndex(1)
            } else {
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
                    case 3:
                        thirdView
                    case 4:
                        fourthView
                    case 5:
                        fifthView
                    case 6:
                        sixthView
                        
                    default:
                        firstView
                    }
                    
                    Spacer()
                    
                    if currentView != 3 && currentView != 5 {
                        Button(action: {
                            triggerHapticOnButton()
                            if currentView == 6 {
                                showNextView = true
                            }
                            currentView += 1
                           
                        }) {
                            Text(isFirstView ? "Start Workout":"Try Exercise")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity, maxHeight: 47)
                                .background(Color(hex: "#FF1919"))
                                .foregroundColor(.white)
                                .cornerRadius(30)
                                .padding(.horizontal, 56)
                        }
                        .padding(.bottom, 32)
                    } else {
                        Button(action: {
                            triggerHapticOnButton()
                            isPaused.toggle()
                            if isPaused {
                                pauseAllAnimations()
                            } else {
                                resumeAllAnimations()
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
                    }
                }
                
                
            }
        }
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
            
            Text("You’ve learned what PF muscles are and how to contract them.\n\nSo, it’s the right time to try to 2 simple exercises that will be part of your training.")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal,35)
    }
    
    var secondView: some View {
        VStack(spacing: 45) {
            
            Text("✊")
                .font(.system(size: 64, weight: .regular))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Hold")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("**Contract** your pelvic floor muscle and hold it steady while the timer **counts down.**\nThe circle stays expanded—stay **tight** until it closes.\nThis builds **endurance** and staying power when it matters most.")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal,35)
    }
    
    var thirdView: some View {
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
                            RadialGradient(
                                gradient: Gradient(colors: [Color(hex: "#990F0F"), Color(hex: "#FF0000")]),
                                center: .center,
                                startRadius: 50,
                                endRadius: 70
                            )
                        )
                        .frame(width: 152, height: 152)
                        .position(x: centerX, y: centerY)
                        .scaleEffect(isExpanded ? 1.7 : 1)
                        .offset(x: isTrembling ? trembleOffset : 0)
                    
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
                        
                        Text("Hold")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .transaction { transaction in
                                transaction.disablesAnimations = true
                            }
                    }
                    .position(x: centerX, y: centerY)
                }
            }
            Spacer()
            VStack(spacing: 5) {
                Text("Hold")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Rectangle()
                    .fill(Color.white)
                    .frame(height: 4)
                    .frame(width: 60)
            }
            Spacer().frame(height: 61)
        }
        .onAppear{
            // Reset animation states
            isExpanded = false
            isTrembling = false
            trembleOffset = 0
            currentHoldTime = 0
            currentRep = 0
            repProgress = 0
            holdProgress = 0
            
            // Reset progress
            progress = 0.0
            totalTimeRemaining = 10
            contractOrExpandText = "Contract"
            
            progress = 0
            totalTimeRemaining = 10
            
            startTimer()
            startHoldAnimation()
        }
        .onChange(of: totalTimeRemaining, {
            if (totalTimeRemaining == Double(0) && currentView == 3) {
                currentView = 4
                stopTimer()
                stopHoldTimer()
                withAnimation(.easeOut(duration: 1)) {
                    isExpanded = false
                }
            }
        })
        .onChange(of: isTrembling, {
            if currentView == 3 && isTrembling {
                triggerHaptic()
            }
        })
    }
    
    var fourthView: some View {
        VStack(spacing: 45) {
            
            Text("⚡")
                .font(.system(size: 64, weight: .regular))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Rapid Fire")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("When the circle expands—**contract** your pelvic floor muscle.\nWhen it shrinks—**release**.\nFollow the **rhythm** on screen. **Quick.**\n **Controlled. Sharp.**")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal,35)
    }
    
    var fifthView : some View {
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
                            RadialGradient(
                                gradient: Gradient(colors: [Color(hex: "#990F0F"), Color(hex: "#FF0000")]),
                                center: .center,
                                startRadius: 50,
                                endRadius: 70
                            )
                        )
                        .frame(width: 152, height: 152)
                        .position(x: centerX, y: centerY)
                        .scaleEffect(isExpanded ? 1.7 : 1)
                        .offset(x: isTrembling ? trembleOffset : 0)
                    
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
            
            Spacer()
            VStack(spacing: 5) {
                Text("Rapid Fire")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Rectangle()
                    .fill(Color.white)
                    .frame(height: 4)
                    .frame(width: 60)
            }
            Spacer().frame(height: 61)
        }
        .onAppear{
            // Reset animation states
            isExpanded = false
            isTrembling = false
            trembleOffset = 0
            currentHoldTime = 0
            currentRep = 0
            repProgress = 0
            holdProgress = 0
            
            // Reset progress
            progress = 0.0
            totalTimeRemaining = Double(18) * 0.5
            totalRepsRemaining = 18
            contractOrExpandText = "Contract"
            repPhase = .contract
            
            isHoldExercise = false
            
            startTimer()
            startRepetitionAnimation()
        }
        .onChange(of: totalTimeRemaining, {
            if (totalTimeRemaining == Double(0) && currentView == 5) {
                currentView = 6
                stopTimer()
                stopRepTimer()
                withAnimation(.easeOut(duration: 1)) {
                    isExpanded = false
                }
            }
        })
    }
    
    var sixthView: some View {
        VStack(spacing: 45) {
            Image("workoutIconLarge")
                .resizable()
                .frame(width: 77,height: 77)
            
            Text("You’re about to start a\nworkout.")
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
    }
    
    //MARK: Timers
    func startHoldAnimation() {
        stopRepTimer()
        stopHoldTimer()
        currentHoldTime = 0 // Reset the timer
        holdDuration = 10
        
        // Step 1: Expand the circle in the start
        withAnimation(.easeOut(duration: 1)) {
            isExpanded = true
        }
        
        
        // Tremble after delay
        holdTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            print(currentHoldTime)
            if totalTimeRemaining == Double(1) {
                stopHoldTimer()
                return
            }
            
            // Tremble animation
            isTrembling = true
            withAnimation(.linear(duration: 0.1).repeatCount(10, autoreverses: true)) {
                trembleOffset = 6
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.linear(duration: 0.05)) {
                    trembleOffset = 0
                    isTrembling = false
                }
            }
            
            currentHoldTime += 1
        }
    }
    
    func pauseHoldAnimation() {
        stopHoldTimer()
    }
    
    func resumeHoldAnimation() {
        // Start from where we left off
        holdTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard totalTimeRemaining > 0 else {
                stopHoldTimer()
                return
            }
            
            // Tremble animation
            isTrembling = true
            withAnimation(.linear(duration: 0.1).repeatCount(10, autoreverses: true)) {
                trembleOffset = 6
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.linear(duration: 0.05)) {
                    trembleOffset = 0
                    isTrembling = false
                }
            }
            
            currentHoldTime += 1
            holdProgress = Double(currentHoldTime) / Double(holdDuration)
        }
    }
    
    func stopHoldTimer() {
        holdTimer?.invalidate()
        holdTimer = nil
    }
    
    // MARK: Repetition Animation
    func startRepetitionAnimation() {
        stopRepTimer()
        stopHoldTimer()

//        let rhythm = currentExercise.getRhythmParameters()
        currentRep = 0
        repDuration = 0.5
        totalReps = 18
        repProgress = 0
        repPhase = .contract
        contractOrExpandText = "Contract" // Ensure we start with contract
        
        // Immediately start the first rep
        startNextRep()
    }
    
    func startNextRep() {
        let halfDuration = repDuration / 2
        
        // Contract phase
        contractOrExpandText = "Contract"
        repPhase = .contract
        
        haptics.playRampUpHaptic(duration: halfDuration)
        
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
                
                if self.currentRep < self.totalReps && self.totalTimeRemaining > 0 {
                    self.startNextRep()
                }
            }
        }
    }
    
    func pauseRepetitionAnimation() {
        stopRepTimer()
        
        if repPhase == .contract {
            haptics.pauseHaptic()
        }
    }
    
    func resumeRepetitionAnimation() {
        let halfDuration = repDuration / 2
        
        // Calculate how much time should be spent in the current phase
        let currentPhaseTimeRemaining: Double
        let totalPhaseTime = halfDuration
        
        if repPhase == .contract {
            // If we're in contract phase, calculate remaining time in this phase
            haptics.resumeHaptic()
            
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
                
                self.haptics.stopHaptic()
                
                // Schedule next rep
                self.repTimer = Timer.scheduledTimer(withTimeInterval: halfDuration, repeats: false) { _ in
                    self.currentRep += 1
                    
                    if self.currentRep < self.totalReps && self.totalTimeRemaining > 0 {
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
                
                if self.currentRep < self.totalReps && self.totalTimeRemaining > 0 {
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
                        self.progress = 1.0 - (self.totalTimeRemaining / Double(10))
                    }
                case false:
                    let totalDuration = Double(18) * 0.5
                    withAnimation {
                        self.progress = 1.0 - (self.totalTimeRemaining / Double(totalDuration))
                    }
                    
                    // Calculate remaining reps properly
                    let completedTime = totalDuration - self.totalTimeRemaining
                    let completedReps = Int(floor(completedTime / 0.5))
                    self.totalRepsRemaining = max(1, 18 - completedReps)
                    
                    // Update rep progress for pause/resume functionality
                    let currentRepTime = completedTime.truncatingRemainder(dividingBy: 0.5)
                    self.repProgress = currentRepTime / 0.5
                    
                    // Only update phase when not paused to avoid state inconsistency
                    if !self.isPaused {
                        // Update phase based on progress (only when not paused)
                        let newPhase: RepPhase = self.repProgress < 0.5 ? .contract : .relax
                        
                        // Only update if phase changed to prevent unnecessary UI updates
                        if self.repPhase != newPhase {
                            self.repPhase = newPhase
                            self.contractOrExpandText = newPhase == .contract ? "Contract" : "Relax"
                        }
                    }
                    
                }
                
                // If time is up (exactly zero or less), complete exercise
                if self.totalTimeRemaining <= 0.05 { // Use small threshold to prevent
                    self.totalTimeRemaining = 0
//                    self.exerciseCompleted()
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
    
    // Function to start the appropriate animation based on exercise type
    func startCurrentExerciseAnimation() {
        if currentView == 3 {
            startHoldAnimation()
        } else if currentView == 5 {
            startRepetitionAnimation()
        }
    }
    
    // Pause all running animations and timers
    func pauseAllAnimations() {
        stopTimer()
        if currentView == 3 {
            pauseHoldAnimation()
        } else if currentView == 5 {
            pauseRepetitionAnimation()
        }
    }
    
    // Resume all animations and timers from where they left off
    func resumeAllAnimations() {
        startTimer()
        if currentView == 3 {
            resumeHoldAnimation()
        } else if currentView == 5 {
            resumeRepetitionAnimation()
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
