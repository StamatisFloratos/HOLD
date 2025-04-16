//
//  KnowledgeItem.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import Foundation
import SwiftUI

struct KnowledgeWrapper: Codable {
    let category: String
    let item: KnowledgeItem
}

struct KnowledgeItem: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let imageName: String
    let shortDescription: String
    let longText: String
    
    init(id: UUID = UUID(), title: String, imageName: String, shortDescription: String, longText: String) {
        self.id = id
        self.title = title
        self.imageName = imageName
        self.shortDescription = shortDescription
        self.longText = longText
    }
    
    // Computed property to get the Image from the image name
    var image: Image {
        Image(imageName)
    }
    
    // Required for Hashable conformance when using UUID
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Required for Equatable (which Hashable inherits from)
    static func == (lhs: KnowledgeItem, rhs: KnowledgeItem) -> Bool {
        lhs.id == rhs.id
    }
    
    // Sample data for previews and testing
    static let sampleItems: [KnowledgeItem] = [
        KnowledgeItem(
            title: "What are Kegel Exercises?",
            imageName: "kegel_intro",
            shortDescription: "Learn about the basics of Kegel exercises and why they're important.",
            longText: """
            Kegel exercises are designed to strengthen your pelvic floor muscles. These muscles support your bladder, urethra, uterus (if applicable), and rectum.
            
            Originally developed by Dr. Arnold Kegel in the 1940s, these exercises have been proven to help with urinary incontinence, improve sexual health, and support overall pelvic health.
            
            To perform a Kegel exercise, you tighten, hold, and then relax the pelvic floor muscles. With regular practice, these muscles become stronger over time.
            """
        ),
        KnowledgeItem(
            title: "Benefits of Regular Practice",
            imageName: "benefits",
            shortDescription: "Discover how consistent Kegel training can improve your health.",
            longText: """
            Regular practice of Kegel exercises can lead to numerous health benefits:
            
            1. Improved bladder control and reduced urinary incontinence
            2. Enhanced sexual performance and sensation
            3. Prevention of pelvic organ prolapse
            4. Faster recovery after prostate surgery
            5. Better core stability and overall pelvic health
            
            Studies show that most people begin to see improvements within 3-6 weeks of regular practice, with significant benefits appearing after 2-3 months of consistent training.
            """
        )
    ]
}
