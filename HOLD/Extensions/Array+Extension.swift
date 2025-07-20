//
//  Array+Extension.swift
//  HOLD
//
//  Created by Muhammad Ali on 08/07/2025.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
