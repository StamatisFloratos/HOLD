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
import FacebookCore
import FirebaseAnalytics

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        AppsFlyerLib.shared().appsFlyerDevKey = "WaVeTPraQ7xQAnTge9W5tg"
        AppsFlyerLib.shared().appleAppID = "6745149501"
        AppsFlyerLib.shared().customerUserID = DeviceIdManager.getUniqueDeviceId()
        
        #if DEBUG
        AppsFlyerLib.shared().isDebug = true
        #endif
        
        FirebaseApp.configure()
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        Settings.shared.enableLoggingBehavior(.appEvents)
        Settings.shared.isAutoLogAppEventsEnabled = true
        Settings.shared.isAdvertiserIDCollectionEnabled = true
        
        SubscriptionManager.shared.checkSubscriptionStatus()
        
        if UserStorage.isOpeningTrainingUpdateFirstTime {
            UserStorage.isOpeningTrainingUpdateFirstTime = false
            if !UserStorage.showWelcomeOnboarding {
                UserStorage.showTrainingPlanOnboarding = true
            } else {
                UserStorage.showTrainingPlanOnboarding = false
            }
        }
        
        AppDelegate.configureShortcutItem()
        
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        let _ = ApplicationDelegate.shared.application(application, continue: userActivity)
        
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
      let _ = ApplicationDelegate.shared.application(app, open: url, options: options)
      
      return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(name: "Quick Actions Configuration", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = QuickActionsSceneDelegate.self
        
        if let shortcutItem = options.shortcutItem {
            handleShortcutItem(shortcutItem)
        }
        
        return sceneConfiguration
    }

    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) {
        let userProfile = UserProfile.load()
        
        if userProfile.age < 18 {
            Superwall.shared.register(placement: "hold_gift_offer_meta_under_18", feature: {
                SubscriptionManager.shared.checkSubscriptionStatus()
            })
        } else if userProfile.age <= 24 && userProfile.age >= 18 {
            Superwall.shared.register(placement: "hold_gift_offer_meta_18_24", feature: {
                SubscriptionManager.shared.checkSubscriptionStatus()
            })
        } else {
            Superwall.shared.register(placement: "hold_gift_offer_meta_25_plus", feature: {
                SubscriptionManager.shared.checkSubscriptionStatus()
            })
        }
    }
    
    static func configureShortcutItem() {
        if SubscriptionManager.shared.isPremium {
            UIApplication.shared.shortcutItems = []
        } else {
            let type = Bundle.main.bundleIdentifier! + ".Dynamic"
            let item = UIApplicationShortcutItem.init(type: type, localizedTitle: "Secret Offer 🤫", localizedSubtitle: "", icon: UIApplicationShortcutIcon(type: .love))
            
            UIApplication.shared.shortcutItems = [item]
        }
    }
}

class QuickActionsSceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        handleShortcutItem(shortcutItem)
    }
    
    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) {
        let userProfile = UserProfile.load()
        
        if userProfile.age < 18 {
            Superwall.shared.register(placement: "hold_gift_offer_meta_under_18", feature: {
                SubscriptionManager.shared.checkSubscriptionStatus()
            })
        } else if userProfile.age <= 24 && userProfile.age >= 18 {
            Superwall.shared.register(placement: "hold_gift_offer_meta_18_24", feature: {
                SubscriptionManager.shared.checkSubscriptionStatus()
            })
        } else {
            Superwall.shared.register(placement: "hold_gift_offer_meta_25_plus", feature: {
                SubscriptionManager.shared.checkSubscriptionStatus()
            })
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
                    _ = ApplicationDelegate.shared.application(UIApplication.shared, open: url, options: [:])
                }
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                    _ = ApplicationDelegate.shared.application(UIApplication.shared, continue: userActivity)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        DispatchQueue.main.async {
                            AppsFlyerManager.launchSDK()
                        }
                    }
                    
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
