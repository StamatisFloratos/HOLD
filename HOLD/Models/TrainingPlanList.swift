import Foundation

struct TrainingPlanListItem: Identifiable {
    let id: String
    let name: String
    let description: String
    let duration: Int
    let isCompleted: Bool
    let isCurrent: Bool
    let isLocked: Bool
    let cardImage: String?
} 