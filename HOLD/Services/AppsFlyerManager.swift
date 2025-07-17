//
//  AppsFlyerManager.swift
//  HOLD
//
//  Created by Hafiz Muhammad Ali on 04/05/2025.
//

import Foundation
import AppsFlyerLib
import AdSupport
import AppTrackingTransparency
import UIKit
import FacebookCore
import FirebaseAnalytics

class AppsFlyerManager {
    static func launchSDK() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                AppsFlyerLib.shared().start()
                AppEvents.shared.activateApp()
            }
        } else {
            AppsFlyerLib.shared().start()
            AppEvents.shared.activateApp()
        }
    }
    
    static func checkForFirebaseDeepLink() {
        AppLinkUtility.fetchDeferredAppLink { (url, error) in
            if let error = error {
                print("Received error while fetching deferred app link: \(error)")
            }
            if let _ = url {}
        }
    }
    
    static func trackEvent(name: String, parameters: [String: Any]? = nil) {
        AppsFlyerLib.shared().logEvent(name, withValues: parameters)
    }
}
