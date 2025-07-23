import SwiftUI

struct PlanCompletionModalView: View {
    let completedPlan: TrainingPlan
    let nextPlan: TrainingPlan?
    let onDone: () -> Void
    let onSwitchProgram: () -> Void
    
    @State private var showNextPlan = false
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 10) {
                Text("Program Completed")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(Color(hex: "#06A800"))
            }
            .padding(.top, 40)
            .padding(.bottom, 80)
            .animation(.easeInOut(duration: 0.5), value: showNextPlan)
            
            ZStack {
                VStack(spacing: 24) {
                    Text("You just successfully completed:")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                    TrainingPlanCardModal(
                        planName: completedPlan.name,
                        daysLeft: 0,
                        percentComplete: 100,
                        progress: 1.0,
                        image: completedPlan.image,
                        height: 250,
                        completed: true,
                        onTap: {}
                    )
                    
                    Spacer()
                    
                    Button(action: {
                        triggerHaptic()
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showNextPlan = true
                        }
                    }) {
                        Text("Next")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity, maxHeight: 47)
                            .background(Color(hex: "#FF1919"))
                            .foregroundColor(.white)
                            .cornerRadius(30)
                            .padding(.horizontal, 16)
                    }
                    .opacity(showNextPlan ? 0 : 1)
                    .animation(.easeInOut(duration: 0.5), value: showNextPlan)
                }
                .opacity(showNextPlan ? 0 : 1)
                .animation(.easeInOut(duration: 0.5), value: showNextPlan)

                VStack(spacing: 24) {
                    if let nextPlan = nextPlan {
                        Text("Your next program is:")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                        TrainingPlanCardModal(
                            planName: nextPlan.name,
                            daysLeft: nextPlan.duration,
                            percentComplete: 0,
                            progress: 0.0,
                            image: nextPlan.image,
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
                                onDone()
                            }) {
                                Text("Done")
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(maxWidth: .infinity, maxHeight: 47)
                                    .background(Color(hex: "#FF1919"))
                                    .foregroundColor(.white)
                                    .cornerRadius(30)
                                    .padding(.horizontal, 16)
                            }
                        }
                    }
                }
                .opacity(showNextPlan ? 1 : 0)
                .animation(.easeInOut(duration: 0.5), value: showNextPlan)
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
    let completedPlan = TrainingPlan(
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
    let nextPlan = TrainingPlan(
        id: "2",
        name: "Full Control",
        duration: 45,
        difficulty: "Hard",
        summary: "Take full control",
        description: "Next program description.",
        unlockRequirement: nil,
        days: [],
        image: "full_control"
    )
    return Group {
        PlanCompletionModalView(
            completedPlan: completedPlan,
            nextPlan: nextPlan,
            onDone: {},
            onSwitchProgram: {}
        )
        .previewDisplayName("Initial State")
    }
}
