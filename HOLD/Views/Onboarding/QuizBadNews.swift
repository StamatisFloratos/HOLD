//
//  QuizBadNews.swift
//  HOLD
//
//  Created by Hafiz Muhammad Ali on 31/05/2025.
//

import SwiftUI

struct QuizBadNews: View {
    @State private var showNextView = false
    @State private var animatedProgress: Double = 0.0
    
    var body: some View {
        ZStack {
            AppBackground()
            if showNextView {
                QuizGoodNews()
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
                    
                    Spacer().frame(height: 100)
                    
                    VStack(spacing: 0) {
                        Text("We’ve got some news we need to break to you...")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        HStack {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                ProgressBarView(value: animatedProgress, total: 100, backgroundColor: Color(hex: "#626262"))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 22)
                                    .foregroundStyle(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(hex: "#990F0F"),
                                                Color(hex: "#FF1919")
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            }
                            Text("🏆")
                                .font(.system(size: 32, weight: .semibold))
                        }
                        .padding(.top, 46)
                        
                        Spacer()
                        
                        (
                            Text("Based on your answers you are only reaching ") +
                            Text("13%").foregroundColor(Color(hex: "#FF0000")) +
                            Text(" of your potential.")
                        )
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        (
                            Text("That places you in the ") +
                            Text("bottom 20%").foregroundColor(Color(hex: "#FF0000")) +
                            Text(" of men worldwide.")
                        )
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        Text("But it’s not all bad...")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Spacer()
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
            withAnimation(.easeInOut(duration: 1.5)) {
                animatedProgress = 13
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
    QuizBadNews()
}
