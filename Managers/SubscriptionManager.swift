import Foundation
import SwiftUI
import StoreKit

// MARK: - 订阅管理器
class SubscriptionManager: ObservableObject {
    @Published var isPremium: Bool = false
    @Published var isLoading: Bool = false
    @Published var subscriptionType: SubscriptionType = .none
    @Published var showSubscriptionSheet: Bool = false
    @Published var isFreeTrial: Bool = false
    @Published var trialEndDate: Date?
    @Published var trialDaysRemaining: Int = 0
    
    // MARK: - 检查订阅状态
    func checkSubscriptionStatus() {
        // 检查本地存储的订阅状态
        isPremium = UserDefaults.standard.bool(forKey: "isPremium")
        if let typeRaw = UserDefaults.standard.string(forKey: "subscriptionType"),
           let type = SubscriptionType(rawValue: typeRaw) {
            subscriptionType = type
        }
        
        // 检查免费试用
        checkFreeTrial()
    }
    
    // MARK: - 免费试用
    func startFreeTrial() {
        isFreeTrial = true
        trialEndDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        isPremium = true
        
        UserDefaults.standard.set(true, forKey: "isPremium")
        UserDefaults.standard.set(true, forKey: "isFreeTrial")
        UserDefaults.standard.set(trialEndDate, forKey: "trialEndDate")
        
        showSubscriptionSheet = false
    }
    
    private func checkFreeTrial() {
        isFreeTrial = UserDefaults.standard.bool(forKey: "isFreeTrial")
        if let endDate = UserDefaults.standard.value(forKey: "trialEndDate") as? Date {
            trialEndDate = endDate
            let days = Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0
            trialDaysRemaining = max(0, days)
            
            // 如果试用已过期
            if trialDaysRemaining == 0 {
                isPremium = false
                isFreeTrial = false
                UserDefaults.standard.set(false, forKey: "isPremium")
                UserDefaults.standard.set(false, forKey: "isFreeTrial")
            }
        }
    }
    
    // MARK: - 购买订阅
    func purchaseSubscription(_ type: SubscriptionType) async {
        await MainActor.run { isLoading = true }
        
        do {
            // 模拟购买流程(实际项目需要集成 StoreKit 2)
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            // 购买成功 - 在主线程更新 UI
            await MainActor.run {
                isPremium = true
                subscriptionType = type
                
                UserDefaults.standard.set(true, forKey: "isPremium")
                UserDefaults.standard.set(type.rawValue, forKey: "subscriptionType")
                
                showSubscriptionSheet = false
            }
        } catch {
            print("购买失败: \(error)")
        }
        
        await MainActor.run { isLoading = false }
    }
    
    // MARK: - 恢复购买
    func restorePurchases() async {
        await MainActor.run { isLoading = true }
        
        do {
            // 模拟恢复流程
            try await Task.sleep(nanoseconds: 500_000_000)
            
            // 恢复成功 - 在主线程更新 UI
            await MainActor.run {
                checkSubscriptionStatus()
            }
        } catch {
            print("恢复失败: \(error)")
        }
        
        await MainActor.run { isLoading = false }
    }
    
    // MARK: - 取消订阅
    func cancelSubscription() {
        isPremium = false
        subscriptionType = .none
        
        UserDefaults.standard.set(false, forKey: "isPremium")
        UserDefaults.standard.removeObject(forKey: "subscriptionType")
    }
    
    // MARK: - 功能可用性检查
    func canUsePremiumFeature() -> Bool {
        return isPremium
    }
}

// MARK: - 订阅类型
enum SubscriptionType: String {
    case none = "none"
    case monthly = "monthly"
    case yearly = "yearly"
    case lifetime = "lifetime"
    
    var displayName: String {
        switch self {
        case .none:
            return "Free"
        case .monthly:
            return "Monthly"
        case .yearly:
            return "Yearly"
        case .lifetime:
            return "Lifetime"
        }
    }
    
    var price: String {
        switch self {
        case .monthly:
            return "$4.99/月"
        case .yearly:
            return "$29.99/年"
        case .lifetime:
            return "$59.99"
        case .none:
            return ""
        }
    }
    
    var savings: String? {
        switch self {
        case .yearly:
            return "Save 50%"
        case .lifetime:
            return "Best Value"
        default:
            return nil
        }
    }
}

// MARK: - 订阅功能特性
struct PremiumFeature {
    let icon: String
    let title: String
    let description: String
}

struct PremiumFeatures {
    static let allFeatures: [PremiumFeature] = [
        PremiumFeature(icon: "timer", title: "自定义时长", description: "自由设置专注和休息时间"),
        PremiumFeature(icon: "chart.bar.fill", title: "详细统计", description: "查看完整的数据分析和趋势"),
        PremiumFeature(icon: "waveform", title: "白噪音库", description: "解锁所有高品质白噪音"),
        PremiumFeature(icon: "tag.fill", title: "分类标签", description: "为专注时间添加分类标签"),
        PremiumFeature(icon: "icloud.fill", title: "iCloud 同步", description: "多设备数据自动同步"),
        PremiumFeature(icon: "widget.family.medium", title: "桌面组件", description: "精美的桌面小组件")
    ]
}
