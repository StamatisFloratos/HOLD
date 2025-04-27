//
//  HOLDApp.swift
//  HOLD
//
//  Created by Stamatis Floratos on 20/3/25.
//

import Foundation
import SwiftUI
import SwiftData

@main
struct HOLDApp: App {
    @Environment(\.scenePhase) var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var tabManager = TabManager()
    @StateObject private var navigationManager = NavigationManager()
    @StateObject private var workoutViewModel = WorkoutViewModel()
    @StateObject private var progressViewModel = ProgressViewModel()
    @StateObject private var challengeViewModel = ChallengeViewModel()
    @StateObject private var knowledgeViewModel = KnowledgeViewModel()
    
    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(navigationManager)
                .environmentObject(tabManager)
                .environmentObject(workoutViewModel)
                .environmentObject(progressViewModel)
                .environmentObject(challengeViewModel)
                .environmentObject(knowledgeViewModel)
                .onAppear {
                    appDelegate.applicationDidBecomeActive()
                }
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .background {
                        navigationManager.reset()
                    } else if newPhase == .active {
                        if navigationManager.routes.isEmpty {
                            navigationManager.push(to: .mainTabView)
                        }
                    }
                }
        }
    }
}
