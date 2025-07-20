import SwiftUI

struct SwitchProgramSheet: View {
    @ObservedObject var viewModel: TrainingPlansViewModel
    var onSelect: (TrainingPlan) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var showLearnMore = false
    @State private var selectedPlan: TrainingPlan? = nil
    
    var body: some View {
        ZStack {
            AppBackground()
            
            if showLearnMore {
                if let plan = selectedPlan {
                    TrainingPlanLearnMoreView(
                        plan: plan,
                        trainingPlansViewModel: viewModel,
                        onClose: {
                            withAnimation {
                                showLearnMore = false
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                }
            } else {
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.top, 18)
                                .padding(.trailing, 8)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                    VStack(spacing: 4) {
                        Text("Available Programs")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.top, 8)
                        Text("Choose a program that suits you and your goals")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.top, 8)
                            .padding(.bottom, 18)
                    }
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 50) {
                            ForEach(viewModel.plans) { plan in
                                ZStack(alignment: .top) {
                                    ZStack(alignment: .bottom) {
                                            if let imageName = plan.image {
                                                Image(imageName)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: UIScreen.main.bounds.width - 52, height: 250)
                                                    .clipped()
                                                    .cornerRadius(20)
                                            } else {
                                                Color.gray
                                                    .frame(width: UIScreen.main.bounds.width - 52, height: 250)
                                                    .cornerRadius(20)
                                            }
                                            
                                            VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark, alpha: 0.5)
                                                .frame(height: 85)
                                                .clipShape(RoundedCorner(radius: 30, corners: [.bottomLeft, .bottomRight]))
                                            
                                            VStack {
                                                Text(plan.name)
                                                    .font(.system(size: 20, weight: .medium))
                                                    .foregroundColor(.white)
                                                    .padding(.top, 15)
                                                
                                                if viewModel.currentPlanId == plan.id {
                                                    Text("Current Program")
                                                        .font(.system(size: 12, weight: .medium))
                                                        .foregroundColor(.white)
                                                        .padding(.horizontal, 14)
                                                        .padding(.vertical, 5)
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
                                                        .cornerRadius(30)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 30)
                                                                .inset(by: 0.25)
                                                                .stroke(.white, lineWidth: 0.5)
                                                        )
                                                } else if viewModel.isPlanCompleted(plan.id) {
                                                    Text("Completed")
                                                        .font(.system(size: 12, weight: .medium))
                                                        .foregroundColor(Color(hex: "#00FF22"))
                                                        .padding(.horizontal, 14)
                                                        .padding(.vertical, 5)
                                                        .background(Color(red: 0, green: 1, blue: 0.13).opacity(0.3))
                                                        .cornerRadius(30)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 30)
                                                                .inset(by: 0.25)
                                                                .stroke(Color(red: 0, green: 1, blue: 0.13), lineWidth: 0.5)
                                                            
                                                        )
                                                }
                                                
                                                Spacer()
                                                Button(action: {
                                                    selectedPlan = plan
                                                    withAnimation {
                                                        showLearnMore = true
                                                    }
                                                }) {
                                                    HStack(spacing: 8) {
                                                        Text("Learn More")
                                                            .font(.system(size: 16, weight: .semibold))
                                                        Image(systemName: "info.circle")
                                                            .font(.system(size: 18, weight: .medium))
                                                    }
                                                    .foregroundColor(.black)
                                                    .padding(.horizontal, 32)
                                                    .padding(.vertical, 14)
                                                    .background(Color.white)
                                                    .cornerRadius(30)
                                                }
                                                .padding(.bottom, 18)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        }
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .inset(by: 0.25)
                                        .stroke(.white, lineWidth: 0.5)
                                )
                                .frame(width: UIScreen.main.bounds.width - 52, height: 250)
                            }
                        }
                        .padding(.top, 50)
                        .padding(.bottom, 32)
                        .padding(.horizontal, 26)
                    }
                }
                .padding(.top, 0)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
            }
        }
        .animation(.easeInOut, value: showLearnMore)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if DEBUG
struct SwitchProgramSheet_Previews: PreviewProvider {
    static var previews: some View {
        let mockPlans = [
            TrainingPlan(
                id: "kegel_basics",
                name: "Kegel Basics",
                duration: 35,
                difficulty: "Easy",
                summary: "A beginner program to build pelvic floor strength.",
                description: "This is a detailed description of the Kegel Basics plan.",
                unlockRequirement: nil,
                days: [],
                image: "kegel_basics"
            ),
            TrainingPlan(
                id: "stronger_holds",
                name: "Stronger Holds",
                duration: 35,
                difficulty: "Medium",
                summary: "A medium program to build endurance.",
                description: "This is a detailed description of the Stronger Holds plan.",
                unlockRequirement: nil,
                days: [],
                image: "stronger_holds"
            ),
            TrainingPlan(
                id: "full_control",
                name: "Full Control",
                duration: 35,
                difficulty: "Hard",
                summary: "An advanced program for full control.",
                description: "This is a detailed description of the Full Control plan.",
                unlockRequirement: nil,
                days: [],
                image: "full_control"
            )
        ]
        let vm = TrainingPlansViewModel.preview
        vm.plans = mockPlans
        return SwitchProgramSheet(viewModel: vm, onSelect: { _ in })
            .background(Color.black)
            .environmentObject(vm)
    }
}
#endif
