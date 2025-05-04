//
//  SplashView.swift
//  ShowMe
//
//  Created by Rabbia Ijaz on 08/09/2024.
//

import Foundation
import SwiftUI
import Photos


struct SplashView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @EnvironmentObject var challengeViewModel: ChallengeViewModel

    var body: some View {
        splash
            .onAppear {
                navigateView()
            }
            .navigationDestination(
                for: NavigationManager.Route.self,
                destination: {
                    destination in
                    switch destination {
                    case .mainTabView:
                        MainTabView()
                            .environmentObject(progressViewModel)
                            .environmentObject(challengeViewModel)
                    }
                }
            )
            .embedNavigationStackWithPath(path: $navigationManager.routes)
    }
    
    //MARK: - UI Components
    private var splash: some View {
        ZStack {
            AppBackground()
            Image("holdIcon")
                
        }
    }
    
    //MARK: - Funcs
    private func navigateView() {
//        if !UserStorage.isOnboardingDone {
//            navigationManager.push(to: .onboarding)
//        } else {
        navigationManager.push(to: .mainTabView)
//        }
    }
}

#Preview {
    SplashView()
        .environmentObject(NavigationManager())
//        .environmentObject(OnboardingData())
//        .environmentObject(PaywallViewModel())
}
