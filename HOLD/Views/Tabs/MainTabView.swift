//
//  MainTabView.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import SwiftUI

class TabManager: ObservableObject {
    @Published var selectedTab: Int = 1
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
            // Custom tab bar
            if !keyboardResponder.isKeyboardVisible {
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
                .background(Color(hex: "#111720"))
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
                selectedTab == 0 ? "Progress" : (selectedTab == 1 ? "Workout" : (selectedTab == 2 ? "Knowledge" : "Profile") )
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
}
