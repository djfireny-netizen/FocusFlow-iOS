import Foundation
import WatchConnectivity
import Combine

// MARK: - iPhone 端 Watch 通信管理器
class iPhoneConnectivityManager: NSObject, ObservableObject {
    static let shared = iPhoneConnectivityManager()
    
    private var session: WCSession?
    
    @Published var isWatchPaired: Bool = false
    @Published var isWatchReachable: Bool = false
    @Published var lastSyncTime: Date?
    
    private override init() {
        super.init()
    }
    
    // MARK: - 激活会话
    func activate() {
        guard WCSession.isSupported() else {
            print("⚠️ WatchConnectivity 不支持")
            return
        }
        
        session = WCSession.default
        session?.delegate = self
        session?.activate()
        
        print("✅ iPhone ConnectivityManager 已激活")
    }
    
    // MARK: - 发送计时器状态
    func sendTimerState(_ state: TimerStateSync) {
        guard let session = session, session.isReachable else {
            print("⚠️ Watch 不可达")
            return
        }
        
        let message = SyncMessage(command: .syncResponse, timerState: state)
        
        do {
            let data = try JSONEncoder().encode(message)
            let dict = ["timerState": data] as [String : Any]
            
            session.sendMessage(dict, replyHandler: { reply in
                print("✅ 计时器状态已发送到 Watch")
            }, errorHandler: { error in
                print("❌ 发送失败: \(error.localizedDescription)")
            })
            
            lastSyncTime = Date()
        } catch {
            print("❌ 编码失败: \(error)")
        }
    }
    
    // MARK: - 发送专注记录
    func sendSessions(_ sessions: [SessionSync]) {
        guard let session = session, session.isReachable else { return }
        
        let message = SyncMessage(command: .syncResponse, sessions: sessions)
        
        do {
            let data = try JSONEncoder().encode(message)
            session.sendMessage(["sessions": data], replyHandler: nil, errorHandler: nil)
            print("✅ 已发送 \(sessions.count) 条专注记录")
        } catch {
            print("❌ 编码失败: \(error)")
        }
    }
    
    // MARK: - 处理 Watch 命令
    private func handleWatchCommand(_ message: [String : Any]) {
        guard let data = message["command"] as? Data,
              let command = try? JSONDecoder().decode(SyncCommand.self, from: data) else {
            return
        }
        
        print("📥 收到 Watch 命令: \(command.rawValue)")
        
        // 通知 TimerManager（通过 NotificationCenter）
        NotificationCenter.default.post(
            name: NSNotification.Name("WatchCommandReceived"),
            object: nil,
            userInfo: ["command": command]
        )
    }
}

// MARK: - WCSessionDelegate
extension iPhoneConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("❌ Session 激活失败: \(error)")
            return
        }
        
        isWatchPaired = session.isPaired
        isWatchReachable = session.isReachable
        
        print("✅ Session 激活成功 - Paired: \(isWatchPaired), Reachable: \(isWatchReachable)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("⚠️ Session 变为非活动")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("⚠️ Session 已停用")
        isWatchPaired = false
        isWatchReachable = false
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handleWatchCommand(message)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        handleWatchCommand(message)
        replyHandler(["status": "ok"])
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        isWatchReachable = session.isReachable
        print("📡 Watch 可达性变化: \(isWatchReachable)")
    }
}
