//
//  ChallengeResult.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import Foundation
import SwiftUI

struct ChallengeResult: Identifiable, Codable, Hashable  {
    let id: UUID
    let date: Date
    let duration: TimeInterval
    
    init(date: Date = Date(), duration: TimeInterval) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.duration = duration
    }
    
    // Calculate the percentile based on duration
    var percentile: Double {
        // If duration is over 90 minutes (5400 seconds), return top 0.1%
        if duration >= 5400 {
            return 0.1
        }
        
        // Updated progression curve:
        // 1 second = 100% (complete bottom)
        // 3 minutes = 30% 
        // 10 minutes = 20%
        // 25 minutes = 10%
        // 60 minutes = 1%
        // 90 minutes = 0.1%
        
        // Map time ranges to percentile ranges
        // We'll use a piecewise approach for more precise control
        switch duration {
        case 0..<1:
            return 100.0
        case 1..<180: // 1 second to 3 minutes
            let progress = (duration - 1) / (180 - 1)
            return 100 - (progress * (100 - 30))
        case 180..<600: // 3 minutes to 10 minutes
            let progress = (duration - 180) / (600 - 180)
            return 30 - (progress * (30 - 20))
        case 600..<1500: // 10 minutes to 25 minutes
            let progress = (duration - 600) / (1500 - 600)
            return 20 - (progress * (20 - 10))
        case 1500..<3600: // 25 minutes to 60 minutes
            let progress = (duration - 1500) / (3600 - 1500)
            return 10 - (progress * (10 - 1))
        case 3600..<5400: // 60 minutes to 90 minutes
            let progress = (duration - 3600) / (5400 - 3600)
            return 1 - (progress * (1 - 0.1))
        default:
            return 0.1
        }
    }
    
    // Format the percentile for display
    var percentileDisplay: String {
        if percentile < 0.11 {
            return "0.1%"
        } else {
            return "\(String(format: "%.1f", percentile))%"
        }
    }
    
    // Format duration for display
    var durationDisplay: String {
        timeDisplay(duration: duration.self)
    }
    
    // Rank based on duration
    enum Rank: String, Codable {
        case simp = "Simp"
        case npc = "NPC"
        case huzzer = "Huzzer"
        case rizz = "Rizz"
        case minChad = "MinChad"
        case gigaChad = "GigaChad"
        
        // For UI display - could add emoji or custom descriptions
        var displayName: String {
            return self.rawValue
        }
    }

    // Calculate rank based on duration
    var rank: Rank {
        let seconds = duration
        
        switch seconds {
        case 0..<60: // 0 seconds to 1 minute
            return .simp
        case 60..<180: // 1 minute to 3 minutes
            return .npc
        case 180..<300: // 3 minutes to 5 minutes
            return .huzzer
        case 300..<900: // 5 minutes to 15 minutes
            return .rizz
        case 900..<2400: // 15 minutes to 40 minutes
            return .minChad
        default: // 40+ minutes (2400+ seconds)
            return .gigaChad
        }
    }

    // Format for display
    var rankDisplay: String {
        return rank.displayName
    }
    
    var rankImage: String {
        switch rank {
        case .simp:
            return "simp-rank"
        case .npc:
            return "moderator-rank"
        case .huzzer:
            return "happy-wojak-rank"
        case .rizz:
            return "rizz-rank"
        case .minChad:
            return "minichad-rank"
        case .gigaChad:
            return "giga-chad-rank"
        }
    }
    
    var backgroundColor: [Color] {
        switch rank {
            
        case .simp:
            return [
                Color(hex:"#FFFFFF"),
                Color(hex:"#D7D6D6")
            ]
        case .npc:
            return [
                Color(hex:"#FFFFFF"),
                Color(hex:"#D7D6D6")
            ]
        case .huzzer:
            return [
                Color(hex:"#D92D43"),
                Color(hex:"#FFC602")
            ]
        case .rizz:
            return [
                Color(hex:"#AA6A13"),
                Color(hex:"#F3CE6B")
            ]
        case .minChad:
            return [
                Color(hex:"#4499DA"),
                Color(hex:"#102B47")
            ]
        case .gigaChad:
            return [
                Color(hex:"#0C0E21"),
                Color(hex:"#0D47AE")
            ]
        }
    }
    
    var nextRankValue: TimeInterval {
        switch duration {
        case 0..<60: // 0 seconds to 1 minute
            return 60
        case 60..<180: // 1 minute to 3 minutes
            return 180
        case 180..<300: // 3 minutes to 5 minutes
            return 300
        case 300..<900: // 5 minutes to 15 minutes
            return 900
        case 900..<2400: // 15 minutes to 40 minutes
            return 2400
        default:
            return 2500
        }
    }
    
    var challengeDescription: String {
        switch percentile {
        case 100:
            return "🤨 We got work to do."
        case 50..<100:
            return "🤨 We got work to do."
        case 20..<49.9:
            return "🙂 We’re getting somewhere!"
        case 0.01..<19.9:
            return "😧 That’s really impressive!"
        default:
            return ""
        }
    }
    
    var challengeColor: [Color] {
        switch percentile {
        case 0.01..<19.9: return [
            Color(hex:"#16D700"),
            Color(hex:"#0B7100")
        ]
        case 20..<49.9: return [
            Color(hex:"#D7B700"),
            Color(hex:"#716000")
        ]
        
        case 50..<100: return [
            Color(hex:"#FF1919"),
            Color(hex:"#990F0F")
        ]
        default:
            return [
                Color(hex:"#FF1919"),
                Color(hex:"#990F0F")
            ]
        }
    }
    
    func timeDisplay(duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let remainingSeconds = Int(duration) % 60

        if minutes > 0 && remainingSeconds > 0 {
            return "\(minutes)m \(remainingSeconds)s"
        } else if minutes > 0 && remainingSeconds == 0 {
            return "\(minutes)m"
        }
        else {
            return "\(remainingSeconds)s"
        }
    }
    
    func timeDisplayForProgress(duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let remainingSeconds = Int(duration) % 60

        if minutes > 0 && remainingSeconds > 0 {
            return "\(minutes) mins \(remainingSeconds) sec"
        } else if minutes > 0 && remainingSeconds == 0 {
            return "\(minutes) mins"
        }
        else {
            return "\(remainingSeconds) sec"
        }
    }
    
    func dateOfChallenge() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        let dateString = formatter.string(from: date)

        return dateString // → "May 18, 2025"
    }
}
