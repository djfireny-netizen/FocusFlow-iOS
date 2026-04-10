//
//  PhoneConnectivityManager.swift
//  FocusFlow
//
//  Created for FocusFlow Go
//

import Foundation
import WatchConnectivity
import SwiftUI

// MARK: - iPhone 端 Watch 通信管理器
@MainActor
class PhoneConnectivityManager: NSObject, ObservableObject {
    static let shared = PhoneConnectivityManager()
    
    @Published var isWatchReachable: Bool = false
    @Published var lastError: String?
    
    private let session = WCSession.default
    private var timerManager: TimerManager?
    private var statsManager: StatsManager?
    
    // 初始化时需要传入依赖
    func configure(timerManager: TimerManager, statsManager: StatsManager) {
        self.timerManager = timerManager
        self.statsManager = statsManager
        
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }
    
    // MARK: - 发送更新到 Watch
    
    /// 更新计时器状态
    func updateTimerState() {
        guard session.isReachable else { return }
        
        let message: [String: Any] = [
            "action": "updateTimerState",
            "timerState": timerManager?.timerState.rawValue ?? "idle",
            "timeRemaining": timerManager?.timeRemaining ?? 0
        ]
        
        session.sendMessage(message, replyHandler: nil, errorHandler: { error in
            self.lastError = error.localizedDescription
        })
    }
    
    /// 更新专注记录
    func updateSessions() {
        guard session.isReachable, let timerManager = timerManager else { return }
        
        let sessionsData = timerManager.sessions.prefix(10).map { session -> [String: Any] in
            return [
                "id": session.id.uuidString,
                "category": session.category,
                "duration": Int(session.duration),
                "date": session.date.timeIntervalSince1970,
                "isCompleted": session.isCompleted
            ]
        }
        
        let message: [String: Any] = [
            "action": "updateSessions",
            "sessions": sessionsData
        ]
        
        session.sendMessage(message, replyHandler: nil, errorHandler: nil)
    }
}

// MARK: - WCSessionDelegate
extension PhoneConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            lastError = error.localizedDescription
        } else {
            isWatchReachable = session.isReachable
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        isWatchReachable = session.isReachable
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        guard let action = message["action"] as? String else { return }
        
        switch action {
        case "requestTodayStats":
            handleRequestTodayStats(replyHandler: replyHandler)
            
        case "requestSessions":
            handleRequestSessions(replyHandler: replyHandler)
            
        case "startFocus":
            handleStartFocus(message: message, replyHandler: replyHandler)
            
        case "pauseTimer":
            handlePauseTimer(replyHandler: replyHandler)
            
        case "resumeTimer":
            handleResumeTimer(replyHandler: replyHandler)
            
        case "stopTimer":
            handleStopTimer(replyHandler: replyHandler)
            
        case "controlSound":
            handleControlSound(message: message, replyHandler: replyHandler)
            
        default:
            break
        }
    }
    
    // MARK: - 处理 Watch 请求
    
    private func handleRequestTodayStats(replyHandler: @escaping ([String: Any]) -> Void) {
        guard let statsManager = statsManager else {
            replyHandler(["error": "Data not available"])
            return
        }
        
        let todayStats = statsManager.getTodayStats()
        let statsData: [String: Any] = [
            "totalMinutes": todayStats.totalMinutes,
            "sessionCount": todayStats.sessionCount,
            "categories": todayStats.categories.map { cat in
                [
                    "name": cat.name,
                    "minutes": cat.minutes,
                    "count": cat.count
                ] as [String: Any]
            }
        ]
        
        replyHandler(["stats": statsData])
    }
    
    private func handleRequestSessions(replyHandler: @escaping ([String: Any]) -> Void) {
        guard let timerManager = timerManager else {
            replyHandler(["error": "Data not available"])
            return
        }
        
        let sessionsData = timerManager.sessions.prefix(10).map { session -> [String: Any] in
            return [
                "id": session.id.uuidString,
                "category": session.category,
                "duration": Int(session.duration),
                "date": session.date.timeIntervalSince1970,
                "isCompleted": session.isCompleted
            ]
        }
        
        replyHandler(["sessions": sessionsData])
    }
    
    private func handleStartFocus(message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        guard let timerManager = timerManager,
              let duration = message["duration"] as? TimeInterval,
              let category = message["category"] as? String else {
            replyHandler(["error": "Invalid parameters"])
            return
        }
        
        // 设置计时器参数
        timerManager.focusDuration = duration
        timerManager.selectedCategory = category
        timerManager.timeRemaining = duration
        
        // 启动计时器
        timerManager.startTimer()
        
        replyHandler([
            "timerState": timerManager.timerState.rawValue,
            "success": true
        ])
    }
    
    private func handlePauseTimer(replyHandler: @escaping ([String: Any]) -> Void) {
        timerManager?.pauseTimer()
        replyHandler(["timerState": timerManager?.timerState.rawValue ?? "idle"])
    }
    
    private func handleResumeTimer(replyHandler: @escaping ([String: Any]) -> Void) {
        timerManager?.resumeTimer()
        replyHandler(["timerState": timerManager?.timerState.rawValue ?? "idle"])
    }
    
    private func handleStopTimer(replyHandler: @escaping ([String: Any]) -> Void) {
        timerManager?.stopTimer()
        replyHandler(["timerState": "idle"])
    }
    
    private func handleControlSound(message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        guard let play = message["play"] as? Bool else { return }
        
        if play {
            // 播放白噪音
            timerManager?.onSoundControl?(true)
        } else {
            // 停止白噪音
            timerManager?.onSoundControl?(false)
        }
        
        replyHandler(["success": true])
    }
}
