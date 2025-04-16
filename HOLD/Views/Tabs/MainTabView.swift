//
//  MainTabView.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import SwiftUI

class TabManager: ObservableObject {
    @Published var selectedTab: Int = 0
}

struct MainTabView: View {
    
//    @EnvironmentObject var onboardingData: OnboardingData
    @EnvironmentObject var navigationManager: NavigationManager
//    @State private var isNavigateToPremium = false
//    @State private var isFromOnboarding = false
//    @State private var isUserFirstTimeHere = true
    @State private var selectedTab = 0
    @EnvironmentObject var tabManager: TabManager

    init() {
        UITabBar.appearance().isHidden = true // Hide the default tab bar
    }
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $tabManager.selectedTab) {
                ProgressTabView()
                    .tag(0)
                WorkoutTabView()
                    .tag(1)
                KnowledgeTabView()
                    .tag(2)
                ProfileTabView()
                    .tag(3)
            }
            .edgesIgnoringSafeArea(.top)
            // Custom tab bar
            HStack {
                TabBarButton(imageName: "progressIcon", isSelected: tabManager.selectedTab == 0, selectedTab: 0)
                    .onTapGesture { tabManager.selectedTab = 0 }
                
                Spacer()
                
                TabBarButton(imageName: "workoutIcon", isSelected: tabManager.selectedTab == 1, selectedTab: 1)
                    .onTapGesture { tabManager.selectedTab = 1 }
                
                Spacer()
                
                TabBarButton(imageName: "knowledgeIcon", isSelected: tabManager.selectedTab == 2, selectedTab: 2)
                    .onTapGesture { tabManager.selectedTab = 2 }
                
                Spacer()
                
                TabBarButton(imageName: "profileIcon", isSelected: tabManager.selectedTab == 3, selectedTab: 3)
                    .onTapGesture { tabManager.selectedTab = 3 }
            }
            .frame(height: 76)
            .padding(.top, 10)
            .background(Color(hex: "#111720"))
        }
    }
}

struct TabBarButton: View {
    var imageName: String
    var isSelected: Bool
    var selectedTab: Int
    
    var body: some View {
        VStack {
            Image(imageName)
                .renderingMode(.template)
                    .resizable()
                    .frame(width:32,height: 32)
                    .foregroundColor(isSelected ? .white : .gray)
            Text(
                selectedTab == 0 ? "Progress" : (selectedTab == 1 ? "Workout" : (selectedTab == 2 ? "Knowledge" : "Profile") )
            )
            .foregroundColor(isSelected ? .white : .gray)
        }
        .frame(maxWidth: .infinity)
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
    MainTabView().environmentObject(TabManager())
}
