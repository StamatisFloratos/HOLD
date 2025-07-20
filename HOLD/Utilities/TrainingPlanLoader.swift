import Foundation

class TrainingPlanLoader {
    static func loadWorkouts() -> [String: Workout] {
        guard let url = Bundle.main.url(forResource: "test_workout_hold", withExtension: "json") else { return [:] }
        do {
            let data = try Data(contentsOf: url)
            // Use temp structs for robust decoding
            struct TempWorkout: Codable {
                let id: String
                let name: String
                let difficulty: String
                let durationMinutes: Int
                let restSeconds: Int
                let description: String
                let exercises: [TempExercise]
            }
            struct TempExercise: Codable {
                let name: String
                let reps: Int?
                let seconds: Int?
            }
            let decoder = JSONDecoder()
            let tempWorkouts = try decoder.decode([TempWorkout].self, from: data)
            var workouts: [Workout] = []
            for tempWorkout in tempWorkouts {
                let difficultyEnum: WorkoutDifficulty
                switch tempWorkout.difficulty.lowercased() {
                case "easy": difficultyEnum = .easy
                case "medium": difficultyEnum = .medium
                case "hard": difficultyEnum = .hard
                default: difficultyEnum = .medium
                }
                var exercisesList: [Exercise] = []
                for tempExercise in tempWorkout.exercises {
                    let exerciseType: ExerciseType
                    switch tempExercise.name.lowercased() {
                    case "clamp": exerciseType = .clamp
                    case "rapid fire": exerciseType = .rapidFire
                    case "flash": exerciseType = .flash
                    case "hold": exerciseType = .hold
                    case "rest": exerciseType = .rest
                    default:
                        if let matchingType = ExerciseType(rawValue: tempExercise.name.lowercased()) {
                            exerciseType = matchingType
                        } else {
                            exerciseType = .clamp
                        }
                    }
                    let exercise = Exercise(
                        id: UUID(),
                        name: tempExercise.name,
                        type: exerciseType,
                        description: "",
                        reps: tempExercise.reps,
                        seconds: tempExercise.seconds
                    )
                    exercisesList.append(exercise)
                }
                let workout = Workout(
                    id: tempWorkout.id,
                    name: tempWorkout.name,
                    difficulty: difficultyEnum,
                    durationMinutes: tempWorkout.durationMinutes,
                    description: tempWorkout.description,
                    exercises: exercisesList,
                    restSeconds: tempWorkout.restSeconds
                )
                workouts.append(workout)
            }
            return Dictionary(uniqueKeysWithValues: workouts.map { ($0.id, $0) })
        } catch {
            print("Failed to load workouts: \(error)")
            return [:]
        }
    }

    static func loadAllPlans() -> [TrainingPlan] {
        guard let url = Bundle.main.url(forResource: "TrainingPlans", withExtension: "json") else { return [] }
        do {
            let data = try Data(contentsOf: url)
            let wrapper = try JSONDecoder().decode(TrainingPlansWrapper.self, from: data)
            return wrapper.workoutPrograms
        } catch {
            print("Failed to load plans: \(error)")
            return []
        }
    }
}
