//
//  ColorExtension.swift
//  HOLD
//
//  Created by Rabbia Ijaz on 09/04/2025.
//

import SwiftUICore

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: Double
        if hex.count == 6 {
            r = Double((int >> 16) & 0xFF) / 255
            g = Double((int >> 8) & 0xFF) / 255
            b = Double(int & 0xFF) / 255
        } else {
            r = 1; g = 1; b = 1 // fallback white
        }

        self.init(red: r, green: g, blue: b)
    }
}
