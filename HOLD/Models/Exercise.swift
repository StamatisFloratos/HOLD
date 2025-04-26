//
//  Exercise.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import Foundation

enum ExerciseType: String, Codable, CaseIterable {
    case clamp
    case rapidFire
    case flash
    case hold
    case rest
}

struct Exercise: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let type: ExerciseType
    let description: String
    
    // Parameter for clamp, rapid fire, and flash (number of repetitions)
    let reps: Int?
    
    // Parameter for hold (duration in seconds)
    let seconds: Int?
    
    var isValid: Bool {
        switch type {
        case .clamp, .rapidFire, .flash:
            return reps != nil && reps! > 0
        case .hold:
            return seconds != nil && seconds! > 0
        case .rest:
            return seconds != nil && seconds! > 0
        }
    }
    
    init(id: UUID = UUID(), name: String, type: ExerciseType, description: String = "", reps: Int? = nil, seconds: Int? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.description = description
        
        // Set the appropriate parameter based on exercise type
        switch type {
        case .clamp, .rapidFire, .flash:
            self.reps = reps
            self.seconds = nil
        case .hold:
            self.reps = nil
            self.seconds = seconds
        case .rest:
            self.reps = nil
            self.seconds = seconds
        }
    }
    
    // Helper function to get the rhythm parameters (can be used in view models)
    func getRhythmParameters() -> (duration: Double, intensity: Double) {
        switch type {
        case .clamp:
            return (duration: 3.0, intensity: 0.5)  // Slower, smooth pulsating
        case .rapidFire:
            return (duration: 1.0, intensity: 0.7)  // Fast pulsating
        case .flash:
            return (duration: 2.0, intensity: 0.9)  // Abrupt, medium-speed pulsating
        case .hold:
            return (duration: 0.5, intensity: 1.0)  // Steady state for holding
        case .rest:
            return (duration: 0.5, intensity: 1.0)
        }
    }
    
    // Factory methods for creating standard exercises
    static func clamp(name: String = "Clamp", reps: Int = 10, description: String = "Slow and controlled contractions") -> Exercise {
        Exercise(name: name, type: .clamp, description: description, reps: reps)
    }
    
    static func rapidFire(name: String = "Rapid Fire", reps: Int = 20, description: String = "Quick, rhythmic contractions") -> Exercise {
        Exercise(name: name, type: .rapidFire, description: description, reps: reps)
    }
    
    static func flash(name: String = "Flash", reps: Int = 15, description: String = "Sharp, distinct contractions") -> Exercise {
        Exercise(name: name, type: .flash, description: description, reps: reps)
    }
    
    static func hold(name: String = "Hold", seconds: Int = 10, description: String = "Sustained contraction") -> Exercise {
        Exercise(name: name, type: .hold, description: description, seconds: seconds)
    }
    static func rest(name: String = "Rest", seconds: Int = 10, description: String = "Rest") -> Exercise {
        Exercise(name: name, type: .hold, description: description, seconds: seconds)
    }
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        lhs.id == rhs.id
    }
    
    // MARK: - Sample Exercises
    
    static let sampleExercises: [Exercise] = [
        clamp(reps: 10),
        rapidFire(reps: 20),
        flash(reps: 15),
        hold(seconds: 10)
    ]
    
    var textForScreen: String {
        switch type {
            
        case .clamp:
            return "Contract & Let Go"
        case .rapidFire:
            return "Contract & Let Go"
        case .flash:
            return "Contract & Let Go"
        case .hold:
            return "Contract & Hold"
        case .rest:
            return "Rest"
        }
    }
}
