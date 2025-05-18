//
//  ShakeEffect.swift
//  HOLD
//
//  Created by Hafiz Muhammad Ali on 11/05/2025.
//

import Foundation
import SwiftUICore

struct ShakeEffect: GeometryEffect {
    var amplitude: CGFloat = 1
    var shakesPerUnit: CGFloat = 2
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = amplitude * sin(animatableData * .pi * shakesPerUnit)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}
