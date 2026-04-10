import SwiftUI
import StoreKit

// MARK: - 订阅页面
struct SubscriptionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var selectedPlan: SubscriptionType = .yearly
    
    var body: some View {
        NavigationView {
            ZStack {
                // 深色背景
                AppTheme.backgroundPrimary
                    .ignoresSafeArea()
                
                // 渐变球体背景
                AppTheme.gradientOrb(size: 450)
                    .position(x: UIScreen.main.bounds.width / 2, y: 300)
                
                // 装饰细线
                GeometryReader { geometry in
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: geometry.size.height * 0.2))
                        path.addQuadCurve(to: CGPoint(x: geometry.size.width, y: geometry.size.height * 0.4),
                                         control: CGPoint(x: geometry.size.width * 0.5, y: geometry.size.height * 0.1))
                    }
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: geometry.size.height * 0.7))
                        path.addQuadCurve(to: CGPoint(x: geometry.size.width, y: geometry.size.height * 0.8),
                                         control: CGPoint(x: geometry.size.width * 0.5, y: geometry.size.height * 0.9))
                    }
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
                }
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // 头部
                        headerSection
                        
                        // 社会证明
                        socialProofSection
                        
                        // 免费试用提示
                        if !subscriptionManager.isFreeTrial {
                            freeTrialBanner
                        }
                        
                        // 功能列表
                        featuresSection
                        
                        // 价格方案
                        pricingSection
                        
                        // 购买按钮（包含恢复购买）
                        purchaseButton
                        
                        // 条款
                        termsText
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle(L("upgrade_premium"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L("close")) {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.accentOrange)
                }
            }
        }
    }
    
    // MARK: - 头部
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.accentOrange)
            
            Text(L("unlock_all_features"))
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)
            
            Text(L("make_focus_habit"))
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - 社会证明
    private var socialProofSection: some View {
        VStack(spacing: 12) {
            // 用户数量
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("10,000+")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.accentBlue)
                    
                    Text("活跃用户")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Divider()
                    .frame(height: 30)
                
                VStack(spacing: 4) {
                    Text("4.9")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.accentYellow)
                    
                    Text("App Store 评分")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Divider()
                    .frame(height: 30)
                
                VStack(spacing: 4) {
                    Text("500,000+")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.accentGreen)
                    
                    Text("专注次数")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .padding()
            .background(AppTheme.cardBackground)
            .cornerRadius(16)
            
            // 限时优惠
            HStack(spacing: 8) {
                Image(systemName: "timer")
                    .foregroundColor(.red)
                
                Text("限时优惠：年费立省 40%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                
                Spacer()
                
                Text("仅剩 3 天")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .cornerRadius(8)
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.red.opacity(0.1), Color.orange.opacity(0.1)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    // MARK: - 免费试用横幅
    private var freeTrialBanner: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "gift.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(L("free_trial_7_days"))
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(L("free_trial_description"))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
            }
        }
        .padding()
        .background(
            AppTheme.primaryGradient
        )
        .cornerRadius(16)
    }
    
    // MARK: - 功能列表
    private var featuresSection: some View {
        VStack(spacing: 16) {
            ForEach(PremiumFeatures.allFeatures, id: \.title) { feature in
                HStack(spacing: 12) {
                    Image(systemName: feature.icon)
                        .font(.title2)
                        .foregroundColor(AppTheme.accentBlue)
                        .frame(width: 40)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(feature.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text(feature.description)
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(16)
    }
    
    // MARK: - 价格方案
    private var pricingSection: some View {
        VStack(spacing: 12) {
            Text(L("select_plan"))
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // 月度方案
            PlanCard(
                type: .monthly,
                isSelected: selectedPlan == .monthly,
                action: { selectedPlan = .monthly }
            )
            
            // 年度方案
            PlanCard(
                type: .yearly,
                isSelected: selectedPlan == .yearly,
                action: { selectedPlan = .yearly }
            )
            
            // 终身方案
            PlanCard(
                type: .lifetime,
                isSelected: selectedPlan == .lifetime,
                action: { selectedPlan = .lifetime }
            )
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(16)
    }
    
    // MARK: - 购买按钮
    private var purchaseButton: some View {
        VStack(spacing: 12) {
            // 购买按钮
            Button(action: {
                Task {
                    // 获取选中的产品
                    guard let productID = selectedPlan.productID,
                          let product = subscriptionManager.products.first(where: { $0.id == productID }) else {
                        // 产品未加载时的提示
                        subscriptionManager.purchaseError = "订阅产品未配置，请先在 App Store Connect 创建产品"
                        return
                    }
                    await subscriptionManager.purchase(product)
                }
            }) {
                HStack {
                    if subscriptionManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text(selectedPlan == .lifetime ? L("purchase_lifetime") : L("subscribe_now"))
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.primaryGradient)
                .cornerRadius(16)
            }
            .disabled(subscriptionManager.isLoading)  // 临时移除 products.isEmpty 检查，用于测试 UI
            
            // 错误提示
            if let error = subscriptionManager.purchaseError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            
            // 恢复购买
            Button(action: {
                Task {
                    await subscriptionManager.restorePurchases()
                }
            }) {
                Text(L("restore_purchases"))
                    .font(.subheadline)
                    .foregroundColor(AppTheme.accentBlue)
            }
            .disabled(subscriptionManager.isLoading)
        }
    }
    
    // MARK: - 条款
    private var termsText: some View {
        VStack(spacing: 8) {
            Text(L("subscription_auto_renew"))
                .font(.caption)
                .foregroundColor(AppTheme.textTertiary)
            
            HStack(spacing: 12) {
                Button(L("terms_of_service")) {
                    if let url = URL(string: "https://djfireny-netizen.github.io/focusflow-support/TERMS_OF_SERVICE.md") {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.caption)
                .foregroundColor(AppTheme.accentBlue)
                
                Text("•")
                    .foregroundColor(AppTheme.textTertiary)
                
                Button(L("privacy_policy")) {
                    if let url = URL(string: "https://djfireny-netizen.github.io/focusflow-support/privacy-en.html") {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.caption)
                .foregroundColor(AppTheme.accentBlue)
            }
        }
    }
}

// MARK: - 方案卡片
struct PlanCard: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    let type: SubscriptionType
    let isSelected: Bool
    let action: () -> Void
    
    var product: Product? {
        guard let productID = type.productID else { return nil }
        return subscriptionManager.products.first { $0.id == productID }
    }
    
    var displayPrice: String {
        guard let product = product else { 
            return type == .monthly ? "$3.99" : type == .yearly ? "$24.99" : "$49.99"
        }
        return product.displayPrice
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(type.displayName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        if let savings = type.savings {
                            Text(savings)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(AppTheme.accentGreen)
                                .cornerRadius(8)
                        }
                    }
                    
                    Text(displayPrice)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.accentBlue)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? AppTheme.accentBlue : AppTheme.textTertiary)
            }
            .padding()
            .background(
                isSelected ?
                AppTheme.accentBlue.opacity(0.1) : AppTheme.backgroundSecondary
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? AppTheme.accentBlue : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .disabled(product == nil && !subscriptionManager.products.isEmpty)
    }
}

#Preview {
    SubscriptionView()
        .environmentObject(SubscriptionManager())
}
