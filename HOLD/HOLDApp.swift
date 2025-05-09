//
//  HOLDApp.swift
//  HOLD
//
//  Created by Stamatis Floratos on 20/3/25.
//

import Foundation
import SwiftUI
import SwiftData
import SuperwallKit

@main
struct HOLDApp: App {
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var tabManager = TabManager()
    @StateObject private var navigationManager = NavigationManager()
    @StateObject private var workoutViewModel = WorkoutViewModel()
    @StateObject private var progressViewModel = ProgressViewModel()
    @StateObject private var challengeViewModel = ChallengeViewModel()
    @StateObject private var knowledgeViewModel = KnowledgeViewModel()
    @StateObject private var keyboardResponder = KeyboardResponder()
    
    @StateObject private var notificationsManager = NotificationsManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    init() {
        Superwall.configure(apiKey: "pk_3250452d883111f9496cbba98c6fb4fb7250b12e524fbaa6")
        AppsFlyerManager.initialize()
    }
    
    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(navigationManager)
                .environmentObject(tabManager)
                .environmentObject(workoutViewModel)
                .environmentObject(progressViewModel)
                .environmentObject(challengeViewModel)
                .environmentObject(knowledgeViewModel)
                .environmentObject(keyboardResponder)
                .environmentObject(notificationsManager)
                .environmentObject(subscriptionManager)
                .onAppear {
                    AppsFlyerManager.checkAndRequestATT()
                    subscriptionManager.checkSubscriptionStatus()
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .background {
//                        navigationManager.reset()
                    } else if newPhase == .active {
                        if navigationManager.routes.isEmpty {
                            navigationManager.push(to: .mainTabView)
                        }
                    }
                }
        }
    }
}
