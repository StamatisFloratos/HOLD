import SwiftUI

struct PersonalPlanView: View {
    @State private var progress: Double = 0
    @State private var checkmarkOpacities: [Double] = [0, 0, 0, 0]
    private let steps = [
        "Analyzing your profile",
        "Calculating current position",
        "Tailoring a plan to your needs",
        "Adjusting for your goals"
    ]
    private let totalDuration: Double = 30 // seconds
    private let timerInterval: Double = 0.03 // seconds
    @State private var showNextView = false
    @State private var hapticTimer: Timer?
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .light)


    var body: some View {
        ZStack {
            AppBackground()
            if showNextView {
                if UserStorage.onboarding == OnboardingType.onboardingThree
                    .rawValue {
                    QuizBadNews()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                        .zIndex(1)
                } else {
                    GoodNewsView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                        .zIndex(1)
                }
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
                        Text("Creating Your Personal Plan")
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(.white)
                            .padding(.top, 86)
                            .padding(.horizontal,33)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        ZStack {
                            Circle()
                                .stroke(Color(hex:"#393939"), lineWidth: 15)
                                .frame(width: 198, height: 198)
                            Circle()
                                .trim(from: 0, to: progress / 100)
                                .stroke(
                                    Color(hex: "#FF0000"),
                                    style: StrokeStyle(lineWidth: 15, lineCap: .round)
                                )
                                .rotationEffect(.degrees(90)) // Changed from -90 to 90 to start from bottom
                                .frame(width: 198, height: 198)
                            Text("\(Int(progress))%")
                                .font(.system(size: 48, weight: .black))
                                .foregroundColor(.white)
                                .animation(nil) // Prevents text from animating its value
                        }
                        .padding(.top, 72)
                        Spacer().frame(maxHeight: 55)
                            .zIndex(1)
                        
                        VStack(alignment: .leading, spacing: 18) {
                            ForEach(0..<steps.count, id: \.self) { idx in
                                HStack(spacing: 12) {
                                    Image(systemName: progress >= Double((idx + 1) * 25) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(progress >= Double((idx + 1) * 25) ? Color(hex: "#FF1919") : .clear)
                                        .opacity(checkmarkOpacities[idx])
                                        .font(.system(size: 20))
                                    Text(steps[idx])
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .medium))
                                }
                            }
                        }
                        .padding(.top, 20)
                        
                    }
                    Spacer()

                }
            }
        }
        .onAppear {
            track("ob_personal_plan")
            startProgress()
        }
        .onChange(of: progress) { oldValue, newValue in
            if Int(newValue) == 100 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        showNextView = true
                    }
                }
            }
        }
        .animation(.easeInOut, value: showNextView)
    }
    
    private func startProgress() {
        progress = 0
        checkmarkOpacities = [0, 0, 0, 0]
        
        startHapticFeedback()
        
        // Calculate segment durations for exact speed ratios:
        // Speed ratio: 1 : 1.5 : 1 : 1.2
        
        // For even distribution (25% per segment), with total 30 seconds:
        // If 1x speed takes T seconds for 25%, then:
        // - 1.5x speed takes T/1.5 seconds for 25%
        // - 1.2x speed takes T/1.2 seconds for 25%
        // For total 30 seconds: T + T/1.5 + T + T/1.2 = 30
        // Solving: T * (1 + 1/1.5 + 1 + 1/1.2) = 30
        // T * (1 + 0.667 + 1 + 0.833) = 30
        // T * 3.5 = 30
        // T = 8.57 seconds
        
        let baseTime = 8.57
        
        let segment1EndTime = baseTime
        let segment2EndTime = segment1EndTime + baseTime/1.5
        let segment3EndTime = segment2EndTime + baseTime
        let segment4EndTime = segment3EndTime + baseTime/1.2
        
        var startTime = Date()
        
        Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { timer in
            let elapsedTime = Date().timeIntervalSince(startTime)
            var newProgress: Double = 0
            
            if elapsedTime <= segment1EndTime {
                newProgress = min(25, (elapsedTime / segment1EndTime) * 25)
            } else if elapsedTime <= segment2EndTime {
                let segmentElapsed = elapsedTime - segment1EndTime
                let segmentDuration = segment2EndTime - segment1EndTime
                newProgress = min(50, 25 + (segmentElapsed / segmentDuration) * 25)
            } else if elapsedTime <= segment3EndTime {
                let segmentElapsed = elapsedTime - segment2EndTime
                let segmentDuration = segment3EndTime - segment2EndTime
                newProgress = min(75, 50 + (segmentElapsed / segmentDuration) * 25)
            } else if elapsedTime <= segment4EndTime {
                let segmentElapsed = elapsedTime - segment3EndTime
                let segmentDuration = segment4EndTime - segment3EndTime
                newProgress = min(100, 75 + (segmentElapsed / segmentDuration) * 25)
            } else {
                newProgress = 100
            }
            
            progress = newProgress
            
            for i in 0..<4 {
                let threshold = Double((i + 1) * 25)
                if progress >= threshold && checkmarkOpacities[i] == 0 {
                    withAnimation(.easeIn(duration: 0.5)) {
                        checkmarkOpacities[i] = 1.0
                    }
                }
            }
            
            if progress >= 100 {
                timer.invalidate()
                stopHapticFeedback()
            }
        }
    }
    
    private func startHapticFeedback() {
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] _ in
            hapticFeedback.prepare()
            hapticFeedback.impactOccurred()
        }
    }
    
    private func stopHapticFeedback() {
        hapticTimer?.invalidate()
        hapticTimer = nil
    }
}

#Preview {
    PersonalPlanView()
}
