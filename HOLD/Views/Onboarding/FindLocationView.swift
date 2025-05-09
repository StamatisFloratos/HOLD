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

    let stepDuration: TimeInterval = 5.0
    let timerInterval: TimeInterval = 0.01

    var body: some View {
        ZStack {
            AppBackground()
            if showNextView {
                TryExerciseView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                    .zIndex(1)
            } else {
                VStack {
                    ProgressBar(currentStep: currentStep, totalSteps: totalSteps, progress: progress)
                        .padding(.top, 32)
                        .padding(.bottom, 16)
                    
//                    Spacer().frame(height: 40)
                    Spacer()
                    
                    Group {
                        switch currentStep {
                        case 1:
                            firstView
                        case 2: secondView
                        case 3: thirdView
                        default: firstView
                        }
                    }
                    .animation(.easeIn, value: currentStep)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                    
//                    Spacer().frame(height: 40)
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
                }
                .onDisappear {
                    timer?.invalidate()
                }
                .blur(radius: showCompletionModal ? 20 : 0)
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
                                    // Handle "Yes" action
                                    triggerHaptic()
                                    withAnimation {
                                        showNextView = true
                                    }
                                }) {
                                    Text("Yes, I did")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity,maxHeight: 45)
                                        .padding(0)
                                        .background(Color(hex: "#1A2C46"))
                                        .cornerRadius(24)
                                }
                                .padding(.top, 23)
                                
                                Button(action: {
                                    // Handle "No" action
                                    triggerHaptic()
                                    showCompletionModal = false // or show help, etc.
                                    currentStep = 1
                                    progress = 0.0
                                    startProgress()
                                }) {
                                    Text("No, I don't get it")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.red)
                                        .frame(maxWidth: .infinity,maxHeight: 45)
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
                            .transition(.move(edge: .bottom))
                        }
                    }
                )
            }
        }
        .animation(.easeInOut, value: showNextView)
    }
    
    private func startProgress() {
        progress = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { t in
            progress += CGFloat(timerInterval / stepDuration)
            if progress >= 1.0 {
                progress = 1.0
                t.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    if currentStep < totalSteps {
                        currentStep += 1
                        startProgress()
                    } else {
                        showCompletionModal = true
                    }
                }
            }
        }
    }
    
    var firstView: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top,spacing:0) {
                VStack(alignment: .leading,spacing: 21) {
                    Text("Find Location")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Text("PF muscles are\nlocated between\nthe pubic and the\ntailbone they\ncontrol and\nsupport your\npenis.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white)
                        .lineSpacing(6)

                }
                .padding(.leading,26)
                .padding(.top,49)
                
                Image("image1")
                    .resizable()
                    .scaledToFit()
                    .padding(.leading,-46)
            }
            
            Image("image2")
                .resizable()
                .scaledToFit()
                .padding(.trailing,88)
        }
    }
    
    var secondView: some View {
        VStack(alignment: .center,spacing: 14) {
            Image("image3")
                .resizable()
                .scaledToFit()
                .frame(height: UIScreen.main.bounds.height/2)
                .padding(.horizontal,0)
            VStack(alignment: .leading,spacing: 14) {
                Text("Learn How to Use")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal,40)
                Text("Imagine you're peeing and you suddenly try to stop midstream. The muscles you just used That's your pelvic floor. That's what we're here to train.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                    .padding(.horizontal,40)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(6)
            }
        }
    }
    var thirdView: some View {
        VStack(alignment: .center,spacing: 14) {
            Image("image4")
                .resizable()
                .scaledToFit()
                .frame(height: UIScreen.main.bounds.height/2)
                .padding(.horizontal,0)
            VStack(alignment: .leading,spacing: 14) {
                Text("Feel the Sensation")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal,40)
                Text("When you contract the right muscles, you'll feel a lift at the base of your penis and a squeeze near the anus.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                    .padding(.horizontal,40)
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
