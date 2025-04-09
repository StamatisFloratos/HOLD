//
//  ContentView.swift
//  HOLD
//
//  Created by Stamatis Floratos on 20/3/25.
//

import Foundation
import SwiftUI
import SwiftData

//@main
struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var navigationManager = NavigationManager()
    var body: some View {
        SplashView()
            .environmentObject(navigationManager)
            .onAppear {
                appDelegate.applicationDidBecomeActive()
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .background {
                    navigationManager.reset()
                } else if newPhase == .active {
                    if navigationManager.routes.isEmpty {
//                        let nextRoute: NavigationManager.Route = UserStorage.isOnboardingDone ? .dashboardView : .onboarding
                        navigationManager.push(to: .progressView)
                    }
                }
            }
    }
}

//#Preview {
//    ContentView()
//}
