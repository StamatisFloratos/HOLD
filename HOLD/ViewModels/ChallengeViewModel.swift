//
//  ChallengeViewModel.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import Foundation
import SwiftUI

class ChallengeViewModel: ObservableObject {
    @Published var allChallengeResults: [ChallengeResult] = []
    @Published var bestChallengeResult: ChallengeResult = ChallengeResult(duration: 0)
    @Published var latestChallengeResult: ChallengeResult? = nil
    
    init() {
        loadChallengeResults()
    }
    
    // MARK: - Challenge Results Management
    
    func challengeDidFinish(duration: TimeInterval) {
        print("Challenge completed with duration: \(duration) seconds")
        
        // Create new result
        let newResult = ChallengeResult(duration: duration)
        
        // Add to our collection
        allChallengeResults.append(newResult)
        
        // Update latest and best results
        latestChallengeResult = newResult
        if bestChallengeResult.duration == 0 || duration > bestChallengeResult.duration {
            bestChallengeResult = newResult
        }
        
        // Save to persistent storage
        saveChallengeResultsToFile()
        
        print("Successfully saved challenge result: \(duration) seconds, rank: \(newResult.rankDisplay)")
    }
    
    // MARK: - File Persistence
    
    private var challengeResultsFileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("challenge_results.json")
    }
    
    private func saveChallengeResultsToFile() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(allChallengeResults)
            try data.write(to: challengeResultsFileURL, options: [.atomicWrite])
            print("Successfully saved \(allChallengeResults.count) challenge results")
        } catch {
            print("Error saving challenge results: \(error)")
        }
    }
    
    private func loadChallengeResults() {
        guard FileManager.default.fileExists(atPath: challengeResultsFileURL.path) else {
            print("Challenge results file not found, starting fresh.")
            return
        }
        
        do {
            let data = try Data(contentsOf: challengeResultsFileURL)
            let decoder = JSONDecoder()
            allChallengeResults = try decoder.decode([ChallengeResult].self, from: data)
            
            // Set latest and best results
            latestChallengeResult = allChallengeResults.last ?? ChallengeResult(duration: 0)
            bestChallengeResult = allChallengeResults.max(by: { $0.duration < $1.duration }) ?? ChallengeResult(duration: 0)
            
            print("Successfully loaded \(allChallengeResults.count) challenge results")
        } catch {
            print("Error loading or decoding challenge results: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    
    var allChallengeResultsSorted: [ChallengeResult] {
        return allChallengeResults.sorted(by: { $0.date > $1.date })
    }
    
    var bestRank: String {
        return bestChallengeResult.rankDisplay
    }
    
    var bestDuration: String {
        return bestChallengeResult.durationDisplay
    }
    
    func lastAttemptedChallengeDateString() -> String {
        guard let lastResult = allChallengeResultsSorted.first else {
            return "Never"
        }
        let calendar = Calendar.current
        if calendar.isDateInToday(lastResult.date) {
            return "Today"
        } else if calendar.isDateInYesterday(lastResult.date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM yyyy"
            return formatter.string(from: lastResult.date)
        }
    }
}
