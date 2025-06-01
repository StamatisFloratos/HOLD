//
//  ReviewView 2.swift
//  HOLD
//
//  Created by Rabbia Ijaz on 08/05/2025.
//
import Foundation
import SwiftUI

struct MilestoneView: View {
    @State private var showNextView = false
    @State private var userProfile: UserProfile = UserProfile.load()
    @State private var showContinueButton = false
    @State private var milestoneOpacity: Double = 0
    @State var progress: Int = 0
    
    var milestoneTitle: String = "Milestone 1"
    var streak: String = "1 day"
    var badge: String = "Holder"
    
    let welcomeMessagesV1 = [
        "Welcome to HOLD, your personal performance trainer.",
        "Based on your answers, we've built a custom plan just for you.",
        "You're already 40% of the way to your first milestone!",
        "This plan helps you take control, last longer, and be irresistible.",
        "Now, it's time to invest in yourself."
    ]
    
    let welcomeMessagesV2 = [
        "Welcome to HOLD, your personal performance trainer.",
        "Based on your answers, we've built a custom plan just for you.",
        "You have all this potential ahead of you. Don’t waste it.",
        "This plan helps you take control, last longer, and be irresistible.",
        "Now, it's time to invest in yourself."
    ]
    
    var body: some View {
        ZStack {
            AppBackground()
            
            if showNextView {
                SubscriptionView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                    .zIndex(1)
            } else {
                VStack {
                    HStack {
                        Spacer()
                        Image("holdIcon")
                        Spacer()
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 24)
                    
                    VStack {
                        TypewriterText(texts: UserStorage.onboarding == OnboardingType.onboardingThree.rawValue ? welcomeMessagesV2 : welcomeMessagesV1, onCompletion: {
                            withAnimation(.easeIn(duration: 0.3)) {
                                showContinueButton = true
                            }
                        })
                        .padding(.horizontal, 35)
                    }
                    .frame(height: 80)
                    
                    Spacer()
                    
                    milestoneView
                        .opacity(milestoneOpacity)
                    
                    Spacer()
                    
                    if showContinueButton {
                        Button(action: {
                            withAnimation {
                                showNextView = true
                            }
                            UserStorage.isOnboardingDone = true
                        }) {
                            Text("Continue")
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
        .navigationBarHidden(true)
        .animation(.easeInOut, value: showNextView)
        .onAppear {
            if UserStorage.onboarding == OnboardingType.onboardingThree.rawValue {
                progress = 13
            } else {
                progress = 40
            }
            
            track("ob_milestone")
            withAnimation(.easeIn(duration: 0.8).delay(0.3)) {
                milestoneOpacity = 1.0
            }
        }
    }
    
    var milestoneView: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#990000"), Color(hex: "#FF0000")]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Holder")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.4))
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                        Spacer()
                        Text(milestoneTitle)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(UserStorage.onboarding == OnboardingType.onboardingThree.rawValue ? "Potential Used" : "Progress")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        Text("\(progress)%")
                            .font(.system(size: 48, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
            .frame(height: 265)
            
            HStack {
                Color.white
            }
            .frame(height: 1)
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Name")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.5))
                    Text(userProfile.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Active Streak")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.5))
                    Text(streak)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .frame(height: 87)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(hex: "#393939"))
            .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
            
        }
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white, lineWidth: 1)
        )
        .frame(width: 269)
        .shadow(radius: 8)
    }
}

#Preview {
    MilestoneView()
}
