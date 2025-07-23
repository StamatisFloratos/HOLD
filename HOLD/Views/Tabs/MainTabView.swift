//
//  MainTabView.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import SwiftUI

class TabManager: ObservableObject {
    @Published var selectedTab: Int = 1
    @Published var isTabBarHidden: Bool = false
}

struct MainTabView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var selectedTab = 1
    @EnvironmentObject var tabManager: TabManager
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @EnvironmentObject var challengeViewModel: ChallengeViewModel
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    @EnvironmentObject var knowledgeViewModel: KnowledgeViewModel
    @EnvironmentObject var keyboardResponder: KeyboardResponder
    
    @State private var showWelcomeOnboarding = UserStorage.showWelcomeOnboarding
    @State private var showTrainingPlanOnboarding = UserStorage.showTrainingPlanOnboarding
    @State private var blurAmount: CGFloat = 0
    @State private var welcomeContentOpacity: Double = 0
    @State private var trainingPlanContentOpacity: Double = 0
    
    init() {
        UITabBar.appearance().isHidden = true // Hide the default tab bar
    }
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $tabManager.selectedTab) {
                ProgressTabView()
                    .tag(0)
                    .environmentObject(challengeViewModel)
                    .environmentObject(progressViewModel)
                WorkoutTabView()
                    .tag(1)
                    .environmentObject(workoutViewModel)
                KnowledgeTabView()
                    .tag(2)
                ProfileTabView()
                    .tag(3)
            }
            .edgesIgnoringSafeArea(.top)
            
            if !keyboardResponder.isKeyboardVisible && !tabManager.isTabBarHidden {
                ZStack {
                    HStack(spacing: 0) {
                        TabBarButton(imageName: "progressIcon", isSelected: tabManager.selectedTab == 0, selectedTab: 0)
                            .onTapGesture {
                                triggerHaptic()
                                tabManager.selectedTab = 0 }
                        Spacer()
                        TabBarButton(imageName: "workoutIcon", isSelected: tabManager.selectedTab == 1, selectedTab: 1)
                            .onTapGesture {
                                triggerHaptic()
                                tabManager.selectedTab = 1 }
                        Spacer()
                        TabBarButton(imageName: "knowledgeIcon", isSelected: tabManager.selectedTab == 2, selectedTab: 2)
                            .onTapGesture {
                                triggerHaptic()
                                tabManager.selectedTab = 2 }
                        Spacer()
                        TabBarButton(imageName: "profileIcon", isSelected: tabManager.selectedTab == 3, selectedTab: 3)
                            .onTapGesture {
                                triggerHaptic()
                                tabManager.selectedTab = 3 }
                    }
                    .padding(.horizontal,5)
                }
                .background(Color(hex: "#111720"))
                .animation(.easeInOut(duration: 0.5), value: tabManager.isTabBarHidden)
            }
        }
        .blur(radius: blurAmount)
        .onAppear() {
            if showWelcomeOnboarding {
                startWelcomeAnimation()
            } else if showTrainingPlanOnboarding {
                startTrainingPlanAnimation()
            }
            
            FirebaseManager.shared.logAgeEvent()
        }
        .overlay {
            if showWelcomeOnboarding {
                DashboardWelcomeView(onCompletion: {
                    dismissWelcomeAnimation()
                })
                .transition(.asymmetric(
                    insertion: .opacity,
                    removal: .move(edge: .leading)
                ))
                .opacity(welcomeContentOpacity)
            } else if showTrainingPlanOnboarding {
                TrainingPlanOnboarding(onCompletion: {
                    dismissTrainingPlanAnimation()
                })
            }
        }
    }
    
    private func startTrainingPlanAnimation() {
        withAnimation(.easeInOut(duration: 0.4)) {
            blurAmount = 20
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeInOut(duration: 0.3)) {
                trainingPlanContentOpacity = 1.0
            }
        }
    }
    
    private func dismissTrainingPlanAnimation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            trainingPlanContentOpacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.4)) {
                blurAmount = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                showTrainingPlanOnboarding = false
                UserStorage.showTrainingPlanOnboarding = false
            }
        }
    }
    
    private func startWelcomeAnimation() {
        withAnimation(.easeInOut(duration: 0.4)) {
            blurAmount = 20
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeInOut(duration: 0.3)) {
                welcomeContentOpacity = 1.0
            }
        }
    }
    
    private func dismissWelcomeAnimation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            welcomeContentOpacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.4)) {
                blurAmount = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                showWelcomeOnboarding = false
                UserStorage.showWelcomeOnboarding = false
            }
        }
    }
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}

struct TabBarButton: View {
    var imageName: String
    var isSelected: Bool
    var selectedTab: Int
    
    var body: some View {
        VStack(spacing:3) {
            if selectedTab == 3 {
                Image(systemName: "person.fill")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30 )
                    .foregroundColor(isSelected ? .white : .gray)
            }
            else {
                Image(imageName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30)
                    .foregroundColor(isSelected ? .white : .gray)
            }
            
            Text(
                selectedTab == 0 ? "Progress" : (selectedTab == 1 ? "Workout" : (selectedTab == 2 ? "Explore" : "Profile") )
            )
            .font(.system(size: 12))
            .foregroundColor(isSelected ? .white : .gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 15)
        
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}



#Preview {
    MainTabView()
        .environmentObject(TabManager())
        .environmentObject(ChallengeViewModel())
        .environmentObject(ProgressViewModel())
        .environmentObject(WorkoutViewModel())
        .environmentObject(KnowledgeViewModel())
        .environmentObject(KeyboardResponder())
        .environmentObject(TrainingPlansViewModel.preview)
}
