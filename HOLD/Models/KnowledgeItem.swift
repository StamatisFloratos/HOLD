//
//  KnowledgeItem.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import Foundation
import SwiftUI

import Foundation

struct KnowledgeItem: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let imageName: String
    let article: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case imageName
        case article
    }
}

