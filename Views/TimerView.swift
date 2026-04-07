import SwiftUI

// L函数已在LanguageManager中定义

// MARK: - 计时器主视图
struct TimerView: View {
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var soundManager: SoundManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var showSoundPicker: Bool = false
    @State private var showFullScreen: Bool = false
    @State private var lockScreenSetup = false
    @State private var lockScreenTimer: Timer?
    @State private var currentLockScreenState: TimerState = .idle
    
    var body: some View {
        ZStack {
            // 背景渐变
            AppTheme.backgroundPrimary
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // 顶部标题
                    headerSection
                    
                    // 计时器圆环
                    timerRingSection
                    
                    // 控制按钮
                    controlButtons
                    
                    // 分类选择
                    categorySection
                    
                    // 白噪音选择
                    soundSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .onAppear {
            // 如果正在专注或休息,立即更新锁屏信息
            if timerManager.timerState == .focusing || timerManager.timerState == .onBreak {
                currentLockScreenState = .idle // 重置状态,强制重新设置
                updateLockScreenInfo()
            }
            
            // 注意:计时器与白噪音的联动已在 App 级别设置
            // 这样切换标签页时白噪音不会停止
        }
        .onDisappear {
            // 只停止定时更新,不清除锁屏信息(专注中切换标签页时保持显示)
            stopLockScreenUpdates()
            // 注意:不清除锁屏信息,这样锁屏界面在切换标签页时仍然显示
        }
        .sheet(isPresented: $showSoundPicker) {
            SoundPickerView()
        }
    }
    
    // MARK: - 设置锁屏控制
    private func setupLockScreenControls() {
        LockScreenManager.shared.configureLockScreenControls(
            timerTitle: "\(timerManager.selectedCategory) - 专注中",
            isPlaying: timerManager.timerState == .focusing,
            elapsedTime: timerManager.focusDuration - timerManager.timeRemaining,
            totalDuration: timerManager.focusDuration
        ) { [weak timerManager] in
            // 播放
            timerManager?.resumeTimer()
        } pauseHandler: { [weak timerManager] in
            // 暂停
            timerManager?.pauseTimer()
        } stopHandler: { [weak timerManager] in
            // 停止
            timerManager?.stopTimer()
        }
    }
    
    // MARK: - 启动锁屏信息更新
    private func startLockScreenUpdates() {
        lockScreenTimer?.invalidate()
        lockScreenTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateLockScreenInfo()
        }
    }
    
    // MARK: - 停止锁屏信息更新
    private func stopLockScreenUpdates() {
        lockScreenTimer?.invalidate()
        lockScreenTimer = nil
    }
    
    // MARK: - 更新锁屏信息
    private func updateLockScreenInfo() {
        // 检查状态是否变化
        if timerManager.timerState != currentLockScreenState {
            currentLockScreenState = timerManager.timerState
            
            // 专注/休息开始时激活音频会话并设置锁屏控制
            if timerManager.timerState == .focusing || timerManager.timerState == .onBreak {
                LockScreenManager.shared.activateAudioSession()
                // 设置锁屏控制(包括远程控制命令)
                setupLockScreenControls()
                // 启动定时更新
                startLockScreenUpdates()
            } else if timerManager.timerState == .idle {
                // 专注结束,清除锁屏
                stopLockScreenUpdates()
                LockScreenManager.shared.clearLockScreenInfo()
                LockScreenManager.shared.deactivateAudioSession()
            }
        } else {
            // 状态未变,只更新进度时间
            if timerManager.timerState == .focusing || timerManager.timerState == .onBreak {
                configureLockScreenInfo()
            }
        }
    }
    
    // MARK: - 配置锁屏信息(只更新数据,不重新设置控制)
    private func configureLockScreenInfo() {
        let isBreak = timerManager.timerState == .onBreak
        let title = isBreak ? "休息中" : "\(timerManager.selectedCategory) - 专注中"
        let totalDuration = isBreak ? timerManager.breakDuration : timerManager.focusDuration
        let elapsed = totalDuration - timerManager.timeRemaining
        
        LockScreenManager.shared.updateNowPlayingInfo(
            title: title,
            isPlaying: true,
            elapsedTime: elapsed,
            totalDuration: totalDuration
        )
    }
    
    // MARK: - 顶部标题（已隐藏）
    private var headerSection: some View {
        EmptyView()
    }
    
    // MARK: - 计时器圆环
    private var timerRingSection: some View {
        ZStack {
            // 外圈背景
            Circle()
                .stroke(AppTheme.cardBackground, lineWidth: 12)
                .frame(width: 280, height: 280)
            
            // 进度圈
            Circle()
                .trim(from: 0, to: timerManager.progress)
                .stroke(
                    LinearGradient(
                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 280, height: 280)
                .animation(.linear(duration: 1), value: timerManager.progress)
            
            // 中心内容
            VStack(spacing: 6) {
                // 番茄钟计数/状态提示 - 放在倒计时上方
                if timerManager.timerState == .focusing || timerManager.timerState == .paused {
                    Text(L("tomato_count", timerManager.currentSession))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AppTheme.textSecondary)
                } else if timerManager.timerState == .onBreak {
                    // 休息时显示 ☕️ 和文字在一行
                    HStack(spacing: 6) {
                        Text("☕️")
                            .font(.title3)
                        Text(L("take_a_break"))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(AppTheme.accentBlue)
                } else {
                    // 空闲状态占位
                    Text(L("ready_to_focus"))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                // 倒计时数字
                Text(timerManager.formattedTime)
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary)
                    .shadow(color: AppTheme.glowColor, radius: 10, x: 0, y: 0)
                
                // 底部占位保持高度一致
                Text(" ")
                    .font(.subheadline)
            }
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - 控制按钮
    private var controlButtons: some View {
        Group {
            // 休息模式:只显示一个"结束休息"按钮
            if timerManager.timerState == .onBreak {
                Button(action: {
                    HapticFeedback.play(.medium)
                    timerManager.stopTimer()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "stop.fill")
                            .font(.title3)
                        Text(L("end_break"))
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(AppTheme.primaryGradient)
                    .clipShape(Capsule())
                    .shadow(color: Color(hex: "667eea").opacity(0.4), radius: 10, y: 4)
                }
            } else {
                // 专注模式:显示三个按钮
                HStack(spacing: 30) {
                    // 停止按钮
                    if timerManager.timerState != .idle {
                        Button(action: {
                            HapticFeedback.play(.heavy)
                            timerManager.stopTimer()
                        }) {
                            Image(systemName: "stop.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(AppTheme.error)
                                .clipShape(Circle())
                        }
                    }
                    
                    // 主按钮
                    Button(action: {
                        HapticFeedback.play(.medium)
                        switch timerManager.timerState {
                        case .idle:
                            timerManager.startTimer()
                            HapticFeedback.notification(.success)
                        case .focusing:
                            timerManager.pauseTimer()
                            HapticFeedback.notification(.warning)
                        case .paused:
                            timerManager.resumeTimer()
                            HapticFeedback.notification(.success)
                        case .onBreak:
                            timerManager.stopTimer()
                        }
                    }) {
                        Image(systemName: buttonIcon)
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(AppTheme.primaryGradient)
                            .clipShape(Circle())
                            .shadow(color: Color(hex: "667eea").opacity(0.5), radius: 15, y: 5)
                    }
                    
                    // 跳到休息
                    if timerManager.timerState == .focusing || timerManager.timerState == .paused {
                        Button(action: {
                            HapticFeedback.play(.light)
                            timerManager.skipToBreak()
                        }) {
                            Image(systemName: "forward.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(AppTheme.accentBlue)
                                .clipShape(Circle())
                        }
                    }
                }
            }
        }
    }
    
    private var buttonIcon: String {
        switch timerManager.timerState {
        case .idle:
            return "play.fill"
        case .focusing:
            return "pause.fill"
        case .paused:
            return "play.fill"
        case .onBreak:
            return "stop.fill"
        }
    }
    
    // MARK: - 分类选择
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L("focus_category"))
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(AppConstants.categories, id: \.self) { category in
                        CategoryChip(
                            category: categoryLocalized(category),
                            isSelected: timerManager.selectedCategory == category
                        ) {
                            timerManager.selectedCategory = category
                        }
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(16)
    }
    
    // MARK: - 白噪音区域
    private var soundSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(L("white_noise"))
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Button(action: {
                    showSoundPicker = true
                }) {
                    Text(L("view_all"))
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "667eea"))
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach([WhiteNoiseType.rain, .ocean, .forest, .cafe]) { sound in
                        SoundCard(sound: sound)
                            .environmentObject(soundManager)
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(16)
    }
}

// MARK: - 分类标签组件
struct CategoryChip: View {
    let category: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : AppTheme.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    AnyShapeStyle(
                        isSelected ? AnyShapeStyle(AppTheme.primaryGradient) : AnyShapeStyle(AppTheme.backgroundSecondary)
                    )
                )
                .cornerRadius(20)
        }
    }
}

// MARK: - 声音卡片组件
struct SoundCard: View {
    @EnvironmentObject var soundManager: SoundManager
    let sound: WhiteNoiseType
    
    var body: some View {
        Button(action: {
            soundManager.toggleSound(sound)
        }) {
            VStack(spacing: 8) {
                Image(systemName: soundIcon)
                    .font(.title2)
                    .foregroundColor(isPlaying ? Color(hex: "667eea") : AppTheme.textSecondary)
                    .frame(width: 50, height: 50)
                    .background(
                        isPlaying ? Color(hex: "667eea").opacity(0.2) : AppTheme.backgroundSecondary
                    )
                    .clipShape(Circle())
                
                Text(sound.displayName)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding()
        .background(AppTheme.backgroundSecondary)
        .cornerRadius(12)
    }
    
    private var isPlaying: Bool {
        return soundManager.currentSound == sound && soundManager.isPlaying
    }
    
    private var soundIcon: String {
        switch sound {
        case .rain: return "cloud.rain.fill"
        case .ocean: return "waveform.path.ecg"
        case .forest: return "tree.fill"
        case .cafe: return "cup.and.saucer.fill"
        case .fireplace: return "flame.fill"
        case .wind: return "wind"
        case .none: return "speaker.slash.fill"
        }
    }
}

// 分类本地化辅助函数
private func categoryLocalized(_ key: String) -> String {
    L("cat_" + key)
}

#Preview {
    TimerView()
        .environmentObject(TimerManager())
        .environmentObject(SoundManager())
        .environmentObject(StatsManager())
        .environmentObject(SubscriptionManager())
}
