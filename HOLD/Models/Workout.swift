//
//  Workout.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import Foundation
import SwiftUICore

enum WorkoutDifficulty: String, Codable, CaseIterable {
    case easy
    case medium
    case hard
    
    var description: String {
        switch self {
        case .easy: return "Easy 🙂"
        case .medium: return "Medium 😭"
        case .hard: return "Hard 😩"
        }
    }
    
    var descriptionSimple: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
    
    var color: [Color] {
        switch self {
        case .easy: return [
            Color(hex:"#16D700"),
            Color(hex:"#0B7100")
        ]
        case .medium: return [
            Color(hex:"#D7B700"),
            Color(hex:"#716000")
        ]
        case .hard: return [
            Color(hex:"#FF1919"),
            Color(hex:"#990F0F")
        ]
        }
    }
}

struct Workout: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let difficulty: WorkoutDifficulty
    let durationMinutes: Int
    let description: String
    let exercises: [Exercise]
    let restSeconds: Int
    
    // Computed property to get total time including rest periods
    var totalTimeSeconds: Int {
        let exerciseTime = exercises.reduce(0) { total, exercise in
            switch exercise.type {
            case .hold:
                return total + (exercise.seconds ?? 0)
            case .clamp, .rapidFire, .flash:
                // Estimate time based on reps and rhythm parameters
                let rhythm = exercise.getRhythmParameters()
                return total + Int((Double(exercise.reps ?? 0) * rhythm.duration))
            case .rest:
                return total + (exercise.seconds ?? 0)
            }
        }
        
        // Add rest time between exercises (rest after each exercise except the last one)
        let restTime = restSeconds * max(0, exercises.count - 1)
        
        return exerciseTime + restTime
    }
    
    init(id: String, 
         name: String, 
         difficulty: WorkoutDifficulty, 
         durationMinutes: Int, 
         description: String = "", 
         exercises: [Exercise], 
         restSeconds: Int = 30) {
        self.id = id
        self.name = name
        self.difficulty = difficulty
        self.durationMinutes = durationMinutes
        self.description = description
        self.exercises = exercises
        self.restSeconds = restSeconds
    }
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Workout, rhs: Workout) -> Bool {
        lhs.id == rhs.id
    }
}

// Separate struct to track workout completion status
struct WorkoutCompletion: Codable, Identifiable {
    let id: UUID
    let workoutName: String
    let date: Date
    let completed: Bool
    
    init(id: UUID = UUID(), workoutName: String, date: Date = Date(), completed: Bool = true) {
        self.id = id
        self.workoutName = workoutName
        self.date = date
        self.completed = completed
    }
}

// Class to manage workout completions
class WorkoutCompletionManager {
    private static let completionsKey = "workoutCompletions"
    
    // Save a workout completion
    static func saveCompletion(_ completion: WorkoutCompletion) {
        var completions = getCompletions()
        completions.append(completion)
        saveCompletions(completions)
    }
    
    // Get all workout completions
    static func getCompletions() -> [WorkoutCompletion] {
        guard let data = UserDefaults.standard.data(forKey: completionsKey),
              let completions = try? JSONDecoder().decode([WorkoutCompletion].self, from: data) else {
            return []
        }
        return completions
    }
    
    // Save all workout completions
    private static func saveCompletions(_ completions: [WorkoutCompletion]) {
        if let data = try? JSONEncoder().encode(completions) {
            UserDefaults.standard.set(data, forKey: completionsKey)
        }
    }
    
    // Check if a workout was completed today
    static func isWorkoutCompletedToday(workoutName: String) -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        
        return getCompletions().contains(where: { completion in
            completion.workoutName == workoutName &&
            completion.completed &&
            Calendar.current.isDate(completion.date, inSameDayAs: today)
        })
    }
    
    // Get workouts completed on a specific date
    static func getCompletionsForDate(_ date: Date) -> [WorkoutCompletion] {
        return getCompletions().filter { completion in
            Calendar.current.isDate(completion.date, inSameDayAs: date)
        }
    }
}

// MARK: - Sample Data

extension Workout {
    static let sampleWorkouts: [Workout] = [
        Workout(
            id: "Beginner's Routine",
            name: "Beginner's Routine",
            difficulty: .easy,
            durationMinutes: 5,
            description: "A gentle introduction to kegel exercises",
            exercises: [
                Exercise.clamp(reps: 5),
                Exercise.hold(seconds: 5),
                Exercise.flash(reps: 10)
            ]
        ),
        Workout(
            id: "Daily Maintenance",
            name: "Daily Maintenance",
            difficulty: .medium,
            durationMinutes: 10,
            description: "Regular practice to maintain pelvic floor strength",
            exercises: [
                Exercise.clamp(reps: 10),
                Exercise.rapidFire(reps: 15),
                Exercise.hold(seconds: 10),
                Exercise.flash(reps: 15)
            ]
        ),
        Workout(
            id: "Advanced Strengthening",
            name: "Advanced Strengthening",
            difficulty: .hard,
            durationMinutes: 15,
            description: "Intensive workout for experienced practitioners",
            exercises: [
                Exercise.clamp(reps: 15),
                Exercise.hold(seconds: 20),
                Exercise.rapidFire(reps: 30),
                Exercise.flash(reps: 20),
                Exercise.hold(seconds: 30)
            ]
        )
    ]
}
