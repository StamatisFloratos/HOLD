//
//  AppDelegate.swift
//  TempMail
//
//  Created by Rabbia Ijaz on 08/09/2024.
//


import Foundation
import UIKit
//import FirebaseCore
//import CoreLocation
//import FBSDKCoreKit
//import AdServices
//import AdSupport
//import AppTrackingTransparency
//import UserNotifications
//import RevenueCat
//import Qonversion
//import SuperwallKit
//import SmartlookAnalytics


class AppDelegate: NSObject, UIApplicationDelegate, UIWindowSceneDelegate, UNUserNotificationCenterDelegate/*,PurchasesDelegate */{
    var window: UIWindow?
//    let locationManager = CLLocationManager()
    let encoderProperty = PropertyListEncoder()
    let decoderProperty = PropertyListDecoder()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Setup Superwall
//        Superwall.configure(apiKey: UserStorage.SuperwallKey)
        
        // Setup Qonversion
//        let config = Qonversion.Configuration(projectKey: UserStorage.QonversionKey, launchMode: .analytics)
//        Qonversion.initWithConfig(config)
//        
//        Qonversion.shared().remoteConfig { remoteConfig, error in
//            if let payload = remoteConfig?.payload {
//                UserStorage.isShowSuperWallPaywall = payload["isShowSuperwallPaywall"] as? Bool ?? false
//            }
//        }
        
        // Setup SmartLook
//        Smartlook.instance.preferences.projectKey = UserStorage.SmartLookKey
//        Smartlook.instance.start()
        
        // Setup Firebase
//        FirebaseApp.configure()
        
        // Setup Facebook SDK
//        ApplicationDelegate.shared.application(
//            application,
//            didFinishLaunchingWithOptions: launchOptions
//        )
//        Settings.shared.isAdvertiserTrackingEnabled = true
//        Settings.shared.enableLoggingBehavior(.appEvents)
//        Settings.shared.isAutoLogAppEventsEnabled = true
//        Settings.shared.isAdvertiserIDCollectionEnabled = true
        
        
        // Send in-app subscription data to Firebase
//        Qonversion.shared().setUserProperty(.userID, value: UserManager.getUserID())
        
        // Setup Facebook Ads Attribution
//        AppEvents.shared.userID = UserManager.getUserID()
        
        // Setup Apple Ads Attribution
//        Qonversion.shared().collectAppleSearchAdsAttribution()
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                // Check if notifications are enabled
//                UserStorage.isNotificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
        
//        Purchases.logLevel = .debug
//        Purchases.configure(withAPIKey: "appl_WUMSqqIBpgdHQLuUSHnFSyAdMZN")
//        Purchases.shared.delegate = self
//        
//        if ATTrackingManager.trackingAuthorizationStatus != .notDetermined {
//            // The user has previously seen a tracking request, so enable automatic collection
//            // before configuring in order to to collect whichever token is available
//            Purchases.shared.attribution.enableAdServicesAttributionTokenCollection()
//        }
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Handle device token
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Handle error
        print("Failed to register: \(error)")
    }
    
    // Handle foreground notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
    
    // Handle background notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Process the notification content
        print("User Info: \(userInfo)")
        completionHandler()
    }
    
    func applicationDidBecomeActive() {
//        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
//            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
//                switch status {
//                case .authorized:
//                    Settings.shared.isAutoLogAppEventsEnabled = true
//                    Settings.shared.isAdvertiserTrackingEnabled = true
//                    Purchases.shared.attribution.enableAdServicesAttributionTokenCollection()
//                    break
//                    
//                case .denied:
//                    Settings.shared.isAutoLogAppEventsEnabled = false
//                    Settings.shared.isAdvertiserTrackingEnabled = false
//                    Purchases.shared.attribution.enableAdServicesAttributionTokenCollection()
//                    break
//                    
//                default:
//                    break
//                }
//            })
//        }
        
//        AppEvents.shared.activateApp()
    }
    
//    func application(
//        _ app: UIApplication,
//        open url: URL,
//        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
//    ) -> Bool {
//        ApplicationDelegate.shared.application(
//            app,
//            open: url,
//            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
//            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
//        )
//    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(name: "Quick Actions Configuration", sessionRole: connectingSceneSession.role)
//        sceneConfiguration.delegateClass = QuickActionsSceneDelegate.self
        
        if let shortcutItem = options.shortcutItem {
//            handleShortcutItem(shortcutItem)
        }
        
        return sceneConfiguration
    }
    
//    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) {
//        Superwall.shared.register(event: "showGatedPaywall") {
//            _ = PaywallViewModel()
//        }
//    }
    
//    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
//        print("Purchases: didReceiveUpdated CustomerInfo - \(customerInfo)")
//    }
    
//    private func purchases(_ purchases: Purchases, readyForPromotedProduct product: StoreProduct, purchase startPurchase: @escaping StartPurchaseBlock) {
//        print("Purchases: readyForPromotedProduct - \(product.productIdentifier)")
//        startPurchase { (transaction, info, error, userCancelled) in
//            if let error = error {
//                print("Purchases: Error - \(error.localizedDescription)")
//            } else if let transaction = transaction, let info = info {
//                print("Purchases: Successful Transaction - \(transaction), CustomerInfo - \(info)")
//            }
//        }
//    }
//
//    func purchases(_ purchases: Purchases, shouldPurchasePromoProduct product: StoreProduct) -> Bool {
//        print("Purchases: shouldPurchasePromoProduct - \(product.productIdentifier)")
//        return true
//    }
}
