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
                    case .measurementView:
                        MeasurementSheetView()
                    case .progressView:
                        MainTabView()
                    case .measurementActivityView:
                        MeasurementActivityView()
                    case .workoutView:
                        WorkoutTabView()
                    case .knowledgeView:
                        KnowledgeTabView()
                    }
                }
            )
            .embedNavigationStackWithPath(path: $navigationManager.routes)
    }
    
    //MARK: - UI Components
    private var splash: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex:"#10171F"),
                    Color(hex:"#466085")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            Image("holdIcon")
                
        }
    }
    
    //MARK: - Funcs
    private func navigateView() {
//        if !UserStorage.isOnboardingDone {
//            navigationManager.push(to: .onboarding)
//        } else {
        navigationManager.push(to: .progressView)
//        }
    }
}

#Preview {
    SplashView()
        .environmentObject(NavigationManager())
//        .environmentObject(OnboardingData())
//        .environmentObject(PaywallViewModel())
}
