//
//  Tracking.swift
//  HOLD
//
//  Created by Amalia Kyriakopoulou on 19/05/2025.
//

import Foundation
import FirebaseAnalytics

// MARK: - Basic Tracking

// Simple tracking function with optional parameters
// If no parameters provided, maintains backward compatibility
public func track(_ name: String, parameters: [String: Any]? = nil) {
    Analytics.logEvent(name, parameters: parameters)
}

// MARK: - Onboarding-Specific Tracking

// Specific function for tracking onboarding events with variant information
// This ensures all onboarding events include the A/B test variant for proper analysis
public func trackOnboarding(_ eventName: String, variant: String) {
    let parameters: [String: Any] = [
        "onboarding_variant": variant,
        "variant_type": variant  // Alternative key for easier querying
    ]
    Analytics.logEvent(eventName, parameters: parameters)
}

// MARK: - Usage Examples
/*
 Example usage:
 
 // Basic tracking (no parameters) - maintains backward compatibility
 track("user_tapped_button")
 
 // Enhanced tracking with custom parameters
 track("user_completed_action", parameters: ["action_type": "workout", "duration": 120])
 
 // Onboarding tracking (automatically includes A/B test variant)
 trackOnboarding("ob_step_completed", variant: UserStorage.onboarding)
 
 // Before: Event: ob_q01_shown, Parameters: null
 // After:  Event: ob_q01_shown, Parameters: {
 //           "onboarding_variant": "Onboarding2",
 //           "variant_type": "Onboarding2"
 //         }
 */
