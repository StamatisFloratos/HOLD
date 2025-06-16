//
//  FindLocationView.swift
//  HOLD
//
//  Created by Rabbia Ijaz on 06/05/2025.
//

import SwiftUI
import Combine

struct FindLocationView: View {
    @State private var showNextView = false
    @State private var currentStep = 1
    private let totalSteps = 3
    @State private var progress: CGFloat = 0.0
    @State private var timer: Timer?
    @State private var showCompletionModal = false
    @State private var isPaused = false
    @State private var blurAmount: CGFloat = 0

    let stepDuration: TimeInterval = 5.0
    let timerInterval: TimeInterval = 0.01

    var onCompletion: (() -> Void)?
    
    var body: some View {
        ZStack {
            AppBackground()
            if showNextView {
                TryExerciseView(onCompletion: onCompletion)
                    .zIndex(1)
            } else {
                VStack {
                    ProgressBar(currentStep: currentStep, totalSteps: totalSteps, progress: progress)
                        .padding(.top, 32)
                        .padding(.bottom, 16)
                    
                    Spacer()
                    
                    ZStack {
                        firstView
                            .opacity(currentStep == 1 ? 1 : 0)
                        secondView
                            .opacity(currentStep == 2 ? 1 : 0)
                        thirdView
                            .opacity(currentStep == 3 ? 1 : 0)
                    }
                    
                    Spacer()
                    VStack(spacing: 0) {
                        HStack {
                            Spacer()
                            Image("holdIcon")
                            Spacer()
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 30)
                    }
                }
                .onAppear {
                    startProgress()
                    trackOnboarding("ob_find_location_step1", variant: UserStorage.onboarding)
                }
                .onDisappear {
                    timer?.invalidate()
                }
                .onChange(of: currentStep) { oldValue, newValue in
                    let stepEvent = "ob_find_location_step\(newValue)"
                    trackOnboarding(stepEvent, variant: UserStorage.onboarding)
                }
                .blur(radius: blurAmount)
                .overlay(
                    HStack(spacing: 0) {
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if currentStep > 1 {
                                    triggerHaptic()
                                    goToPreviousStep()
                                }
                            }
                            .frame(width: UIScreen.main.bounds.width / 3)
                        
                        Color.clear
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { _ in
                                        if !isPaused {
                                            pauseProgress()
                                        }
                                    }
                                    .onEnded { _ in
                                        if isPaused {
                                            resumeProgress()
                                        }
                                    }
                            )
                            .frame(width: UIScreen.main.bounds.width / 3)
                        
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if currentStep < totalSteps {
                                    triggerHaptic()
                                    goToNextStep()
                                } else {
                                    showCompletionModalWithAnimation()
                                }
                            }
                            .frame(width: UIScreen.main.bounds.width / 3)
                    }
                )
                .overlay(
                    Group {
                        if showCompletionModal {
                            Color(hex: "#2C2C2C").opacity(0.2)
                                .ignoresSafeArea()
                            
                            VStack(spacing: 0) {
                                Text("Did you manage to find the PF muscles?")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 24)
                                    .padding(.horizontal, 20)
                                Button(action: {
                                    triggerHaptic()
                                    withAnimation {
                                        showNextView = true
                                    }
                                }) {
                                    Text("Yes, I did")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, maxHeight: 45)
                                        .padding(0)
                                        .background(Color(hex: "#1A2C46"))
                                        .cornerRadius(24)
                                }
                                .padding(.top, 23)
                                
                                Button(action: {
                                    triggerHaptic()
                                    hideCompletionModalWithAnimation()
                                    currentStep = 1
                                    progress = 0.0
                                    startProgress()
                                }) {
                                    Text("No, I don't get it")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.red)
                                        .frame(maxWidth: .infinity, maxHeight: 45)
                                        .padding(0)
                                        .background(Color(hex: "#1A2C46"))
                                        .cornerRadius(30)
                                }
                                .padding(.vertical, 15)
                            }
                            .padding(.horizontal, 25)
                            .background(Color(hex: "#10171F"))
                            .cornerRadius(20)
                            .padding(.horizontal, 18)
                            .frame(maxWidth: 400)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            .offset(y: showCompletionModal ? 0 : 300) // For slide-up animation
                            .animation(.spring(), value: showCompletionModal)
                        }
                    }
                )
            }
        }
        .animation(nil, value: currentStep)
    }
    
    private func startProgress() {
        progress = 0
        isPaused = false
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { t in
            if !isPaused {
                progress += CGFloat(timerInterval / stepDuration)
                if progress >= 1.0 {
                    progress = 1.0
                    t.invalidate()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        if currentStep < totalSteps {
                            triggerHaptic() // Haptic feedback when auto-advancing
                            currentStep += 1
                            startProgress()
                        } else {
                            showCompletionModalWithAnimation()
                        }
                    }
                }
            }
        }
    }
    
    private func pauseProgress() {
        isPaused = true
    }
    
    private func resumeProgress() {
        isPaused = false
    }
    
    private func goToNextStep() {
        if currentStep < totalSteps {
            currentStep += 1
            progress = 0.0
            startProgress()
        }
    }
    
    private func goToPreviousStep() {
        if currentStep > 1 {
            currentStep -= 1
            progress = 0.0
            startProgress()
        }
    }
    
    private func showCompletionModalWithAnimation() {
        timer?.invalidate()
        isPaused = true
        
        // Animate the blur and show the modal
        withAnimation(.easeInOut(duration: 0.3)) {
            blurAmount = 20
        }
        
        withAnimation(.spring()) {
            showCompletionModal = true
        }
    }
    
    private func hideCompletionModalWithAnimation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            blurAmount = 0
        }
        
        withAnimation(.spring()) {
            showCompletionModal = false
        }
    }
    
    var firstView: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 21) {
                    Text("Find Location")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Text("PF muscles are\nlocated between\nthe pubic and the\ntailbone they\ncontrol and\nsupport your\npenis.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white)
                        .lineSpacing(6)

                }
                .padding(.leading, 26)
                .padding(.top, 49)
                
                Image("image1")
                    .resizable()
                    .scaledToFit()
                    .padding(.leading, -46)
            }
            
            Image("image2")
                .resizable()
                .scaledToFit()
                .padding(.trailing, 88)
        }
    }
    
    var secondView: some View {
        VStack(alignment: .center, spacing: 14) {
            Image("image3")
                .resizable()
                .scaledToFit()
                .frame(height: UIScreen.main.bounds.height/2)
                .padding(.horizontal, 0)
            VStack(alignment: .leading, spacing: 14) {
                Text("Learn How to Use")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                Text("Imagine you're peeing and you suddenly try to stop midstream. The muscles you just used That's your pelvic floor. That's what we're here to train.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(6)
            }
        }
    }
    
    var thirdView: some View {
        VStack(alignment: .center, spacing: 14) {
            Image("image4")
                .resizable()
                .scaledToFit()
                .frame(height: UIScreen.main.bounds.height/2)
                .padding(.horizontal, 0)
            VStack(alignment: .leading, spacing: 14) {
                Text("Feel the Sensation")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                Text("When you contract the right muscles, you'll feel a lift at the base of your penis and a squeeze near the anus.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(6)
            }
        }
    }
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}

struct ProgressBar: View {
    let currentStep: Int      // 1-based
    let totalSteps: Int
    let progress: CGFloat     // 0.0 to 1.0

    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<totalSteps, id: \.self) { index in
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 4)
                        if index < currentStep - 1 {
                            Capsule()
                                .fill(Color.white)
                                .frame(width: geometry.size.width, height: 4)
                        } else if index == currentStep - 1 {
                            Capsule()
                                .fill(Color.white)
                                .frame(width: geometry.size.width * progress, height: 4)
                        }
                    }
                }
                .frame(height: 4)
            }
        }
        .frame(height: 4)
        .padding(.horizontal, 32)
    }
}

#Preview {
    FindLocationView()
}
