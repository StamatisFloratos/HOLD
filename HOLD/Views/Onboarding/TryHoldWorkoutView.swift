//
//  TryHoldWorkoutView.swift
//  HOLD
//
//  Created by Rabbia Ijaz on 05/05/2025.
//

import SwiftUI

struct TryHoldWorkoutView: View {
    @State private var showNextView = false
    

    var body: some View {
        ZStack {
            AppBackground()
            if showNextView {
                BeforeWeStartView()
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
                    VStack(spacing: 0) {
                        Image("Try a HOLD Workout Icon")
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal,0)
                            .padding(.top, 59)
                            .padding(.bottom, 25)
                        Text("Take the first step toward a great new sex life")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.top, 34)
                            .padding(.horizontal,22)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 8)
                        Image("Try a HOLD Workout")
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal,85)
                        VStack(alignment: .leading, spacing: 18) {
                            benefitRow(text: "Train wherever you are")
                            benefitRow(text: "Takes 2 minutes ")
                            benefitRow(text: "The difficulty adjusts to you")
                        }.padding(.top, 53)

                        
                        
                        Spacer()
                        
                        Button(action: {
                            triggerHaptic()
                            withAnimation {
                                showNextView = true
                            }
                        }) {
                            Text("Start Workout")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity, maxHeight: 47)
                                .background(Color(hex: "#FF1919"))
                                .foregroundColor(.white)
                                .cornerRadius(30)
                                .padding(.horizontal, 56)
                        }
                        .padding(.bottom, 32)
                        .padding(.top)
                        
                    }
                }
            }
        }
        .animation(.easeInOut, value: showNextView)
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
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}

#Preview {
    TryHoldWorkoutView()
}
