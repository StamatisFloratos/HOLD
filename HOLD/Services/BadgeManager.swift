//
//  BadgeManager.swift
//  HOLD
//
//  Created by Muhammad Ali on 15/06/2025.
//

import Foundation

class BadgeManager: ObservableObject {
    @Published var badges: [StreakBadge] = []
    @Published var nextBadgeToUnlock: StreakBadge?
    
    private let badgesKey = "streak_badges_key"
    
    init() {
        loadBadges()
        updateNextBadgeToUnlock()
    }
    
    private func createDefaultBadges() -> [StreakBadge] {
        return [
            StreakBadge(
                name: "Week Warrior",
                description: "Complete 7 days in a row",
                requiredDays: 7,
                imageName: "badge_1_week"
            ),
            StreakBadge(
                name: "Two Week Champion",
                description: "Complete 14 days in a row",
                requiredDays: 14,
                imageName: "badge_2_weeks"
            ),
            StreakBadge(
                name: "Monthly Master",
                description: "Complete 30 days in a row",
                requiredDays: 30,
                imageName: "badge_1_month"
            ),
            StreakBadge(
                name: "Two Month Hero",
                description: "Complete 60 days in a row",
                requiredDays: 60,
                imageName: "badge_2_months"
            ),
            StreakBadge(
                name: "Three Month Legend",
                description: "Complete 90 days in a row",
                requiredDays: 90,
                imageName: "badge_3_months"
            ),
            StreakBadge(
                name: "Half Year Champion",
                description: "Complete 180 days in a row",
                requiredDays: 180,
                imageName: "badge_6_months"
            ),
            StreakBadge(
                name: "Year Long Warrior",
                description: "Complete 365 days in a row",
                requiredDays: 365,
                imageName: "badge_1_year"
            )
        ]
    }
    
    func checkAndAwardBadges(for currentStreak: Int) -> [StreakBadge] {
        var newlyEarnedBadges: [StreakBadge] = []
        
        for (index, badge) in badges.enumerated() {
            if !badge.isEarned && currentStreak >= badge.requiredDays {
                let earnedBadge = badge.withEarnedStatus(isEarned: true, earnedDate: Date())
                badges[index] = earnedBadge
                newlyEarnedBadges.append(earnedBadge)
            }
        }
        
        if !newlyEarnedBadges.isEmpty {
            saveBadges()
            updateNextBadgeToUnlock()
        }
        
        return newlyEarnedBadges
    }
    
    private func updateNextBadgeToUnlock() {
        nextBadgeToUnlock = badges.first { !$0.isEarned }
        
        if nextBadgeToUnlock == nil {
            print("🏆 All badges have been earned!")
        }
    }
    
    func getEarnedBadges() -> [StreakBadge] {
        return badges.filter { $0.isEarned }
    }
    
    func getUnearnedBadges() -> [StreakBadge] {
        return badges.filter { !$0.isEarned }
    }
    
    func getBadgeProgress(for currentStreak: Int) -> (current: Int, target: Int, progress: Double)? {
        guard let nextBadge = nextBadgeToUnlock else { return nil }
        
        let progress = min(Double(currentStreak) / Double(nextBadge.requiredDays), 1.0)
        return (current: currentStreak, target: nextBadge.requiredDays, progress: progress)
    }
    
    func getTotalBadgesEarned() -> Int {
        return badges.filter { $0.isEarned }.count
    }
    
    func getTotalBadgesAvailable() -> Int {
        return badges.count
    }
    
    private func saveBadges() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let data = try encoder.encode(badges)
            UserDefaults.standard.set(data, forKey: badgesKey)
            print("Successfully saved \(badges.count) badges to UserDefaults")
        } catch {
            print("Error saving badges to UserDefaults: \(error)")
        }
    }
    
    private func loadBadges() {
        if let data = UserDefaults.standard.data(forKey: badgesKey) {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                badges = try decoder.decode([StreakBadge].self, from: data)
                print("Successfully loaded \(badges.count) badges from UserDefaults")
                
                ensureAllBadgesExist()
                
            } catch {
                print("Error loading badges from UserDefaults: \(error)")
                badges = createDefaultBadges()
                saveBadges()
            }
        } else {
            badges = createDefaultBadges()
            saveBadges()
            print("Created default badges for first time setup")
        }
    }
    
    private func ensureAllBadgesExist() {
        let defaultBadges = createDefaultBadges()
        let currentRequiredDays = Set(badges.map { $0.requiredDays })
        let defaultRequiredDays = Set(defaultBadges.map { $0.requiredDays })
        
        let missingRequiredDays = defaultRequiredDays.subtracting(currentRequiredDays)
        
        if !missingRequiredDays.isEmpty {
            for defaultBadge in defaultBadges {
                if missingRequiredDays.contains(defaultBadge.requiredDays) {
                    badges.append(defaultBadge)
                }
            }
            
            badges.sort { $0.requiredDays < $1.requiredDays }
            saveBadges()
            print("Added \(missingRequiredDays.count) missing badges")
        }
    }
    
    func resetAllBadges() {
        badges = createDefaultBadges()
        saveBadges()
        updateNextBadgeToUnlock()
        print("All badges have been reset")
    }
    
    func clearBadgeData() {
        UserDefaults.standard.removeObject(forKey: badgesKey)
        badges = createDefaultBadges()
        updateNextBadgeToUnlock()
        print("Badge data cleared from UserDefaults")
    }
    
    func printBadgeStatus() {
        print("\n=== BADGE STATUS ===")
        for badge in badges {
            let status = badge.isEarned ? "✅ EARNED" : "⏳ LOCKED"
            let earnedInfo = badge.isEarned ? " (Earned: \(badge.earnedDate?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown"))" : ""
            print("\(status) \(badge.name) - \(badge.requiredDays) days\(earnedInfo)")
        }
        
        if let nextBadge = nextBadgeToUnlock {
            print("\n🎯 Next Badge: \(nextBadge.name) (\(nextBadge.requiredDays) days)")
        } else {
            print("\n🏆 All badges earned!")
        }
        
        print("📊 Progress: \(getTotalBadgesEarned())/\(getTotalBadgesAvailable()) badges earned")
        print("==================\n")
    }
}
