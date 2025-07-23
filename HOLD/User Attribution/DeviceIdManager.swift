//
//  DeviceIdManager.swift
//  HOLD
//
//  Created by Muhammad Ali on 07/06/2025.
//

import Foundation

class DeviceIdManager {
    static let key = "com.hold.uniqueDeviceId"
    
    static func getUniqueDeviceId() -> String {
        if let existingId = KeychainHelper.get(forKey: key) {
            return existingId
        }
        
        let newId = UUID().uuidString
        KeychainHelper.save(value: newId, forKey: key)
        return newId
    }
}
