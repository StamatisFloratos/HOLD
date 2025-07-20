//
//  WorkoutDetailView.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import SwiftUI
import AudioToolbox
import UIKit

// Enum to track rep phase
enum RepPhase {
    case contract
    case relax
}

struct WorkoutDetailView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    @Environment(\.scenePhase) var scenePhase
    
    @State private var isPaused: Bool = false
    var selectedWorkout: Workout
    @State private var selectedExerciseIndex: Int = 0
    
    // Progress animation
    @State private var progress: CGFloat = 0
    @State private var timers: [Timer] = []
    @State private var totalTimeRemaining: Double = 0 // Time in seconds
    @State private var totalRepsRemaining: Int = 0
    @State private var scrollViewProxy: ScrollViewProxy? = nil
    @State private var finish = false
    
    // Animation state tracking
    @State private var isExpanded = false
    
    @State private var shakeTrigger: CGFloat = 0
    @State private var trembleTimer: Timer?
    
    // Rep tracking
    @State private var currentRep = 0
    @State private var totalReps = 0
    @State private var repDuration = 0.0
    @State private var repTimer: Timer?
    @State private var repPhase: RepPhase = .contract // Track whether we're in contract or relax phase
    @State private var repProgress: Double = 0 // Track progress within current rep (0.0-1.0)
   
    // Hold tracking
    @State private var holdTimer: Timer?
    @State private var holdDuration = 0
    @State private var currentHoldTime = 0
    @State private var holdProgress: Double = 0 // Track progress within hold (0.0-1.0)

    @State private var contractOrExpandText = "Contract"
    @State private var isStartExercise = false
    
    @State private var animateWorkoutOut = false
    @State private var animateCongratsIn = false
    
    var onBack: () -> Void

    let haptics = HapticManager()
    
    
    
    var body: some View {
        ZStack {
            AppBackground()
            
            VStack(spacing:0) {
                // Logo at the top
                HStack {
                    Spacer()
                    Image("holdIcon")
                    Spacer()
                }
                .padding(.top, 24)
                .padding(.bottom, 14)
                
                Spacer()
                
                ZStack {
                    if !animateWorkoutOut {
                        workoutContent
                            .transition(.asymmetric(
                                insertion: .identity,
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }

                    if animateCongratsIn {
                        finishContent
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .animation(.easeInOut(duration: 0.5), value: animateWorkoutOut)
                .animation(.easeInOut(duration: 0.5), value: animateCongratsIn)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            initializeExercise()
            startTimer()
            startCurrentExerciseAnimation()
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                isPaused = true
                pauseAllAnimations()
            }
        }
        .onChange(of: shakeTrigger, {
            if currentExercise.type == .hold {
                triggerHaptic()
            }
        })
        .onChange(of: finish, { _, newValue in
            if newValue {
                withAnimation {
                    animateWorkoutOut = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        animateCongratsIn = true
                    }
                }
            }
        })
    }
    
    private var workoutContent: some View {
        VStack {
            progressCircle

            Spacer()

            exerciseTabs

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
                .padding()
                .frame(maxWidth: 282,maxHeight: 47)
                .background(Color(hex: "#2C2C2C"))
                .cornerRadius(30)
            }
            .padding(.bottom, 40)
        }
    }
    
    private var finishContent: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 122)

            VStack(spacing: 37) {
                Text("🎉")
                    .font(.system(size: 64, weight: .semibold))
                Text("Congratulations!")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Text("You finished today’s workout!")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: 5) {
                Text("Finish")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)

                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white)
                    .frame(height: 4)
                    .frame(width: 60)
            }
            Spacer().frame(height: 61)

            Button(action: {
                triggerHaptic()
                onBack()
            }) {
                Text("Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .padding()
                    .frame(maxWidth: .infinity,maxHeight: 47)
                    .background(Color(hex: "#FF1919"))
                    .foregroundColor(.white)
                    .cornerRadius(30)
            }
            .padding(.horizontal, 50)
            .padding(.bottom, 15)
        }
    }
    
    // MARK: Progress Circle
    var progressCircle: some View {
        // Progress circle with counter
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                // Center point for reference
                let centerX = geometry.size.width / 2
                let centerY = geometry.size.height / 2
                
                // Outer glow circle
                if currentExercise.type != .rest {
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
                }
                
                // Inner dark circle - explicitly positioned
                Circle()
                    .fill(currentExercise.type != .rest ? Color(hex: "#111720") : Color.clear)
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
                    Text((currentExercise.type == .hold || currentExercise.type == .rest) ?
                         "\(Int(ceil(totalTimeRemaining)))" : "\(totalRepsRemaining)")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(currentExercise.type == .rest ? "Rest" : contractOrExpandText)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                .position(x: centerX, y: centerY)
            }
        }
    }
    
    // MARK: Animation Control Functions
    
    // Function to start the appropriate animation based on exercise type
    func startCurrentExerciseAnimation() {
        if currentExercise.type == .rest {
            // For rest, we just need the timer, no animation
            return
        } else if currentExercise.type == .hold {
            startHoldAnimation()
        } else {
            startRepetitionAnimation()
        }
    }
    
    // Pause all running animations and timers
    func pauseAllAnimations() {
        stopTimer()
        if currentExercise.type == .hold {
            pauseHoldAnimation()
        } else if currentExercise.type != .rest {
            pauseRepetitionAnimation()
        }
    }
    
    // Resume all animations and timers from where they left off
    func resumeAllAnimations() {
        startTimer()
        if currentExercise.type == .hold {
            resumeHoldAnimation()
        } else if currentExercise.type != .rest {
            resumeRepetitionAnimation()
        }
    }
    
    func startHoldAnimation() {
        stopRepTimer()
        stopHoldTimer()

        holdDuration = currentExercise.seconds ?? 10
        holdProgress = 0

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
    
    // MARK: Repetition Animation
    func startRepetitionAnimation() {
        stopRepTimer()
        stopHoldTimer()

        let rhythm = currentExercise.getRhythmParameters()
        currentRep = 0
        repDuration = rhythm.duration
        totalReps = currentExercise.reps ?? 0
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
        
        haptics.playRampUpHaptic(duration: repDuration)
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
    
    // MARK: Main Timer
    func startTimer() {
        let exercise = currentExercise
        
        stopTimer()
        
        // Get rhythm parameters
        let rhythm = exercise.getRhythmParameters()
        
        // Timer for updating the overall time remaining (runs every 0.1 seconds)
        let timeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if self.totalTimeRemaining > 0 {
                self.totalTimeRemaining -= 0.1
                
                // Update the progress based on time remaining
                switch exercise.type {
                case .rest, .hold:
                    if let seconds = exercise.seconds, seconds > 0 {
                        withAnimation {
                            self.progress = 1.0 - (self.totalTimeRemaining / Double(seconds))
                        }
                    }
                case .clamp, .rapidFire, .flash:
                    if let reps = exercise.reps {
                        let totalDuration = Double(reps) * rhythm.duration
                        withAnimation {
                            self.progress = 1.0 - (self.totalTimeRemaining / Double(totalDuration))
                        }
                        
                        // Calculate remaining reps properly
                        let completedTime = totalDuration - self.totalTimeRemaining
                        let completedReps = Int(floor(completedTime / rhythm.duration))
                        self.totalRepsRemaining = max(0, reps - completedReps)
                        
                        // Update rep progress for pause/resume functionality
                        let currentRepTime = completedTime.truncatingRemainder(dividingBy: rhythm.duration)
                        self.repProgress = currentRepTime / rhythm.duration
                    }
                }
                
                // If time is up (exactly zero or less), complete exercise
                if self.totalTimeRemaining <= 0.05 { // Use small threshold to prevent rounding issues
                    self.totalTimeRemaining = 0
                    self.exerciseCompleted()
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
    
    // MARK: Exercise Tabs
    var exerciseTabs: some View  {
        // Exercise tabs - horizontal scrolling view
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { proxy in
                HStack(spacing: 27) {
                    // Left spacer to center first item
                    Spacer().frame(width: UIScreen.main.bounds.width / 2 - 92 / 2)
                    
                    ForEach(0..<workoutWithRests.exercises.count, id: \.self) { index in
                        let exercise = workoutWithRests.exercises[index]
                        exerciseTab(name: exercise.name,
                                    isSelected: index == selectedExerciseIndex
                        )
                        .id(index)
                    }
                    
                    exerciseTab(name: "Finish", isSelected: finish)
                        .id(workoutWithRests.exercises.count)
                    
                    // Right spacer to center last item
                    Spacer().frame(width: UIScreen.main.bounds.width / 2 - 92 / 2)
                }
                .padding(.horizontal, 0)
                .onAppear {
                    scrollViewProxy = proxy
                    centerSelectedExercise()
                }
                .onChange(of: selectedExerciseIndex) { _ in
                    centerSelectedExercise()
                }
            }
        }
        .scrollDisabled(true)
        .padding(.bottom, 61)
    }
    
    // Computed property to create the expanded workout with rest periods
    var workoutWithRests: Workout {
        var exercisesWithRests: [Exercise] = []
        
        for (index, exercise) in selectedWorkout.exercises.enumerated() {
            exercisesWithRests.append(exercise)
            
            if index < selectedWorkout.exercises.count - 1 {
                let restExercise = Exercise.rest(seconds: selectedWorkout.restSeconds)
                exercisesWithRests.append(restExercise)
            }
        }
        
        return Workout(
            id: selectedWorkout.id,
            name: selectedWorkout.name,
            difficulty: selectedWorkout.difficulty,
            durationMinutes: selectedWorkout.durationMinutes,
            description: selectedWorkout.description,
            exercises: exercisesWithRests,
            restSeconds: selectedWorkout.restSeconds
        )
    }
    
    // Helper function to create exercise tabs
    func exerciseTab(name: String, isSelected: Bool = false) -> some View {
        VStack(spacing: 5) {
            Text(name)
                .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                .foregroundColor(.white)
            
            RoundedRectangle(cornerRadius: 5)
                .fill(isSelected ? Color.white : Color.clear)
                .frame(height: 4)
                .frame(width: 42)
                .cornerRadius(5)
        }
    }
    
    // Get the current exercise from the workout
    var currentExercise: Exercise {
        return workoutWithRests.exercises[selectedExerciseIndex]
    }
    
    // Handle exercise completion
    func exerciseCompleted() {
        stopTimer()
        stopRepTimer()
        stopHoldTimer()
        
        switch currentExercise.type {
        case .hold:
            withAnimation(.easeIn(duration: 0.5)) {
                isExpanded = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                if selectedExerciseIndex < workoutWithRests.exercises.count - 1 {
                    // Move to the next exercise (which could be a rest period)
                    
                    selectedExerciseIndex += 1
                    
                    // Reset animation state
                    
                    self.initializeExercise()
                    self.startTimer()
                    self.startCurrentExerciseAnimation()
                    
                } else {
                    // Workout completed
                    WorkoutCompletionManager.saveCompletion(WorkoutCompletion(workoutName: selectedWorkout.name))
                    workoutViewModel.updateStreakAfterWorkout()
                    workoutViewModel.checkAndAwardBadges()
                    finish = true
                }
            })
        case .clamp, .flash, .rapidFire, .rest:
            isExpanded = false
            
            if selectedExerciseIndex < workoutWithRests.exercises.count - 1 {
                // Move to the next exercise (which could be a rest period)
                
                selectedExerciseIndex += 1
                
                // Reset animation state
                
                self.initializeExercise()
                self.startTimer()
                self.startCurrentExerciseAnimation()
                
            } else {
                // Workout completed
                WorkoutCompletionManager.saveCompletion(WorkoutCompletion(workoutName: selectedWorkout.name))
                workoutViewModel.updateStreakAfterWorkout()
                workoutViewModel.checkAndAwardBadges()
                finish = true
            }
        }
    }
    
    // Initialize the current exercise
    func initializeExercise() {
        let exercise = currentExercise
        
        // Reset animation states
        isExpanded = false
        currentHoldTime = 0
        currentRep = 0
        repProgress = 0
        holdProgress = 0
        
        // Reset progress
        progress = 0.0
        
        // Set instruction text and counter based on exercise type
        switch exercise.type {
        case .hold, .rest:
            if let seconds = exercise.seconds {
                totalTimeRemaining = Double(seconds)
            }
            if exercise.type == .hold {
                contractOrExpandText = "Contract"
            }
        case .clamp, .rapidFire, .flash:
            if let reps = exercise.reps {
                let rhythm = exercise.getRhythmParameters()
                totalTimeRemaining = Double(reps) * rhythm.duration
                totalRepsRemaining = reps
                contractOrExpandText = "Contract"
                repPhase = .contract
            }
        }
    }
    
    func centerSelectedExercise() {
        withAnimation {
            scrollViewProxy?.scrollTo(selectedExerciseIndex, anchor: .center)
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
    let workout = Workout(id: "workout_detail", name: "Workout Detail", difficulty: .easy, durationMinutes: 5, description: "", exercises: [], restSeconds: 30)
    WorkoutDetailView(selectedWorkout: workout, onBack: {})
        .environmentObject(NavigationManager())
        .environmentObject(WorkoutViewModel())
}
