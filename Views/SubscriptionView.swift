import SwiftUI

// MARK: - 订阅页面
struct SubscriptionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var selectedPlan: SubscriptionType = .yearly
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundPrimary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // 头部
                        headerSection
                        
                        // 免费试用提示
                        if !subscriptionManager.isFreeTrial {
                            freeTrialBanner
                        }
                        
                        // 功能列表
                        featuresSection
                        
                        // 价格方案
                        pricingSection
                        
                        // 购买按钮
                        purchaseButton
                        
                        // 恢复购买
                        restoreButton
                        
                        // 条款
                        termsText
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("升级 Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "667eea"))
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
    
    // MARK: - 免费试用横幅
    private var freeTrialBanner: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "gift.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("🎉 限时免费试用 7 天")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("无需付费，立即体验所有高级功能")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                startPoint: .leading,
                endPoint: .trailing
            )
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
                        .foregroundColor(Color(hex: "667eea"))
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
            Text("选择方案")
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
            if !subscriptionManager.isFreeTrial {
                // 免费试用按钮
                Button(action: {
                    subscriptionManager.startFreeTrial()
                }) {
                    HStack {
                        Image(systemName: "gift.fill")
                        Text("开始 7 天免费试用")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: Color(hex: "667eea").opacity(0.4), radius: 10, y: 5)
                }
                
                Text("试用结束后，将自动以 $4.99/月 续费，可随时取消")
                    .font(.caption)
                    .foregroundColor(AppTheme.textTertiary)
                    .multilineTextAlignment(.center)
            } else {
                // 已试用，显示正常购买
                Button(action: {
                    Task {
                        await subscriptionManager.purchaseSubscription(selectedPlan)
                    }
                }) {
                    HStack {
                        if subscriptionManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("立即订阅")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.primaryGradient)
                    .cornerRadius(16)
                }
                .disabled(subscriptionManager.isLoading)
            }
        }
    }
    
    // MARK: - 恢复购买
    private var restoreButton: some View {
        Button(action: {
            Task {
                await subscriptionManager.restorePurchases()
            }
        }) {
            Text("恢复购买")
                .font(.subheadline)
                .foregroundColor(Color(hex: "667eea"))
        }
    }
    
    // MARK: - 条款
    private var termsText: some View {
        VStack(spacing: 8) {
            Text("订阅将自动续期,可随时在设置中取消")
                .font(.caption)
                .foregroundColor(AppTheme.textTertiary)
            
            HStack(spacing: 12) {
                Button("使用条款") {
                    // 打开条款
                }
                .font(.caption)
                .foregroundColor(Color(hex: "667eea"))
                
                Text("•")
                    .foregroundColor(AppTheme.textTertiary)
                
                Button("隐私政策") {
                    // 打开隐私政策
                }
                .font(.caption)
                .foregroundColor(Color(hex: "667eea"))
            }
        }
    }
}

// MARK: - 方案卡片
struct PlanCard: View {
    let type: SubscriptionType
    let isSelected: Bool
    let action: () -> Void
    
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
                    
                    Text(type.price)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "667eea"))
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? Color(hex: "667eea") : AppTheme.textTertiary)
            }
            .padding()
            .background(
                isSelected ?
                Color(hex: "667eea").opacity(0.1) : AppTheme.backgroundSecondary
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color(hex: "667eea") : Color.clear,
                        lineWidth: 2
                    )
            )
        }
    }
}

#Preview {
    SubscriptionView()
        .environmentObject(SubscriptionManager())
}
