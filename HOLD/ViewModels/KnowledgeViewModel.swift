//
//  KnowledgeViewModel.swift
//  HOLD
//
//  Created by Gemini on 08/04/25. // Adjust date/author
//

import Foundation
import SwiftUI

class KnowledgeViewModel: ObservableObject {

    @Published var groupedKnowledgeData: [String: [KnowledgeItem]] = [:]
    @Published var sortedCategories: [String] = []

    init() {
        loadAndGroupData()
    }

    private func loadAndGroupData() {
        // Directly load [String: [KnowledgeItem]] from JSON
        let loadedData: [String: [KnowledgeItem]]? = load("knowledge_sample.json")

        guard let loadedData else {
            print("Warning: Failed to load or parse knowledge data.")
            return
        }

        DispatchQueue.main.async {
            self.groupedKnowledgeData = loadedData
            self.sortedCategories = loadedData.keys.sorted() // You can customize sorting if needed
        }
    }
}

// --- JSON Loading Helper ---

func load<T: Decodable>(_ filename: String) -> T? {
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil) else {
        print("Error: Couldn't find \(filename) in main bundle.")
        return nil
    }

    do {
        let data = try Data(contentsOf: file)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        print("Error: Couldn't load and decode \(filename):\n\(error)")
        return nil
    }
}
