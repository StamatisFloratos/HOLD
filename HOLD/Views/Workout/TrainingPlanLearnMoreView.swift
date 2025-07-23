import SwiftUI

struct TrainingPlanLearnMoreView: View {
    let plan: TrainingPlan
    @ObservedObject var trainingPlansViewModel: TrainingPlansViewModel
    var onClose: (() -> Void)? = nil
    
    @State private var showConfirmation = false
    @State private var showUnlockRequirement = false
    
    var isCurrentPlan: Bool {
        trainingPlansViewModel.currentPlanId == plan.id
    }
    var isDifferentPlanActive: Bool {
        trainingPlansViewModel.currentPlanId != nil && trainingPlansViewModel.currentPlanId != plan.id
    }
    var hasUnlockRequirement: Bool {
        plan.unlockRequirement != nil && !trainingPlansViewModel.completedPlanIds.contains(plan.unlockRequirement!)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    if let imageName = plan.image {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width, height: 400)
                            .clipped()
                    } else {
                        Color.black.frame(height: 400)
                    }
                    
                    VStack(spacing: 0) {
                        HStack {
                            Spacer()
                            Button(action: {
                                triggerHaptic()
                                onClose?()
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(.top, 18)
                                    .padding(.trailing, 18)
                            }
                        }
                        Text(plan.name)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 8)
                        Text("Program Details")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.top, 8)
                        Spacer()
                        Text("Duration: \(plan.duration) days")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.bottom, 14)
                        if isCurrentPlan {
                            Button(action: {}) {
                                Text("Current Program")
                                    .font(.system(size: 16, weight: .medium))
                                    .frame(width: 165, height: 50)
                                    .background(
                                        LinearGradient(
                                            stops: [
                                                Gradient.Stop(color: Color(red: 1, green: 0.1, blue: 0.1), location: 0.00),
                                                Gradient.Stop(color: Color(red: 0.6, green: 0.06, blue: 0.06), location: 1.00),
                                            ],
                                            startPoint: UnitPoint(x: 0, y: 0.5),
                                            endPoint: UnitPoint(x: 1, y: 0.5)
                                        )
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(30)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .inset(by: 0.25)
                                            .stroke(.white, lineWidth: 0.5)
                                        
                                    )
                            }
                            .padding(.bottom, 16)
                            .disabled(true)
                        } else {
                            Button(action: {
                                triggerHaptic()
                                if hasUnlockRequirement {
                                    withAnimation {
                                        showUnlockRequirement = true
                                    }
                                } else if isDifferentPlanActive {
                                    withAnimation {
                                        showConfirmation = true
                                    }
                                } else {
                                    trainingPlansViewModel.switchToPlan(plan.id)
                                }
                            }) {
                                Text("Start Program")
                                    .font(.system(size: 16, weight: .medium))
                                    .frame(width: 165, height: 50)
                                    .background(.white)
                                    .foregroundColor(.black)
                                    .cornerRadius(30)
                            }
                            .padding(.bottom, 16)
                        }
                        
                        Rectangle()
                            .fill(.white)
                            .frame(height: 0.5)
                    }
                }
                .frame(height: 400)
                
                ZStack {
                    AppBackground()
                        .ignoresSafeArea(.container, edges: .bottom)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            CardView(label: "Summary", value: plan.summary)
                                .padding(.bottom, 20)
                            CardView(label: "Difficulty", value: plan.difficulty)
                                .padding(.bottom, 30)
                            Text(plan.description)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            
            if showConfirmation {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        Text("Are You Sure?")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.top, 16)
                            .padding(.horizontal, 16)
                        Text("You are already in a different program. If you change your program all current progress will be lost.")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.top, 5)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                        Divider()
                            .background(Color.white.opacity(0.4))
                        HStack(spacing: 0) {
                            Button(action: {
                                triggerHaptic()
                                withAnimation {
                                    showConfirmation = false
                                }
                            }) {
                                Text("Cancel")
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(Color(red: 0.11, green: 0.6, blue: 0.95))
                                    .frame(maxWidth: .infinity, maxHeight: 48)
                            }
                            Divider()
                                .background(Color.white.opacity(0.4))
                                .frame(height: 48)
                            Button(action: {
                                triggerHaptic()
                                trainingPlansViewModel.switchToPlan(plan.id)
                                withAnimation {
                                    showConfirmation = false
                                }
                            }) {
                                Text("I'm Sure")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(Color(red: 0.11, green: 0.6, blue: 0.95))
                                    .frame(maxWidth: .infinity, maxHeight: 48)
                            }
                        }
                        .background(Color.clear)
                    }
                    .frame(width: 280)
                    .background(Color(hex: "#313131"))
                    .cornerRadius(22)
                    .shadow(radius: 30)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            
            if showUnlockRequirement {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        Text("Locked for now")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.top, 16)
                            .padding(.horizontal, 16)
                        Text("You need to complete the “Outlast” program before unlocking Multi-Orgasm Protocol.")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.top, 5)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                        Divider()
                            .background(Color.white.opacity(0.4))
                        Button(action: {
                            triggerHaptic()
                            withAnimation {
                                showUnlockRequirement = false
                            }
                        }) {
                            Text("Okay")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(Color(red: 0.11, green: 0.6, blue: 0.95))
                                .frame(maxWidth: .infinity, maxHeight: 48)
                        }
                    }
                    .frame(width: 280)
                    .background(Color(hex: "#313131"))
                    .cornerRadius(22)
                    .shadow(radius: 30)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .animation(.easeInOut, value: showConfirmation)
        .animation(.easeInOut, value: showUnlockRequirement)
    }
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}

struct CardView: View {
    let label: String
    let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(LinearGradient(
                    colors: [Color(hex: "#FFFFFF"), Color(hex: "#FFFFFF"), Color(hex: "#B8B8B8")],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .padding(.top, 12)
                .padding(.bottom, 2)
                .padding(.horizontal, 16)
            Text(value)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.18, green: 0.18, blue: 0.18))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 9)
                .inset(by: 0.5)
                .stroke(.white, lineWidth: 1)
        )
    }
}

#if DEBUG
struct TrainingPlanLearnMoreView_Previews: PreviewProvider {
    static var previews: some View {
        let plan = TrainingPlan(
            id: "kegel_basics",
            name: "Kegel Basics",
            duration: 35,
            difficulty: "This is a beginner program and is relatively easy for most users.",
            summary: "Over 35 days, you'll train your pelvic floor to hold a strong, focused Kegel for up to 2 minutes, with full awareness and no tension in the rest of your body. This should help you maintain control before ejaculation and should significantly increase your endurance in bed at the end of this program.",
            description: "Why This Program Matters and Why You'll Be Glad You Started\n\nYou're not just doing a 35-day challenge. You're building a skill that rewires how your body performs from the inside out. Most people never train their pelvic floor. But the ones who do know: it changes everything.\n\nThis beginner program is designed to help you develop full control over your pelvic floor muscles, starting with simple activations and building up to holding strong, focused Kegels for up to 2 minutes. But the real transformation happens in how you feel, move, and perform.\n\nHere's what's waiting for you on the other side:\n\nBetter control before ejaculation\nYou'll learn to pause, reset, and stay in the moment longer, leading to more satisfying, confident experiences in bed.\n\nMore stamina\nYour endurance will noticeably increase. You'll last longer, feel stronger, and recover faster.\n\nHarder erections\nImproved blood flow and muscle tone means firmer erections with less effort.\n\nBetter core strength and posture\nYour pelvic floor is the hidden base of your core. Strengthening it improves stability and posture, especially during workouts or long hours at a desk.\n\nIncreased sensation\nKegels heighten your mind-muscle connection. More awareness, more sensitivity, more pleasure for you and your partner.\n\nConfidence\nQuiet, calm confidence that comes from knowing you're in control of your body.\n\nAnd here's the best part: you don't need to carve out hours a day or do anything embarrassing. Just 5 to 10 minutes a day, privately, on your terms, with powerful, long-term results.\n\nThis is your first step toward lasting control, endurance, and performance. 35 days from now, you won't just feel the difference. You'll be living it.",
            unlockRequirement: nil,
            days: [],
            image: nil
        )
        TrainingPlanLearnMoreView(plan: plan, trainingPlansViewModel: TrainingPlansViewModel())
            .background(Color(red: 18/255, green: 28/255, blue: 41/255))
    }
}
#endif
