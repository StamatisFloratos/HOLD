//
//  NotificationsManager.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import Foundation
import UserNotifications
import SwiftUICore
import SwiftUI

class NotificationsManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationsManager()

    @Published var isAuthorized = false
    @Published var notificationsEnabled = false
    private let notificationCenter = UNUserNotificationCenter.current()
    
    @AppStorage("isNotificationsScheduled") private var isNotificationsScheduled: Bool = false
    
    private let firstLaunchDateKey = "com.hold.firstLaunchDate"
    private let notificationsEnabledKey = "com.hold.notificationsEnabled"

    private override init() {
        super.init()
        
        notificationsEnabled = UserDefaults.standard.bool(forKey: notificationsEnabledKey)

        notificationCenter.delegate = self
        checkAuthorizationStatus()
        saveFirstLaunchDateIfNeeded()
    }

    private func saveFirstLaunchDateIfNeeded() {
        if UserDefaults.standard.object(forKey: firstLaunchDateKey) == nil {
            UserDefaults.standard.set(Date(), forKey: firstLaunchDateKey)
        }
    }

    private func getFirstLaunchDate() -> Date {
        if let date = UserDefaults.standard.object(forKey: firstLaunchDateKey) as? Date {
            return date
        }
        let now = Date()
        UserDefaults.standard.set(now, forKey: firstLaunchDateKey)
        return now
    }

    func checkAuthorizationStatus() {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
                self.notificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }

    func requestPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if granted {
                    self.notificationsEnabled = true
                    self.isNotificationsScheduled = true
                    self.scheduleAllNotifications()
                }
            }
        }
    }

    func enableNotifications() {
        notificationsEnabled = true
        isNotificationsScheduled = true
        UserDefaults.standard.set(true, forKey: notificationsEnabledKey)
        scheduleAllNotifications()
    }

    func disableNotifications() {
        notificationsEnabled = false
        isNotificationsScheduled = false
        UserDefaults.standard.set(false, forKey: notificationsEnabledKey)
        notificationCenter.removeAllPendingNotificationRequests()
    }

    // MARK: - Schedule All Notifications
    private func scheduleAllNotifications() {
        guard notificationsEnabled, isAuthorized else { return }

        notificationCenter.removeAllPendingNotificationRequests()

        scheduleDailyReminder()
        scheduleEveryThirdDayNotifications()
    }

    private func scheduleDailyReminder() {
        let userProfile = UserProfile.load()
        
        let content = UNMutableNotificationContent()
        content.title = "\(userProfile.name), Today's workout is ready"
        content.body = "Rome wasn't built in a day, neither did anyone's stamina. Come do a 5 min workout!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 19

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyWorkout", content: content, trigger: trigger)
        notificationCenter.add(request)
    }

    private func scheduleEveryThirdDayNotifications() {
        let messages = [
            "He went from 2 minutes to 20… I couldn’t walk after",
            "I faked it for 6 months… now I can’t stop screaming",
            "Bro, I almost cried after. I felt like a king",
            "She said, ‘What the did you do?!'",
            "I used to avoid sex. Now I initiate it",
            "She told her friends. Now they want their boyfriends to try it",
            "From ‘it’s okay’ to ‘don’t you dare stop’",
            "I used to lose it as soon as she touched me…",
            "She said it felt like we were having sex for the first time again",
            "You’re not broken. You’re just untrained"
        ]
        
        let descriptions = [
            "My boyfriend started using Hold two weeks ago. At first, I thought it was another useless app but last night? Let’s just say, I didn’t know he had it in him. Literally changed everything.",
            "I used to pretend just to get it over with. Then he told me he was using something called Hold. Now? I beg him not to stop. Whoever made this app, thank you.",
            "Not gonna lie, I was nervous. I always finished way too fast. But after a few sessions with Hold, it just clicked. I finally controlled it. And the look on her face? I’ll never forget it.",
            "That’s what she whispered after our last session. I didn’t even tell her I was training with Hold. She just knew something was different. Better. Way better.",
            "I hated the embarrassment. Finishing early kills your confidence. But Hold gave me tools that actually work. I feel in control now and that changes everything.",
            "Yeah, it was that good. One night, and she wouldn’t shut up about it. Now her group chat’s asking about that app you’re using. Hold’s my secret weapon and I’m proud of it.",
            "That shift didn’t come overnight. But Hold taught me how to train for real stamina. She notices. I notice. We both leave the bed smiling now.",
            "It was humiliating. But I didn’t give up. Hold gave me daily routines that built control step by step. Now I take my time and she loves every second.",
            "It wasn’t magic, it was practice. Hold made me consistent. Focused. Strong. And that moment we locked eyes, both breathless? I knew I was never going back.",
            "I thought I was the problem. But Hold showed me how to treat my performance like a skill. It’s training, not luck. I took control and it’s the best decision I’ve made for us."
        ]

        let firstLaunch = getFirstLaunchDate()
        let calendar = Calendar.current

        for (index, message) in messages.enumerated() {
            guard let fireDate = calendar.date(byAdding: .day, value: index * 3, to: firstLaunch) else { continue }

            var dateComponents = calendar.dateComponents([.year, .month, .day], from: fireDate)
            dateComponents.hour = 18

            let content = UNMutableNotificationContent()
            content.title = messages[index]
            content.body = descriptions[index]
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let identifier = "thirdDay-\(index)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            notificationCenter.add(request)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func resetBadgeCount() {
        notificationCenter.setBadgeCount(0) { error in
            if let error = error {
                print("Error resetting badge count: \(error.localizedDescription)")
            }
        }
    }
}
