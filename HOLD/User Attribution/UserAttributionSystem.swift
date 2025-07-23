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

class UserAttributionSystem {
    static let shared = UserAttributionSystem()
    private let db = Firestore.firestore()
    
    func attributeUser(userAttribution: UserAttribution) {
        checkExistingAttribution(userId: userAttribution.userId) { [weak self] existingAttribution in
            if let existingAttribution = existingAttribution {
                self?.handleExistingUserAttribution(existingAttribution: existingAttribution, newAttribution: userAttribution)
            } else {
                self?.createNewUserAttribution(userId: userAttribution.userId, userAttribution: userAttribution)
            }
        }
    }
    
    private func checkExistingAttribution(userId: String, completion: @escaping (UserAttribution?) -> Void) {
        db.collection("user_attributions").document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()!
                let attribution = UserAttribution(
                    userId: data["user_id"] as? String ?? "",
                    userName: data["user_name"] as? String ?? "",
                    userAge: data["user_age"] as? Int ?? 0,
                    onboarding: data["onboarding"] as? String ?? "",
                    productID: data["product_id"] as? String ?? "",
                    productName: data["product_name"] as? String ?? "",
                    purchaseAmount: Decimal(data["purchase_amount"] as? Double ?? 0.0),
                    currency: data["currency"] as? String ?? "",
                    isFreeTrial: data["isFreeTrial"] as? Bool ?? false,
                )
                
                completion(attribution)
            } else {
                completion(nil)
            }
        }
    }
    
    private func createNewUserAttribution(
        userId: String,
        userAttribution: UserAttribution
    ) {
        let attributionData: [String: Any] = [
            "user_id": userId,
            "user_name": userAttribution.userName,
            "user_age": userAttribution.userAge,
            "onboarding": userAttribution.onboarding,
            "product_id": userAttribution.productID,
            "product_name": userAttribution.productName,
            "purchase_amount": userAttribution.purchaseAmount,
            "currency": userAttribution.currency,
            "isFreeTrial": userAttribution.isFreeTrial,
            "last_updated": Timestamp(date: Date()),
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "unknown"
        ]
        
        db.collection("user_attributions").document(userId).setData(attributionData) { error in
            if let error = error {
                print("Error storing attribution: \(error)")
            } else {
                print("Attribution stored successfully")
            }
        }
    }
    
    private func handleExistingUserAttribution(
        existingAttribution: UserAttribution,
        newAttribution: UserAttribution
    ) {
        let updateData: [String: Any] = [
            "product_id": newAttribution.productID,
            "product_name": newAttribution.productName,
            "purchase_amount": newAttribution.purchaseAmount,
            "currency": newAttribution.currency,
            "isFreeTrial": newAttribution.isFreeTrial,
            "last_updated": Timestamp(date: Date()),
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "unknown"
        ]
        
        db.collection("user_attributions").document(existingAttribution.userId).updateData(updateData) { error in
            if let error = error {
                print("Error updating attribution: \(error)")
            } else {
                print("Attribution updated successfully")
            }
        }
    }
}
