import Foundation
import SwiftData
import ActivityKit
import SwiftUI

// MARK: - 语言管理器
class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "appLanguage")
            UserDefaults.standard.synchronize()
        }
    }
    
    // 支持的语言
    let supportedLanguages = [
        (code: "auto", name: "跟随系统", nameEn: "System"),
        (code: "zh", name: "简体中文", nameEn: "Simplified Chinese"),
        (code: "en", name: "English", nameEn: "English")
    ]
    
    private init() {
        // 从 UserDefaults 读取，默认跟随系统
        self.currentLanguage = UserDefaults.standard.string(forKey: "appLanguage") ?? "auto"
    }
    
    // 获取实际使用的语言代码
    var effectiveLanguage: String {
        if currentLanguage == "auto" {
            // 跟随系统语言
            let systemLang = Locale.current.language.languageCode?.identifier ?? "en"
            return systemLang == "zh" ? "zh" : "en"
        }
        return currentLanguage
    }
    
    // 判断当前是否是中文
    var isChinese: Bool {
        effectiveLanguage == "zh"
    }
    
    // 获取语言显示名称
    func languageDisplayName(for code: String) -> String {
        if code == "auto" {
            return isChinese ? "跟随系统" : "System"
        }
        if let lang = supportedLanguages.first(where: { $0.code == code }) {
            return isChinese ? lang.name : lang.nameEn
        }
        return code
    }
}

// MARK: - 全局本地化函数
func L(_ key: String, _ arguments: CVarArg...) -> String {
    let lang = LanguageManager.shared.effectiveLanguage
    
    let strings: [String: [String: String]] = [
        // 中文
        "zh": [
            "focus": "专注",
            "statistics": "统计",
            "achievements": "成就",
            "settings": "设置",
            "focus_time": "专注时间",
            "break_time": "休息时间",
            "start_focus": "开始专注",
            "pause": "暂停",
            "resume": "继续",
            "give_up": "放弃",
            "tomato_count": "第 %d 个番茄钟",
            "take_a_break": "休息一下",
            "ready_to_focus": "准备专注",
            "white_noise": "白噪音",
            "category": "分类",
            "work": "工作",
            "study": "学习",
            "reading": "阅读",
            "meditation": "冥想",
            "apple_health": "Apple 健康",
            "sync_focus_data": "同步专注数据",
            "authorize": "去授权",
            "authorized": "已授权",
            "focus_duration": "专注时长",
            "break_duration": "休息时长",
            "minutes": "%d 分钟",
            "today_focus": "今日专注",
            "total_sessions": "总专注次数",
            "current_streak": "连续天数",
            "days": "%d 天",
            "hours": "%d 小时",
            "notification_settings": "通知设置",
            "timer_settings": "计时器设置",
            "about": "关于",
            "version": "版本",
            "feedback": "反馈",
            "clear_data": "清除所有数据",
            "data_management": "数据管理",
            "dangerous_action": "危险操作",
            "confirm_clear": "确认清除",
            "cancel": "取消",
            "enter_delete_confirm": "请输入 \"删除\" 以确认：",
            "delete_placeholder": "删除",
            "will_permanently_delete": "此操作将永久删除：",
            "all_focus_records": "所有专注记录",
            "all_achievement_data": "所有成就数据",
            "statistics_data": "统计数据",
            "language": "语言",
            "system": "跟随系统",
            "stay_focused": "保持专注，成就更多",
            "done": "完成",
            "minutes_plain": "分钟",
            "view_all": "查看全部",
            "volume": "音量",
            "playing": "播放中",
            "tap_to_play": "点击播放",
            "sound_rain": "雨声",
            "sound_ocean": "海浪",
            "sound_forest": "森林",
            "sound_cafe": "咖啡馆",
            "sound_fireplace": "壁炉",
            "sound_wind": "风声",
            "sound_none": "无",
            "cat_work": "工作",
            "cat_study": "学习",
            "cat_reading": "阅读",
            "cat_creation": "创作",
            "cat_exercise": "运动",
            "cat_meditation": "冥想",
            "cat_custom": "自定义",
            "daily_goal": "今日目标",
            "goal_achieved": "目标达成!",
            "minutes_remaining": "还差 %d 分钟",
            "weekly_trend": "本周趋势",
            "category_stats": "分类统计",
            "no_data": "暂无数据",
            "unlock_premium": "解锁高级功能",
            "premium_desc": "解锁所有高级功能，提升专注体验",
            "monthly_plan": "月付方案",
            "yearly_plan": "年付方案",
            "lifetime_plan": "终身方案",
            "subscribe": "订阅",
            "restore_purchases": "恢复购买",
            "terms": "服务条款",
            "privacy": "隐私政策",
            "subscription_note": "订阅将自动续期，可随时取消",
            "unlocked": "已解锁",
            "total_achievements": "总成就",
            "end_break": "结束休息",
            "focus_category": "专注分类",
            "on_break": "休息中",
            "focusing": "专注中...",
            "paused": "已暂停",
            "upgrade": "升级",
            "daily_focus_goal": "每日专注目标",
            "target_duration": "目标时长",
            "daily_goal_tip": "每日完成 %d 分钟目标，解锁成就！",
            "daily_reminder": "每日专注提醒",
            "send_feedback": "发送反馈",
            "feedback_message": "请发送邮件至：fireny@live.com\n\n建议包含以下内容：\n• 遇到的问题描述\n• 复现步骤\n• 截图（如有）",
            "copy_email": "复制邮箱",
            "unlock_all_features": "解锁全部功能",
            "make_focus_habit": "让专注成为一种习惯",
            "completed_count": "完成次数",
            "longest_streak": "最长连续",
            "days_unit": "天",
            "weekday_sun": "周日",
            "weekday_mon": "周一",
            "weekday_tue": "周二",
            "weekday_wed": "周三",
            "weekday_thu": "周四",
            "weekday_fri": "周五",
            "weekday_sat": "周六",
            "ach_first_try": "初次尝试",
            "ach_first_try_desc": "完成第一次专注",
            "ach_getting_better": "渐入佳境",
            "ach_getting_better_desc": "完成10次专注",
            "ach_focus_expert": "专注达人",
            "ach_focus_expert_desc": "完成50次专注",
            "ach_focus_master": "专注大师",
            "ach_focus_master_desc": "完成100次专注",
            "ach_persistent": "坚持不懈",
            "ach_persistent_desc": "连续专注5天",
            "ach_on_fire": "火力全开",
            "ach_on_fire_desc": "连续专注30天",
            "ach_early_bird": "早起鸟",
            "ach_early_bird_desc": "在早上6点前完成专注",
            "ach_night_owl": "夜猫子",
            "ach_night_owl_desc": "在晚上11点后完成专注",
            "ach_marathon": "马拉松选手",
            "ach_marathon_desc": "单次专注超过60分钟",
            "ach_time_lord": "时间领主",
            "ach_time_lord_desc": "累计专注100小时",
            "ach_goal_achiever": "目标达成者",
            "ach_goal_achiever_desc": "完成1次每日目标",
            "ach_weekly_star": "一周达人",
            "ach_weekly_star_desc": "连续7天达成目标",
            "ach_monthly_star": "月度之星",
            "ach_monthly_star_desc": "单月专注超过50小时",
            "ach_wh_noise_lover": "白噪音爱好者",
            "ach_wh_noise_lover_desc": "使用白噪音专注20次",
            "ach_efficient": "高效能手",
            "ach_efficient_desc": "一天内完成10个番茄钟",
            "ach_study_expert": "学习达人",
            "ach_study_expert_desc": "学习类专注完成30次",
            "ach_workaholic": "工作狂人",
            "ach_workaholic_desc": "工作类专注完成50次",
            "ach_balanced_life": "平衡生活",
            "ach_balanced_life_desc": "使用所有分类各10次",
            "premium_member": "Premium 会员",
            "upgrade_to_premium": "升级到 Premium",
            "thanks_for_support": "感谢支持！享受所有高级功能",
            "health_synced": "专注时间已同步到 Apple 健康",
            "health_auth_desc": "授权后将专注时间同步到 Apple 健康 App",
            "developer": "开发者"
        ],
        // 英文
        "en": [
            "focus": "Focus",
            "statistics": "Statistics",
            "achievements": "Achievements",
            "settings": "Settings",
            "focus_time": "Focus Time",
            "break_time": "Break Time",
            "start_focus": "Start Focus",
            "pause": "Pause",
            "resume": "Resume",
            "give_up": "Give Up",
            "tomato_count": "Tomato %d",
            "take_a_break": "Take a Break",
            "ready_to_focus": "Ready to Focus",
            "white_noise": "White Noise",
            "category": "Category",
            "work": "Work",
            "study": "Study",
            "reading": "Reading",
            "meditation": "Meditation",
            "apple_health": "Apple Health",
            "sync_focus_data": "Sync Focus Data",
            "authorize": "Authorize",
            "authorized": "Authorized",
            "focus_duration": "Focus Duration",
            "break_duration": "Break Duration",
            "minutes": "%d min",
            "today_focus": "Today's Focus",
            "total_sessions": "Total Sessions",
            "current_streak": "Current Streak",
            "days": "%d days",
            "hours": "%d hours",
            "notification_settings": "Notifications",
            "timer_settings": "Timer Settings",
            "about": "About",
            "version": "Version",
            "feedback": "Feedback",
            "clear_data": "Clear All Data",
            "data_management": "Data Management",
            "dangerous_action": "Dangerous Action",
            "confirm_clear": "Confirm Clear",
            "cancel": "Cancel",
            "enter_delete_confirm": "Type \"DELETE\" to confirm:",
            "delete_placeholder": "DELETE",
            "will_permanently_delete": "This will permanently delete:",
            "all_focus_records": "All focus records",
            "all_achievement_data": "All achievement data",
            "statistics_data": "Statistics data",
            "language": "Language",
            "system": "System",
            "stay_focused": "Stay focused, achieve more",
            "done": "Done",
            "minutes_plain": "minutes",
            "view_all": "View All",
            "volume": "Volume",
            "playing": "Playing",
            "tap_to_play": "Tap to Play",
            "sound_rain": "Rain",
            "sound_ocean": "Ocean",
            "sound_forest": "Forest",
            "sound_cafe": "Cafe",
            "sound_fireplace": "Fireplace",
            "sound_wind": "Wind",
            "sound_none": "None",
            "cat_work": "Work",
            "cat_study": "Study",
            "cat_reading": "Reading",
            "cat_creation": "Creation",
            "cat_exercise": "Exercise",
            "cat_meditation": "Meditation",
            "cat_custom": "Custom",
            "daily_goal": "Daily Goal",
            "goal_achieved": "Goal Achieved!",
            "minutes_remaining": "%d min remaining",
            "weekly_trend": "Weekly Trend",
            "category_stats": "Category Stats",
            "no_data": "No Data",
            "unlock_premium": "Unlock Premium",
            "premium_desc": "Unlock all premium features for better focus",
            "monthly_plan": "Monthly",
            "yearly_plan": "Yearly",
            "lifetime_plan": "Lifetime",
            "subscribe": "Subscribe",
            "restore_purchases": "Restore",
            "terms": "Terms",
            "privacy": "Privacy",
            "subscription_note": "Auto-renews, cancel anytime",
            "unlocked": "Unlocked",
            "total_achievements": "Total",
            "end_break": "End Break",
            "focus_category": "Category",
            "on_break": "On Break",
            "focusing": "Focusing...",
            "paused": "Paused",
            "upgrade": "Upgrade",
            "daily_focus_goal": "Daily Goal",
            "target_duration": "Target",
            "daily_goal_tip": "Complete %d min daily to unlock achievements!",
            "daily_reminder": "Daily Reminder",
            "send_feedback": "Send Feedback",
            "feedback_message": "Please email: fireny@live.com\n\nInclude:\n• Issue description\n• Steps to reproduce\n• Screenshots (if any)",
            "copy_email": "Copy Email",
            "unlock_all_features": "Unlock All Features",
            "make_focus_habit": "Make focus a habit",
            "completed_count": "Completed",
            "longest_streak": "Longest Streak",
            "days_unit": " days",
            "weekday_sun": "Sun",
            "weekday_mon": "Mon",
            "weekday_tue": "Tue",
            "weekday_wed": "Wed",
            "weekday_thu": "Thu",
            "weekday_fri": "Fri",
            "weekday_sat": "Sat",
            "ach_first_try": "First Try",
            "ach_first_try_desc": "Complete your first focus session",
            "ach_getting_better": "Getting Better",
            "ach_getting_better_desc": "Complete 10 focus sessions",
            "ach_focus_expert": "Focus Expert",
            "ach_focus_expert_desc": "Complete 50 focus sessions",
            "ach_focus_master": "Focus Master",
            "ach_focus_master_desc": "Complete 100 focus sessions",
            "ach_persistent": "Persistent",
            "ach_persistent_desc": "Focus for 5 consecutive days",
            "ach_on_fire": "On Fire",
            "ach_on_fire_desc": "Focus for 30 consecutive days",
            "ach_early_bird": "Early Bird",
            "ach_early_bird_desc": "Complete focus before 6 AM",
            "ach_night_owl": "Night Owl",
            "ach_night_owl_desc": "Complete focus after 11 PM",
            "ach_marathon": "Marathoner",
            "ach_marathon_desc": "Focus for over 60 minutes in one session",
            "ach_time_lord": "Time Lord",
            "ach_time_lord_desc": "Accumulate 100 hours of focus time",
            "ach_goal_achiever": "Goal Achiever",
            "ach_goal_achiever_desc": "Complete daily goal once",
            "ach_weekly_star": "Weekly Star",
            "ach_weekly_star_desc": "Achieve goals for 7 consecutive days",
            "ach_monthly_star": "Monthly Star",
            "ach_monthly_star_desc": "Focus over 50 hours in a month",
            "ach_wh_noise_lover": "White Noise Lover",
            "ach_wh_noise_lover_desc": "Use white noise for 20 focus sessions",
            "ach_efficient": "Efficient",
            "ach_efficient_desc": "Complete 10 Pomodoros in one day",
            "ach_study_expert": "Study Expert",
            "ach_study_expert_desc": "Complete 30 study sessions",
            "ach_workaholic": "Workaholic",
            "ach_workaholic_desc": "Complete 50 work sessions",
            "ach_balanced_life": "Balanced Life",
            "ach_balanced_life_desc": "Use all categories 10 times each",
            "premium_member": "Premium Member",
            "upgrade_to_premium": "Upgrade to Premium",
            "thanks_for_support": "Thanks for your support! Enjoy all features",
            "health_synced": "Focus time synced to Apple Health",
            "health_auth_desc": "Sync focus time to Apple Health after authorization",
            "developer": "Developer"
        ]
    ]
    
    if let format = strings[lang]?[key] {
        return String(format: format, arguments: arguments)
    }
    return key
}

// MARK: - 专注实时活动属性
struct FocusActivityAttributes: ActivityAttributes {
    // 静态数据（活动创建时确定，不会变化）
    let focusCategory: String
    let totalDuration: TimeInterval
    let isBreak: Bool
    
    // 动态数据（活动进行中会更新）
    struct ContentState: Codable, Hashable {
        var timeRemaining: TimeInterval
        var progress: Double
        var currentSession: Int
        var isPaused: Bool
    }
}

// MARK: - 实时活动管理器
@available(iOS 16.1, *)
class LiveActivityManager {
    static let shared = LiveActivityManager()
    
    private var currentActivity: Activity<FocusActivityAttributes>?
    
    // 是否支持实时活动
    var isActivityAvailable: Bool {
        return ActivityAuthorizationInfo().areActivitiesEnabled
    }
    
    // MARK: - 开始专注活动
    func startFocusActivity(
        category: String,
        duration: TimeInterval,
        isBreak: Bool = false,
        currentSession: Int = 1
    ) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("实时活动未授权")
            return
        }
        
        // 结束之前的活动
        endCurrentActivity()
        
        let attributes = FocusActivityAttributes(
            focusCategory: category,
            totalDuration: duration,
            isBreak: isBreak
        )
        
        let initialState = FocusActivityAttributes.ContentState(
            timeRemaining: duration,
            progress: 0.0,
            currentSession: currentSession,
            isPaused: false
        )
        
        do {
            let activityContent = ActivityContent(state: initialState, staleDate: nil)
            let activity = try Activity.request(
                attributes: attributes,
                content: activityContent,
                pushType: nil
            )
            currentActivity = activity
            print("实时活动已启动: \(activity.id)")
        } catch {
            print("启动实时活动失败: \(error)")
        }
    }
    
    // MARK: - 更新活动状态
    func updateActivity(
        timeRemaining: TimeInterval,
        progress: Double,
        currentSession: Int,
        isPaused: Bool = false
    ) {
        guard let activity = currentActivity else { return }
        
        let updatedState = FocusActivityAttributes.ContentState(
            timeRemaining: timeRemaining,
            progress: progress,
            currentSession: currentSession,
            isPaused: isPaused
        )
        let activityContent = ActivityContent(state: updatedState, staleDate: nil)
        
        Task {
            await activity.update(activityContent)
        }
    }
    
    // MARK: - 暂停/继续活动
    func pauseActivity() {
        guard let activity = currentActivity else { return }
        
        let currentState = activity.content.state
        var updatedState = currentState
        updatedState.isPaused = true
        let activityContent = ActivityContent(state: updatedState, staleDate: nil)
        
        Task {
            await activity.update(activityContent)
        }
    }
    
    func resumeActivity() {
        guard let activity = currentActivity else { return }
        
        let currentState = activity.content.state
        var updatedState = currentState
        updatedState.isPaused = false
        let activityContent = ActivityContent(state: updatedState, staleDate: nil)
        
        Task {
            await activity.update(activityContent)
        }
    }
    
    // MARK: - 结束活动
    func endCurrentActivity() {
        guard let activity = currentActivity else { return }
        
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
            currentActivity = nil
            print("实时活动已结束")
        }
    }
}

// MARK: - 专注记录模型
@Model
final class FocusSession {
    var id: UUID
    var startTime: Date
    var endTime: Date
    var duration: TimeInterval
    var category: String
    var completed: Bool
    var notes: String
    
    init(startTime: Date, endTime: Date, duration: TimeInterval, category: String = "工作", completed: Bool = true, notes: String = "") {
        self.id = UUID()
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.category = category
        self.completed = completed
        self.notes = notes
    }
}

// MARK: - 成就模型
@Model
final class Achievement {
    var id: UUID
    var title: String
    var achievementDescription: String
    var icon: String
    var unlocked: Bool
    var unlockedDate: Date?
    var type: AchievementType
    
    init(title: String, description: String, icon: String, type: AchievementType, unlocked: Bool = false, unlockedDate: Date? = nil) {
        self.id = UUID()
        self.title = title
        self.achievementDescription = description
        self.icon = icon
        self.type = type
        self.unlocked = unlocked
        self.unlockedDate = unlockedDate
    }
}

enum AchievementType: String, Codable {
    case firstSession = "first_session"
    case tenSessions = "ten_sessions"
    case fiftySessions = "fifty_sessions"
    case hundredSessions = "hundred_sessions"
    case fiveDayStreak = "five_day_streak"
    case thirtyDayStreak = "thirty_day_streak"
    case earlyBird = "early_bird"
    case nightOwl = "night_owl"
    case marathon = "marathon"
}
