//
//  FindLocationView.swift
//  HOLD
//
//  Created by Rabbia Ijaz on 06/05/2025.
//

import SwiftUI

struct FindLocationView: View {
    @State private var showNextView = false
    @State private var currentStep = 1
    private let totalSteps = 3

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
                VStack {
                    ProgressBar(currentStep: currentStep, totalSteps: totalSteps)
                        .padding(.top, 32)
                        .padding(.bottom, 16)
                    
                    Spacer()
                    
                    //            Group {
                    //                switch currentStep {
                    //                case 0: print("1")
                    //                case 1: print("2")
                    //                case 2: print("3")
                    //                default: EmptyView()
                    //                }
                    //            }
                    //            .animation(.easeInOut, value: currentStep)
                    //            .transition(.slide)
                    
                    Spacer()
                    
                    Button(action: {
                        if currentStep < totalSteps - 1 {
                            currentStep += 1
                        }
                    }) {
                        Text(currentStep == totalSteps - 1 ? "Finish" : "Next")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 32)
                }
            }
        }
    }
}

struct ProgressBar: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index <= currentStep ? Color.white : Color.gray.opacity(0.3))
                    .frame(height: 4)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    FindLocationView()
}
