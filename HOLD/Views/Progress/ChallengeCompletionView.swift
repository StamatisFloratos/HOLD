import SwiftUI

struct ChallengeCompletionView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var challengeViewModel: ChallengeViewModel
    let totalElapsedTime: TimeInterval
    var onBack: () -> Void
    
    var body: some View {
        ZStack {
            AppBackground()
            
            VStack(spacing: 0) {
                // Logo at the top
                HStack {
                    Spacer()
                    Image("holdIcon")
                    Spacer()
                }
                .padding(.top, 24)
                .padding(.bottom, 14)
                
                Spacer()
                let result = ChallengeResult(duration: totalElapsedTime)
                Text("You lasted for:")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.top,6)
                Text(result.durationDisplay)
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.top,6)
                Spacer()
                Text("You Are in The Top:")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.top)
                
                Text(result.percentileDisplay)
                    .font(.system(size: 64, weight: .semibold))
                    .foregroundStyle(LinearGradient(
                        colors: result.challengeColor,
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .padding(.top,19)
                
                Text("of Men Globally")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                Text(result.challengeDescription)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.top,6)
                Spacer()
                Button(action: {
                    triggerHapticForButton()
                    challengeViewModel.challengeDidFinish(duration: totalElapsedTime)
                    onBack()
                }) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .padding()
                        .frame(maxWidth: .infinity,maxHeight: 47)
                        .background(Color(hex: "#FF5E00"))
                        .foregroundColor(.white)
                        .cornerRadius(30)
                }
                .padding(.horizontal, 50)
                .padding(.bottom, 15)
            }
        }
        .navigationBarHidden(true)
    }
    
    func triggerHapticForButton() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

}

#Preview {
    ChallengeCompletionView(totalElapsedTime: 30.0, onBack: {})
        .environmentObject(ChallengeViewModel())
} 
