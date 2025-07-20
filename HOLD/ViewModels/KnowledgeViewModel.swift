//
//  KnowledgeViewModel.swift
//  HOLD
//
//  Created by Gemini on 08/04/25. // Adjust date/author
//

import Foundation
import SwiftUI
import FirebaseDatabase


class KnowledgeViewModel: ObservableObject {

    @Published var categories: [KnowledgeCategory] = []
    
    private var databaseRef = Database.database(url: "https://holdknowledgehub2025-90a4a-76812.firebaseio.com").reference()
    
    init() {
        fetchKnowledgeHubData()
    }
    
    func fetchKnowledgeHubData() {
        databaseRef.child("KnowledgeHub").observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists(),
                  let value = snapshot.value as? [[String: Any]] else {
                print("❌ No data found at 'KnowledgeHub'")
                return
            }

            do {
                let data = try JSONSerialization.data(withJSONObject: value)
                let decoded = try JSONDecoder().decode(KnowledgeHubData.self, from: data)

                DispatchQueue.main.async {
                    self.categories = decoded
                }
            } catch {
                print("❌ Decoding error: \(error.localizedDescription)")
            }
        }
    }
}
