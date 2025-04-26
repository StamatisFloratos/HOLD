//
//  WorkoutViewModel.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import Foundation
import SwiftUI

class WorkoutViewModel: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var selectedWorkout: Workout?
    @Published var isWorkoutInProgress: Bool = false
    @Published var currentExerciseIndex: Int = 0
    
    init() {
        loadWorkoutsFromJSON()
    }
    
    // MARK: - Workout Loading
    
    func loadWorkoutsFromJSON() {
        guard let workouts = loadWorkoutsFromBundle() else {
            // If file loading fails, use sample data
            self.workouts = Workout.sampleWorkouts
            print("Failed to load JSON, using sample workouts")
            return
        }
        
        self.workouts = workouts
        print("Successfully loaded \(workouts.count) workouts from JSON")
    }
    
    private func loadWorkoutsFromBundle() -> [Workout]? {
        guard let url = Bundle.main.url(forResource: "test_workout_hold", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to load test_workout_hold.json from bundle")
            return nil
        }
        
        let decoder = JSONDecoder()
        
        // Handle UUID decoding
        decoder.dataDecodingStrategy = .base64
        
        do {
            let workouts = try decoder.decode([Workout].self, from: data)
            return workouts
        } catch {
            print("Error decoding workouts JSON: \(error)")
            return nil
        }
    }
    
    // MARK: - Workout Management
    
    func selectWorkout(_ workout: Workout) {
        self.selectedWorkout = workout
    }
    
    func startWorkout() {
        guard selectedWorkout != nil else { return }
        isWorkoutInProgress = true
        currentExerciseIndex = 0
    }
    
    func nextExercise() {
        guard let workout = selectedWorkout else { return }
        
        if currentExerciseIndex < workout.exercises.count - 1 {
            currentExerciseIndex += 1
        } else {
            // Last exercise completed
            completeWorkout()
        }
    }
    
    func completeWorkout() {
        guard let workout = selectedWorkout else { return }
        
        // Save workout completion
        let completion = WorkoutCompletion(workoutId: workout.id)
        WorkoutCompletionManager.saveCompletion(completion)
        
        // Reset workout state
        isWorkoutInProgress = false
        currentExerciseIndex = 0
    }
    
    func cancelWorkout() {
        isWorkoutInProgress = false
        currentExerciseIndex = 0
    }
    
    // MARK: - Workout Status
    
    func isWorkoutCompletedToday(_ workout: Workout) -> Bool {
        return WorkoutCompletionManager.isWorkoutCompletedToday(workoutId: workout.id)
    }
    
    // MARK: - Current Exercise Information
    
    var currentExercise: Exercise? {
        guard let workout = selectedWorkout,
              currentExerciseIndex < workout.exercises.count else {
            return nil
        }
        
        return workout.exercises[currentExerciseIndex]
    }
    
    var exerciseProgress: Double {
        guard let workout = selectedWorkout else { return 0.0 }
        return Double(currentExerciseIndex) / Double(workout.exercises.count)
    }
    
    var nextExerciseText: String {
        guard let workout = selectedWorkout,
              currentExerciseIndex < workout.exercises.count - 1 else {
            return "Complete Workout"
        }
        
        return "Next: \(workout.exercises[currentExerciseIndex + 1].name)"
    }
    
    // MARK: - Filtered Workouts
    
    func workoutsByDifficulty(_ difficulty: WorkoutDifficulty) -> [Workout] {
        return workouts.filter { $0.difficulty == difficulty }
    }
    
    // Load JSON from a string (for testing purposes)
    func loadWorkoutsFromString(jsonString: String) -> [Workout]? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Failed to convert JSON string to data")
            return nil
        }
        
        let decoder = JSONDecoder()
        
        do {
            let workouts = try decoder.decode([Workout].self, from: jsonData)
            self.workouts = workouts
            return workouts
        } catch {
            print("Error decoding JSON: \(error)")
            return nil
        }
    }
}

// Extension with test/debugging methods
extension WorkoutViewModel {
    // For debugging: print workout details
    func printWorkoutDetails() {
        for workout in workouts {
            print("Workout: \(workout.name)")
            print("- Difficulty: \(workout.difficulty.description)")
            print("- Duration: \(workout.durationMinutes) minutes")
            print("- Rest between exercises: \(workout.restSeconds) seconds")
            print("- Total exercises: \(workout.exercises.count)")
            
            for (index, exercise) in workout.exercises.enumerated() {
                print("  Exercise \(index + 1): \(exercise.name) (\(exercise.type.rawValue))")
                if let reps = exercise.reps {
                    print("  - Repetitions: \(reps)")
                }
                if let seconds = exercise.seconds {
                    print("  - Duration: \(seconds) seconds")
                }
            }
            print("")
        }
    }
}
