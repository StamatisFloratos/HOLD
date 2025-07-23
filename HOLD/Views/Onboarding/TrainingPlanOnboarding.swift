//
//  TrainingPlanOnboarding.swift
//  HOLD
//
//  Created by Muhammad Ali on 23/07/2025.
//

import SwiftUI

struct TrainingPlanOnboarding: View {
    @EnvironmentObject var viewModel: TrainingPlansViewModel
    
    @State private var showNextView = false
    @State private var currentView = 1
    @State private var trigger: Int = 0
    @State private var contentOpacity: Double = 1.0
    @State private var showSwitchSheet = false
    
    var onCompletion: (() -> Void)?
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            switch currentView {
            case 1:
                stepOne
                    .opacity(contentOpacity)
            case 2:
                stepTwo
                    .opacity(contentOpacity)
            case 3:
                stepThree
                    .opacity(contentOpacity)
            default:
                stepOne
                    .opacity(contentOpacity)
            }
        }
        .animation(.easeInOut, value: showNextView)
    }
    
    var stepOne: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Image("trainingPlanBanner")
                .frame(width: 247, height: 230)
            
            Text("We’re Introducing Programs")
                .font(.system(size: 24, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.top, 26)
                .padding(.bottom, 40)
            
            Text("Now each user gets a series of personalized programs with different difficulties.")
                .font(.system(size: 16, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
            
            Spacer()
            
            Button(action: {
                triggerHaptic()
                animateToNextView()
            }) {
                Text("Next")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity, maxHeight: 47)
                    .background(Color(hex: "#FF1919"))
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .padding(.horizontal, 56)
            }
            .padding(.bottom, 24)
        }
    }
    
    var stepTwo: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Image("trainingPlanBanner")
                .frame(width: 247, height: 230)
            
            Text("Switch Anytime, Stay on Track")
                .font(.system(size: 24, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.top, 26)
                .padding(.bottom, 40)
            
            Text("If it feels too easy or too hard, switch anytime each program is still personalized to your goals.")
                .font(.system(size: 16, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
            
            Spacer()
            
            Button(action: {
                triggerHaptic()
                animateToNextView()
            }) {
                Text("Next")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity, maxHeight: 47)
                    .background(Color(hex: "#FF1919"))
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .padding(.horizontal, 56)
            }
            .padding(.bottom, 24)
        }
    }
    
    var stepThree: some View {
        VStack(spacing: 0) {
            Text("Here’s your first program")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .padding(.top, 40)
                .padding(.bottom, 80)
            
            Spacer()
            
            Text("Your current program is:")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Spacer().frame(height: 24)
            
            if let currentPlanId = viewModel.currentPlanId,
               let currentPlan = viewModel.plans.first(where: { $0.id == currentPlanId }) {
                TrainingPlanCardModal(
                    planName: currentPlan.name,
                    daysLeft: max(0, viewModel.daysLeft(planStartDate: viewModel.planStartDate ?? Date(), currentDate: Date(), planDurationDays: currentPlan.duration)),
                    percentComplete: 0,
                    progress: 0.0,
                    image: currentPlan.image,
                    height: 250,
                    completed: false,
                    onTap: {}
                )
                .padding(.bottom, 60)
            }
            
            Spacer()
            
            VStack(spacing: 10) {
                Button(action: {
                    triggerHaptic()
                    showSwitchSheet = true
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
                    onCompletion?()
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
        .padding(.horizontal, 30)
        .padding(.vertical, 40)
        .sheet(isPresented: $showSwitchSheet, onDismiss: {}) {
            SwitchProgramSheet(viewModel: viewModel, onSelect: { plan in
                viewModel.switchToPlan(plan.id)
                showSwitchSheet = false
            })
        }
    }
    
    func animateToNextView() {
        withAnimation(.easeInOut(duration: 0.3)) {
            contentOpacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentView += 1
            withAnimation(.easeInOut(duration: 0.3)) {
                contentOpacity = 1
            }
        }
    }
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}

#Preview {
    TrainingPlanOnboarding()
        .environmentObject(TrainingPlansViewModel.preview)
}
