//
//  Measurement.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import Foundation

struct Measurement: Codable, Identifiable {
    let id: UUID
    let date: Date
    let duration: TimeInterval
    
    init(date: Date = Date(), duration: TimeInterval) {
        self.id = UUID()
        self.date = date
        self.duration = duration
    }
}
