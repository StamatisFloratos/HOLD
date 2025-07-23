import SwiftUI

struct PlanFailureModalView: View {
    let failedPlan: TrainingPlan
    let percentComplete: Int
    let onRetry: () -> Void
    let onSwitchProgram: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 10) {
                Text("Program Missed")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                Image(systemName: "xmark.circle")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(Color(hex: "#FF0000"))
            }
            .padding(.top, 40)
            .padding(.bottom, 80)
            
            Text("You didn’t complete all workouts in this program")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Spacer().frame(height: 24)
            
            TrainingPlanCardModal(
                planName: failedPlan.name,
                daysLeft: 0,
                percentComplete: percentComplete,
                progress: Double(percentComplete) / 100.0,
                image: failedPlan.image,
                height: 250,
                completed: false,
                onTap: {}
            )
            
            Spacer()
            
            VStack(spacing: 10) {
                Button(action: {
                    triggerHaptic()
                    onSwitchProgram()
                }) {
                    HStack(spacing: 8) {
                        Text("Switch Program")
                        Image("switchIcon")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity, maxHeight: 47)
                    .background(.clear)
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .padding(.horizontal, 16)
                }
                Button(action: {
                    triggerHaptic()
                    onRetry()
                }) {
                    Text("Retry")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity, maxHeight: 47)
                        .background(Color(hex: "#FF1919"))
                        .foregroundColor(.white)
                        .cornerRadius(30)
                        .padding(.horizontal, 16)
                }
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 40)
    }
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}

#Preview {
    let failedPlan = TrainingPlan(
        id: "1",
        name: "Stronger Holds",
        duration: 30,
        difficulty: "Medium",
        summary: "A plan to build strength",
        description: "Full program description.",
        unlockRequirement: nil,
        days: [],
        image: "stronger_holds"
    )
    return PlanFailureModalView(
        failedPlan: failedPlan,
        percentComplete: 85,
        onRetry: {},
        onSwitchProgram: {}
    )
} 
