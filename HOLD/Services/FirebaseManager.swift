//
//  FirebaseManager.swift
//  HOLD
//
//  Created by Hafiz Muhammad Ali on 31/05/2025.
//

import Foundation
import Firebase
import FirebaseRemoteConfig

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    func fetchRemoteConfig(completion: @escaping () -> Void) {
        let remoteConfig = RemoteConfig.remoteConfig()
        
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        
        remoteConfig.fetch { status, error in
            if status == .success {
                remoteConfig.activate { _, error in
                    if let error = error {
                        print("Error activating remote config: \(error.localizedDescription)")
                        completion()
                        return
                    }
                    
                    if UserStorage.isFromMetaAd {
                        UserStorage.onboarding = OnboardingType.onboardingThree.rawValue
                    } else {
                        UserStorage.onboarding = remoteConfig.configValue(forKey: "Onboarding").stringValue
                    }
                    
                    print("Onboarding is: \(UserStorage.onboarding)")
                    completion()
                }
            } else {
                if let error = error {
                    print("Error fetching remote config: \(error.localizedDescription)")
                }
                completion()
            }
        }
    }
    
    func logAgeEvent() {
        if !UserStorage.isNewAgeTriggerLogged {
            let userProfile = UserProfile.load()
            Analytics.logEvent("user_age_trigger_new", parameters: [
                "user_ID": DeviceIdManager.getUniqueDeviceId(),
                "user_name": userProfile.name,
                "user_age": String(userProfile.age)
            ])
            
            UserStorage.isNewAgeTriggerLogged = true
        }
    }
}
