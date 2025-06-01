//
//  StartView.swift
//  HOLD
//
//  Created by Rabbia Ijaz on 04/05/2025.
//

import SwiftUI

struct StartView: View {
    @State private var isStart = false
    @State private var showOnboardingView = false
    
    var body: some View {
        ZStack {
            AppBackground()
            if showOnboardingView {
                OnboardingView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                    .zIndex(1)
            }
            else {
                VStack(spacing:0) {
                    Spacer()
                    VStack(spacing:0) {
                        Image("holdIconLarge")
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal,91)
                            .padding(.top,87)
                        Image("start")
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal,44)
                            .padding(.top,-50)
                            .padding(.bottom,-100)
                    }
                    
                    VStack {
                        Spacer()
                        if !isStart {
                            VStack {
                                HStack(spacing: 0) {
                                    Text("Men are using ")
                                        .foregroundColor(.white)
                                    + Text("H")
                                        .foregroundColor(.white)
                                    + Text("O")
                                        .foregroundColor(Color(red: 189/255, green: 0, blue: 5/255))
                                    + Text("LD")
                                        .foregroundColor(.white)
                                    + Text(" to take back control of their bodies.")
                                        .foregroundColor(.white)
                                }
                                .font(.system(size: 20, weight: .bold))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.horizontal, 40)
                                
                                benefitsView
                                    .padding(.top, 36)
                            }
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.5), value: isStart)
                        } else {
                            Text("Let's start by taking a quiz to tailor your path to total control.")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 25)
                                .transition(.opacity)
                                .animation(.easeInOut(duration: 0.5), value: isStart)
                        }
                        Spacer()
                    }
                    
                    Button(action: {
                        triggerHaptic()
                        if !isStart {
                            withAnimation {
                                isStart = true
                            }
                        } else  {
                            withAnimation {
                                showOnboardingView = true
                            }
                        }
                    }) {
                        Text(isStart ? "Next" : "Start Quiz")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity, maxHeight: 47)
                            .background(Color(hex: "#FF1919"))
                            .foregroundColor(.white)
                            .cornerRadius(30)
                            .padding(.horizontal, 56)
                    }
                    .padding(.bottom, 32)
                }
            }
        }
        .animation(.easeInOut, value: showOnboardingView)
        .onAppear {
            trackOnboarding("ob_start_view", variant: UserStorage.onboarding)
        }
    }
    
    private var benefitsView: some View {
        VStack(alignment: .leading, spacing: 18) {
            benefitRow(text: "Strengthen Erections")
            benefitRow(text: "Last Longer")
            benefitRow(text: "Enhance Orgasms")
        }
        .padding(.vertical, 17)
        .padding(.horizontal, 14)
        .cornerRadius(22)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.white.opacity(0.5), lineWidth: 2)
        )
        .frame(width: 222)
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
    StartView()
}
