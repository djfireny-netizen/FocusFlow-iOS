# FocusFlow - 专注力计时器 🍅

一个精美的番茄钟专注力应用,帮助用户提高工作和学习效率。

## 📱 应用截图

精美的深色主题 UI,流畅的动画效果,让专注成为一种享受。

## ✨ 核心功能

### 免费版
- ✅ 标准番茄钟(25分钟专注 + 5分钟休息)
- ✅ 基础专注记录
- ✅ 今日专注统计
- ✅ 简单成就系统

### Premium 版 (订阅解锁)
- 🎯 自定义专注时长
- 📊 详细数据分析和趋势图表
- 🎵 6种高品质白噪音
- 🏷️ 专注分类标签
- ☁️ iCloud 数据同步
- 📱 桌面小组件
- 🔥 连续天数统计

## 🚀 快速开始

### 系统要求
- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

### 构建项目

#### 方法一: 使用 Xcode (推荐)
1. 打开 `FocusFlow.xcodeproj`
2. 选择目标设备(模拟器或真机)
3. 点击运行按钮 (⌘R)

#### 方法二: 使用命令行
```bash
cd FocusFlow
./build.sh
```

### 项目结构
```
FocusFlow/
├── FocusFlowApp.swift          # 应用入口
├── Models/
│   └── FocusData.swift         # 数据模型
├── Managers/
│   ├── TimerManager.swift      # 计时器管理
│   ├── StatsManager.swift      # 统计管理
│   ├── SoundManager.swift      # 音频管理
│   └── SubscriptionManager.swift # 订阅管理
├── Views/
│   ├── ContentView.swift       # 主界面
│   ├── TimerView.swift         # 计时器页面
│   ├── StatsView.swift         # 统计页面
│   ├── AchievementsView.swift  # 成就页面
│   ├── SettingsView.swift      # 设置页面
│   ├── SubscriptionView.swift  # 订阅页面
│   └── SoundPickerView.swift   # 声音选择器
├── Utilities/
│   ├── AppConstants.swift      # 常量定义
│   └── Theme.swift             # 主题配色
└── Assets.xcassets/            # 资源文件
```

## 🎨 UI 设计

- **主题**: 深色渐变风格
- **主色**: 紫色渐变 (#667eea → #764ba2)
- **字体**: 系统字体 + 等宽数字
- **动画**: 流畅的线性进度动画

## 📋 待办事项

- [ ] 添加真实的白噪音音频文件
- [ ] 集成 StoreKit 2 真实支付
- [ ] 添加桌面小组件
- [ ] 实现 iCloud 同步
- [ ] 添加更多成就
- [ ] 支持 iPad 分屏
- [ ] Apple Watch 版本
- [ ] 多语言支持

## 🛠 开发说明

### 添加白噪音音频
将 MP3 文件添加到项目:
```
rain.mp3
ocean.mp3
forest.mp3
cafe.mp3
fireplace.mp3
wind.mp3
```

### 配置应用图标
替换 `Assets.xcassets/AppIcon.appiconset/AppIcon.png` (1024x1024)

### 配置订阅产品
在 App Store Connect 中创建订阅产品:
- `com.focusflow.premium.monthly`
- `com.focusflow.premium.yearly`
- `com.focusflow.premium.lifetime`

## 📄 许可证

MIT License

## 👨‍💻 开发者

FocusFlow Team

---

**准备好了吗?开始专注吧!** 🚀
