//
//  BeforeWeStartView.swift
//  HOLD
//
//  Created by Rabbia Ijaz on 05/05/2025.
//

import SwiftUI

struct BeforeWeStartView: View {
    @State private var showNextView = false
    

    var body: some View {
        ZStack {
            
            GeometryReader { geometry in
                let height = geometry.size.height

                VStack(spacing: 0) {
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "#990000"), Color(hex: "#FF0000")]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .frame(height: height) // Ensures it fills parent
            }
            .ignoresSafeArea()
            
            if showNextView {
                MainTabView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                    .zIndex(1)
            } else {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        HStack {
                            Spacer()
                            Image("holdIcon")
                            Spacer()
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 14)
                    }
                    Spacer()
                    VStack(spacing: 0) {
                        Image("handIcon")
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal,84)
//                            .padding(.top, 59)
                            .padding(.bottom, 25)
                        Text("Before We Start")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 34)
                            .padding(.horizontal,22)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 8)
                        Text("If you’re not targeting the right spot, nothing works. Please read the next screens carefully as they will help you locate your Pelvic Floor (PF) muscles.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white)
                            .padding(.top, 34)
                            .padding(.horizontal,32)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 8)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showNextView = true
                    }) {
                        Text("I’m ready to find PF muscles")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity, maxHeight: 47)
                            .background(Color(hex: "#FFFFFF"))
                            .foregroundColor(Color(hex: "#111720"))
                            .cornerRadius(30)
                            .padding(.horizontal, 56)
                    }
                    .padding(.bottom, 32)
                    .padding(.top)
                    
                    
                }
            }
        }
    }
    
    @ViewBuilder
    private func benefitRow(text: String) -> some View {
        HStack(spacing: 11) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color(hex: "#FF1919"))
                .font(.system(size: 22))
            Text(text)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .medium))
        }
    }
}

#Preview {
    BeforeWeStartView()
}
