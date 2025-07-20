//
//  String+Extension.swift
//  HOLD
//
//  Created by Muhammad Ali on 18/07/2025.
//

import Foundation

extension String {
    var camelCased: String {
        let parts = self.components(separatedBy: CharacterSet.alphanumerics.inverted)
        let first = parts.first?.lowercased() ?? ""
        let rest = parts.dropFirst().map { $0.capitalized }
        return ([first] + rest).joined()
    }
}
