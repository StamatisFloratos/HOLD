//
//  UserStorage.swift
//  HOLD
//
//  Created by Rabbia Ijaz on 05/05/2025.
//


import Foundation
import SwiftUI

struct UserStorage {
    @AppStorage("isOnboardingDone", store: UserDefaults()) static var isOnboardingDone: Bool = false
    @AppStorage("isFirstTimeAppOpen", store: UserDefaults()) static var isFirstTimeAppOpen: Bool = true
    @AppStorage("isNotificationsEnabled", store: UserDefaults()) static var isNotificationsEnabled: Bool = false
    @AppStorage("isAPIDataExtracted", store: UserDefaults()) static var isAPIDataExtracted: Bool = false
    @AppStorage("caloriesInCurrentWeek", store: UserDefaults()) static var caloriesInCurrentWeek: Int = 0
    @AppStorage("isRoundOneDoneShown", store: UserDefaults()) static var isRoundOneDoneShown: Bool = false
    @AppStorage("isRoundTwoDoneShown", store: UserDefaults()) static var isRoundTwoDoneShown: Bool = false
    @AppStorage("isRoundThreeDoneShown", store: UserDefaults()) static var isRoundThreeDoneShown: Bool = false
    @AppStorage("isChallengeStartedBefore", store: UserDefaults()) static var isChallengeStartedBefore: Bool = false
    @AppStorage("workoutTimeToday", store: UserDefaults()) static var workoutTimeToday: TimeInterval = 0
    
    @AppStorage("isUserPremium", store: UserDefaults()) static var isUserPremium: Bool = false
    @AppStorage("isUserBasic", store: UserDefaults()) static var isUserBasic: Bool = false

    @AppStorage("isFromOnboarding", store: UserDefaults()) static var isFromOnboarding: Bool = true

    @AppStorage("isShowTrialSubscription", store: UserDefaults()) static var isShowTrialSubscription: Bool = false
    @AppStorage("subscriptionWeeklyRevenue", store: UserDefaults()) static var subscriptionWeeklyRevenue: Double = 0
    
    
    @AppStorage("username", store: UserDefaults()) static var username: String = ""
    @AppStorage("age", store: UserDefaults()) static var age: String = ""


}
