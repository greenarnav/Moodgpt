import Foundation
import UserNotifications
import Combine

class NotificationService {
    static let shared = NotificationService()
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Skip actual notification setup on init
    }
    
    // Request notification permissions
    func requestNotificationPermissions(completion: @escaping (Bool) -> Void) {
        // Instead of requesting real permissions, just simulate approval
        print("Notification permissions simulated as approved")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(true)
        }
    }
    
    // Schedule a city mood notification
    func scheduleCityMoodNotification(city: String, mood: Emotion, hourFromNow: Int) {
        // Skip actual notification scheduling
        print("Scheduled notification for \(city) with mood \(mood) in \(hourFromNow) hours (simulated)")
    }
    
    // Schedule a personal mood reminder
    func scheduleMoodCheckInNotification() {
        // Skip actual notification scheduling
        print("Scheduled mood check-in notification (simulated)")
    }
    
    // Schedule an important mood change notification
    func scheduleSignificantMoodChangeNotification(oldMood: Emotion, newMood: Emotion) {
        let content = UNMutableNotificationContent()
        content.title = "Significant Mood Shift Detected"
        content.body = "Your mood has changed from \(oldMood.description) to \(newMood.description). Would you like to explore what factors might be contributing?"
        content.sound = .default
        content.categoryIdentifier = "MOOD_CHANGE"
        
        // Create an immediate trigger
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 5, // 5 seconds delay to avoid immediate popup
            repeats: false
        )
        
        // Create a notification request
        let request = UNNotificationRequest(
            identifier: "mood-change-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        // Add the request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling mood change notification: \(error.localizedDescription)")
            }
        }
    }
    
    // Cancel all pending notifications
    func cancelAllNotifications() {
        // Skip actual notification cancellation
        print("All notifications cancelled (simulated)")
    }
    
    // Setup notification categories and actions
    func setupNotificationCategories() {
        // Skip actual notification category setup
        print("Notification categories setup (simulated)")
    }
    
    func scheduleActivityReminderNotification(activityType: String, timeFromNow: TimeInterval) {
        // Skip actual notification scheduling
        print("Scheduled \(activityType) reminder for \(timeFromNow) seconds from now (simulated)")
    }
} 