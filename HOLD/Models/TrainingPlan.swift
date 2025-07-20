import Foundation

struct TrainingPlansWrapper: Codable {
    let workoutPrograms: [TrainingPlan]
}

struct TrainingDay: Codable {
    let dayIndex: Int
    let workoutId: String
    let showPracticeMeasurement: Bool
    let showPracticeChallenge: Bool
}

struct TrainingPlan: Codable, Identifiable {
    let id: String
    let name: String
    let duration: Int
    let difficulty: String
    let summary: String
    let description: String
    let unlockRequirement: String?
    let days: [TrainingDay]
    let image: String?
} 
