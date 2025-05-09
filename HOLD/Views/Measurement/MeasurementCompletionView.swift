import SwiftUI

struct MeasurementCompletionView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var progressViewModel: ProgressViewModel
    let totalElapsedTime: TimeInterval
    var onBack: () -> Void
    
    var body: some View {
        ZStack {
            AppBackground()
            VStack{
                HStack {
                    Spacer()
                    Image("holdIcon")
                    Spacer()
                }
                .padding(.top, 24)
                .padding(.bottom, 14)
                
                Spacer().frame(height: 122)
                
                VStack(spacing:37) {
                    Text("💪")
                        .font(.system(size: 64, weight: .semibold))
                    Text("You held for:")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text(String(format: "%.f seconds", totalElapsedTime))
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Spacer()
                    
                    Button(action: {
                        triggerHaptic()
                        onBack()
                    }) {
                        Text("Finish")
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
    }
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}

#Preview {
    MeasurementCompletionView(totalElapsedTime: 30.0, onBack: {})
        .environmentObject(ProgressViewModel())
} 
