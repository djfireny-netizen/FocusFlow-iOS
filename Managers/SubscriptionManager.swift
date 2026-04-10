import Foundation
import SwiftUI
import StoreKit

// MARK: - 产品 ID
enum ProductID: String, CaseIterable {
    case monthly = "focusflow.monthly"
    case yearly = "focusflow.yearly"
    case lifetime = "focusflow.lifetime"
}

// MARK: - 订阅管理器
@MainActor
class SubscriptionManager: ObservableObject {
    @Published var isPremium: Bool = false
    @Published var isLoading: Bool = false
    @Published var subscriptionType: SubscriptionType = .none
    @Published var showSubscriptionSheet: Bool = false
    @Published var isFreeTrial: Bool = false
    @Published var trialEndDate: Date?
    @Published var trialDaysRemaining: Int = 0
    
    // StoreKit 产品
    @Published var products: [Product] = []
    @Published var purchaseError: String?
    
    // 购买事务更新监听
    private var updates: Task<Void, Never>?
    
    init() {
        // 启动事务监听
        updates = observeTransactionUpdates()
        // 检查订阅状态
        checkSubscriptionStatus()
        // 获取产品
        Task {
            await fetchProducts()
        }
    }
    
    deinit {
        updates?.cancel()
    }
    
    // MARK: - 获取产品
    func fetchProducts() async {
        await MainActor.run { isLoading = true }
        
        do {
            let productIDs = ProductID.allCases.map { $0.rawValue }
            let storeProducts = try await Product.products(for: Set(productIDs))
            
            await MainActor.run {
                self.products = storeProducts.sorted { p1, p2 in
                    // 排序：月度 < 年度 < 终身
                    let order: [String] = [ProductID.monthly.rawValue, ProductID.yearly.rawValue, ProductID.lifetime.rawValue]
                    guard let index1 = order.firstIndex(of: p1.id),
                          let index2 = order.firstIndex(of: p2.id) else { return false }
                    return index1 < index2
                }
            }
        } catch {
            print("获取产品失败: \(error)")
            await MainActor.run {
                self.purchaseError = "无法加载产品信息"
            }
        }
        
        await MainActor.run { isLoading = false }
    }
    
    // MARK: - 检查订阅状态
    func checkSubscriptionStatus() {
        Task {
            await updateSubscriptionStatus()
        }
    }
    
    private func updateSubscriptionStatus() async {
        var hasActiveSubscription = false
        var currentType: SubscriptionType = .none
        
        // 检查所有产品的事务状态
        for productID in ProductID.allCases {
            guard let product = try? await Product.products(for: [productID.rawValue]).first else { continue }
            
            if let status = try? await product.subscription?.status {
                for state in status {
                    if state.state == .subscribed {
                        hasActiveSubscription = true
                        currentType = subscriptionType(from: productID)
                        break
                    }
                }
            }
            
            // 检查非消耗型购买（终身）
            if productID == .lifetime {
                if await product.currentEntitlement != nil {
                    hasActiveSubscription = true
                    currentType = .lifetime
                }
            }
        }
        
        await MainActor.run {
            self.isPremium = hasActiveSubscription || UserDefaults.standard.bool(forKey: "isPremium")
            self.subscriptionType = currentType
        }
    }
    
    private func subscriptionType(from productID: ProductID) -> SubscriptionType {
        switch productID {
        case .monthly: return .monthly
        case .yearly: return .yearly
        case .lifetime: return .lifetime
        }
    }
    
    // MARK: - 购买产品
    func purchase(_ product: Product) async {
        await MainActor.run { 
            isLoading = true 
            purchaseError = nil
        }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // 验证购买
                let transaction = try checkVerified(verification)
                
                // 完成事务
                await transaction.finish()
                
                // 更新状态
                await updateSubscriptionStatus()
                
                await MainActor.run {
                    self.isPremium = true
                    self.subscriptionType = subscriptionType(from: ProductID(rawValue: product.id) ?? .monthly)
                    self.showSubscriptionSheet = false
                }
                
            case .userCancelled:
                print("用户取消购买")
            case .pending:
                print("购买等待中")
            @unknown default:
                print("未知购买结果")
            }
        } catch {
            print("购买失败: \(error)")
            await MainActor.run {
                self.purchaseError = "购买失败: \(error.localizedDescription)"
            }
        }
        
        await MainActor.run { isLoading = false }
    }
    
    // MARK: - 购买订阅（按类型）
    func purchaseSubscription(_ type: SubscriptionType) async {
        let productID: String
        switch type {
        case .monthly: productID = ProductID.monthly.rawValue
        case .yearly: productID = ProductID.yearly.rawValue
        case .lifetime: productID = ProductID.lifetime.rawValue
        case .none: return
        }
        
        guard let product = products.first(where: { $0.id == productID }) else {
            await MainActor.run {
                self.purchaseError = "产品不可用"
            }
            return
        }
        
        await purchase(product)
    }
    
    // MARK: - 恢复购买
    func restorePurchases() async {
        await MainActor.run { isLoading = true }
        
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
        } catch {
            print("恢复失败: \(error)")
            await MainActor.run {
                self.purchaseError = "恢复购买失败"
            }
        }
        
        await MainActor.run { isLoading = false }
    }
    
    // MARK: - 监听事务更新
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await verificationResult in Transaction.updates {
                do {
                    let transaction = try checkVerified(verificationResult)
                    
                    // 完成事务
                    await transaction.finish()
                    
                    // 更新订阅状态
                    await updateSubscriptionStatus()
                } catch {
                    print("事务验证失败: \(error)")
                }
            }
        }
    }
    
    // MARK: - 验证购买
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
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
    
    // MARK: - 取消订阅
    func cancelSubscription() {
        // 引导用户到系统设置取消订阅
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - 功能可用性检查
    func canUsePremiumFeature() -> Bool {
        return isPremium
    }
}

// MARK: - Store 错误
enum StoreError: Error {
    case failedVerification
}

extension StoreError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "购买验证失败"
        }
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
            return L("subscription_free")
        case .monthly:
            return L("subscription_monthly")
        case .yearly:
            return L("subscription_yearly")
        case .lifetime:
            return L("subscription_lifetime")
        }
    }
    
    var productID: String? {
        switch self {
        case .monthly: return ProductID.monthly.rawValue
        case .yearly: return ProductID.yearly.rawValue
        case .lifetime: return ProductID.lifetime.rawValue
        case .none: return nil
        }
    }
    
    var savings: String? {
        switch self {
        case .yearly:
            return L("subscription_save_50")
        case .lifetime:
            return L("subscription_best_value")
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
    static var allFeatures: [PremiumFeature] {
        [
            PremiumFeature(icon: "paintpalette.fill", title: L("feature_themes"), description: L("feature_themes_desc")),
            PremiumFeature(icon: "timer", title: L("feature_custom_duration"), description: L("feature_custom_duration_desc")),
            PremiumFeature(icon: "waveform", title: L("feature_white_noise_pro"), description: L("feature_white_noise_pro_desc")),
            PremiumFeature(icon: "chart.line.uptrend.xyaxis", title: L("feature_advanced_stats"), description: L("feature_advanced_stats_desc")),
            PremiumFeature(icon: "apple.logo", title: L("feature_watch_app"), description: L("feature_watch_app_desc")),
            PremiumFeature(icon: "star.fill", title: L("feature_no_ads"), description: L("feature_no_ads_desc"))
        ]
    }
}
