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
                    }
                }
            )
            .embedNavigationStackWithPath(path: $navigationManager.routes)
    }
    
    //MARK: - UI Components
    private var splash: some View {
        ZStack {
            // Background gradient with specified hex colors
            LinearGradient(
                colors: [
                    Color(red: 16/255, green: 23/255, blue: 31/255),  // #10171F
                    Color(red: 70/255, green: 96/255, blue: 133/255)  // #466085
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
