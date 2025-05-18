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
    
    @AppStorage("isPremium") var isPremium: Bool = false
    
    @State private var showStartView = false

    var body: some View {
        ZStack {
            if isPremium {
                MainTabView()
            } else {
                if UserStorage.isOnboardingDone {
                    SubscriptionView()
                } else {
                    StartView()
                }
            }
        }
    }
}

#Preview {
    SplashView()
        .environmentObject(NavigationManager())
}
