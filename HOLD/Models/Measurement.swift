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
    var durationSeconds: Double
    
    init(id: UUID, date: Date, durationSeconds: Double) {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
        self.durationSeconds = durationSeconds
    }
}
