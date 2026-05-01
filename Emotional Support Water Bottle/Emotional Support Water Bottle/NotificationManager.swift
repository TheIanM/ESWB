//
//  NotificationManager.swift
//  Emotional Support Water Bottle
//
//  Handles requesting notification permissions, scheduling, and canceling
//  local notifications for hydration reminders.
//

import UserNotifications

class NotificationManager {
    
    static let shared = NotificationManager()
    
    private init() {}
    
    // MARK: - Permission
    
    /// Request notification authorization. Call on first launch or after onboarding.
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            #if DEBUG
            print("[NotificationManager] Permission granted: \(granted)")
            #endif
            return granted
        } catch {
            #if DEBUG
            print("[NotificationManager] Permission error: \(error)")
            #endif
            return false
        }
    }
    
    /// Check current authorization status
    func authorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
    
    // MARK: - Schedule
    
    /// Schedule a single notification
    func scheduleNotification(
        id: String,
        title: String,
        body: String,
        at date: Date,
        sound: Bool = true
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = sound ? .default : nil
        content.categoryIdentifier = "HYDRATION_REMINDER"
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: date
            ),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                #if DEBUG
                print("[NotificationManager] Failed to schedule \(id): \(error)")
                #endif
            }
        }
    }
    
    /// Schedule a test notification (fires after a short delay)
    func scheduleTestNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "HYDRATION_REMINDER"
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 5,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "test-reminder",
            content: content,
            trigger: trigger
        )
        
        // Remove any previous test first
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["test-reminder"])
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                #if DEBUG
                print("[NotificationManager] Test notification failed: \(error)")
                #endif
            } else {
                #if DEBUG
                print("[NotificationManager] Test notification scheduled (5s)")
                #endif
            }
        }
    }
    
    // MARK: - Cancel
    
    /// Remove all pending hydration reminders
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        #if DEBUG
        print("[NotificationManager] All reminders canceled")
        #endif
    }
    
    /// Remove reminders with specific IDs
    func cancelReminders(ids: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }
}
