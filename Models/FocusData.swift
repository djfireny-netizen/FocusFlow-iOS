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
        (code: "auto", name: "跟随系统"),
        (code: "zh", name: "简体中文"),
        (code: "zh-Hant", name: "繁體中文"),
        (code: "en", name: "English"),
        (code: "ja", name: "日本語")
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
            let region = Locale.current.language.region?.identifier ?? ""
            
            // 中文处理
            if systemLang == "zh" {
                if region == "TW" || region == "HK" || region == "MO" {
                    return "zh-Hant"  // 繁体中文
                }
                return "zh"  // 简体中文
            }
            return systemLang
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
            return lang.name  // 始终使用 name，不进行本地化
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
            "developer": "开发者",
            // 付费页面相关
            "close": "关闭",
            "upgrade_premium": "升级专业版",
            "free_trial_7_days": "🎉 限时免费试用 7 天",
            "free_trial_description": "无需付费，立即体验所有高级功能",
            "select_plan": "选择方案",
            "feature_custom_duration": "自定义时长",
            "feature_custom_duration_desc": "自由设置专注和休息时间",
            "feature_detailed_stats": "详细统计",
            "feature_detailed_stats_desc": "查看完整的数据分析和趋势",
            "feature_white_noise": "白噪音库",
            "feature_white_noise_desc": "解锁所有高品质白噪音",
            "feature_category_tags": "分类标签",
            "feature_category_tags_desc": "为专注时间添加分类标签",
            "feature_icloud_sync": "iCloud 同步",
            "feature_icloud_sync_desc": "多设备数据自动同步",
            "feature_widgets": "桌面组件",
            "feature_widgets_desc": "精美的桌面小组件",
            "feature_themes": "主题背景",
            "feature_themes_desc": "解锁所有动态主题和粒子效果",
            "feature_advanced_stats": "高级统计",
            "feature_advanced_stats_desc": "周/月/年度数据趋势分析",
            "feature_watch_app": "Watch App",
            "feature_watch_app_desc": "在 Apple Watch 上专注和查看统计",
            "feature_no_ads": "无广告",
            "feature_no_ads_desc": "享受无干扰的专注体验",
            "feature_lifetime": "终身访问",
            "feature_lifetime_desc": "一次购买，永久使用所有功能",
            "feature_priority_support": "优先支持",
            "feature_priority_support_desc": "获得专属技术支持和新功能优先体验",
            "subscription_monthly": "月度订阅",
            "subscription_yearly": "年度订阅",
            "subscription_lifetime": "终身买断",
            "subscription_save_50": "省50%",
            "subscription_best_value": "最划算",
            "subscribe_now": "立即订阅",
            "purchase_lifetime": "购买终身版",
            "restore_purchases": "恢复购买",
            "subscription_auto_renew": "订阅将自动续期，除非在当前周期结束前至少24小时关闭自动续期。",
            "terms_of_service": "服务条款",
            "privacy_policy": "隐私政策",
            "subscription_free": "免费版"
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
            "developer": "Developer",
            // Subscription page
            "close": "Close",
            "upgrade_premium": "Upgrade to Premium",
            "free_trial_7_days": "🎉 Free 7-Day Trial",
            "free_trial_description": "No payment required, try all premium features now",
            "select_plan": "Select Plan",
            "feature_custom_duration": "Custom Duration",
            "feature_custom_duration_desc": "Set custom focus and break times",
            "feature_detailed_stats": "Detailed Statistics",
            "feature_detailed_stats_desc": "View complete data analysis and trends",
            "feature_white_noise": "White Noise Library",
            "feature_white_noise_desc": "Unlock all high-quality white noise sounds",
            "feature_category_tags": "Category Tags",
            "feature_category_tags_desc": "Add category tags to focus sessions",
            "feature_icloud_sync": "iCloud Sync",
            "feature_icloud_sync_desc": "Automatic data sync across devices",
            "feature_widgets": "Desktop Widgets",
            "feature_widgets_desc": "Beautiful home screen widgets",
            "feature_themes": "Dynamic Themes",
            "feature_themes_desc": "Unlock all animated themes and particle effects",
            "feature_advanced_stats": "Advanced Statistics",
            "feature_advanced_stats_desc": "Weekly/monthly/yearly data trend analysis",
            "feature_watch_app": "Watch App",
            "feature_watch_app_desc": "Focus and view stats on Apple Watch",
            "feature_no_ads": "Ad-Free Experience",
            "feature_no_ads_desc": "Enjoy distraction-free focus sessions",
            "feature_lifetime": "Lifetime Access",
            "feature_lifetime_desc": "One-time purchase, permanent access to all features",
            "feature_priority_support": "Priority Support",
            "feature_priority_support_desc": "Get dedicated support and early access to new features",
            "subscription_monthly": "Monthly",
            "subscription_yearly": "Yearly",
            "subscription_lifetime": "Lifetime",
            "subscription_save_50": "Save 50%",
            "subscription_best_value": "Best Value",
            "subscribe_now": "Subscribe Now",
            "purchase_lifetime": "Purchase Lifetime",
            "restore_purchases": "Restore Purchases",
            "subscription_auto_renew": "Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period.",
            "terms_of_service": "Terms of Service",
            "privacy_policy": "Privacy Policy",
            "subscription_free": "Free"
        ],

        // 繁體中文
        "zh-Hant": [
            "focus": "專注",
            "statistics": "統計",
            "achievements": "成就",
            "settings": "設定",
            "focus_time": "專注時間",
            "break_time": "休息時間",
            "start_focus": "開始專注",
            "pause": "暫停",
            "resume": "繼續",
            "give_up": "放棄",
            "tomato_count": "第 %d 個番茄鐘",
            "take_a_break": "休息一下",
            "ready_to_focus": "準備專注",
            "white_noise": "白噪音",
            "category": "分類",
            "work": "工作",
            "study": "學習",
            "reading": "閱讀",
            "meditation": "冥想",
            "apple_health": "Apple 健康",
            "sync_focus_data": "同步專注數據",
            "authorize": "去授權",
            "authorized": "已授權",
            "focus_duration": "專注時長",
            "break_duration": "休息時長",
            "minutes": "%d 分鐘",
            "today_focus": "今日專注",
            "total_sessions": "總專注次數",
            "current_streak": "連續天數",
            "days": "%d 天",
            "hours": "%d 小時",
            "notification_settings": "通知設定",
            "timer_settings": "計時器設定",
            "about": "關於",
            "version": "版本",
            "feedback": "反饋",
            "clear_data": "清除所有數據",
            "data_management": "數據管理",
            "dangerous_action": "危險操作",
            "confirm_clear": "確認清除",
            "cancel": "取消",
            "enter_delete_confirm": "請輸入「刪除」以確認：",
            "delete_placeholder": "刪除",
            "will_permanently_delete": "此操作將永久刪除：",
            "all_focus_records": "所有專注記錄",
            "all_achievement_data": "所有成就數據",
            "statistics_data": "統計數據",
            "language": "語言",
            "system": "跟隨系統",
            "stay_focused": "保持專注，成就更多",
            "done": "完成",
            "minutes_plain": "分鐘",
            "view_all": "查看全部",
            "volume": "音量",
            "playing": "播放中",
            "tap_to_play": "點擊播放",
            "sound_rain": "雨聲",
            "sound_ocean": "海浪",
            "sound_forest": "森林",
            "sound_cafe": "咖啡館",
            "sound_fireplace": "壁爐",
            "sound_wind": "風聲",
            "sound_none": "無",
            "cat_work": "工作",
            "cat_study": "學習",
            "cat_reading": "閱讀",
            "cat_creation": "創作",
            "cat_exercise": "運動",
            "cat_meditation": "冥想",
            "cat_custom": "自定義",
            "daily_goal": "今日目標",
            "goal_achieved": "目標達成！",
            "minutes_remaining": "還差 %d 分鐘",
            "weekly_trend": "本週趨勢",
            "category_stats": "分類統計",
            "no_data": "暫無數據",
            "unlock_premium": "解鎖高級功能",
            "premium_desc": "解鎖所有高級功能，提升專注體驗",
            "monthly_plan": "月付方案",
            "yearly_plan": "年付方案",
            "lifetime_plan": "終身方案",
            "subscribe": "訂閱",
            "terms": "服務條款",
            "privacy": "隱私政策",
            "subscription_note": "訂閱將自動續期，可隨時取消",
            "unlocked": "已解鎖",
            "total_achievements": "總成就",
            "end_break": "結束休息",
            "focus_category": "專注分類",
            "on_break": "休息中",
            "focusing": "專注中...",
            "paused": "已暫停",
            "upgrade": "升級",
            "daily_focus_goal": "每日專注目標",
            "target_duration": "目標時長",
            "daily_goal_tip": "每日完成 %d 分鐘目標，解鎖成就！",
            "daily_reminder": "每日專注提醒",
            "send_feedback": "發送反饋",
            "feedback_message": "請發送郵件至：fireny@live.com\n\n建議包含以下內容：\n• 遇到的問題描述\n• 復現步驟\n• 截圖（如有）",
            "copy_email": "複製郵箱",
            "unlock_all_features": "解鎖全部功能",
            "make_focus_habit": "讓專注成為一種習慣",
            "completed_count": "完成次數",
            "longest_streak": "最長連續",
            "days_unit": "天",
            "weekday_sun": "週日",
            "weekday_mon": "週一",
            "weekday_tue": "週二",
            "weekday_wed": "週三",
            "weekday_thu": "週四",
            "weekday_fri": "週五",
            "weekday_sat": "週六",
            "ach_first_try": "初次嘗試",
            "ach_first_try_desc": "完成第一次專注",
            "ach_getting_better": "漸入佳境",
            "ach_getting_better_desc": "完成10次專注",
            "ach_focus_expert": "專注達人",
            "ach_focus_expert_desc": "完成50次專注",
            "ach_focus_master": "專注大師",
            "ach_focus_master_desc": "完成100次專注",
            "ach_persistent": "堅持不懈",
            "ach_persistent_desc": "連續專注5天",
            "ach_on_fire": "火力全開",
            "ach_on_fire_desc": "連續專注30天",
            "ach_early_bird": "早起鳥",
            "ach_early_bird_desc": "在早上6點前完成專注",
            "ach_night_owl": "夜貓子",
            "ach_night_owl_desc": "在晚上11點後完成專注",
            "ach_marathon": "馬拉松選手",
            "ach_marathon_desc": "單次專注超過60分鐘",
            "ach_time_lord": "時間領主",
            "ach_time_lord_desc": "累計專注100小時",
            "ach_goal_achiever": "目標達成者",
            "ach_goal_achiever_desc": "完成1次每日目標",
            "ach_weekly_star": "一週達人",
            "ach_weekly_star_desc": "連續7天達成目標",
            "ach_monthly_star": "月度之星",
            "ach_monthly_star_desc": "單月專注超過50小時",
            "ach_wh_noise_lover": "白噪音愛好者",
            "ach_wh_noise_lover_desc": "使用白噪音專注20次",
            "ach_efficient": "高效能手",
            "ach_efficient_desc": "一天內完成10個番茄鐘",
            "ach_study_expert": "學習達人",
            "ach_study_expert_desc": "學習類專注完成30次",
            "ach_workaholic": "工作狂人",
            "ach_workaholic_desc": "工作類專注完成50次",
            "ach_balanced_life": "平衡生活",
            "ach_balanced_life_desc": "使用所有分類各10次",
            "premium_member": "Premium 會員",
            "upgrade_to_premium": "升級到 Premium",
            "thanks_for_support": "感謝支持！享受所有高級功能",
            "health_synced": "專注時間已同步到 Apple 健康",
            "health_auth_desc": "授權後將專注時間同步到 Apple 健康 App",
            "developer": "開發者",
            "close": "關閉",
            "upgrade_premium": "升級專業版",
            "free_trial_7_days": "🎉 限時免費試用 7 天",
            "free_trial_description": "無需付費，立即體驗所有高級功能",
            "select_plan": "選擇方案",
            "feature_custom_duration": "自定義時長",
            "feature_custom_duration_desc": "自由設置專注和休息時間",
            "feature_detailed_stats": "詳細統計",
            "feature_detailed_stats_desc": "查看完整的數據分析和趨勢",
            "feature_white_noise": "白噪音庫",
            "feature_white_noise_desc": "解鎖所有高品質白噪音",
            "feature_category_tags": "分類標籤",
            "feature_category_tags_desc": "為專注時間添加分類標籤",
            "feature_icloud_sync": "iCloud 同步",
            "feature_icloud_sync_desc": "多設備數據自動同步",
            "feature_widgets": "桌面組件",
            "feature_widgets_desc": "精美的桌面小組件",
            "subscription_monthly": "月度訂閱",
            "subscription_yearly": "年度訂閱",
            "subscription_lifetime": "終身買斷",
            "subscription_save_50": "省50%",
            "subscription_best_value": "最劃算",
            "subscribe_now": "立即訂閱",
            "purchase_lifetime": "購買終身版",
            "restore_purchases": "恢復購買",
            "subscription_auto_renew": "訂閱將自動續期，除非在當前週期結束前至少24小時關閉自動續期。",
            "terms_of_service": "服務條款",
            "privacy_policy": "隱私政策",
            "subscription_free": "免費版"
        ],

        // 日本語
        "ja": [
            "focus": "集中",
            "statistics": "統計",
            "achievements": "実績",
            "settings": "設定",
            "focus_time": "集中時間",
            "break_time": "休憩時間",
            "start_focus": "集中開始",
            "pause": "一時停止",
            "resume": "再開",
            "give_up": "中断",
            "tomato_count": "トマト %d個目",
            "take_a_break": "休憩しましょう",
            "ready_to_focus": "集中準備",
            "white_noise": "ホワイトノイズ",
            "category": "カテゴリ",
            "work": "仕事",
            "study": "学習",
            "reading": "読書",
            "meditation": "瞑想",
            "apple_health": "Appleヘルスケア",
            "sync_focus_data": "集中データを同期",
            "authorize": "認証",
            "authorized": "認証済み",
            "focus_duration": "集中時間",
            "break_duration": "休憩時間",
            "minutes": "%d分",
            "today_focus": "今日の集中",
            "total_sessions": "総セッション数",
            "current_streak": "継続日数",
            "days": "%d日",
            "hours": "%d時間",
            "notification_settings": "通知設定",
            "timer_settings": "タイマー設定",
            "about": "概要",
            "version": "バージョン",
            "feedback": "フィードバック",
            "clear_data": "全データ削除",
            "data_management": "データ管理",
            "dangerous_action": "危険な操作",
            "confirm_clear": "削除確認",
            "cancel": "キャンセル",
            "enter_delete_confirm": "確認のため「削除」と入力：",
            "delete_placeholder": "削除",
            "will_permanently_delete": "この操作で完全に削除されます：",
            "all_focus_records": "全ての集中記録",
            "all_achievement_data": "全ての実績データ",
            "statistics_data": "統計データ",
            "language": "言語",
            "system": "システム設定",
            "stay_focused": "集中して、もっと達成しよう",
            "done": "完了",
            "minutes_plain": "分",
            "view_all": "すべて表示",
            "volume": "音量",
            "playing": "再生中",
            "tap_to_play": "タップして再生",
            "sound_rain": "雨の音",
            "sound_ocean": "海の音",
            "sound_forest": "森の音",
            "sound_cafe": "カフェ",
            "sound_fireplace": "暖炉",
            "sound_wind": "風の音",
            "sound_none": "なし",
            "cat_work": "仕事",
            "cat_study": "学習",
            "cat_reading": "読書",
            "cat_creation": "創作",
            "cat_exercise": "運動",
            "cat_meditation": "瞑想",
            "cat_custom": "カスタム",
            "daily_goal": "今日の目標",
            "goal_achieved": "目標達成！",
            "minutes_remaining": "残り%d分",
            "weekly_trend": "今週のトレンド",
            "category_stats": "カテゴリ統計",
            "no_data": "データなし",
            "unlock_premium": "プレミアムを解除",
            "premium_desc": "全てのプレミアム機能で集中力を向上",
            "monthly_plan": "月額プラン",
            "yearly_plan": "年額プラン",
            "lifetime_plan": "ライフタイムプラン",
            "subscribe": "購読",
            "terms": "利用規約",
            "privacy": "プライバシー",
            "subscription_note": "自動更新、いつでもキャンセル可能",
            "unlocked": "解除済み",
            "total_achievements": "合計",
            "end_break": "休憩終了",
            "focus_category": "カテゴリ",
            "on_break": "休憩中",
            "focusing": "集中中...",
            "paused": "一時停止中",
            "upgrade": "アップグレード",
            "daily_focus_goal": "1日の集中目標",
            "target_duration": "目標時間",
            "daily_goal_tip": "毎日%d分を達成して実績を解除！",
            "daily_reminder": "毎日の集中リマインダー",
            "send_feedback": "フィードバックを送信",
            "feedback_message": "メール：fireny@live.com\n\n含める内容：\n• 問題の説明\n• 再現手順\n• スクリーンショット（任意）",
            "copy_email": "メールをコピー",
            "unlock_all_features": "全機能を解除",
            "make_focus_habit": "集中を習慣にしよう",
            "completed_count": "完了回数",
            "longest_streak": "最長継続",
            "days_unit": "日",
            "weekday_sun": "日",
            "weekday_mon": "月",
            "weekday_tue": "火",
            "weekday_wed": "水",
            "weekday_thu": "木",
            "weekday_fri": "金",
            "weekday_sat": "土",
            "ach_first_try": "初挑戦",
            "ach_first_try_desc": "初めての集中を完了",
            "ach_getting_better": "上達中",
            "ach_getting_better_desc": "集中を10回完了",
            "ach_focus_expert": "集中エキスパート",
            "ach_focus_expert_desc": "集中を50回完了",
            "ach_focus_master": "集中マスター",
            "ach_focus_master_desc": "集中を100回完了",
            "ach_persistent": "粘り強い",
            "ach_persistent_desc": "5日間連続で集中",
            "ach_on_fire": "絶好調",
            "ach_on_fire_desc": "30日間連続で集中",
            "ach_early_bird": "早起き",
            "ach_early_bird_desc": "午前6時前に集中を完了",
            "ach_night_owl": "夜更かし",
            "ach_night_owl_desc": "午後11時後に集中を完了",
            "ach_marathon": "マラソン選手",
            "ach_marathon_desc": "1回で60分以上集中",
            "ach_time_lord": "タイムロード",
            "ach_time_lord_desc": "集中時間100時間達成",
            "ach_goal_achiever": "目標達成者",
            "ach_goal_achiever_desc": "1日の目標を1回完了",
            "ach_weekly_star": "ウィークリースター",
            "ach_weekly_star_desc": "7日間連続で目標達成",
            "ach_monthly_star": "月間スター",
            "ach_monthly_star_desc": "1ヶ月で50時間以上集中",
            "ach_wh_noise_lover": "ホワイトノイズ好き",
            "ach_wh_noise_lover_desc": "ホワイトノイズで20回集中",
            "ach_efficient": "効率的",
            "ach_efficient_desc": "1日に10ポモドーロ完了",
            "ach_study_expert": "学習エキスパート",
            "ach_study_expert_desc": "学習セッションを30回完了",
            "ach_workaholic": "ワーカホリック",
            "ach_workaholic_desc": "仕事セッションを50回完了",
            "ach_balanced_life": "バランスの取れた生活",
            "ach_balanced_life_desc": "全てのカテゴリを10回ずつ使用",
            "premium_member": "プレミアム会員",
            "upgrade_to_premium": "プレミアムにアップグレード",
            "thanks_for_support": "ご支援ありがとうございます！全ての機能をお楽しみください",
            "health_synced": "集中時間がAppleヘルスケアに同期されました",
            "health_auth_desc": "認証後、集中時間をAppleヘルスケアに同期",
            "developer": "開発者",
            "close": "閉じる",
            "upgrade_premium": "プレミアムにアップグレード",
            "free_trial_7_days": "🎉 7日間無料トライアル",
            "free_trial_description": "支払い不要、今すぐ全てのプレミアム機能を体験",
            "select_plan": "プランを選択",
            "feature_custom_duration": "カスタム時間",
            "feature_custom_duration_desc": "集中と休憩時間を自由に設定",
            "feature_detailed_stats": "詳細な統計",
            "feature_detailed_stats_desc": "完全なデータ分析とトレンドを表示",
            "feature_white_noise": "ホワイトノイズライブラリ",
            "feature_white_noise_desc": "全ての高音質ホワイトノイズを解除",
            "feature_category_tags": "カテゴリタグ",
            "feature_category_tags_desc": "集中セッションにカテゴリタグを追加",
            "feature_icloud_sync": "iCloud同期",
            "feature_icloud_sync_desc": "デバイス間で自動データ同期",
            "feature_widgets": "デスクトップウィジェット",
            "feature_widgets_desc": "美しいホーム画面ウィジェット",
            "subscription_monthly": "月額",
            "subscription_yearly": "年額",
            "subscription_lifetime": "ライフタイム",
            "subscription_save_50": "50%お得",
            "subscription_best_value": "最佳価値",
            "subscribe_now": "今すぐ購読",
            "purchase_lifetime": "ライフタイムを購入",
            "restore_purchases": "購入を復元",
            "subscription_auto_renew": "現在の期間終了の24時間前までに自動更新をオフにしない限り、自動的に更新されます。",
            "terms_of_service": "利用規約",
            "privacy_policy": "プライバシーポリシー",
            "subscription_free": "無料版"
        ],
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
    
    // MARK: - 清理所有活动
    func endAllActivities() async {
        for activity in Activity<FocusActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        currentActivity = nil
        print("所有实时活动已清理")
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
    // 基础成就
    case firstSession = "first_session"
    case tenSessions = "ten_sessions"
    case fiftySessions = "fifty_sessions"
    case hundredSessions = "hundred_sessions"
    case fiveDayStreak = "five_day_streak"
    case thirtyDayStreak = "thirty_day_streak"
    case earlyBird = "early_bird"
    case nightOwl = "night_owl"
    case marathon = "marathon"
    
    // 新增成就 - 提升留存
    case twoHundredSessions = "two_hundred_sessions"  // 200次专注
    case fiveHundredSessions = "five_hundred_sessions"  // 500次专注
    case sevenDayStreak = "seven_day_streak"  // 7天连续
    case fourteenDayStreak = "fourteen_day_streak"  // 14天连续
    case sixtyDayStreak = "sixty_day_streak"  // 60天连续
    case hundredDayStreak = "hundred_day_streak"  // 100天连续
    
    // 时长成就
    case tenHoursFocus = "ten_hours_focus"  // 10小时
    case fiftyHoursFocus = "fifty_hours_focus"  // 50小时
    case twoHundredHoursFocus = "two_hundred_hours_focus"  // 200小时
    case fiveHundredHoursFocus = "five_hundred_hours_focus"  // 500小时
    case thousandHoursFocus = "thousand_hours_focus"  // 1000小时
    
    // 特殊成就
    case perfectDay = "perfect_day"  // 完美一天（8个番茄）
    case superMarathon = "super_marathon"  // 单次专注2小时
    case weeklyGoal10 = "weekly_goal_10"  // 10次达成周目标
    case monthlyGoal30 = "monthly_goal_30"  // 30次达成月目标
    case useAllSounds = "use_all_sounds"  // 使用所有白噪音
    case exploreCategories = "explore_categories"  // 使用所有分类
    case shareAchievement = "share_achievement"  // 分享成就
    case exportData = "export_data"  // 导出数据
    case earlyAdopter = "early_adopter"  // 早期用户
    case premiumMember = "premium_member"  // Premium 会员
    case themeCollector = "theme_collector"  // 主题收藏家
}
