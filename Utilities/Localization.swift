import Foundation
import SwiftUI

// MARK: - 本地化工具
struct L {
    // 基础翻译
    static func string(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
    
    // 带参数的翻译
    static func string(_ key: String, _ arguments: CVarArg...) -> String {
        let format = NSLocalizedString(key, comment: "")
        return String(format: format, arguments: arguments)
    }
}

// MARK: - 本地化键值
extension L {
    // 计时器页面
    static let focusTime = "focus_time"
    static let breakTime = "break_time"
    static let startFocus = "start_focus"
    static let pause = "pause"
    static let resume = "resume"
    static let giveUp = "give_up"
    static let tomatoCount = "tomato_count"
    static let takeABreak = "take_a_break"
    static let readyToFocus = "ready_to_focus"
    
    // Tab栏
    static let focus = "focus"
    static let statistics = "statistics"
    static let achievements = "achievements"
    static let settings = "settings"
    
    // 功能
    static let whiteNoise = "white_noise"
    static let category = "category"
    static let work = "work"
    static let study = "study"
    static let reading = "reading"
    static let meditation = "meditation"
    
    // HealthKit
    static let appleHealth = "apple_health"
    static let syncFocusData = "sync_focus_data"
    static let authorize = "authorize"
    static let authorized = "authorized"
    
    // 设置
    static let focusDuration = "focus_duration"
    static let breakDuration = "break_duration"
    static let minutes = "minutes"
    static let notificationSettings = "notification_settings"
    static let timerSettings = "timer_settings"
    static let about = "about"
    static let version = "version"
    
    // 统计
    static let todayFocus = "today_focus"
    static let totalSessions = "total_sessions"
    static let currentStreak = "current_streak"
    static let days = "days"
    static let hours = "hours"
}

// MARK: - View 扩展
extension View {
    func localized(_ key: String) -> Text {
        Text(L.string(key))
    }
}