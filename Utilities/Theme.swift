import SwiftUI
import UIKit

// MARK: - 触觉反馈工具
struct HapticFeedback {
    static func play(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

// MARK: - 颜色主题
struct AppTheme {
    // 主要渐变色 - 蓝橙渐变（参考设计风格）
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "4facfe"), Color(hex: "ff6b35")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // 专注状态渐变 - 暖橙色
    static let focusGradient = LinearGradient(
        colors: [Color(hex: "ff6b35"), Color(hex: "ff8c42")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // 休息状态渐变 - 冷蓝色
    static let breakGradient = LinearGradient(
        colors: [Color(hex: "4facfe"), Color(hex: "00f2fe")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // 背景色 - 深色主题
    static let backgroundPrimary = Color(hex: "0a0a0a")
    static let backgroundSecondary = Color(hex: "141414")
    static let cardBackground = Color(hex: "1a1a1a").opacity(0.8)
    static let cardBackgroundHover = Color(hex: "252525")
    
    // 强调色 - 蓝橙配色
    static let accentBlue = Color(hex: "4facfe")
    static let accentOrange = Color(hex: "ff6b35")
    static let accentPurple = Color(hex: "a18cd1")
    static let accentGreen = Color(hex: "00d9a6")
    static let accentPink = Color(hex: "ff6b9d")
    static let accentYellow = Color(hex: "ffd93d")
    
    // 文字颜色
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "a0a0a0")
    static let textTertiary = Color(hex: "666666")
    
    // 状态色
    static let success = Color(hex: "00d9a6")
    static let warning = Color(hex: "ffc107")
    static let error = Color(hex: "ff6b6b")
    
    // 阴影
    static let shadowColor = Color.black.opacity(0.5)
    static let glowColor = Color(hex: "4facfe").opacity(0.3)
    
    // 渐变球体
    static func gradientOrb(size: CGFloat) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [Color(hex: "ff6b35"), Color(hex: "4facfe"), Color.clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: size / 2
                )
            )
            .frame(width: size, height: size)
            .blur(radius: 60)
            .opacity(0.6)
    }
}

// MARK: - 动画主题
struct AnimationTheme {
    static let spring = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let easeInOut = Animation.easeInOut(duration: 0.3)
    static let linear = Animation.linear(duration: 0.1)
}

// MARK: - 布局主题
struct LayoutTheme {
    static let cornerRadius: CGFloat = 16
    static let cornerRadiusSmall: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 24
    static let padding: CGFloat = 20
    static let spacing: CGFloat = 16
    static let spacingSmall: CGFloat = 8
    static let spacingLarge: CGFloat = 24
}

// MARK: - 颜色扩展
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
