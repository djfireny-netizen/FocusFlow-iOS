import SwiftUI
import SwiftData

// L函数和LanguageManager已在LanguageManager.swift中定义

// MARK: - 设置页面
struct SettingsView: View {
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var healthManager = HealthManager.shared
    @StateObject private var languageManager = LanguageManager.shared
    @State private var showSubscriptionSheet = false
    @State private var showClearAlert = false
    @State private var dailyGoalMinutes: Int = UserDefaults.standard.integer(forKey: "dailyGoalMinutes") > 0 ? UserDefaults.standard.integer(forKey: "dailyGoalMinutes") : 120
    @State private var enableDailyReminder: Bool = UserDefaults.standard.bool(forKey: "enableDailyReminder")
    @State private var isSyncingHealth: Bool = false
    @State private var showFocusDurationPicker: Bool = false
    @State private var showBreakDurationPicker: Bool = false
    @State private var showLanguagePicker = false
    @State private var showThemePicker = false
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // 标题
                    Text(L("settings"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    // 订阅卡片
                    subscriptionCard
                    
                    // 计时器设置
                    timerSettingsSection
                    
                    // 每日目标
                    dailyGoalSection
                    
                    // 通知设置
                    notificationSection
                    
                    // 健康集成
                    if healthManager.isHealthAvailable {
                        healthSection
                    }
                    
                    // 数据管理
                    dataManagementSection
                    
                    // 关于
                    aboutSection
                }
            }
        }
        .sheet(isPresented: $showSubscriptionSheet) {
            SubscriptionView()
        }
        .alert(isPresented: $showFeedbackAlert) {
            feedbackAlert
        }
        .onAppear {
            notificationManager.checkPermission()
            healthManager.checkAvailability()
            healthManager.checkHealthPermission()
        }
    }
    
    // MARK: - 订阅卡片
    private var subscriptionCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(subscriptionManager.isPremium ? L("premium_member") : L("upgrade_to_premium"))
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text(
                        subscriptionManager.isPremium ?
                        L("thanks_for_support") : L("unlock_all_features")
                    )
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                if subscriptionManager.isPremium {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title2)
                        .foregroundColor(AppTheme.accentGreen)
                } else {
                    Button(action: {
                        showSubscriptionSheet = true
                    }) {
                        Text(L("upgrade"))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(AppTheme.primaryGradient)
                            .cornerRadius(20)
                    }
                }
            }
        }
        .padding()
        .background(
            AppTheme.cardBackground
        )
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
    
    // MARK: - 计时器设置
    private var timerSettingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L("timer_settings"))
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            VStack(spacing: 1) {
                // 专注时长
                Button(action: {
                    showFocusDurationPicker = true
                }) {
                    HStack {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundColor(AppTheme.accentBlue)
                                .frame(width: 30)
                            
                            Text(L("focus_duration"))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Spacer()
                            
                            Text("\(Int(timerManager.focusDuration / 60))" + L("minutes_plain"))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(AppTheme.textTertiary)
                        }
                    }
                    .padding()
                }
                
                Divider()
                    .padding(.leading, 50)
                
                // 休息时长
                Button(action: {
                    showBreakDurationPicker = true
                }) {
                    HStack {
                        HStack {
                            Image(systemName: "cup.and.saucer.fill")
                                .foregroundColor(AppTheme.accentOrange)
                                .frame(width: 30)
                            
                            Text(L("break_duration"))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Spacer()
                            
                            Text("\(Int(timerManager.breakDuration / 60))" + L("minutes_plain"))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(AppTheme.textTertiary)
                        }
                    }
                    .padding()
                }
            }
            .background(AppTheme.cardBackground)
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
        .sheet(isPresented: $showFocusDurationPicker) {
            DurationPickerView(
                title: L("focus_duration"),
                currentValue: Int(timerManager.focusDuration / 60),
                options: [15, 20, 25, 30, 45, 50, 60, 90]
            ) { minutes in
                timerManager.focusDuration = Double(minutes) * 60
                timerManager.timeRemaining = timerManager.focusDuration
            }
        }
        .sheet(isPresented: $showBreakDurationPicker) {
            DurationPickerView(
                title: L("break_duration"),
                currentValue: Int(timerManager.breakDuration / 60),
                options: [3, 5, 8, 10, 15, 20, 25, 30]
            ) { minutes in
                timerManager.breakDuration = Double(minutes) * 60
            }
        }
    }
    
    // MARK: - 每日目标
    private var dailyGoalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(L("daily_focus_goal"))
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Text("\(dailyGoalMinutes) " + L("minutes_plain"))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.accentBlue)
            }
            
            VStack(spacing: 16) {
                // 目标滑块
                    VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "target")
                            .foregroundColor(AppTheme.accentBlue)
                        Text(L("target_duration"))
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                    }
                    
                    Slider(
                        value: Binding(
                            get: { Double(dailyGoalMinutes) },
                            set: { 
                                dailyGoalMinutes = Int($0)
                                UserDefaults.standard.set(Int($0), forKey: "dailyGoalMinutes")
                            }
                        ),
                        in: 30...480,
                        step: 30
                    )
                    .tint(AppTheme.accentBlue)
                    
                    HStack {
                        Text("30" + L("minutes_plain"))
                            .font(.caption)
                            .foregroundColor(AppTheme.textTertiary)
                        Spacer()
                        Text("8 " + L("hours"))
                            .font(.caption)
                            .foregroundColor(AppTheme.textTertiary)
                    }
                }
                
                // 目标进度提示
                HStack {
                    Image(systemName: "info.circle.fill")
                        .font(.caption)
                        .foregroundColor(AppTheme.accentBlue)
                    Text(L("daily_goal_tip", dailyGoalMinutes))
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .padding()
            .background(AppTheme.cardBackground)
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - 健康集成
    private var healthSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L("apple_health"))
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            VStack(spacing: 1) {
                HStack {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .frame(width: 30)
                        
                        Text(L("sync_focus_data"))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Spacer()
                        
                        if isSyncingHealth {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else if healthManager.isHealthEnabled {
                            // 已授权状态
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                Text(L("authorized"))
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    
                    // 未授权时显示"去授权"按钮,已授权时不显示按钮
                    if !healthManager.isHealthEnabled {
                        Button(action: {
                            isSyncingHealth = true
                            healthManager.requestHealthPermission { granted in
                                if granted {
                                    healthManager.saveFocusSessions(timerManager.sessions)
                                }
                                isSyncingHealth = false
                            }
                        }) {
                            Text(L("authorize"))
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(AppTheme.accentBlue)
                                .cornerRadius(8)
                        }
                        .disabled(isSyncingHealth)
                    }
                }
                .padding()
                
                Divider()
                    .padding(.leading, 50)
                
                HStack {
                    Image(systemName: "info.circle.fill")
                        .font(.caption)
                        .foregroundColor(AppTheme.accentBlue)
                    
                    Text(healthManager.isHealthEnabled ? L("health_synced") : L("health_auth_desc"))
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Spacer()
                }
                .padding()
            }
            .background(AppTheme.cardBackground)
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - 通知设置
    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L("notification_settings"))
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            VStack(spacing: 1) {
                HStack {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(AppTheme.accentBlue)
                            .frame(width: 30)
                        
                        Text(L("daily_reminder"))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: Binding(
                        get: { enableDailyReminder },
                        set: { newValue in
                            enableDailyReminder = newValue
                            UserDefaults.standard.set(newValue, forKey: "enableDailyReminder")
                            
                            if newValue {
                                notificationManager.requestPermission { granted in
                                    if granted {
                                        notificationManager.scheduleDailyReminder()
                                    }
                                }
                            } else {
                                notificationManager.cancelDailyReminder()
                            }
                        }
                    ))
                    .labelsHidden()
                }
                .padding()
            }
            .background(AppTheme.cardBackground)
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - 数据管理
    @State private var showClearSheet = false
    @State private var confirmText = ""
    
    private var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L("data_management"))
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            VStack(spacing: 1) {
                // 导出 CSV 数据
                Button(action: {
                    exportDataAsCSV()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(AppTheme.accentBlue)
                            .frame(width: 30)
                        
                        Text("导出专注数据 (CSV)")
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(AppTheme.textTertiary)
                    }
                    .padding()
                }
                
                Divider()
                    .padding(.leading, 62)
                
                // 导出统计报告
                Button(action: {
                    exportStatsReport()
                }) {
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(AppTheme.accentBlue)
                            .frame(width: 30)
                        
                        Text("导出统计报告")
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(AppTheme.textTertiary)
                    }
                    .padding()
                }
                
                Divider()
                    .padding(.leading, 62)
                
                // 清除数据
                Button(action: {
                    showClearSheet = true
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                            .frame(width: 30)
                        
                        Text(L("clear_data"))
                            .foregroundColor(.red)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(AppTheme.textTertiary)
                    }
                    .padding()
                }
            }
            .background(AppTheme.cardBackground)
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
        .sheet(isPresented: $showClearSheet) {
            ClearDataSheet(
                confirmText: $confirmText,
                onConfirm: {
                    timerManager.clearHistory()
                    showClearSheet = false
                    confirmText = ""
                },
                onCancel: {
                    showClearSheet = false
                    confirmText = ""
                }
            )
        }
    }
    
    // MARK: - 关于
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L("about"))
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            VStack(spacing: 1) {
                // 语言选择
                Button(action: {
                    showLanguagePicker = true
                }) {
                    HStack {
                        Text(L("language"))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Spacer()
                        
                        Text(languageManager.languageDisplayName(for: languageManager.currentLanguage))
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(AppTheme.textTertiary)
                    }
                    .padding()
                }
                
                // 主题选择（Premium 功能）
                Button(action: {
                    showThemePicker = true
                }) {
                    HStack {
                        Text("主题背景")
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Spacer()
                        
                        if !subscriptionManager.isPremium {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundColor(AppTheme.accentOrange)
                        }
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(AppTheme.textTertiary)
                    }
                    .padding()
                }
                
                Divider()
                    .padding(.leading, 50)
                
                AboutRow(title: L("version"), value: AppConstants.appVersion)
                
                Divider()
                    .padding(.leading, 50)
                
                AboutRow(title: L("developer"), value: "FocusFlow Team")
                
                Divider()
                    .padding(.leading, 50)
                
                // 反馈按钮 - 点击打开邮件
                Button(action: {
                    sendFeedbackEmail()
                }) {
                    HStack {
                        Text(L("feedback"))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "envelope")
                            .font(.caption)
                            .foregroundColor(AppTheme.textTertiary)
                    }
                    .padding()
                }
            }
            .background(AppTheme.cardBackground)
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
        .sheet(isPresented: $showLanguagePicker) {
            LanguagePickerView()
        }
        .sheet(isPresented: $showThemePicker) {
            ThemePickerView()
        }
        // 语言切换时强制刷新
        .id(languageManager.currentLanguage)
    }
    
    // MARK: - 发送反馈邮件
    @State private var showFeedbackAlert = false
    
    private func sendFeedbackEmail() {
        let subject = "FocusFlow 反馈"
        let body = "\n\n---\nApp 版本: \(AppConstants.appVersion)\niOS 版本: \(UIDevice.current.systemVersion)\n设备: \(UIDevice.current.model)"
        
        if let url = URL(string: "mailto:fireny@live.com?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            UIApplication.shared.open(url) { success in
                if !success {
                    // 如果无法打开邮件客户端，显示提示
                    showFeedbackAlert = true
                }
            }
        }
    }
    
    // MARK: - 反馈提示
    private var feedbackAlert: Alert {
        Alert(
            title: Text(L("send_feedback")),
            message: Text(L("feedback_message")),
            primaryButton: .default(Text(L("copy_email"))) {
                UIPasteboard.general.string = "fireny@live.com"
            },
            secondaryButton: .cancel(Text(L("cancel")))
        )
    }
}

// MARK: - 设置行
struct SettingRow: View {
    let icon: String
    let title: String
    let value: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.accentBlue)
                    .frame(width: 30)
                
                Text(title)
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Text(value)
                    .foregroundColor(AppTheme.textSecondary)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppTheme.textTertiary)
            }
            .padding()
        }
    }
}

// MARK: - 关于行
struct AboutRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(AppTheme.textPrimary)
            
            Spacer()
            
            if !value.isEmpty {
                Text(value)
                    .foregroundColor(AppTheme.textSecondary)
            } else {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppTheme.textTertiary)
            }
        }
        .padding()
    }
}

// MARK: - 清除数据确认页
struct ClearDataSheet: View {
    @Binding var confirmText: String
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    // 根据语言确定确认文字
    private var confirmKeyword: String {
        LanguageManager.shared.isChinese ? "删除" : "DELETE"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // 警告图标
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                    .padding(.top, 40)
                
                // 标题
                Text(L("dangerous_action"))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                
                // 说明
                VStack(alignment: .leading, spacing: 12) {
                    Text(L("will_permanently_delete"))
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Text(L("all_focus_records"))
                    }
                    
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Text(L("all_achievement_data"))
                    }
                    
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Text(L("statistics_data"))
                    }
                }
                .foregroundColor(AppTheme.textSecondary)
                .padding(.horizontal, 32)
                
                // 确认输入
                VStack(alignment: .leading, spacing: 8) {
                    Text(L("enter_delete_confirm"))
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    TextField(L("delete_placeholder"), text: $confirmText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // 按钮
                VStack(spacing: 12) {
                    Button(action: onConfirm) {
                        Text(L("confirm_clear"))
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(confirmText == confirmKeyword ? Color.red : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(confirmText != confirmKeyword)
                    .padding(.horizontal, 32)
                    
                    Button(action: onCancel) {
                        Text(L("cancel"))
                            .font(.headline)
                            .foregroundColor(AppTheme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .padding(.horizontal, 32)
                }
                .padding(.bottom, 32)
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - 语言选择器
struct LanguagePickerView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var languageManager = LanguageManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundPrimary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(languageManager.supportedLanguages, id: \.code) { lang in
                            LanguageOptionButton(
                                lang: lang,
                                isSelected: languageManager.currentLanguage == lang.code,
                                action: {
                                    withAnimation(.spring(response: 0.3)) {
                                        languageManager.currentLanguage = lang.code
                                    }
                                    // 延迟关闭，让用户看到选中效果
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        dismiss()
                                    }
                                }
                            )
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(L("language"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L("cancel")) {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.accentBlue)
                }
            }
        }
    }
}

// MARK: - 语言选项按钮
struct LanguageOptionButton: View {
    let lang: (code: String, name: String)
    let isSelected: Bool
    let action: () -> Void
    
    @StateObject private var languageManager = LanguageManager.shared
    
    var displayName: String {
        lang.name  // 始终使用 name，不进行本地化
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // 语言图标
                ZStack {
                    Circle()
                        .fill(isSelected ? AppTheme.accentBlue : Color.gray.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Text(langIcon)
                        .font(.title3)
                }
                
                // 语言名称
                VStack(alignment: .leading, spacing: 2) {
                    Text(displayName)
                        .font(.body)
                        .fontWeight(isSelected ? .semibold : .regular)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    // 显示系统当前语言（仅跟随系统选项）
                    if lang.code == "auto" {
                        Text(systemLanguageDisplay)
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                
                Spacer()
                
                // 选中标记
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(AppTheme.accentBlue)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppTheme.accentBlue.opacity(0.5) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.2), value: isSelected)
    }
    
    private var langIcon: String {
        switch lang.code {
        case "auto": return "🌐"
        case "zh": return "🇨🇳"
        case "zh-Hant": return "🇨🇳"
        case "en": return "🇬🇧"
        case "ja": return "🇯🇵"
        default: return "🌐"
        }
    }
    
    private var systemLanguageDisplay: String {
        let systemLang = Locale.current.language.languageCode?.identifier ?? "en"
        let isSystemChinese = systemLang == "zh"
        if languageManager.isChinese {
            return isSystemChinese ? "当前系统：中文" : "当前系统：English"
        } else {
            return isSystemChinese ? "System: Chinese" : "System: English"
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(TimerManager())
        .environmentObject(SubscriptionManager())
}

// MARK: - 主题选择器
struct ThemePickerView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var themeManager = ThemeManager.shared
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundPrimary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // 主题网格
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                            ForEach(ThemeType.allCases) { theme in
                                ThemeCard(
                                    theme: theme,
                                    isUnlocked: subscriptionManager.isPremium || theme == .default,
                                    isSelected: themeManager.currentTheme == theme
                                )
                                .onTapGesture {
                                    if subscriptionManager.isPremium || theme == .default {
                                        withAnimation(.spring(response: 0.3)) {
                                            themeManager.saveTheme(theme)
                                        }
                                    } else {
                                        // 提示升级
                                        showUpgradeAlert()
                                    }
                                }
                            }
                        }
                        .padding()
                        
                        // 自动切换开关
                        if subscriptionManager.isPremium {
                            VStack(spacing: 12) {
                                HStack {
                                    Text("自动切换主题")
                                        .font(.body)
                                        .foregroundColor(AppTheme.textPrimary)
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: Binding(
                                        get: { themeManager.autoSwitch },
                                        set: { themeManager.saveAutoSwitch($0) }
                                    ))
                                    .labelsHidden()
                                }
                                
                                Text("根据白噪音自动切换主题背景")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding()
                            .background(AppTheme.cardBackground)
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("主题背景")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L("done")) {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.accentBlue)
                }
            }
        }
    }
    
    private func showUpgradeAlert() {
        // TODO: 显示升级弹窗
        print("需要升级到 Premium")
    }
    
    // MARK: - 导出数据
    private func exportDataAsCSV() {
        // TODO: 需要在 Xcode 中添加 Managers/ExportManager.swift 到项目
        // 然后取消下面的注释
        
        /*
        // 获取所有专注会话
        let fetchDescriptor = FetchDescriptor<FocusSession>()
        guard let sessions = try? modelContext.fetch(fetchDescriptor) else {
            print("❌ 获取数据失败")
            return
        }
        
        guard let url = ExportManager.shared.exportFocusDataAsCSV(sessions: sessions) else {
            print("❌ 导出失败")
            return
        }
        
        ExportManager.shared.shareFile(url: url)
        */
        
        print("⚠️ 请先在 Xcode 中添加 ExportManager.swift 到项目")
    }
    
    private func exportStatsReport() {
        // TODO: 需要在 Xcode 中添加 Managers/ExportManager.swift 到项目
        // 然后取消下面的注释
        
        /*
        let statsManager = StatsManager()
        
        guard let url = ExportManager.shared.exportStatsAsText(
            totalSessions: statsManager.totalSessions,
            totalFocusTime: statsManager.totalFocusTime,
            currentStreak: statsManager.currentStreak,
            longestStreak: statsManager.longestStreak,
            todaySessions: statsManager.todaySessions,
            todayFocusTime: statsManager.todayFocusTime
        ) else {
            print("❌ 导出失败")
            return
        }
        
        ExportManager.shared.shareFile(url: url)
        */
        
        print("⚠️ 请先在 Xcode 中添加 ExportManager.swift 到项目")
    }
}

// MARK: - 主题卡片
struct ThemeCard: View {
    let theme: ThemeType
    let isUnlocked: Bool
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            // 主题预览
            LinearGradient(
                colors: theme.colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 120)
            .cornerRadius(12)
            
            VStack {
                // 主题图标
                Image(systemName: theme.icon)
                    .font(.title)
                    .foregroundColor(.white)
                
                Spacer()
                
                // 主题名称
                Text(theme.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(6)
            }
            .padding()
            
            // 锁图标（未解锁时显示）
            if !isUnlocked {
                Image(systemName: "lock.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(12)
            }
            
            // 选中标记
            if isSelected {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(4)
                    }
                    Spacer()
                }
            }
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .shadow(color: isSelected ? AppTheme.accentBlue.opacity(0.5) : .clear, radius: 10)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}
