# Watch 应用配置指南

## ✅ 已完成的代码

所有 Watch 应用的代码文件已经创建并提交到 GitHub：

### iPhone 端（已完成）
- ✅ `Managers/WatchSyncData.swift` - 同步数据模型
- ✅ `Managers/iPhoneConnectivityManager.swift` - iPhone 通信管理器
- ✅ `FocusFlowApp.swift` - 已集成 Watch 通信

### Watch 端（代码已创建，需要添加 Target）
以下文件已在项目中创建，但需要在 Xcode 中添加 Watch Target 后才能被识别：

1. `WatchFocusFlow/FocusFlowWatchApp.swift` - Watch 应用入口
2. `WatchFocusFlow/Managers/WatchConnectivityManager.swift` - Watch 通信管理器
3. `WatchFocusFlow/Managers/WatchTimerManager.swift` - Watch 计时器管理器
4. `WatchFocusFlow/Views/ContentView.swift` - 主界面
5. `WatchFocusFlow/Views/TimerView.swift` - 计时器界面
6. `WatchFocusFlow/Views/SoundPickerView.swift` - 白噪音选择
7. `WatchFocusFlow/Views/StatsView.swift` - 数据统计
8. `WatchFocusFlow/Views/SettingsView.swift` - 设置页面
9. `WatchFocusFlow/Complication/ComplicationController.swift` - 复杂功能

---

## 🔧 明天需要做的操作（约 5 分钟）

### 步骤 1：在 Xcode 中添加 Watch Target

1. **打开 Xcode**
   - 打开 `/Users/fireny/Desktop/Qoder/FocusFlow/FocusFlow.xcodeproj`

2. **添加 Target**
   - 点击菜单栏：**File** → **New** → **Target**
   - 选择 **watchOS** → **Watch App**
   - 点击 **Next**

3. **配置 Target**
   - **Product Name**: `WatchFocusFlow`
   - **Team**: 选择你的开发团队
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **勾选**: 
     - ✅ Include Configuration Entitlement
     - ✅ Include Live Activities（如果需要）
   - 点击 **Finish**

4. **确认添加**
   - 如果弹出 "Activate Scheme?" 对话框，点击 **Activate**
   - 现在项目导航中应该能看到 `WatchFocusFlow` 文件夹

### 步骤 2：配置 Entitlements

1. **选择 WatchFocusFlow Target**
   - 点击项目导航中的 `WatchFocusFlow`

2. **添加 Capabilities**
   - 点击 **Signing & Capabilities** 标签
   - 点击 **+ Capability**
   - 添加以下 Capabilities：
     - ✅ **Background Modes**
       - 勾选：Background fetch
       - 勾选：Remote notifications
     - ✅ **HealthKit**（如果需要健康数据同步）

3. **配置 App Groups**（用于数据共享）
   - 点击 **+ Capability**
   - 选择 **App Groups**
   - 添加 Group: `group.com.focusflow.watch`

### 步骤 3：验证配置

1. **检查文件是否被识别**
   - 在 Xcode 项目导航中展开 `WatchFocusFlow`
   - 确认所有 `.swift` 文件都有实心图标（不是空心）
   - 如果有空心图标，右键文件 → Get Info → 勾选 Target Membership

2. **编译测试**
   - 选择设备：**Watch Series 9 (45mm)** 或类似
   - 按 **⌘ + B** 编译
   - 应该能成功编译

3. **运行测试**
   - 按 **⌘ + R** 运行
   - 会在 Watch 模拟器中启动应用

---

## 📱 测试 Watch 应用

### 测试项清单

1. **基础功能**
   - [ ] Watch 应用能够启动
   - [ ] Tab 导航正常（计时器、白噪音、统计、设置）
   - [ ] UI 显示正确

2. **通信测试**
   - [ ] iPhone 启动计时器，Watch 实时显示
   - [ ] Watch 点击开始，iPhone 同步启动
   - [ ] 暂停/恢复/停止双向同步

3. **复杂功能**
   - [ ] 在表盘上添加 FocusFlow 复杂功能
   - [ ] 显示当前计时状态
   - [ ] 倒计时更新正常

---

## 🐛 常见问题

### 问题 1：编译错误 "No such module 'WatchConnectivity'"
**解决**：
- 确保 Watch Target 已正确添加
- 检查 Target Membership（文件右侧面板）

### 问题 2：Watch 模拟器无法启动
**解决**：
- 确保已安装 watchOS Simulator
- Xcode → Settings → Platforms → 下载 watchOS

### 问题 3：通信不工作
**解决**：
- 确保 iPhone 和 Watch 都运行了应用
- 检查控制台日志是否有错误
- 确认 `WCSession.isSupported()` 返回 true

---

## 📞 需要帮助？

如果在配置过程中遇到问题：
1. 查看 Xcode 控制台的错误信息
2. 检查 GitHub Issues
3. 参考 Apple 官方文档：[Watch Connectivity](https://developer.apple.com/documentation/watchconnectivity)

---

## 🎉 完成后的效果

配置完成后，你将拥有：
- ✅ 完整的 Apple Watch 独立应用
- ✅ iPhone ↔ Watch 实时双向同步
- ✅ 专注计时器远程控制
- ✅ 白噪音播放控制
- ✅ 数据统计查看
- ✅ 表盘复杂功能支持

---

**预计配置时间**: 5-10 分钟

**祝你配置顺利！** 🚀
