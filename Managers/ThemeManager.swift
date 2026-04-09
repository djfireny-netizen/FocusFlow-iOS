import SwiftUI

// MARK: - 主题类型
enum ThemeType: String, CaseIterable, Identifiable {
    case `default` = "默认"
    case rain = "雨声"
    case ocean = "海浪"
    case forest = "森林"
    case cafe = "咖啡馆"
    case fireplace = "壁炉"
    case wind = "风声"
    
    var id: String { rawValue }
    
    // 主题渐变颜色
    var colors: [Color] {
        switch self {
        case .default:
            // 原来的深色主题
            return [Color(hex: "1a1a2e"), Color(hex: "16213e"), Color(hex: "0f3460")]
        case .rain:
            return [Color(hex: "2c3e50"), Color(hex: "4a6274"), Color(hex: "667eea")]
        case .ocean:
            return [Color(hex: "00b4db"), Color(hex: "0083b0"), Color(hex: "00d2ff")]
        case .forest:
            return [Color(hex: "134e5e"), Color(hex: "71b280"), Color(hex: "a8e063")]
        case .cafe:
            return [Color(hex: "8e6e53"), Color(hex: "c79081"), Color(hex: "dfa579")]
        case .fireplace:
            return [Color(hex: "f12711"), Color(hex: "f5af19"), Color(hex: "ff6b35")]
        case .wind:
            return [Color(hex: "89f7fe"), Color(hex: "66a6ff"), Color(hex: "a1c4fd")]
        }
    }
    
    // 粒子效果类型
    var particleType: ParticleType {
        switch self {
        case .rain: return .rainDrops
        case .ocean: return .waves
        case .forest: return .fallingLeaves
        case .cafe: return .steam
        case .fireplace: return .flames
        case .wind: return .windParticles
        default: return .none
        }
    }
    
    // 图标
    var icon: String {
        switch self {
        case .default: return "sparkles"
        case .rain: return "cloud.rain"
        case .ocean: return "wave"
        case .forest: return "tree"
        case .cafe: return "cup.and.saucer"
        case .fireplace: return "flame"
        case .wind: return "wind"
        }
    }
}

// MARK: - 粒子类型
enum ParticleType {
    case none
    case rainDrops
    case waves
    case fallingLeaves
    case steam
    case flames
    case windParticles
}

// MARK: - 主题管理器
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: ThemeType = .default
    @Published var autoSwitch: Bool = true  // 自动根据白噪音切换
    
    private init() {
        // 从 UserDefaults 读取
        if let themeString = UserDefaults.standard.string(forKey: "currentTheme"),
           let theme = ThemeType(rawValue: themeString) {
            currentTheme = theme
        }
        
        autoSwitch = UserDefaults.standard.object(forKey: "autoSwitchTheme") as? Bool ?? true
    }
    
    // 保存主题设置
    func saveTheme(_ theme: ThemeType) {
        currentTheme = theme
        UserDefaults.standard.set(theme.rawValue, forKey: "currentTheme")
    }
    
    // 保存自动切换设置
    func saveAutoSwitch(_ enabled: Bool) {
        autoSwitch = enabled
        UserDefaults.standard.set(enabled, forKey: "autoSwitchTheme")
    }
    
    // 根据白噪音自动切换主题
    func updateTheme(for soundType: WhiteNoiseType) {
        guard autoSwitch else { return }
        
        let theme = soundType.theme
        if currentTheme != theme {
            withAnimation(.easeInOut(duration: 1.0)) {
                currentTheme = theme
            }
        }
    }
}

// MARK: - WhiteNoiseType 扩展
extension WhiteNoiseType {
    var theme: ThemeType {
        switch self {
        case .rain: return .rain
        case .ocean: return .ocean
        case .forest: return .forest
        case .cafe: return .cafe
        case .fireplace: return .fireplace
        case .wind: return .wind
        case .none: return .default
        }
    }
}

// MARK: - 主题背景视图
struct ThemeBackgroundView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @EnvironmentObject var soundManager: SoundManager
    
    var body: some View {
        ZStack {
            // 渐变背景
            LinearGradient(
                colors: themeManager.currentTheme.colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .animation(.easeInOut(duration: 1.0), value: themeManager.currentTheme)
            
            // 粒子效果
            if themeManager.currentTheme.particleType != .none {
                ParticleEffectView(
                    particleType: themeManager.currentTheme.particleType
                )
                .opacity(0.3)
            }
        }
        .onChange(of: soundManager.currentSound) { newSound in
            themeManager.updateTheme(for: newSound)
        }
    }
}

// MARK: - 粒子效果视图（简化版）
struct ParticleEffectView: View {
    let particleType: ParticleType
    
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30)) { timeline in
            Canvas { context, size in
                drawParticles(context: context, size: size, time: timeline.date.timeIntervalSinceReferenceDate)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                animationOffset = 1000
            }
        }
    }
    
    private func drawParticles(context: GraphicsContext, size: CGSize, time: TimeInterval) {
        switch particleType {
        case .rainDrops:
            drawRainDrops(context: context, size: size, time: time)
        case .waves:
            drawWaves(context: context, size: size, time: time)
        case .fallingLeaves:
            drawFallingLeaves(context: context, size: size, time: time)
        case .steam:
            drawSteam(context: context, size: size, time: time)
        case .flames:
            drawFlames(context: context, size: size, time: time)
        case .windParticles:
            drawWindParticles(context: context, size: size, time: time)
        case .none:
            break
        }
    }
    
    // 雨滴效果
    private func drawRainDrops(context: GraphicsContext, size: CGSize, time: TimeInterval) {
        let dropCount = 50
        for i in 0..<dropCount {
            let x = CGFloat(i) * size.width / CGFloat(dropCount)
            let speed = 2.0 + Double(i % 5) * 0.3
            let y = (time * speed * 100).truncatingRemainder(dividingBy: size.height + 50) - 25
            
            let dropRect = CGRect(x: x, y: y, width: 1.5, height: 15)
            context.fill(Path(dropRect), with: .color(.white.opacity(0.4)))
        }
    }
    
    // 波浪效果
    private func drawWaves(context: GraphicsContext, size: CGSize, time: TimeInterval) {
        for wave in 0..<3 {
            var path = Path()
            let amplitude: CGFloat = 20 - CGFloat(wave) * 5
            let frequency: CGFloat = 0.02
            let yOffset = size.height * 0.7 + CGFloat(wave) * 30
            
            for x in stride(from: 0, through: size.width, by: 5) {
                let y = yOffset + sin(x * frequency + time * 2 + Double(wave)) * amplitude
                if x == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            
            context.stroke(path, with: .color(.white.opacity(0.2)), lineWidth: 2)
        }
    }
    
    // 树叶飘落效果
    private func drawFallingLeaves(context: GraphicsContext, size: CGSize, time: TimeInterval) {
        let leafCount = 20
        for i in 0..<leafCount {
            let speed = 1.0 + Double(i % 3) * 0.2
            let x = (CGFloat(i) * size.width / CGFloat(leafCount) + time * 30 * cos(time + Double(i))).truncatingRemainder(dividingBy: size.width)
            let y = (time * speed * 80).truncatingRemainder(dividingBy: size.height + 50) - 25
            
            let leafRect = CGRect(x: x, y: y, width: 8, height: 8)
            context.fill(Path(leafRect), with: .color(.green.opacity(0.3)))
        }
    }
    
    // 蒸汽效果
    private func drawSteam(context: GraphicsContext, size: CGSize, time: TimeInterval) {
        let steamCount = 15
        for i in 0..<steamCount {
            let x = size.width / 2 + CGFloat(i - steamCount/2) * 20
            let speed = 0.5 + Double(i % 3) * 0.1
            let y = size.height - (time * speed * 100).truncatingRemainder(dividingBy: size.height)
            let opacity = 0.3 - (y / size.height) * 0.3
            
            let steamCircle = Path(ellipseIn: CGRect(x: x - 10, y: y, width: 20, height: 20))
            context.fill(steamCircle, with: .color(.white.opacity(opacity)))
        }
    }
    
    // 火焰效果
    private func drawFlames(context: GraphicsContext, size: CGSize, time: TimeInterval) {
        let flameCount = 30
        for i in 0..<flameCount {
            let x = size.width / 2 + CGFloat(i - flameCount/2) * 15
            let baseY = size.height * 0.8
            let flicker = sin(time * 5 + Double(i) * 0.5) * 20
            let y = baseY + flicker - CGFloat(i % 5) * 30
            let opacity = 0.4 - CGFloat(i % 5) * 0.08
            
            let flamePath = Path(ellipseIn: CGRect(x: x - 8, y: y, width: 16, height: 24))
            context.fill(flamePath, with: .color(.orange.opacity(opacity)))
        }
    }
    
    // 风粒子效果
    private func drawWindParticles(context: GraphicsContext, size: CGSize, time: TimeInterval) {
        let particleCount = 40
        for i in 0..<particleCount {
            let speed = 2.0 + Double(i % 4) * 0.5
            let x = (time * speed * 100 + CGFloat(i) * 50).truncatingRemainder(dividingBy: size.width + 100) - 50
            let y = CGFloat(i) * size.height / CGFloat(particleCount) + sin(time + Double(i)) * 20
            
            let particleRect = CGRect(x: x, y: y, width: 3, height: 1.5)
            context.fill(Path(particleRect), with: .color(.white.opacity(0.3)))
        }
    }
}
