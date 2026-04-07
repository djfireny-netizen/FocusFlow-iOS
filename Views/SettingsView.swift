import SwiftUI

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
            LinearGradient(
                colors: [
                    Color(hex: "667eea").opacity(0.2),
                    Color(hex: "764ba2").opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
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
                                .foregroundColor(Color(hex: "667eea"))
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
                                .foregroundColor(Color(hex: "764ba2"))
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
                    .foregroundColor(Color(hex: "667eea"))
            }
            
            VStack(spacing: 16) {
                // 目标滑块
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "target")
                            .foregroundColor(Color(hex: "667eea"))
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
                    .tint(Color(hex: "667eea"))
                    
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
                        .foregroundColor(Color(hex: "667eea"))
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
                                .background(Color(hex: "667eea"))
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
                        .foregroundColor(Color(hex: "667eea"))
                    
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
                            .foregroundColor(Color(hex: "667eea"))
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
                    .foregroundColor(Color(hex: "667eea"))
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
                    .foregroundColor(Color(hex: "667eea"))
                }
            }
        }
    }
}

// MARK: - 语言选项按钮
struct LanguageOptionButton: View {
    let lang: (code: String, name: String, nameEn: String)
    let isSelected: Bool
    let action: () -> Void
    
    @StateObject private var languageManager = LanguageManager.shared
    
    var displayName: String {
        languageManager.isChinese ? lang.name : lang.nameEn
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // 语言图标
                ZStack {
                    Circle()
                        .fill(isSelected ? Color(hex: "667eea") : Color.gray.opacity(0.15))
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
                        .foregroundColor(Color(hex: "667eea"))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: "667eea").opacity(0.5) : Color.clear, lineWidth: 2)
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
        case "en": return "🇬🇧"
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
