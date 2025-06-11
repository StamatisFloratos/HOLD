//
//  CreatorAttributionSystem.swift
//  HOLD
//
//  Created by Muhammad Ali on 07/06/2025.
//

import Foundation
import Firebase
import FirebaseFirestore
import AppsFlyerLib

class CreatorAttributionSystem {
    static let shared = CreatorAttributionSystem()
    private let db = Firestore.firestore()
    
    func attributeUser(creatorIdentifier: String, source: AttributionSource) {
        let userId = DeviceIdManager.getUniqueDeviceId()
        
        checkExistingAttribution(userId: userId) { [weak self] existingAttribution in
            if let existingAttribution = existingAttribution {
                self?.handleExistingUserAttribution(existing: existingAttribution, newCreatorIdentifier: creatorIdentifier, newSource: source)
            } else {
                self?.createNewUserAttribution(userId: userId, creatorIdentifier: creatorIdentifier, source: source)
            }
        }
    }
    
    private func checkExistingAttribution(userId: String, completion: @escaping (UserAttribution?) -> Void) {
        db.collection("user_attributions").document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()!
                let attribution = UserAttribution(
                    userId: data["user_id"] as! String,
                    creatorCode: data["creator_code"] as! String,
                    attributionSource: data["attribution_source"] as! String,
                    linkIdentifier: data["link_identifier"] as! String,
                    platform: data["platform"] as! String
                )
                completion(attribution)
            } else {
                completion(nil)
            }
        }
    }
    
    private func createNewUserAttribution(
        userId: String,
        creatorIdentifier: String,
        source: AttributionSource
    ) {
        if source == .code {
            validateCreator(creatorIdentifier) { [weak self] isValid in
                guard isValid else {
                    print("Invalid creator identifier: \(creatorIdentifier)")
                    return
                }
                
                let attributionData: [String: Any] = [
                    "user_id": userId,
                    "creator_code": creatorIdentifier,
                    "attribution_source": AttributionSource.code.rawValue,
                    "link_identifier": "",
                    "last_updated": Timestamp(date: Date()),
                    "platform": "ios",
                    "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "unknown"
                ]
                
                self?.db.collection("user_attributions").document(userId).setData(attributionData) { error in
                    if let error = error {
                        print("Error storing attribution: \(error)")
                    } else {
                        UserStorage.isValidAttributionSource = true
                        print("Attribution stored successfully")
                    }
                }
            }
        } else if source == .link {
            let attributionData: [String: Any] = [
                "user_id": userId,
                "creator_code": "",
                "attribution_source": AttributionSource.link.rawValue,
                "link_identifier": creatorIdentifier,
                "last_updated": Timestamp(date: Date()),
                "platform": "ios",
                "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "unknown"
            ]
            
            self.db.collection("user_attributions").document(userId).setData(attributionData) { error in
                if let error = error {
                    print("Error storing attribution: \(error)")
                } else {
                    UserStorage.isValidAttributionSource = true
                    print("Attribution stored successfully")
                }
            }
        }
    }
    
    private func handleExistingUserAttribution(
        existing: UserAttribution,
        newCreatorIdentifier: String,
        newSource: AttributionSource
    ) {
        if existing.attributionSource == AttributionSource.code.rawValue {
            if newSource == .link {
                let updateData: [String: Any] = [
                    "attribution_source": "both",
                    "last_updated": Timestamp(date: Date()),
                    "link_identifier": newCreatorIdentifier
                ]
                
                db.collection("user_attributions").document(existing.userId).updateData(updateData) { error in
                    if let error = error {
                        print("Error updating attribution: \(error)")
                    } else {
                        UserStorage.isValidAttributionSource = true
                        print("Attribution updated successfully")
                    }
                }
            } else if newSource == .code {
                validateCreator(newCreatorIdentifier) { [weak self] isValid in
                    guard isValid else {
                        print("Invalid creator identifier: \(newCreatorIdentifier)")
                        return
                    }
                    
                    let updateData: [String: Any] = [
                        "creator_code": newCreatorIdentifier,
                        "last_updated": Timestamp(date: Date())
                    ]
                    
                    self?.db.collection("user_attributions").document(existing.userId).updateData(updateData) { error in
                        if let error = error {
                            print("Error updating attribution: \(error)")
                        } else {
                            UserStorage.isValidAttributionSource = true
                            print("Attribution updated successfully")
                        }
                    }
                }
            }
        } else if existing.attributionSource == AttributionSource.link.rawValue {
            if newSource == .code {
                let updateData: [String: Any] = [
                    "attribution_source": "both",
                    "last_updated": Timestamp(date: Date()),
                    "creator_code": newCreatorIdentifier
                ]
                
                db.collection("user_attributions").document(existing.userId).updateData(updateData) { error in
                    if let error = error {
                        print("Error updating attribution: \(error)")
                    } else {
                        UserStorage.isValidAttributionSource = true
                        print("Attribution updated successfully")
                    }
                }
            } else {
                let updateData: [String: Any] = [
                    "link_identifier": newCreatorIdentifier,
                    "last_updated": Timestamp(date: Date())
                ]
                
                db.collection("user_attributions").document(existing.userId).updateData(updateData) { error in
                    if let error = error {
                        print("Error updating attribution: \(error)")
                    } else {
                        UserStorage.isValidAttributionSource = true
                        print("Attribution updated successfully")
                    }
                }
            }
        } else {
            if newSource == .code {
                let updateData: [String: Any] = [
                    "creator_code": newCreatorIdentifier,
                    "last_updated": Timestamp(date: Date())
                ]
                
                db.collection("user_attributions").document(existing.userId).updateData(updateData) { error in
                    if let error = error {
                        print("Error updating attribution: \(error)")
                    } else {
                        UserStorage.isValidAttributionSource = true
                        print("Attribution updated successfully")
                    }
                }
            } else if newSource == .link {
                let updateData: [String: Any] = [
                    "link_identifier": newCreatorIdentifier,
                    "last_updated": Timestamp(date: Date())
                ]
                
                db.collection("user_attributions").document(existing.userId).updateData(updateData) { error in
                    if let error = error {
                        print("Error updating attribution: \(error)")
                    } else {
                        UserStorage.isValidAttributionSource = true
                        print("Attribution updated successfully")
                    }
                }
            }
        }
    }
    
    private func validateCreator(_ creatorIdentifier: String, completion: @escaping (Bool) -> Void) {
        db.collection("creators").document(creatorIdentifier).getDocument() { (document, error) in
            if let document = document, document.exists {
                let isActive = document.data()?["is_active"] as? Bool ?? false
                completion(isActive)
            } else {
                completion(false)
            }
        }
    }
}
