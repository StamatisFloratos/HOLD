//
//  NotificationsManager.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import Foundation
import UserNotifications

class NotificationsManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationsManager()
    
    @Published var isAuthorized = false
    @Published var notificationsEnabled = true
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // Keys for storing user preferences
    private let firstLaunchDateKey = "com.hold.firstLaunchDate"
    private let notificationsEnabledKey = "com.hold.notificationsEnabled"
    
    private override init() {
        super.init()
        // Load notification preference from UserDefaults
        // Default to true if the key doesn't exist yet
        if UserDefaults.standard.object(forKey: notificationsEnabledKey) == nil {
            // First time running the app, set notifications to enabled by default
            UserDefaults.standard.set(true, forKey: notificationsEnabledKey)
            self.notificationsEnabled = true
        } else {
            // Use the stored value
            self.notificationsEnabled = UserDefaults.standard.bool(forKey: notificationsEnabledKey)
        }
        
        // Set this class as the notification delegate
        notificationCenter.delegate = self
        checkAuthorizationStatus()
        saveFirstLaunchDateIfNeeded()
    }
    
    // Save the first launch date if it hasn't been saved yet
    private func saveFirstLaunchDateIfNeeded() {
        if UserDefaults.standard.object(forKey: firstLaunchDateKey) == nil {
            UserDefaults.standard.set(Date(), forKey: firstLaunchDateKey)
        }
    }
    
    // Get the first launch date
    private func getFirstLaunchDate() -> Date {
        if let date = UserDefaults.standard.object(forKey: firstLaunchDateKey) as? Date {
            return date
        } else {
            // If for some reason the date wasn't saved, save it now and return current date
            let now = Date()
            UserDefaults.standard.set(now, forKey: firstLaunchDateKey)
            return now
        }
    }
    
    // Check if we're still within the first week of app usage
    private func isWithinFirstWeek() -> Bool {
        let firstLaunchDate = getFirstLaunchDate()
        let calendar = Calendar.current
        if let oneWeekLater = calendar.date(byAdding: .day, value: 7, to: firstLaunchDate) {
            return Date() < oneWeekLater
        }
        return false
    }
    
    // Enable all notifications
    func enableNotifications() {
        notificationsEnabled = true
        UserDefaults.standard.set(true, forKey: notificationsEnabledKey)
        
        // Re-request permission if needed
        requestPermission { [weak self] granted in
            if granted {}
        }
    }
    
    // Disable all notifications
    func disableNotifications() {
        notificationsEnabled = false
        UserDefaults.standard.set(false, forKey: notificationsEnabledKey)
        
        // Cancel all pending notifications
        cancelAllNotifications()
    }
    
    // Request notification permissions
    func requestPermission(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
                completion(granted)
            }
            
            if granted && self?.notificationsEnabled == true {}
            
            if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    // Check current authorization status
    func checkAuthorizationStatus() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // Cancel all notifications
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        print("All notifications have been canceled")
    }
    
    // MARK: - Testing Functions
    
    // Send a notification that appears immediately with no delay
    func sendInstantNotification() {
        // First check if we have permission
        checkAuthorizationStatus()
        
        guard isAuthorized else {
            print("Cannot send notification - notifications are not authorized")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Instant Notification"
        content.body = "This notification appears immediately without delay."
        content.sound = .default
        
        // Create a trigger with no delay (0 seconds)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        
        // Create the request
        let request = UNNotificationRequest(
            identifier: "com.hold.instantTest",
            content: content,
            trigger: trigger
        )
        
        // Add the request
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error sending instant notification: \(error.localizedDescription)")
            } else {
                print("Instant notification sent! Should appear immediately.")
            }
        }
    }
    
    // Send an immediate test notification (for debugging)
    func sendImmediateTestNotification() {
        // First check if we have permission
        checkAuthorizationStatus()
        
        guard isAuthorized else {
            print("Cannot send test notification - notifications are not authorized")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This is a test notification that triggers immediately."
        content.sound = .default
        
        // Create a trigger that fires 5 seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        // Create the request
        let request = UNNotificationRequest(
            identifier: "com.hold.immediateTest",
            content: content,
            trigger: trigger
        )
        
        // Add the request
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error sending test notification: \(error.localizedDescription)")
            } else {
                print("Test notification scheduled to appear in 5 seconds")
            }
        }
    }
        
    
    // Debug function to print all pending notifications
    func printAllPendingNotifications() {
        notificationCenter.getPendingNotificationRequests { requests in
            print("===== PENDING NOTIFICATIONS =====")
            print("Total count: \(requests.count)")
            
            for (index, request) in requests.enumerated() {
                print("\n--- Notification #\(index + 1) ---")
                print("Identifier: \(request.identifier)")
                
                if let content = request.content as? UNMutableNotificationContent {
                    print("Title: \(content.title)")
                    print("Body: \(content.body)")
                }
                
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    print("Next trigger date: \(trigger.nextTriggerDate()?.description ?? "unknown")")
                    print("Repeats: \(trigger.repeats)")
                } else if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                    print("Time interval: \(trigger.timeInterval)")
                    print("Next trigger date: \(trigger.nextTriggerDate()?.description ?? "unknown")")
                    print("Repeats: \(trigger.repeats)")
                }
            }
            print("================================")
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    // This method will be called when app is in foreground and notification is received
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show the notification even when the app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // This method will be called when a notification is tapped
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.notification.request.identifier
        
        completionHandler()
    }
    
    // Reset badge count when app becomes active
    func resetBadgeCount() {
        // Replace deprecated UIApplication.shared.applicationIconBadgeNumber
        notificationCenter.setBadgeCount(0) { error in
            if let error = error {
                print("Error resetting badge count: \(error.localizedDescription)")
            }
        }
    }
}
