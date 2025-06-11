//
//  PurchaseTracker.swift
//  HOLD
//
//  Created by Muhammad Ali on 07/06/2025.
//

import Foundation
import Firebase
import FirebaseFirestore

class PurchaseTracker {
    static let shared = PurchaseTracker()
    private let db = Firestore.firestore()
    
    func trackPurchase(purchaseAttribution: PurchaseAttribution) {
        let userId = DeviceIdManager.getUniqueDeviceId()
        
        db.collection("user_attributions").document(userId).getDocument { [weak self] (document, error) in
            
            guard error == nil else {
                print("Firestore error: \(error!.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists else {
                print("No attribution found for user: \(userId), skipping revenue event.")
                return
            }
            
            guard UserStorage.isValidAttributionSource else {
                print("Invalid attribution source in storage, skipping revenue event.")
                return
            }
            
            let data = document.data()!
            let attribution = UserAttribution(
                userId: data["user_id"] as! String,
                creatorCode: data["creator_code"] as! String,
                attributionSource: data["attribution_source"] as! String,
                linkIdentifier: data["link_identifier"] as! String,
                platform: data["platform"] as! String
            )
            
            self?.validateDuplicateTransactionEvent(userAttribution: attribution, purchaseAttribution: purchaseAttribution)
        }
    }
    
    private func validateDuplicateTransactionEvent(
        userAttribution: UserAttribution,
        purchaseAttribution: PurchaseAttribution
    ) {
        db.collection("revenue_events").document(userAttribution.userId).getDocument { [weak self] (document, error) in
            guard error == nil else {
                print("Firestore error: \(error!.localizedDescription)")
                return
            }
            
            guard let document = document, !document.exists else {
                print("No attribution found for user: \(userAttribution.userId), skipping revenue event.")
                return
            }
            
            self?.storeRevenueEvent(userAttribution: userAttribution, purchaseAttribution: purchaseAttribution)
        }
    }
    
    private func storeRevenueEvent(
        userAttribution: UserAttribution,
        purchaseAttribution: PurchaseAttribution
    ) {
        let revenueData: [String: Any] = [
            "user_id": userAttribution.userId,
            "creator_code": userAttribution.creatorCode,
            "link_identifier": userAttribution.linkIdentifier,
            "attribution_source": userAttribution.attributionSource,
            "purchase_amount": purchaseAttribution.purchaseAmount,
            "product_id": purchaseAttribution.productID,
            "product_name": purchaseAttribution.productName,
            "currency": purchaseAttribution.currency,
            "isFreeTrial": purchaseAttribution.isFreeTrial,
            "purchase_date": Timestamp(date: Date())
        ]
        
        db.collection("revenue_events").document(userAttribution.userId).setData(revenueData) { error in
            if let error = error {
                print("Error storing revenue event: \(error)")
            } else {
                print("Revenue stored successfully!")
            }
        }
    }
}
