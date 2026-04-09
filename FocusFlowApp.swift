import SwiftUI
import SwiftData
import WidgetKit

@main
struct FocusFlowApp: App {
    @StateObject private var timerManager = TimerManager()
    @StateObject private var soundManager = SoundManager()
    @StateObject private var statsManager = StatsManager()
    @StateObject private var subscriptionManager = SubscriptionManager()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            FocusSession.self,
            Achievement.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            LaunchScreenView()
                .environmentObject(timerManager)
                .environmentObject(soundManager)
                .environmentObject(statsManager)
                .environmentObject(subscriptionManager)
                .onAppear {
                    timerManager.loadData()
                    statsManager.loadData()
                    subscriptionManager.checkSubscriptionStatus()
                    
                    // 清理旧的实时活动
                    if #available(iOS 16.1, *) {
                        Task {
                            await LiveActivityManager.shared.endAllActivities()
                        }
                    }
                    
                    // 更新小组件数据
                    updateWidgetData()
                    
                    // 设置计时器与白噪音的联动 - 在App级别确保切换标签页不会停止白噪音
                    setupTimerSoundBinding()
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    // MARK: - 设置计时器与白噪音联动
    private func setupTimerSoundBinding() {
        timerManager.onSoundControl = { shouldPlay in
            if shouldPlay {
                // 继续播放(如果有选中的声音)
                if soundManager.currentSound != .none {
                    soundManager.resumeSound()
                }
            } else {
                // 暂停播放
                if soundManager.isPlaying {
                    soundManager.pauseSound()
                }
            }
        }
    }
    
    // MARK: - 更新小组件数据
    private func updateWidgetData() {
        // 使用 App Group 共享数据
        let sharedDefaults = UserDefaults(suiteName: "group.com.fireny.focusflow2026")
        
        // 保存今日专注数据
        sharedDefaults?.set(statsManager.todayFocusTime / 60, forKey: "widgetFocusTime")
        sharedDefaults?.set(statsManager.todaySessions, forKey: "widgetFocusSessions")
        
        // 刷新小组件
        WidgetCenter.shared.reloadAllTimelines()
    }
}
