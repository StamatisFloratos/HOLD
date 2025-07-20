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

class AppDelegate: UIResponder, UIApplicationDelegate, DeepLinkDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        AppsFlyerLib.shared().appsFlyerDevKey = "WaVeTPraQ7xQAnTge9W5tg"
        AppsFlyerLib.shared().appleAppID = "6745149501"
        AppsFlyerLib.shared().customerUserID = DeviceIdManager.getUniqueDeviceId()
        
        #if DEBUG
        AppsFlyerLib.shared().isDebug = true
        #endif
        
        AppsFlyerLib.shared().deepLinkDelegate = self
        
        FirebaseApp.configure()
        
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
      AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
      return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
      AppsFlyerLib.shared().handleOpen(url, options: options)
      return true
    }
    
    func didResolveDeepLink(_ result: DeepLinkResult) {
        switch result.status {
        case .found:
            let deepLink = result.deepLink
            
            if let mediaSource = deepLink?.mediaSource,
               mediaSource == "Social_facebook" || mediaSource == "Social_instagram" {
                UserStorage.isFromMetaAd = true
                UserStorage.onboarding = OnboardingType.onboardingThree.rawValue
            }
            
            if let deepLinkValue = deepLink?.deeplinkValue {
                CreatorAttributionSystem.shared.attributeUser(
                    creatorIdentifier: deepLinkValue,
                    source: .link
                )
            }
        default:
            print("No deep link found or error occurred.")
        }
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
    @StateObject private var trainingPlansViewModel = TrainingPlansViewModel()
    
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
                .environmentObject(trainingPlansViewModel)
                .onOpenURL { url in
                    AppsFlyerLib.shared().handleOpen(url)
                }
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                    AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        DispatchQueue.main.async {
                            AppsFlyerManager.launchSDK()
                        }
                    }
                    
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
