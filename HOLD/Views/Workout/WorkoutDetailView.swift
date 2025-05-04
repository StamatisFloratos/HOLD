//
//  WorkoutDetailView.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import SwiftUI
import AudioToolbox

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
    
    
    @State private var isExpanded = false
    @State private var isTrembling = false
    @State private var trembleOffset: CGFloat = 0
    
    @State private var currentRep = 0
    @State private var totalReps = 0
    @State private var repDuration = 0.0
    @State private var repTimer: Timer?
   
    
    @State private var holdTimer: Timer?
    @State private var holdDuration = 0
    @State private var currentHoldTime = 0

    @State private var contractOrExpandText = "Contract"
    @State private var isStartExercise = true
    var onBack: () -> Void

    
    
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
                
                progressCircle
                
                Spacer()
                
                exerciseTabs
                
                
                // Pause button
                Button(action: {
                    triggerHapticOnButton()
                    isPaused.toggle()
                    isPaused == true ? stopTimer() : startTimer()
                    if currentExercise.type == .hold {
                        isPaused == true ? stopHoldTimer() : startHoldAnimation()
                    } else {
                        isPaused == true ? stopRepTimer() : startRepetitionAnimation()
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
            
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: "#10171F").opacity(0.3), location: 0),
                    .init(color: Color.clear, location: 0.15),
                    .init(color: Color.clear, location: 0.85),
                    .init(color: Color(hex: "#10171F").opacity(0.3), location: 1)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .allowsHitTesting(false)
            .ignoresSafeArea()
            
            
        }
        .navigationBarHidden(true)
        .onAppear {
            initializeExercise()
            startTimer()
            if currentExercise.type != .rest {
                if currentExercise.type == .hold {
                    startHoldAnimation()
                } else {
                    startRepetitionAnimation()
                }
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background {
                isPaused = true
                stopTimer()
                if currentExercise.type == .hold {
                   stopHoldTimer()
                } else {
                    stopRepTimer()
                }
            }
        }
        .onChange(of: isExpanded, {
            if currentExercise.type != .rest {
                triggerHaptic()
            }
        })
        .onChange(of: isTrembling, {
            if currentExercise.type == .hold && isTrembling {
                triggerHaptic()
            }
        })
        .onChange(of: finish, {
            if finish {
                onBack()
            }
        })
    }
    
//MARK: Progress Circle
    var progressCircle: some View {
        // Progress circle with counter
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                // Center point for reference
                let centerX = geometry.size.width / 2
                let centerY = geometry.size.height / 2
                
                // Outer glow circle
                if currentExercise.type != .rest {
                    let rhythm = currentExercise.getRhythmParameters()
                    
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
                        .scaleEffect(isStartExercise ? 1.7 : isExpanded ? 1.7 : 1)
                        .offset(x: isTrembling ? trembleOffset : 0)
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
                         "\(Int(totalTimeRemaining))" : "\(totalRepsRemaining)")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(currentExercise.type == .rest ? "Rest" : contractOrExpandText)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .transaction { transaction in
                                transaction.disablesAnimations = true
                            }
                }
                .position(x: centerX, y: centerY)
            }
        }
    }
    
//MARK: Timers
    func startHoldAnimation() {
        stopRepTimer()
        stopHoldTimer()
        
        holdDuration = currentExercise.seconds ?? 10

        // Step 1: Expand the circle in the start
        withAnimation(.easeOut(duration: 1)) {
            isStartExercise = false
            isExpanded = true
        }
        
        
        // Tremble after delay
        holdTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in

            guard /*currentHoldTime < holdDuration*/ totalTimeRemaining > 0 else {
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
    
    func stopHoldTimer() {
        
        holdTimer?.invalidate()
        holdTimer = nil
    }
    
    func startRepetitionAnimation() {
        stopRepTimer()
        stopHoldTimer()

        let rhythm = currentExercise.getRhythmParameters()
        currentRep = 0
        repDuration = rhythm.duration
        totalReps = currentExercise.reps ?? 0
        
        repTimer = Timer.scheduledTimer(withTimeInterval: repDuration, repeats: true) { _ in
            guard currentRep < totalReps else {
                stopRepTimer()
                return
            }

            
            // let go after half duration
            contractOrExpandText = "Contract"
            withAnimation(.easeInOut(duration: repDuration / 2)) {
                isExpanded = true
                isStartExercise = false
            }
            
            // Contract after
            DispatchQueue.main.asyncAfter(deadline: .now() + repDuration / 2) {
                contractOrExpandText = "Relax"
                withAnimation(.easeInOut(duration: repDuration / 2)) {
                    isExpanded = false
                    
                }
                
            }

            currentRep += 1
        }
    }

    func stopRepTimer() {
        repTimer?.invalidate()
        repTimer = nil
        
    }
    
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
                        // At 2.5 seconds left out of 10: 1-(2.5/10) = 0.75 (75% done)
                        withAnimation {
                            self.progress = 1.0 - (self.totalTimeRemaining / Double(seconds))
                        }
                    }
                case .clamp, .rapidFire, .flash:
                    if let reps = exercise.reps {
                        let totalDuration = Double(reps) * rhythm.duration
                        // Same formula for rep exercises
                        withAnimation {
                            self.progress = 1.0 - (self.totalTimeRemaining / Double(totalDuration))
                        }
                        self.totalRepsRemaining = reps - Int(floor((totalDuration - totalTimeRemaining) / rhythm.duration)) + 1
                    
                    }
                }
                
                // If time is up, complete exercise
                if self.totalTimeRemaining <= 0 {
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
    
 //MARK: Exercise Tabs
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
//                        .frame(width: 92) // <- Ensures centering math works
                        
                    }
                    
                    exerciseTab(name: "Finish",isSelected: finish)
//                        .frame(width: 92) // <- Ensures centering math works
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
    
    // 1. Add a computed property to create the expanded workout with rest periods
    var workoutWithRests: Workout {
        // Create a placeholder for the new exercises array with rests
        var exercisesWithRests: [Exercise] = []
        
        // Insert rest periods between exercises
        for (index, exercise) in selectedWorkout.exercises.enumerated() {
            // Add the actual exercise
            exercisesWithRests.append(exercise)
            
            // Add a rest period after each exercise (except the last one)
            if index < selectedWorkout.exercises.count - 1 {
                let restExercise = Exercise.rest(seconds: selectedWorkout.restSeconds)
                exercisesWithRests.append(restExercise)
            }
        }
        
        // Create a new workout with the expanded exercises array
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
            
            Rectangle()
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
        
        if selectedExerciseIndex < workoutWithRests.exercises.count - 1 {
            // Move to the next exercise (which could be a rest period)
            selectedExerciseIndex += 1
            
            // Small delay before starting the next
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.initializeExercise()
                self.startTimer()
                if currentExercise.type != .rest {
                    if currentExercise.type == .hold {
                        startHoldAnimation()
                    } else {
                        startRepetitionAnimation()
                    }
                }
//            }
        } else {
            // Workout completed
            WorkoutCompletionManager.saveCompletion(WorkoutCompletion(workoutName: selectedWorkout.name))
            workoutViewModel.updateStreakAfterWorkout()
            finish = true
        }
    }
    
    // Initialize the current exercise
    func initializeExercise() {
        let exercise = currentExercise
        if currentExercise.type != .hold {
            isStartExercise = true
        } else {
            isStartExercise = false
        }
        
        // Reset progress
        progress = 0.0
        
        // Set instruction text and counter based on exercise type
        switch exercise.type {
        case .hold, .rest:
            if let seconds = exercise.seconds {
                totalTimeRemaining = Double(seconds)
            }
        case .clamp, .rapidFire, .flash:
            if let reps = exercise.reps {
                let rhythm = exercise.getRhythmParameters()
                totalTimeRemaining = Double(reps) * rhythm.duration
                totalRepsRemaining = reps
            }
        }
    }
    
    func centerSelectedExercise() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                scrollViewProxy?.scrollTo(selectedExerciseIndex, anchor: .center)
            }
//        }
    }
    
    
//MARK: Haptic feedback
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
    let workout = Workout(
        name: "Daily Maintenance",
        difficulty: .medium,
        durationMinutes: 10,
        description: "Regular practice to maintain pelvic floor strength",
        exercises: [
            Exercise.clamp(reps: 10),
            Exercise.rapidFire(reps: 10),
            Exercise.flash(reps: 10),
            Exercise.hold(seconds: 10),
            
            Exercise.rapidFire(reps: 2),
            Exercise.hold(seconds: 10),
            Exercise.flash(reps: 2)
        ]
    )
    WorkoutDetailView(selectedWorkout: workout, onBack: {})
        .environmentObject(NavigationManager())
        .environmentObject(WorkoutViewModel())
}
