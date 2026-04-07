import SwiftUI
import UIKit

// MARK: - 分享管理器
class ShareManager {
    static let shared = ShareManager()
    
    // MARK: - 分享统计数据 (图片)
    func shareStats(
        todayFocusTime: TimeInterval,
        todaySessions: Int,
        totalSessions: Int,
        currentStreak: Int
    ) {
        let hours = Int(todayFocusTime) / 3600
        let minutes = (Int(todayFocusTime) % 3600) / 60
        
        let view = StatsShareCardView(
            todayHours: hours,
            todayMinutes: minutes,
            todaySessions: todaySessions,
            totalSessions: totalSessions,
            currentStreak: currentStreak
        )
        
        generateAndShareImage(from: view, size: CGSize(width: 800, height: 1000))
    }
    
    // MARK: - 分享成就 (图片)
    func shareAchievement(
        title: String,
        description: String,
        icon: String
    ) {
        let view = AchievementShareCardView(
            title: title,
            description: description,
            icon: icon
        )
        
        generateAndShareImage(from: view, size: CGSize(width: 800, height: 600))
    }
    
    // MARK: - 分享目标达成 (图片)
    func shareGoalAchieved(
        goalMinutes: Int,
        completedMinutes: Int
    ) {
        let view = GoalShareCardView(
            goalMinutes: goalMinutes,
            completedMinutes: completedMinutes
        )
        
        generateAndShareImage(from: view, size: CGSize(width: 800, height: 800))
    }
    
    // MARK: - 生成并分享图片
    private func generateAndShareImage(from view: some View, size: CGSize) {
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(origin: .zero, size: size)
        
        // 渲染为图片
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { _ in
            hostingController.view.drawHierarchy(in: hostingController.view.bounds, afterScreenUpdates: true)
        }
        
        // 分享图片
        shareImage(image)
    }
    
    // MARK: - 分享图片
    private func shareImage(_ image: UIImage) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return
        }
        
        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        
        // iPad 支持
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = window
            popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        rootViewController.present(activityVC, animated: true)
    }
}

// MARK: - 统计分享卡片
struct StatsShareCardView: View {
    let todayHours: Int
    let todayMinutes: Int
    let todaySessions: Int
    let totalSessions: Int
    let currentStreak: Int
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 24) {
                // 标题
                HStack {
                    Image(systemName: "timer")
                        .font(.title2)
                    Text("FocusFlow")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                // 今日专注
                VStack(spacing: 16) {
                    Text("今日专注")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                    
                    HStack(spacing: 30) {
                        StatItem(
                            icon: "clock.fill",
                            value: "\(todayHours)小时\(todayMinutes)分钟",
                            label: "专注时长"
                        )
                        
                        StatItem(
                            icon: "checkmark.circle.fill",
                            value: "\(todaySessions)次",
                            label: "完成番茄钟"
                        )
                    }
                }
                .padding()
                .background(Color.white.opacity(0.15))
                .cornerRadius(16)
                
                // 累计成就
                VStack(spacing: 16) {
                    Text("累计成就")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                    
                    HStack(spacing: 30) {
                        StatItem(
                            icon: "chart.bar.fill",
                            value: "\(totalSessions)次",
                            label: "总专注次数"
                        )
                        
                        StatItem(
                            icon: "flame.fill",
                            value: "\(currentStreak)天",
                            label: "连续专注"
                        )
                    }
                }
                .padding()
                .background(Color.white.opacity(0.15))
                .cornerRadius(16)
                
                Spacer()
                
                // 底部标语
                VStack(spacing: 8) {
                    Text("让专注成为一种习惯! 💪")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("#FocusFlow #专注力 #番茄钟")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(30)
        }
    }
}

// MARK: - 成就分享卡片
struct AchievementShareCardView: View {
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 30) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)
                
                Text("🎉 成就解锁!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                HStack(spacing: 20) {
                    Image(systemName: icon)
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(description)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding()
                .background(Color.white.opacity(0.15))
                .cornerRadius(16)
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text("通过 FocusFlow 达成! 🚀")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("#FocusFlow #成就达成")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(30)
        }
    }
}

// MARK: - 目标达成分享卡片
struct GoalShareCardView: View {
    let goalMinutes: Int
    let completedMinutes: Int
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "4facfe"), Color(hex: "00f2fe")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 30) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                
                Text("🎯 目标达成!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                VStack(spacing: 20) {
                    // 进度显示
                    HStack {
                        Text("\(completedMinutes)")
                            .font(.system(size: 72, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("/ \(goalMinutes) 分钟")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // 进度条
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 12)
                                .cornerRadius(6)
                            
                            Rectangle()
                                .fill(Color.white)
                                .frame(
                                    width: geometry.size.width * min(1.0, Double(completedMinutes) / Double(goalMinutes)),
                                    height: 12
                                )
                                .cornerRadius(6)
                        }
                    }
                    .frame(height: 12)
                    
                    Text("✅ 已完成!")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.white.opacity(0.15))
                .cornerRadius(16)
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text("保持专注,继续前行! 💪")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("#FocusFlow #目标达成")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(30)
        }
    }
}

// MARK: - 统计项
struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .opacity(0.8)
        }
        .foregroundColor(.white)
    }
}
