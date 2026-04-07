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
    // 主要渐变色 - 更柔和的紫蓝渐变
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // 专注状态渐变
    static let focusGradient = LinearGradient(
        colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // 休息状态渐变
    static let breakGradient = LinearGradient(
        colors: [Color(hex: "4facfe"), Color(hex: "00f2fe")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // 背景色 - 更温暖的深色
    static let backgroundPrimary = Color(hex: "0d0d1a")
    static let backgroundSecondary = Color(hex: "1a1a2e")
    static let cardBackground = Color(hex: "1e1e3f")
    static let cardBackgroundHover = Color(hex: "252550")
    
    // 强调色
    static let accentGreen = Color(hex: "00d9a6")
    static let accentBlue = Color(hex: "4facfe")
    static let accentPurple = Color(hex: "a18cd1")
    static let accentOrange = Color(hex: "fbc2eb")
    static let accentPink = Color(hex: "ff6b9d")
    static let accentYellow = Color(hex: "ffd93d")
    
    // 文字颜色
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "b8b8d1")
    static let textTertiary = Color(hex: "6b6b8d")
    
    // 状态色
    static let success = Color(hex: "00d9a6")
    static let warning = Color(hex: "ffc107")
    static let error = Color(hex: "ff6b6b")
    
    // 阴影
    static let shadowColor = Color.black.opacity(0.3)
    static let glowColor = Color(hex: "667eea").opacity(0.3)
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
