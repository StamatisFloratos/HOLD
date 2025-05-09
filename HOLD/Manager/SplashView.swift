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
    
    @State private var isOnboardingDone: Bool = false
    @State private var showStartView = false

    var body: some View {
        ZStack {
            if !showStartView {
                // Splash content
                ZStack {
                    AppBackground()
                    Image("holdIcon")
                    
                }
            } else {
                StartView()
                    .transition(.move(edge: .trailing)) // or .opacity, .slide, etc.
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showStartView = true
                }
            }
        }
        
    }
}

#Preview {
    SplashView()
        .environmentObject(NavigationManager())
//        .environmentObject(OnboardingData())
//        .environmentObject(PaywallViewModel())
}
