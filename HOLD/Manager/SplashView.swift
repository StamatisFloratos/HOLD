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
                    case .mainTabView:
                        MainTabView()
                    case .measurementActivityView:
                        MeasurementActivityView()
                    case .workoutTabView:
                        WorkoutTabView()
                    case .knowledgeTabView:
                        KnowledgeTabView()
                    case .knowledgeView(categoryTitle: let categoryTitle, items: let items):
                        KnowledgeView(categoryTitle: categoryTitle, items: items)
                    case .knowledgeDetailView(item: let item):
                        KnowledgeDetailView(item: item)
                    case .workoutView:
                        WorkoutView().environmentObject(workoutViewModel)
                    case .workoutFinishView:
                        WorkoutFinishView()
                    case .workoutDetailView(selectedWorkout: let selectedWorkout):
                        WorkoutDetailView(selectedWorkout: selectedWorkout)
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
