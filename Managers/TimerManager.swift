import Foundation
import SwiftUI
import AudioToolbox
import Combine
import ActivityKit

// MARK: - 计时器管理器
class TimerManager: ObservableObject {
    @Published var timerState: TimerState = .idle
    @Published var timeRemaining: TimeInterval = AppConstants.defaultFocusDuration
    @Published var currentSession: Int = 0
    @Published var focusDuration: TimeInterval = AppConstants.defaultFocusDuration
    @Published var breakDuration: TimeInterval = AppConstants.defaultBreakDuration
    @Published var selectedCategory: String = "工作"
    @Published var sessions: [FocusSession] = []
    
    // 白噪音控制回调
    var onSoundControl: ((Bool) -> Void)?
    
    private var timer: Timer?
    private var sessionStartTime: Date?
    private var totalFocusTime: TimeInterval = 0
    
    // 计算属性
    var progress: Double {
        let totalDuration = timerState == .onBreak ? breakDuration : focusDuration
        return 1.0 - (timeRemaining / totalDuration)
    }
    
    var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - 计时器控制
    func startTimer() {
        guard timerState == .idle || timerState == .paused else { return }
        
        if timerState == .idle {
            sessionStartTime = Date()
            currentSession += 1
            
            // 启动实时活动
            if #available(iOS 16.1, *) {
                LiveActivityManager.shared.startFocusActivity(
                    category: selectedCategory,
                    duration: focusDuration,
                    isBreak: false,
                    currentSession: currentSession
                )
            }
        } else {
            // 从暂停恢复
            if #available(iOS 16.1, *) {
                LiveActivityManager.shared.resumeActivity()
            }
        }
        
        timerState = .focusing
        
        // 如果白噪音正在播放，继续播放
        onSoundControl?(true)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    func pauseTimer() {
        guard timerState == .focusing else { return }
        timer?.invalidate()
        timerState = .paused
        
        // 暂停白噪音
        onSoundControl?(false)
        
        // 暂停实时活动
        if #available(iOS 16.1, *) {
            LiveActivityManager.shared.pauseActivity()
        }
    }
    
    func resumeTimer() {
        guard timerState == .paused else { return }
        timerState = .focusing
        
        // 继续白噪音
        onSoundControl?(true)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        
        // 停止白噪音
        onSoundControl?(false)
        
        // 结束实时活动
        if #available(iOS 16.1, *) {
            LiveActivityManager.shared.endCurrentActivity()
        }
        
        // 保存会话记录
        if let startTime = sessionStartTime {
            let elapsedTime = focusDuration - timeRemaining
            if elapsedTime > 60 { // 超过1分钟才记录
                let session = FocusSession(
                    startTime: startTime,
                    endTime: Date(),
                    duration: elapsedTime,
                    category: selectedCategory,
                    completed: timeRemaining <= 0
                )
                sessions.insert(session, at: 0)
                saveSessions()
                
                // 保存到 Apple 健康(检查同步开关和权限)
                if HealthManager.shared.isHealthEnabled && 
                   HealthManager.shared.isSyncEnabled && 
                   timeRemaining <= 0 {
                    HealthManager.shared.saveFocusSession(
                        startTime: startTime,
                        endTime: Date()
                    ) { _ in }
                }
            }
        }
        
        // 重置
        timerState = .idle
        timeRemaining = focusDuration
        sessionStartTime = nil
    }
    
    func skipToBreak() {
        stopTimer()
        startBreak()
    }
    
    // MARK: - 私有方法
    private func tick() {
        guard timeRemaining > 0 else {
            completeTimer()
            return
        }
        timeRemaining -= 1
        
        // 更新实时活动
        if #available(iOS 16.1, *) {
            LiveActivityManager.shared.updateActivity(
                timeRemaining: timeRemaining,
                progress: progress,
                currentSession: currentSession,
                isPaused: false
            )
        }
    }
    
    private func completeTimer() {
        timer?.invalidate()
        timer = nil
        
        // 播放提示音
        playNotificationSound()
        
        // 保存会话
        if let startTime = sessionStartTime {
            let session = FocusSession(
                startTime: startTime,
                endTime: Date(),
                duration: focusDuration,
                category: selectedCategory,
                completed: true
            )
            sessions.insert(session, at: 0)
            saveSessions()
        }
        
        // 自动进入休息
        if currentSession % AppConstants.sessionsBeforeLongBreak == 0 {
            breakDuration = AppConstants.longBreakDuration
        } else {
            breakDuration = AppConstants.defaultBreakDuration
        }
        
        startBreak()
    }
    
    private func startBreak() {
        timerState = .onBreak
        timeRemaining = breakDuration
        
        // 启动休息计时器
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        
        // 休息结束后自动重置
        DispatchQueue.main.asyncAfter(deadline: .now() + breakDuration) { [weak self] in
            self?.timer?.invalidate()
            self?.timer = nil
            self?.timerState = .idle
            self?.timeRemaining = self?.focusDuration ?? AppConstants.defaultFocusDuration
        }
    }
    
    private func playNotificationSound() {
        // 播放系统提示音
        AudioServicesPlaySystemSound(1005)
    }
    
    // MARK: - 数据持久化
    func saveSessions() {
        if let data = try? JSONEncoder().encode(sessions.map { SessionData(from: $0) }) {
            UserDefaults.standard.set(data, forKey: "focusSessions")
        }
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "focusSessions"),
           let sessionData = try? JSONDecoder().decode([SessionData].self, from: data) {
            sessions = sessionData.map { $0.toFocusSession() }
        }
    }
    
    func clearHistory() {
        sessions.removeAll()
        UserDefaults.standard.removeObject(forKey: "focusSessions")
    }
}

// MARK: - 会话数据(用于序列化)
struct SessionData: Codable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    let duration: TimeInterval
    let category: String
    let completed: Bool
    let notes: String
    
    init(from session: FocusSession) {
        self.id = session.id
        self.startTime = session.startTime
        self.endTime = session.endTime
        self.duration = session.duration
        self.category = session.category
        self.completed = session.completed
        self.notes = session.notes
    }
    
    func toFocusSession() -> FocusSession {
        return FocusSession(
            startTime: startTime,
            endTime: endTime,
            duration: duration,
            category: category,
            completed: completed,
            notes: notes
        )
    }
}
