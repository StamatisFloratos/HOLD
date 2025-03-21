//
//  ChallengeResult.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import Foundation

struct ChallengeResult: Codable, Identifiable {
    let id: UUID
    let date: Date
    let duration: TimeInterval
    
    init(date: Date = Date(), duration: TimeInterval) {
        self.id = UUID()
        self.date = date
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
            return "Top 0.1%"
        } else {
            return "Top \(String(format: "%.1f", percentile))%"
        }
    }
    
    // Format duration for display
    var durationDisplay: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes)m \(seconds)s"
    }
}
