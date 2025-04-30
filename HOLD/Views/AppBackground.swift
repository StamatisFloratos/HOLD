//
//  AppBackground.swift
//  HOLD
//
//  Created by Rabbia Ijaz on 30/04/2025.
//

import SwiftUI
struct AppBackground: View {
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height

            VStack(spacing: 0) {
                Color(hex: "#10171F")
                    .frame(height: height * 0.43)

                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#10171F"), Color(hex: "#466085")]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: height * 0.57)
            }
            .frame(height: height) // Ensures it fills parent
        }
        .ignoresSafeArea()
    }
}
