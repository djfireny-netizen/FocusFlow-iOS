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
            // 主背景渐变
            LinearGradient(
                colors: [
                    Color(hex: "667eea"),
                    Color(hex: "764ba2"),
                    Color(hex: "f093fb")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 装饰圆形
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 300, height: 300)
                .offset(x: -100, y: -200)
                .blur(radius: 40)
            
            Circle()
                .fill(Color.yellow.opacity(0.15))
                .frame(width: 200, height: 200)
                .offset(x: 150, y: 100)
                .blur(radius: 30)
            
            VStack(spacing: 28) {
                // 品牌头部
                HStack(spacing: 12) {
                    // Logo 圆圈
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.25))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "timer")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("FocusFlow")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("FocusFlow Go")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    // 日期
                    Text(Date(), style: .date)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(12)
                }
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                // 核心数据 - 大数字展示
                VStack(spacing: 12) {
                    Text("今日专注")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .fontWeight(.medium)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(todayHours)")
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                        
                        Text("小时")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("\(todayMinutes)")
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                        
                        Text("分钟")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .foregroundColor(.white)
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
                
                // 详细统计网格
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    // 今日番茄钟
                    StatCardModern(
                        icon: "checkmark.circle.fill",
                        iconColor: .green,
                        value: "\(todaySessions)",
                        label: "今日番茄钟",
                        unit: "个"
                    )
                    
                    // 总专注次数
                    StatCardModern(
                        icon: "chart.bar.fill",
                        iconColor: .blue,
                        value: "\(totalSessions)",
                        label: "总专注次数",
                        unit: "次"
                    )
                    
                    // 连续专注
                    StatCardModern(
                        icon: "flame.fill",
                        iconColor: .orange,
                        value: "\(currentStreak)",
                        label: "连续专注",
                        unit: "天"
                    )
                    
                    // 总专注时长（估算）
                    StatCardModern(
                        icon: "clock.fill",
                        iconColor: .purple,
                        value: "\(totalSessions * 25 / 60)",
                        label: "总专注时长",
                        unit: "小时"
                    )
                }
                
                Spacer()
                
                // 底部品牌区
                VStack(spacing: 12) {
                    Divider()
                        .background(Color.white.opacity(0.3))
                    
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.yellow)
                        
                        Text("让专注成为一种习惯")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Image(systemName: "sparkles")
                            .foregroundColor(.yellow)
                    }
                    .foregroundColor(.white)
                    
                    Text("#FocusFlow #专注力 #番茄钟 #效率工具")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(32)
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
                colors: [
                    Color(hex: "f093fb"),
                    Color(hex: "f5576c"),
                    Color(hex: "ff6b6b")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 装饰元素
            Circle()
                .fill(Color.yellow.opacity(0.2))
                .frame(width: 250, height: 250)
                .offset(x: 120, y: -150)
                .blur(radius: 50)
            
            VStack(spacing: 32) {
                // 头部
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.yellow)
                        .font(.title2)
                    
                    Text("成就解锁")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.yellow)
                        .font(.title2)
                }
                .foregroundColor(.white)
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                // 成就图标
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 140, height: 140)
                    
                    Circle()
                        .stroke(Color.white.opacity(0.4), lineWidth: 3)
                        .frame(width: 140, height: 140)
                    
                    Image(systemName: icon)
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                }
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                
                // 成就信息
                VStack(spacing: 16) {
                    Text(title)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(description)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.95))
                        .padding(.horizontal)
                }
                .foregroundColor(.white)
                .padding(.vertical, 24)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
                
                Spacer()
                
                // 底部
                VStack(spacing: 12) {
                    Divider()
                        .background(Color.white.opacity(0.3))
                    
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        
                        Text("通过 FocusFlow 达成")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    
                    Text("#FocusFlow #成就达成 #专注力")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(32)
        }
    }
}

// MARK: - 目标达成分享卡片
struct GoalShareCardView: View {
    let goalMinutes: Int
    let completedMinutes: Int
    
    var progress: Double {
        min(1.0, Double(completedMinutes) / Double(goalMinutes))
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "4facfe"),
                    Color(hex: "00f2fe"),
                    Color(hex: "43e97b")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 装饰元素
            Circle()
                .fill(Color.white.opacity(0.15))
                .frame(width: 280, height: 280)
                .offset(x: -120, y: -100)
                .blur(radius: 40)
            
            VStack(spacing: 32) {
                // 头部
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                    
                    Text("目标达成")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Image(systemName: "target")
                        .font(.title2)
                }
                .foregroundColor(.white)
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                // 进度环
                ZStack {
                    // 外圈
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 12)
                        .frame(width: 180, height: 180)
                    
                    // 进度
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [.white, Color(hex: "f5f7fa")],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 180, height: 180)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: Color.white.opacity(0.5), radius: 8, x: 0, y: 0)
                    
                    // 中间文字
                    VStack(spacing: 4) {
                        Text("\(completedMinutes)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                        
                        Text("/ \(goalMinutes)")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("分钟")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .foregroundColor(.white)
                }
                
                // 进度百分比
                Text("\(Int(progress * 100))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                
                // 完成信息
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.white)
                        
                        Text("恭喜完成今日目标!")
                            .font(.headline)
                    }
                    
                    Text("保持专注,继续前行!")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
                
                Spacer()
                
                // 底部
                VStack(spacing: 12) {
                    Divider()
                        .background(Color.white.opacity(0.3))
                    
                    HStack(spacing: 8) {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.yellow)
                        
                        Text("FocusFlow Go")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.yellow)
                    }
                    .foregroundColor(.white)
                    
                    Text("#FocusFlow #目标达成 #自律")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(32)
        }
    }
}

// MARK: - 现代统计卡片
struct StatCardModern: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String
    let unit: String
    
    var body: some View {
        VStack(spacing: 12) {
            // 图标
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
            }
            
            // 数值
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .foregroundColor(.white)
            
            // 标签
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
        )
    }
}

// MARK: - 统计项（保留兼容）
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
