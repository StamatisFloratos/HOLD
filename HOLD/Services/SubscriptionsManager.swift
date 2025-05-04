//
//  SubscriptionsManager.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import Foundation
import StoreKit
import SuperwallKit
import SwiftUI
import AppsFlyerLib

class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    private var updateListenerTask: Task<Void, Error>? = nil
    
    @AppStorage("isPremium") private var isPremium: Bool = false
    
    private init() {
        // Start a transaction listener as close to app launch as possible
        updateListenerTask = listenForTransactions()
        Superwall.shared.delegate = self
        
        // Check current subscription status on initialization
        Task {
            await updateCustomerProductStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // Listen for transactions - based directly on the example code
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            // Iterate through any transactions that don't come from a direct call to `purchase()`
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    // Deliver products to the user
                    await self.updateCustomerProductStatus()
                    
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification")
                }
            }
        }
    }
    
    // Helper function to verify transaction results - directly from example
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        // Check whether the JWS passes StoreKit verification
        switch result {
        case .unverified:
            // StoreKit parses the JWS, but it fails verification
            throw StoreError.failedVerification
        case .verified(let safe):
            // The result is verified. Return the unwrapped value
            return safe
        }
    }
    
    // Update the subscription status based on current entitlements - based on example
    @MainActor
    func updateCustomerProductStatus() async {
        var hasActiveSubscription = false
        
        for await result in Transaction.currentEntitlements {
            do {
                // Check whether the transaction is verified
                let transaction = try checkVerified(result)
                
                // Check if this is an auto-renewable subscription
                if transaction.productType == .autoRenewable {
                    // If there's no revocation date, the subscription is still active
                    if transaction.revocationDate == nil {
                        hasActiveSubscription = true
                    }
                }
                
                // Always finish a transaction
                await transaction.finish()
            } catch {
                print("Failed updating products")
            }
        }
        
        // Update the isPremium flag based on subscription status
        isPremium = hasActiveSubscription
        
        // Notify any observers that subscription status has changed
        NotificationCenter.default.post(name: .subscriptionStatusChanged, object: nil)
    }
    
    // Public method to manually check subscription status
    func checkSubscriptionStatus() {
        Task {
            await updateCustomerProductStatus()
        }
    }
}

// Custom error for subscription verification - directly from example
enum StoreError: Error {
    case failedVerification
}

// Notification name for subscription status changes
extension Notification.Name {
    static let subscriptionStatusChanged = Notification.Name("subscriptionStatusChanged")
}

extension SubscriptionManager: SuperwallDelegate {
    func handleSuperwallPlacement(withInfo eventInfo: SuperwallPlacementInfo) {
        switch eventInfo.placement {
        case .subscriptionStart(let product, let paywallInfo):
            AppsFlyerLib.shared().logEvent(AFEventSubscribe, withValues: [
                AFEventParamRevenue: product.price,
                AFEventParamCurrency: product.currencyCode ?? "",
                AFEventParamContentId: product.productIdentifier,
                AFEventParamContentType: "Subscription"
            ])
            break
        case .freeTrialStart(let product, let paywallInfo):
            AppsFlyerLib.shared().logEvent(AFEventStartTrial, withValues: [
                AFEventParamContentId: product.productIdentifier,
                AFEventParamContentType: "Trial"
            ])
            break
        default:
            break
        }
    }
}
