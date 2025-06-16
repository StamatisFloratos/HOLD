//
//  StreakBadge.swift
//  HOLD
//
//  Created by Muhammad Ali on 15/06/2025.
//

import Foundation

struct StreakBadge: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String
    let requiredDays: Int
    let imageName: String
    let isEarned: Bool
    let earnedDate: Date?
    
    init(name: String, description: String, requiredDays: Int, imageName: String, isEarned: Bool = false, earnedDate: Date? = nil) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.requiredDays = requiredDays
        self.imageName = imageName
        self.isEarned = isEarned
        self.earnedDate = earnedDate
    }
    
    func withEarnedStatus(isEarned: Bool, earnedDate: Date? = nil) -> StreakBadge {
        return StreakBadge(
            name: self.name,
            description: self.description,
            requiredDays: self.requiredDays,
            imageName: self.imageName,
            isEarned: isEarned,
            earnedDate: earnedDate
        )
    }
}
