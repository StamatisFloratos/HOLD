//
//  VisualEffectBlur.swift
//  HOLD
//
//  Created by Muhammad Ali on 07/07/2025.
//

import Foundation
import SwiftUI

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    var alpha: Double
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
        view.alpha = alpha
        return view
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
