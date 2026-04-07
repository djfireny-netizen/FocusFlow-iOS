import Foundation
import HealthKit

// MARK: - 健康管理器
class HealthManager: ObservableObject {
    static let shared = HealthManager()
    
    private let healthStore = HKHealthStore()
    @Published var isHealthAvailable: Bool = false
    @Published var isHealthEnabled: Bool = false
    
    // 用户控制的同步开关(本地存储)
    private let syncEnabledKey = "healthSyncEnabled"
    var isSyncEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: syncEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: syncEnabledKey)
        }
    }
    
    // MARK: - 检查健康可用性
    func checkAvailability() {
        isHealthAvailable = HKHealthStore.isHealthDataAvailable()
    }
    
    // MARK: - 请求健康权限
    func requestHealthPermission(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit 不可用")
            completion(false)
            return
        }
        
        // 专注时间数据类型
        guard let mindfulnessType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else {
            print("无法获取 mindfulSession 类型")
            completion(false)
            return
        }
        
        let typesToShare: Set = [mindfulnessType]
        let typesToRead: Set = [mindfulnessType]
        
        // 必须在主线程请求授权
        DispatchQueue.main.async {
            self.healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { [weak self] success, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("HealthKit 权限请求失败: \(error.localizedDescription)")
                }
                
                // 延迟检查实际授权状态,因为用户可能刚完成授权
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.checkHealthPermission()
                    completion(self.isHealthEnabled)
                }
            }
        }
    }
    
    // MARK: - 保存专注数据到健康
    func saveFocusSession(
        startTime: Date,
        endTime: Date,
        completion: @escaping (Bool) -> Void
    ) {
        guard HKHealthStore.isHealthDataAvailable(),
              let mindfulnessType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else {
            completion(false)
            return
        }
        
        let session = HKCategorySample(
            type: mindfulnessType,
            value: 0, // HKCategoryValueNotApplicable for mindfulSession
            start: startTime,
            end: endTime
        )
        
        healthStore.save(session) { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("保存健康数据失败: \(error.localizedDescription)")
                }
                completion(success)
            }
        }
    }
    
    // MARK: - 批量保存专注数据
    func saveFocusSessions(_ sessions: [FocusSession]) {
        guard HKHealthStore.isHealthDataAvailable(),
              isHealthEnabled,
              isSyncEnabled else {
            // 同步开关关闭或没有权限,不保存
            return
        }
        
        // 在后台线程异步保存,避免阻塞主线程
        DispatchQueue.global(qos: .background).async {
            let completedSessions = sessions.filter { $0.completed }
            
            for (index, session) in completedSessions.enumerated() {
                self.saveFocusSession(
                    startTime: session.startTime,
                    endTime: session.endTime
                ) { _ in }
                
                // 每保存10个会话暂停一下,避免过快请求
                if (index + 1) % 10 == 0 {
                    Thread.sleep(forTimeInterval: 0.1)
                }
            }
            
            print("已同步 \(completedSessions.count) 个专注会话到健康")
        }
    }
    
    // MARK: - 检查健康权限
    func checkHealthPermission() {
        guard HKHealthStore.isHealthDataAvailable(),
              let mindfulnessType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else {
            isHealthEnabled = false
            return
        }
        
        let status = healthStore.authorizationStatus(for: mindfulnessType)
        DispatchQueue.main.async {
            self.isHealthEnabled = status == .sharingAuthorized
        }
    }
}
