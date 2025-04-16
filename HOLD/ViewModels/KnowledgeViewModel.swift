//
//  KnowledgeViewModel.swift
//  HOLD
//
//  Created by Gemini on 08/04/25. // Adjust date/author
//

import Foundation
import SwiftUI // Needed for KnowledgeItem if it imports SwiftUI

class KnowledgeViewModel: ObservableObject {

    @Published var groupedKnowledgeData: [String: [KnowledgeItem]] = [:]
    @Published var sortedCategories: [String] = []

    init() {
        loadAndGroupData() // Load data when the ViewModel is initialized
    }

    // --- Data Loading and Grouping Logic ---
    private func loadAndGroupData() {
        // 1. Load the array of KnowledgeWrapper objects directly from the JSON file
        //    Make sure the filename matches exactly what you created (e.g., "knowledge_data.json")
        let allWrappers: [KnowledgeWrapper] = load("knowledge_sample.json") ?? []

        // If loading fails, allWrappers will be empty, preventing crashes.
        if allWrappers.isEmpty {
            print("Warning: Failed to load or parse knowledge data. No items to display.")
            // Optionally, set some default error state or empty data here
            // self.groupedKnowledgeData = [:]
            // self.sortedCategories = []
            // return // Or continue with empty data
        }

        // 2. Group the loaded wrappers by category (This part remains the same)
        var groupedData: [String: [KnowledgeItem]] = [:]
        for wrapper in allWrappers {
            groupedData[wrapper.category, default: []].append(wrapper.item)
            // Optional: Sort items within each category
            // groupedData[wrapper.category]?.sort(by: { $0.title < $1.title })
        }

        // 3. Update the published properties (This part remains the same)
        DispatchQueue.main.async {
            self.groupedKnowledgeData = groupedData
            self.sortedCategories = groupedData.keys.sorted() // Or your specific sort order
        }
    }

    // --- End Data Logic ---
}

// Add this outside the KnowledgeViewModel class, or in a Bundle extension file

func load<T: Decodable>(_ filename: String) -> T? {
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil) else {
        print("Error: Couldn't find \(filename) in main bundle.")
        return nil
    }

    let data: Data
    do {
        data = try Data(contentsOf: file)
    } catch {
        print("Error: Couldn't load \(filename) from main bundle:\n\(error)")
        return nil
    }

    do {
        let decoder = JSONDecoder()
        // Optional: Add date/key decoding strategies if needed
        // decoder.dateDecodingStrategy = .iso8601
        // decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    } catch {
        print("Error: Couldn't decode \(filename) as \(T.self):\n\(error)")
        return nil
    }
}
