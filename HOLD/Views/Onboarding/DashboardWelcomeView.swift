//
//  DashboardWelcomeView.swift
//  HOLD
//
//  Created by Muhammad Ali on 06/06/2025.
//

import SwiftUI
import ConfettiSwiftUI

struct DashboardWelcomeView: View {
    @State private var showNextView = false
    @State private var currentView = 1
    @State private var trigger: Int = 0
    @State private var contentOpacity: Double = 1.0
    
    var onCompletion: (() -> Void)?
    
    var body: some View {
        ZStack {
            if showNextView {
                FindLocationView(onCompletion: {
                    UserStorage.isWelcomeOnboardingInProgress = false
                    contentOpacity = 0
                    showNextView = false
                    
                    currentView += 1
                    withAnimation(.easeInOut(duration: 0.3)) {
                        contentOpacity = 1
                    }
                })
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                    .zIndex(1)
            } else {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                
                switch currentView {
                case 1:
                    stepOne
                        .opacity(contentOpacity)
                case 2:
                    stepTwo
                        .opacity(contentOpacity)
                case 3:
                    stepThree
                        .opacity(contentOpacity)
                case 4:
                    if UserStorage.onboarding == OnboardingType.onboardingTwo.rawValue || UserStorage.onboarding == OnboardingType.onboardingThree.rawValue {
                        stepFourExtended
                            .opacity(contentOpacity)
                    } else {
                        stepFourBasic
                            .opacity(contentOpacity)
                    }
                case 5:
                    stepFive
                        .opacity(contentOpacity)
                default:
                    stepOne
                        .opacity(contentOpacity)
                }
            }
        }
        .animation(.easeInOut, value: showNextView)
    }
    
    var stepOne: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Text("👍")
                .font(.system(size: 64, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer().frame(height: 60)
            
            Text("You made a great choice.")
                .font(.system(size: 24, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
            
            Spacer().frame(height: 40)
            
            Text("Together we'll build the best version of yourself.")
                .font(.system(size: 16, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
            
            Spacer()
            
            Button(action: {
                triggerHaptic()
                animateToNextView()
            }) {
                Text("Next")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity, maxHeight: 47)
                    .background(Color(hex: "#FF1919"))
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .padding(.horizontal, 56)
            }
            .padding(.bottom, 24)
        }
    }
    
    var stepTwo: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Text("🔓")
                .font(.system(size: 64, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer().frame(height: 60)
            
            Text("Consistency Is Your Secret Weapon.")
                .font(.system(size: 24, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
            
            Spacer().frame(height: 40)
            
            Text("It only takes 5 minutes a day to start seeing real results. You'll be surprised what a simple routine can do.")
                .font(.system(size: 16, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
            
            Spacer()
            
            Button(action: {
                triggerHaptic()
                animateToNextView()
            }) {
                Text("Next")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity, maxHeight: 47)
                    .background(Color(hex: "#FF1919"))
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .padding(.horizontal, 56)
            }
            .padding(.bottom, 24)
        }
    }
    
    var stepThree: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Text("🤝")
                .font(.system(size: 64, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer().frame(height: 60)
            
            Text("Take The Pledge.")
                .font(.system(size: 24, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
            
            Spacer().frame(height: 40)
            
            Text("I commit to showing up daily, for my health, my confidence, and my performance. Just a few minutes a day. No excuses.")
                .font(.system(size: 16, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
            
            Spacer()
            
            Button(action: {
                triggerHaptic()
                animateToNextView()
            }) {
                Text("I take the pledge!")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity, maxHeight: 47)
                    .background(Color(hex: "#FF1919"))
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .padding(.horizontal, 56)
            }
            .padding(.bottom, 24)
        }
    }
    
    var stepFourBasic: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Text("🎉")
                .font(.system(size: 64, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer().frame(height: 60)
            
            Text("Congratulations!")
                .font(.system(size: 24, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
            
            Spacer().frame(height: 40)
            
            Text("Now it's time to explore the app, start your first workout, and track your progress. Everything you need is waiting inside.")
                .font(.system(size: 16, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
            
            Spacer()
            
            Button(action: {
                triggerHaptic()
                onCompletion?()
            }) {
                Text("Take me inside")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity, maxHeight: 47)
                    .background(Color(hex: "#FF1919"))
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .padding(.horizontal, 56)
            }
            .padding(.bottom, 24)
        }
        .confettiCannon(trigger: $trigger)
        .onAppear() {
            trigger += 1
        }
    }
    
    var stepFourExtended: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Text("✋")
                .font(.system(size: 64, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer().frame(height: 60)
            
            Text("Before We Start")
                .font(.system(size: 24, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
            
            Spacer().frame(height: 40)
            
            Text("If you're not targeting the right spot, nothing works, next screens guide you to your Pelvic Floor muscles, or skip if you've got it.")
                .font(.system(size: 16, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
            
            Spacer()
            
            Button(action: {
                triggerHaptic()
                onCompletion?()
            }) {
                Text("Skip")
                    .font(.system(size: 16, weight: .semibold))
                    .background(.clear)
                    .foregroundColor(.white)
            }
            .padding(.bottom, 24)
            
            Button(action: {
                triggerHaptic()
                withAnimation {
                    showNextView = true
                    UserStorage.isWelcomeOnboardingInProgress = true
                }
            }) {
                Text("Find your PF Muscle")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity, maxHeight: 47)
                    .background(Color(hex: "#FF1919"))
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .padding(.horizontal, 56)
            }
            .padding(.bottom, 24)
        }
        .confettiCannon(trigger: $trigger)
        .onAppear() {
            trigger += 1
        }
    }
    
    var stepFive: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Text("🎉")
                .font(.system(size: 64, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer().frame(height: 60)
            
            Text("Congratulations!")
                .font(.system(size: 24, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
            
            Spacer().frame(height: 40)
            
            Text("Now it's time to explore the app, start your first workout, and track your progress. Everything you need is waiting inside.")
                .font(.system(size: 16, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
            
            Spacer()
            
            Button(action: {
                triggerHaptic()
                onCompletion?()
            }) {
                Text("Take me inside")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity, maxHeight: 47)
                    .background(Color(hex: "#FF1919"))
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .padding(.horizontal, 56)
            }
            .padding(.bottom, 24)
        }
        .confettiCannon(trigger: $trigger)
        .onAppear() {
            trigger += 1
        }
    }
    
    func animateToNextView() {
        withAnimation(.easeInOut(duration: 0.3)) {
            contentOpacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentView += 1
            withAnimation(.easeInOut(duration: 0.3)) {
                contentOpacity = 1
            }
        }
    }
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}

#Preview {
    DashboardWelcomeView()
}
