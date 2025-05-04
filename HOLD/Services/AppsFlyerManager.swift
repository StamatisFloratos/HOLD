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

class AppsFlyerManager {
    static func initialize() {
        AppsFlyerLib.shared().appsFlyerDevKey = ""
        AppsFlyerLib.shared().appleAppID = ""
        AppsFlyerLib.shared().customerUserID = getUniqueDeviceId()
        
        #if DEBUG
        AppsFlyerLib.shared().isDebug = true
        #endif
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            DispatchQueue.main.async {
                self.checkAndRequestATT()
            }
        }
        
        AppsFlyerLib.shared().start()
    }
    
    static func checkAndRequestATT() {
        if #available(iOS 14, *) {
            let status = ATTrackingManager.trackingAuthorizationStatus

            if status == .notDetermined {
                ATTrackingManager.requestTrackingAuthorization { newStatus in
                    print("New ATT Status: \(newStatus.rawValue)")
                }
            } else {
                print("ATT already determined: \(status.rawValue)")
            }
        }
    }
    
    static func trackEvent(name: String, parameters: [String: Any]? = nil) {
        AppsFlyerLib.shared().logEvent(name, withValues: parameters)
    }
    
    static func getUniqueDeviceId() -> String {
        let key = "com.hold.uniqueDeviceId"
        
        if let existingId = UserDefaults.standard.string(forKey: key) {
            return existingId
        }
        
        let newId = UUID().uuidString
        UserDefaults.standard.set(newId, forKey: key)
        
        return newId
    }
}
