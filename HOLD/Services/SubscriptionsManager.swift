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
import os

private let holdLogger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.chronos.holdapp", category: "HOLDapp")

class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    private var updateListenerTask: Task<Void, Error>? = nil
    
    @AppStorage("isPremium") var isPremium: Bool = false
    
    @Published private var isRedeeming: Bool = false
    
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
            if self.isPremium {
                print("Active subscription found via StoreKit")
                return
            }
            
            // check Superwall backend (for web / Stripe purchases)
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                if Superwall.shared.subscriptionStatus.isActive {
                    self.isPremium = true
                } else {
                    self.isPremium = false
                }
            }
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
    func handleSuperwallPlacement(withInfo eventInfo: SuperwallEventInfo) {
        let userProfile = UserProfile.load()
        
        switch eventInfo.event {
        case .subscriptionStart(let product, _):
            AppsFlyerLib.shared().logEvent(AFEventSubscribe, withValues: [
                AFEventParamRevenue: product.price,
                AFEventParamCurrency: product.currencyCode ?? "",
                AFEventParamContentId: product.productIdentifier,
                AFEventParamContentType: "Subscription"
            ])
            UserAttributionSystem.shared.attributeUser(userAttribution: UserAttribution(
                userId: DeviceIdManager.getUniqueDeviceId(),
                userName: userProfile.name,
                userAge: userProfile.age,
                onboarding: UserStorage.onboarding,
                productID: product.productIdentifier,
                productName: product.sk2Product?.displayName ?? "",
                purchaseAmount: product.price,
                currency: product.currencyCode ?? "",
                isFreeTrial: false))
            UserQuestionnaireManager.shared.logSubscriptionEvent()
            break
        case .freeTrialStart(let product, _):
            AppsFlyerLib.shared().logEvent(AFEventStartTrial, withValues: [
                AFEventParamContentId: product.productIdentifier,
                AFEventParamContentType: "Trial"
            ])
            UserAttributionSystem.shared.attributeUser(userAttribution: UserAttribution(
                userId: DeviceIdManager.getUniqueDeviceId(),
                userName: userProfile.name,
                userAge: userProfile.age,
                onboarding: UserStorage.onboarding,
                productID: product.productIdentifier,
                productName: product.sk2Product?.displayName ?? "",
                purchaseAmount: product.price,
                currency: product.currencyCode ?? "",
                isFreeTrial: true))
            UserQuestionnaireManager.shared.logSubscriptionEvent()
            break
        default:
            break
        }
    }
    
        func willRedeemLink() {
            isRedeeming = true
        }
    
    func didRedeemLink(result: RedemptionResult) {
        switch result {
        case .success(_, let info):
            let msg = "Redemption successful for \(info.purchaserInfo.email ?? "unknown")"
            print(msg)
            DispatchQueue.main.async {
                self.isPremium = true
            }
        case .invalidCode(let code):
            let msg = "Invalid redemption code: \(code)"
            print(msg)
        case .expiredCode(let code, _):
            let msg = "Expired redemption code: \(code)"
            print(msg)
        case .expiredSubscription(let code, _):
            let msg = "Expired subscription for code: \(code)"
            print(msg)
            DispatchQueue.main.async {
                self.isPremium = false
            }
        case .error(let code, let error):
            let msg = "Error redeeming code \(code): \(error)"
            print(msg)
        }
    }
    
    func subscriptionStatusDidChange(
        from oldValue: SuperwallKit.SubscriptionStatus,
        to newValue: SuperwallKit.SubscriptionStatus
    ) {
        let msg = "Subscription status changed from \(oldValue) to \(newValue)"
        print(msg)
        holdLogger.debug("\(msg, privacy: .public) - isPremium: \(self.isPremium, privacy: .public)")
        
        if newValue.isActive {
            if isRedeeming {
                self.isPremium = true
                isRedeeming = false
            }
        } else {
            self.isPremium = false
        }
        
        NotificationCenter.default.post(name: .subscriptionStatusChanged, object: nil)
    }
}
