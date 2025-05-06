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
//                    Spacer()
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
                            .padding(.bottom,-50)
                    }
                    Spacer()
                    if !isStart {
                        Image("startText")
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal,25)
                        
                        benefitsView
                            .padding(.top,36)
                    } else {
                        
                        Text("Let’s start by taking a quiz to tailor your path to total control.")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 25)
                    }
                    Spacer()
                    Button(action: {
                        if !isStart {
                            isStart = true
                        } else  {
                            showOnboardingView = true
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
    }

    private var benefitsView: some View {
        VStack(alignment: .leading, spacing: 18) {
            benefitRow(text: "Strengthen Erections")
            benefitRow(text: "Last Longer")
            benefitRow(text: "Enhance Orgasms")
        }
        .padding(.vertical, 17)
        .padding(.horizontal, 14)
        .background(Color(hex: "#232B3A")) // Use your app's dark color
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
}

#Preview {
    StartView()
}
