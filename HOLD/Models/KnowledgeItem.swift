//
//  KnowledgeItem.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import Foundation
import SwiftUI

typealias KnowledgeHubData = [KnowledgeCategory]

struct KnowledgeDetail: Codable, Identifiable {
    let id = UUID()
    let image: String
    let content: String
    let header: String
}

struct KnowledgeCategoryItem: Codable, Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let coverImage: String
    let slides: [KnowledgeDetail]
}

struct KnowledgeCategory: Codable, Identifiable {
    var id: String { categoryName }
    let categoryName: String
    let categoryItems: [KnowledgeCategoryItem]
}
