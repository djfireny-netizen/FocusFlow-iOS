import Foundation
import UserNotifications

// MARK: - 通知管理器
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isNotificationEnabled: Bool = false
    
    // MARK: - 请求通知权限
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            DispatchQueue.main.async {
                self.isNotificationEnabled = granted
                completion(granted)
            }
        }
    }
    
    // MARK: - 检查通知权限
    func checkPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isNotificationEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - 发送专注提醒
    func scheduleFocusReminder(
        title: String = "专注时间到!",
        body: String = "休息 5 分钟，然后继续专注吧！💪",
        delay: TimeInterval = 0
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "FOCUS_REMINDER"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - 发送每日专注提醒
    func scheduleDailyReminder(hour: Int = 9, minute: Int = 0) {
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let content = UNMutableNotificationContent()
        content.title = "🎯 专注时间"
        content.body = "今天还没有开始专注哦，开始你的第一个番茄钟吧！"
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "DAILY_FOCUS_REMINDER",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["DAILY_FOCUS_REMINDER"])
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - 发送目标达成通知
    func sendGoalAchievedNotification() {
        let content = UNMutableNotificationContent()
        content.title = "🎉 目标达成!"
        content.body = "恭喜你完成了今天的专注目标！继续保持！"
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - 取消所有通知
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - 取消特定通知
    func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["DAILY_FOCUS_REMINDER"]
        )
    }
}
