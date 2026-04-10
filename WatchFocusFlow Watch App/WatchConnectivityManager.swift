//
//  WatchConnectivityManager.swift
//  WatchFocusFlow Watch App
//
//  Created for FocusFlow Go
//

import Foundation
import WatchConnectivity
import SwiftUI

// MARK: - Watch 通信管理器
@MainActor
class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    @Published var isReachable: Bool = false
    @Published var lastError: String?
    
    // 接收到的数据
    @Published var focusSessions: [FocusSessionData] = []
    @Published var todayStats: TodayStats?
    @Published var timerState: WatchTimerState = .idle
    
    private let session = WCSession.default
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }
    
    // MARK: - 发送消息到 iPhone
    
    /// 请求今日统计
    func requestTodayStats() {
        guard session.isReachable else {
            lastError = "iPhone 不可达"
            return
        }
        
        session.sendMessage(["action": "requestTodayStats"], replyHandler: { response in
            if let statsData = response["stats"] as? [String: Any],
               let stats = TodayStats.decode(from: statsData) {
                self.todayStats = stats
            }
        }, errorHandler: { error in
            self.lastError = error.localizedDescription
        })
    }
    
    /// 请求专注记录
    func requestFocusSessions() {
        guard session.isReachable else {
            lastError = "iPhone 不可达"
            return
        }
        
        session.sendMessage(["action": "requestSessions"], replyHandler: { response in
            if let sessionsData = response["sessions"] as? [[String: Any]] {
                self.focusSessions = sessionsData.compactMap { FocusSessionData.decode(from: $0) }
            }
        }, errorHandler: { error in
            self.lastError = error.localizedDescription
        })
    }
    
    /// 启动专注计时器
    func startFocus(duration: TimeInterval, category: String) {
        guard session.isReachable else {
            lastError = "iPhone 不可达"
            return
        }
        
        let message: [String: Any] = [
            "action": "startFocus",
            "duration": duration,
            "category": category
        ]
        
        session.sendMessage(message, replyHandler: { response in
            if let state = response["timerState"] as? String {
                self.timerState = WatchTimerState(rawValue: state) ?? .idle
            }
        }, errorHandler: { error in
            self.lastError = error.localizedDescription
        })
    }
    
    /// 暂停计时器
    func pauseTimer() {
        guard session.isReachable else { return }
        
        session.sendMessage(["action": "pauseTimer"], replyHandler: { response in
            if let state = response["timerState"] as? String {
                self.timerState = WatchTimerState(rawValue: state) ?? .idle
            }
        }, errorHandler: nil)
    }
    
    /// 恢复计时器
    func resumeTimer() {
        guard session.isReachable else { return }
        
        session.sendMessage(["action": "resumeTimer"], replyHandler: { response in
            if let state = response["timerState"] as? String {
                self.timerState = WatchTimerState(rawValue: state) ?? .idle
            }
        }, errorHandler: nil)
    }
    
    /// 停止计时器
    func stopTimer() {
        guard session.isReachable else { return }
        
        session.sendMessage(["action": "stopTimer"], replyHandler: { response in
            self.timerState = .idle
        }, errorHandler: nil)
    }
    
    /// 控制白噪音
    func controlSound(play: Bool, soundID: String? = nil) {
        guard session.isReachable else { return }
        
        var message: [String: Any] = ["action": "controlSound", "play": play]
        if let soundID = soundID {
            message["soundID"] = soundID
        }
        
        session.sendMessage(message, replyHandler: nil, errorHandler: nil)
    }
}

// MARK: - WCSessionDelegate
extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            lastError = error.localizedDescription
        } else {
            isReachable = session.isReachable
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        isReachable = session.isReachable
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        // 处理 iPhone 发来的消息
        if let action = message["action"] as? String {
            switch action {
            case "updateTimerState":
                if let state = message["timerState"] as? String {
                    timerState = WatchTimerState(rawValue: state) ?? .idle
                }
                if let time = message["timeRemaining"] as? Double {
                    // 更新计时器剩余时间（如果需要）
                }
            case "updateSessions":
                if let sessionsData = message["sessions"] as? [[String: Any]] {
                    focusSessions = sessionsData.compactMap { FocusSessionData.decode(from: $0) }
                }
            default:
                break
            }
        }
    }
}

// MARK: - 数据模型

/// Watch 计时器状态
enum WatchTimerState: String {
    case idle = "idle"
    case focusing = "focusing"
    case paused = "paused"
    case onBreak = "onBreak"
}

/// 今日统计
struct TodayStats: Codable {
    let totalMinutes: Int
    let sessionCount: Int
    let categories: [CategoryStats]
    
    static func decode(from dict: [String: Any]) -> TodayStats? {
        guard let totalMinutes = dict["totalMinutes"] as? Int,
              let sessionCount = dict["sessionCount"] as? Int,
              let categoriesData = dict["categories"] as? [[String: Any]] else {
            return nil
        }
        
        let categories = categoriesData.compactMap { cat -> CategoryStats? in
            guard let name = cat["name"] as? String,
                  let minutes = cat["minutes"] as? Int,
                  let count = cat["count"] as? Int else {
                return nil
            }
            return CategoryStats(name: name, minutes: minutes, count: count)
        }
        
        return TodayStats(totalMinutes: totalMinutes, sessionCount: sessionCount, categories: categories)
    }
}

/// 分类统计
struct CategoryStats: Codable {
    let name: String
    let minutes: Int
    let count: Int
}

/// 专注记录
struct FocusSessionData: Codable {
    let id: String
    let category: String
    let duration: Int
    let date: Date
    let isCompleted: Bool
    
    static func decode(from dict: [String: Any]) -> FocusSessionData? {
        guard let id = dict["id"] as? String,
              let category = dict["category"] as? String,
              let duration = dict["duration"] as? Int,
              let dateTimestamp = dict["date"] as? TimeInterval,
              let isCompleted = dict["isCompleted"] as? Bool else {
            return nil
        }
        
        return FocusSessionData(
            id: id,
            category: category,
            duration: duration,
            date: Date(timeIntervalSince1970: dateTimestamp),
            isCompleted: isCompleted
        )
    }
}
