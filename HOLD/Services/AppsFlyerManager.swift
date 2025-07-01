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

class AppsFlyerManager {
    static func launchSDK() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                AppsFlyerLib.shared().start()
            }
        } else {
            AppsFlyerLib.shared().start()
        }
    }
    
    static func trackEvent(name: String, parameters: [String: Any]? = nil) {
        AppsFlyerLib.shared().logEvent(name, withValues: parameters)
    }
}
