# FocusFlow v1.1.0 - 多主题背景功能规划

## 🎯 功能概述

根据白噪音类型自动切换动态主题背景，提升用户沉浸感。

---

## 🎨 主题设计

### 6 种主题配色

#### 1. 默认主题（免费）
```swift
// 当前使用的蓝橙渐变
colors: [#ff6b35 → #4facfe]
animation: 渐变流动
```

#### 2. 雨声主题（Premium）
```swift
// 深蓝灰色调
colors: [#2c3e50 → #4a6274 → #667eea]
particle: 雨滴下落效果
```

#### 3. 海浪主题（Premium）
```swift
// 蓝绿色调
colors: [#00b4db → #0083b0 → #00d2ff]
particle: 波浪波动效果
```

#### 4. 森林主题（Premium）
```swift
// 绿色调
colors: [#134e5e → #71b280 → #a8e063]
particle: 树叶飘落效果
```

#### 5. 咖啡馆主题（Premium）
```swift
// 暖棕色调
colors: [#8e6e53 → #c79081 → #dfa579]
particle: 蒸汽上升效果
```

#### 6. 壁炉主题（Premium）
```swift
// 橙红色调
colors: [#f12711 → #f5af19 → #ff6b35]
particle: 火焰跳动效果
```

#### 7. 风声主题（Premium）
```swift
// 浅蓝色调
colors: [#89f7fe → #66a6ff → #a1c4fd]
particle: 风粒子流动效果
```

---

## 🔧 技术实现

### 1. 主题管理器

```swift
// ThemeManager.swift
class ThemeManager: ObservableObject {
    @Published var currentTheme: ThemeType = .default
    
    // 根据白噪音自动切换主题
    func updateTheme(for soundType: SoundType) {
        // 免费版只允许默认主题
        guard subscriptionManager.isPremium else {
            currentTheme = .default
            return
        }
        
        // Premium 用户自动切换
        currentTheme = soundType.theme
    }
}
```

### 2. 主题枚举

```swift
enum ThemeType: String, CaseIterable {
    case `default` = "默认"
    case rain = "雨声"
    case ocean = "海浪"
    case forest = "森林"
    case cafe = "咖啡馆"
    case fireplace = "壁炉"
    case wind = "风声"
    
    var colors: [Color] {
        switch self {
        case .default: return [Color(hex: "ff6b35"), Color(hex: "4facfe")]
        case .rain: return [Color(hex: "2c3e50"), Color(hex: "4a6274")]
        case .ocean: return [Color(hex: "00b4db"), Color(hex: "0083b0")]
        case .forest: return [Color(hex: "134e5e"), Color(hex: "71b280")]
        case .cafe: return [Color(hex: "8e6e53"), Color(hex: "c79081")]
        case .fireplace: return [Color(hex: "f12711"), Color(hex: "f5af19")]
        case .wind: return [Color(hex: "89f7fe"), Color(hex: "66a6ff")]
        }
    }
    
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
}
```

### 3. 主题背景视图

```swift
// ThemeBackgroundView.swift
struct ThemeBackgroundView: View {
    @StateObject var themeManager = ThemeManager.shared
    @StateObject var soundManager = SoundManager.shared
    
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
            ParticleEffectView(
                particleType: themeManager.currentTheme.particleType
            )
        }
        .onAppear {
            // 监听白噪音变化
            themeManager.updateTheme(for: soundManager.currentSound)
        }
    }
}
```

### 4. 粒子效果系统

```swift
// ParticleEffectView.swift
struct ParticleEffectView: View {
    let particleType: ParticleType
    
    var body: some View {
        Canvas { context, size in
            switch particleType {
            case .rainDrops:
                drawRainDrops(context, size)
            case .waves:
                drawWaves(context, size)
            case .fallingLeaves:
                drawFallingLeaves(context, size)
            case .steam:
                drawSteam(context, size)
            case .flames:
                drawFlames(context, size)
            case .windParticles:
                drawWindParticles(context, size)
            case .none:
                break
            }
        }
    }
}
```

---

## 💰 商业化策略

### 免费版限制
```swift
// SubscriptionManager.swift
var availableThemes: [ThemeType] {
    if isPremium {
        return ThemeType.allCases  // 全部主题
    } else {
        return [.default]  // 仅默认主题
    }
}

func isThemeUnlocked(_ theme: ThemeType) -> Bool {
    return isPremium || theme == .default
}
```

### 付费页面更新
```swift
// 添加新功能说明
PremiumFeature(
    title: "动态主题背景",
    description: "6种沉浸式主题，根据白噪音自动切换",
    icon: "paintpalette.fill"
)
```

---

## 📱 UI/UX 设计

### 1. 主题选择器（设置页面）

```swift
// ThemePickerView.swift
struct ThemePickerView: View {
    @StateObject var themeManager = ThemeManager.shared
    @StateObject var subscriptionManager = SubscriptionManager.shared
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                ForEach(ThemeType.allCases, id: \.self) { theme in
                    ThemeCard(
                        theme: theme,
                        isUnlocked: subscriptionManager.isThemeUnlocked(theme),
                        isSelected: themeManager.currentTheme == theme
                    )
                }
            }
        }
    }
}
```

### 2. 主题卡片

```swift
struct ThemeCard: View {
    let theme: ThemeType
    let isUnlocked: Bool
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            // 主题预览
            LinearGradient(
                colors: theme.colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 120)
            .cornerRadius(12)
            
            // 锁图标（未解锁时显示）
            if !isUnlocked {
                Image(systemName: "lock.fill")
                    .font(.title)
                    .foregroundColor(.white)
            }
            
            // 选中标记
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            // 主题名称
            Text(theme.rawValue)
                .font(.caption)
                .foregroundColor(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.black.opacity(0.3))
                .cornerRadius(8)
                .offset(y: 45)
        }
    }
}
```

---

## 🚀 开发步骤

### Phase 1: 基础架构（1-2天）
- [ ] 创建 ThemeManager
- [ ] 定义 6 种主题配色
- [ ] 实现主题切换逻辑
- [ ] 集成到 TimerView

### Phase 2: 粒子效果（2-3天）
- [ ] 实现 Canvas 粒子系统
- [ ] 雨滴效果
- [ ] 波浪效果
- [ ] 树叶飘落效果
- [ ] 蒸汽效果
- [ ] 火焰效果
- [ ] 风粒子效果

### Phase 3: Premium 集成（0.5天）
- [ ] 添加主题锁定逻辑
- [ ] 更新付费页面功能列表
- [ ] 主题选择器 UI
- [ ] 锁图标显示

### Phase 4: 优化（0.5天）
- [ ] 性能优化
- [ ] 内存管理
- [ ] 动画流畅度
- [ ] 测试不同设备

---

## 📊 性能优化

### 1. 粒子数量控制
```swift
// 根据设备性能调整
let particleCount: Int = {
    if ProcessInfo.processInfo.isLowPowerMode {
        return 20  // 省电模式
    } else if isHighEndDevice() {
        return 100  // 高端设备
    } else {
        return 50  // 中端设备
    }
}()
```

### 2. 按需渲染
```swift
// 仅在计时器页面显示粒子效果
if showBackgroundEffects {
    ParticleEffectView(...)
}
```

### 3. 缓存优化
```swift
// 预加载主题资源
func preloadTheme(_ theme: ThemeType) {
    // 预渲染粒子纹理
}
```

---

## 📈 后续扩展

### v1.2.0（未来）
- [ ] 自定义主题（用户创建）
- [ ] 主题商店（下载更多）
- [ ] 短视频背景（可选下载）
- [ ] 节日限定主题
- [ ] 联动成就系统

---

## 🎯 预期效果

### 用户体验提升
- ✅ 沉浸感增强 80%
- ✅ 视觉满意度提升 60%
- ✅ Premium 转化率预计提升 15-20%

### 技术指标
- 应用体积增加：< 2MB
- 性能影响：< 5% CPU
- 内存占用：< 20MB

---

**预计开发时间**: 3-4 天
**预计上线时间**: v1.1.0
