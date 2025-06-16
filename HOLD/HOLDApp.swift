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
import FirebaseCore
import AppsFlyerLib

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        AppsFlyerManager.initialize()
        FirebaseApp.configure()
        
        if let url = launchOptions?[.url] as? URL {
            handleDeepLink(url: url)
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        handleDeepLink(url: url)
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: { _ in })
        
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL {
            handleDeepLink(url: url)
        }
        
        return true
    }
    
    private func handleDeepLink(url: URL) {
        DeepLinkHandler.shared.processDeepLink(url: url)
    }
}

extension AppDelegate: AppsFlyerLibDelegate {
    
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {
        print("AppsFlyer conversion data: \(conversionInfo)")
        
        if let status = conversionInfo["af_status"] as? String,
           status == "Non-organic" {
            
            if let campaign = conversionInfo["campaign"] as? String {
                print("User came from campaign: \(campaign)")
            }
            
            if let deepLinkValue = conversionInfo["deep_link_value"] as? String {
                CreatorAttributionSystem.shared.attributeUser(
                    creatorIdentifier: deepLinkValue,
                    source: .link
                )
            }
        }
    }
    
    func onConversionDataFail(_ error: Error) {
        print("AppsFlyer conversion data failed: \(error)")
    }
    
    func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]) {
        print("AppsFlyer deep link data: \(attributionData)")
        
        if let deepLinkValue = attributionData["deep_link_value"] as? String {
            CreatorAttributionSystem.shared.attributeUser(
                creatorIdentifier: deepLinkValue,
                source: .link
            )
        }
    }
    
    func onAppOpenAttributionFailure(_ error: Error) {
        print("AppsFlyer deep link failed: \(error)")
    }
}


@main
struct HOLDApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
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
                    
                    if !UserStorage.isOnboardingDone {
                        FirebaseManager.shared.fetchRemoteConfig {}
                    }
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        if navigationManager.routes.isEmpty {
                            navigationManager.push(to: .mainTabView)
                        }
                    }
                }
        }
    }
}
