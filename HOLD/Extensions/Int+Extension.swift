//
//  Int+Extension.swift
//  HOLD
//
//  Created by Muhammad Ali on 08/07/2025.
//

import Foundation

extension Int {
    func ordinalSuffix() -> String {
        let ones = self % 10
        let tens = (self / 10) % 10
        if tens == 1 {
            return "th"
        }
        switch ones {
        case 1: return "st"
        case 2: return "nd"
        case 3: return "rd"
        default: return "th"
        }
    }
}
