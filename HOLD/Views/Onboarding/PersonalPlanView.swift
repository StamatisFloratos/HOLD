import SwiftUI

struct PersonalPlanView: View {
    @State private var progress: Double = 0
    private let steps = [
        "Analyzing your profile",
        "Calculating current position",
        "Tailoring a plan to your needs",
        "Adjusting for your goals"
    ]
    private let totalDuration: Double = 30 // seconds
    private let timerInterval: Double = 0.03 // seconds
    @State private var showMainView = false


    var body: some View {
        ZStack {
            AppBackground()
            if showMainView {
                MainTabView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                    .zIndex(1)
            } else {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        HStack {
                            Spacer()
                            Image("holdIcon")
                            Spacer()
                        }
                        //                    .padding(.top, 24)
                    }
                    VStack(spacing: 0) {
                        Text("Creating Your Personal Plan")
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(.white)
                            .padding(.top, 100)
                            .padding(.horizontal,33)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        ZStack {
                            Circle()
                                .stroke(Color(hex:"#525252"), lineWidth: 15)
                                .frame(width: 198, height: 198)
                            Circle()
                                .trim(from: 0, to: progress / 100)
                                .stroke(
                                    Color(hex: "#FF0000"),
                                    style: StrokeStyle(lineWidth: 15, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
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
                                        .font(.system(size: 20))
                                    Text(steps[idx])
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .medium))
                                }
                            }
                        }
                        .padding(.top, 20)
                        
                    }
                }
            }
        }
        .onAppear {
            startProgress()
        }
        .onChange(of: progress, {
            if Int(progress) == 100 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        showMainView = true
                }
            }
        })
    }
    
    private func startProgress() {
        progress = 0
        let stepsCount = Int(totalDuration / timerInterval)
        var currentStep = 0
        Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { timer in
            currentStep += 1
            let newProgress = min(100, (Double(currentStep) / Double(stepsCount)) * 100)
            progress = newProgress
            if progress >= 100 {
                timer.invalidate()
            }
        }
    }
}

#Preview {
    PersonalPlanView()
}
