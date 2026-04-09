import Foundation
import SwiftUI

// MARK: - 应用常量
struct AppConstants {
    static let appName = "FocusFlow"
    static let appVersion = "1.0.0"
    
    // 订阅产品 ID
    static let monthlySubscription = "com.focusflow.premium.monthly"
    static let yearlySubscription = "com.focusflow.premium.yearly"
    static let lifetimePurchase = "com.focusflow.premium.lifetime"
    
    // 默认计时设置
    static let defaultFocusDuration: TimeInterval = 25 * 60 // 25 分钟
    static let defaultBreakDuration: TimeInterval = 5 * 60  // 5 分钟
    static let longBreakDuration: TimeInterval = 15 * 60    // 15 分钟
    static let sessionsBeforeLongBreak = 4
    
    // 颜色主题
    struct Colors {
        static let primary = Color("PrimaryColor")
        static let secondary = Color("SecondaryColor")
        static let accent = Color("AccentColor")
        static let background = Color("BackgroundColor")
        static let card = Color("CardColor")
    }
    
    // 分类
    static let categories = ["work", "study", "reading", "creation", "exercise", "meditation", "custom"]
}

// MARK: - 白噪音类型
enum WhiteNoiseType: String, CaseIterable, Identifiable {
    case rain = "rain"
    case ocean = "ocean"
    case forest = "forest"
    case cafe = "cafe"
    case fireplace = "fireplace"
    case wind = "wind"
    case none = "none"
    
    var id: String { rawValue }
    
    // 本地化显示名称
    var displayName: String {
        switch self {
        case .rain: return L("sound_rain")
        case .ocean: return L("sound_ocean")
        case .forest: return L("sound_forest")
        case .cafe: return L("sound_cafe")
        case .fireplace: return L("sound_fireplace")
        case .wind: return L("sound_wind")
        case .none: return L("sound_none")
        }
    }
    
    var fileName: String {
        switch self {
        case .rain: return "rain"
        case .ocean: return "ocean"
        case .forest: return "forest"
        case .cafe: return "cafe"
        case .fireplace: return "fireplace"
        case .wind: return "wind"
        case .none: return ""
        }
    }
}

// MARK: - 计时器状态
enum TimerState: String {
    case idle
    case focusing
    case onBreak
    case paused
}
