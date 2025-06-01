//
//  WorkoutFinishView.swift
//  HOLD
//
//  Created by Rabbia Ijaz on 08/05/2025.
//


import Foundation
import SwiftUI

struct ProgressFinishView: View {
    @State private var showNextView = false
    @State private var animatedProgress: Double = 0.0
    
    var body: some View {
        ZStack {
            AppBackground()
            if showNextView {
                ReviewView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                    .zIndex(1)
            } else {
                VStack{
                    HStack {
                        Spacer()
                        Image("holdIcon")
                        Spacer()
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 14)
                    
                    Spacer().frame(height: 122)
                    
                    VStack(spacing:37) {
                        Text("Progress")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                        
                        HStack {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                ProgressBarView(value: animatedProgress, total: 100, backgroundColor: Color(hex: "#626262"))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 22)
                                    .foregroundColor(Color(hex: "#00FF2A"))
                            }
                            Text("🏆")
                                .font(.system(size: 32, weight: .semibold))
                        }
                        
                        Text("You are 40% of the way to the first milestone")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Text("💪")
                            .font(.system(size: 64, weight: .semibold))
                        
                        Text("Keep it up!")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal,35)
                    Spacer()
                    
                    
                    Button(action: {
                        triggerHaptic()
                        withAnimation {
                            showNextView = true
                        }
                    }) {
                        Text("Continue")
                            .font(.system(size: 16, weight: .semibold))
                            .padding()
                            .frame(maxWidth: .infinity,maxHeight: 47)
                            .background(Color(hex: "#FF1919"))
                            .foregroundColor(.white)
                            .cornerRadius(30)
                    }
                    .padding(.horizontal, 50)
                    .padding(.bottom, 15)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear{
            trackOnboarding("ob_progress_finish", variant: UserStorage.onboarding)
            withAnimation(.easeInOut(duration: 1.5)) {
                animatedProgress = 40
            }
        }
        .animation(.easeInOut, value: showNextView)

    }
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}

#Preview {
    ProgressFinishView()
}
