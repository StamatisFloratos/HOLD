//
//  WorkoutDetailView.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import SwiftUI

struct WorkoutDetailView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var workoutViewModel: WorkoutViewModel

    @State private var isPaused: Bool = false
    var selectedWorkout: Workout
    @State private var selectedExerciseIndex: Int = 0
    
    // Progress animation
    @State private var progress: CGFloat = 0
    @State private var timers: [Timer] = []
    @State private var totalTimeRemaining: Double = 0 // Time in seconds
    @State private var scrollViewProxy: ScrollViewProxy? = nil
    @State private var pulsate = false // <- Add this inside your View
    @State private var finish = false
    
    var body: some View {
        ZStack {
            AppBackground()
            
            VStack {
                VStack(spacing: 0) {
                    // Logo at the top
                    HStack {
                        Spacer()
                        Image("holdIcon")
                        Spacer()
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 14)
                    
//                    Spacer().frame(height: 122)
                    
                    if !finish {
                        // Progress circle with counter
                        GeometryReader { geometry in
                            ZStack(alignment: .center) {
                                // Center point for reference
                                let centerX = geometry.size.width / 2
                                let centerY = geometry.size.height / 2
                                
                                // Outer glow circle
                                if workoutWithRests.exercises[selectedExerciseIndex].name != "Rest" {
                                    let rhythm = workoutWithRests.exercises[selectedExerciseIndex].getRhythmParameters()
                                    
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                gradient: Gradient(colors: [Color(hex: "#990F0F"), Color(hex: "#FF0000")]),
                                                center: .center,
                                                startRadius: 81,
                                                endRadius: 114
                                            )
                                        )
                                        .frame(width: 228, height: 228)
                                        .position(x: centerX, y: centerY)
                                        .scaleEffect(pulsate ? 1.2 : 1)
                                        .opacity(pulsate ? 0.5 : 1)
                                        .animation(Animation.easeInOut(duration: rhythm.duration)
                                            .repeatForever(autoreverses: true)
                                            .speed(rhythm.intensity),
                                                   value: pulsate)
                                        .onChange(of: pulsate) { _ in
                                            triggerHaptic()
                                        }
                                }
                                
                                // Inner dark circle - explicitly positioned
                                Circle()
                                    .fill(workoutWithRests.exercises[selectedExerciseIndex].name != "Rest" ? Color(hex: "#111720") : Color.clear)
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
                                    
                                    Text(workoutWithRests.exercises[selectedExerciseIndex].name != "Rest" ? "Contract & Let Go" : "Rest")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .position(x: centerX, y: centerY)
                            }
                        }
                    }
                    else {
                        WorkoutFinishView()
                            .padding(.top,122)
                    }
                    Spacer()
                    
                    // Exercise tabs - horizontal scrolling view
                    ZStack {
                        ScrollView(.horizontal, showsIndicators: false) {
                            ScrollViewReader { proxy in
                                HStack(spacing: 27) {
                                    // Left spacer to center first item
                                    Spacer().frame(width: UIScreen.main.bounds.width / 2 - 62 / 2)
                                    
                                    ForEach(0..<workoutWithRests.exercises.count, id: \.self) { index in
                                        let exercise = workoutWithRests.exercises[index]
                                        exerciseTab(
                                            name: exercise.name,
                                            isSelected: finish == true ? false : index == selectedExerciseIndex,
                                            isColorWhite: !finish
                                        )
                                        .id(index)
                                        .frame(width: 62) // <- Ensures centering math works
                                        
                                    }
                                    exerciseTab(
                                        name: "Finish",
                                        isSelected: finish,
                                        isColorWhite: true
                                    )
                                    .frame(width: 62) // <- Ensures centering math works
                                    .id(workoutWithRests.exercises.count)
                                    
                                    // Right spacer to center last item
                                    Spacer().frame(width: UIScreen.main.bounds.width / 2 - 62 / 2)
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
                        
                    }
                    .padding(.bottom, 61)
                    .frame(height:10)
                    
                    // Pause button
                    Button(action: {
                        triggerHapticOnButton()
                        if !finish {
                            isPaused.toggle()
                            isPaused == true ? stopTimer() : startTimer()
                            pulsate.toggle()
                        } else {
                            navigationManager.pop(to: .mainTabView)
                        }
                        
                    }) {
                        HStack {
                            if !finish {
                                Image(systemName: isPaused == false ? "pause.fill" : "play.fill")
                                    .font(.system(size: 20))
                                Text(isPaused == false ? "Pause" : "Continue")
                                    .font(.system(size: 18, weight: .semibold))
                            } else {
                                Text("Continue")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(finish == false ? Color(hex: "#2C2C2C") : Color(hex: "#FF1919"))
                        .cornerRadius(25)
                    }
                    .padding(.bottom, 40)
                }
                
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
            pulsate.toggle()
            initializeExercise()
            startTimer()
        }
        
        
        
    }
    
    // Helper function to create exercise tabs
    func exerciseTab(name: String, isSelected: Bool = false, isColorWhite: Bool) -> some View {
        VStack(spacing: 5) {
            Text(name)
                .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isColorWhite ? .white : .clear )
            
            Rectangle()
                .fill(isSelected ? Color.white : Color.clear)
                .frame(height: 4)
                .frame(width: 42)
                .cornerRadius(5)
        }
    }
    
    // Add this with your other helper functions
    func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.initializeExercise()
                self.startTimer()
            }
        } else {
            // Workout completed
            WorkoutCompletionManager.saveCompletion(WorkoutCompletion(workoutName: selectedWorkout.name))
            workoutViewModel.updateStreakAfterWorkout()
            finish = true
            selectedExerciseIndex += 1 // 👈 Add this line
            navigationManager.push(to: .workoutFinishView)
        }
    }
    
    // Initialize the current exercise
    func initializeExercise() {
        let exercise = currentExercise
        
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
            }
        }
    }
    
    func startTimer() {
        let exercise = workoutWithRests.exercises[selectedExerciseIndex]
        
        stopTimer()
        
        // Get rhythm parameters
        let rhythm = exercise.getRhythmParameters()
        
        // Timer for updating the overall time remaining (runs every 0.1 seconds)
        let timeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if self.totalTimeRemaining > 0 {
                self.totalTimeRemaining -= 0.1
                
                // Update the progress based on time remaining
                switch exercise.type {
                case .hold, .rest:
                    if let seconds = exercise.seconds, seconds > 0 {
                        // Progress increases as time decreases
                        // At 5 seconds left out of 10: 1-(5/10) = 0.5 (half done)
                        // At 2.5 seconds left out of 10: 1-(2.5/10) = 0.75 (75% done)
                        self.progress = 1.0 - (self.totalTimeRemaining / Double(seconds))
                    }
                case .clamp, .rapidFire, .flash:
                    if let reps = exercise.reps {
                        let totalDuration = Double(reps) * rhythm.duration
                        // Same formula for rep exercises
                        self.progress = 1.0 - (self.totalTimeRemaining / totalDuration)
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
    
    func centerSelectedExercise() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                scrollViewProxy?.scrollTo(selectedExerciseIndex, anchor: .center)
            }
        }
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
            Exercise.hold(seconds: 1),
            Exercise.clamp(reps: 1),
            Exercise.rapidFire(reps: 5),
            Exercise.hold(seconds: 5),
            Exercise.flash(reps: 5)
        ]
    )
    WorkoutDetailView(selectedWorkout: workout)
        .environmentObject(NavigationManager())
        .environmentObject(WorkoutViewModel())
}
