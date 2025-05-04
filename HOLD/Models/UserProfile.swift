//
//  UserProfile.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import Foundation

struct UserProfile: Codable {
    var name: String
    var age: Int
    
    // A unique identifier for the user (for internal tracking)
    let id: UUID
    
    init(name: String = "", age: Int = 0, id: UUID = UUID()) {
        self.name = name
        self.age = age
        self.id = id
    }
    
    // Default user for testing and initial app state
    static let defaultUser = UserProfile(
        name: "Guest",
        age: 30,
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000") ?? UUID()
    )
    
    // Static method to load user profile from UserDefaults
    static func load() -> UserProfile {
        if let data = UserDefaults.standard.data(forKey: "userProfile"),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            return profile
        }
        return defaultUser
    }
    
    // Method to save user profile to UserDefaults
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: "userProfile")
        }
    }
    
    // Helper method to check if this is the default user
    var isDefaultUser: Bool {
        return id.uuidString == "00000000-0000-0000-0000-000000000000"
    }
}
