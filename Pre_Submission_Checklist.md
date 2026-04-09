# FocusFlow - 上架前检查清单

## ✅ 已完成项

### 代码和功能
- [x] 所有页面 UI 统一（深色主题 + 蓝橙渐变）
- [x] 付费页面本地化完整（中英文）
- [x] 设置页面本地化完整
- [x] 灵动岛和实时活动 UI 优化
- [x] 桌面小组件实现
- [x] Apple 健康集成
- [x] 成就系统
- [x] 白噪音播放
- [x] 通知系统
- [x] 本地化函数修复（static let → static var）
- [x] 本地化字典去重

### 资源文件
- [x] 应用图标（16个尺寸，已优化）
- [x] Info.plist 配置完整
- [x] Entitlements 配置完整
- [x] 隐私政策和服务条款链接有效

### 本地化
- [x] 中文本地化完整
- [x] 英文本地化完整
- [x] 付费页面所有文本已本地化
- [x] 权限描述已英文（符合审核要求）

---

## ⚠️ 需要在 Xcode 中手动配置

### 1. Capabilities 配置

#### 主 App Target (FocusFlow)
1. 打开 Xcode → 选择 FocusFlow target
2. 点击 "Signing & Capabilities"
3. 点击 "+ Capability"，添加以下：

**App Groups**
- 点击 + App Groups
- 添加: `group.com.fireny.focusflow2026`

**确认已有**:
- ✅ HealthKit
- ✅ Background Modes (Audio, Background fetch)
- ✅ Live Activities (已在 Info.plist 中配置)

#### Widget Extension Target (FocusWidget)
1. 选择 FocusWidgetExtension target
2. 添加 App Groups capability
3. 添加: `group.com.fireny.focusflow2026`

#### Live Activity Extension Target (FocusFlowLiveActivity)
1. 选择 FocusFlowLiveActivityExtension target
2. 确认版本号与主 App 一致 (1.0.0)

---

## 📸 需要准备的材料

### 截图（必须）

#### iPhone 6.5" 截图 (1284 x 2778)
使用 iPhone 14 Pro Max 或 iPhone 15 Pro Max 模拟器截取：

1. **主计时器页面**
   - 显示番茄钟运行中
   - 包含白噪音选择器
   - 显示进度环

2. **统计页面**
   - 显示周/月趋势图表
   - 显示分类统计
   - 数据丰富（至少有几个番茄钟记录）

3. **成就页面**
   - 显示已解锁和未解锁成就
   - 至少解锁 3-5 个成就

4. **设置页面**
   - 显示所有设置选项
   - 包含 HealthKit、通知等

5. **付费页面**
   - 显示三个订阅方案
   - 显示功能列表

#### iPhone 5.5" 截图 (1242 x 2208)
使用 iPhone 8 Plus 模拟器截取相同 5 个页面

#### iPad 12.9" 截图 (2048 x 2732)
使用 iPad Pro 12.9" (6th generation) 模拟器截取至少 1 张

### 截图技巧
1. 使用模拟器 (⌘ + R 运行)
2. 按 ⌘ + S 截图
3. 或使用 Xcode 菜单: Window → Devices and Simulators → 截图
4. 去除状态栏（可选，但推荐）

### 截图顺序建议
1. 主计时器（核心功能）
2. 统计图表（数据价值）
3. 成就系统（游戏化）
4. 设置页面（功能丰富）
5. 付费页面（转化）

---

## 💰 App Store Connect 配置

### 创建订阅产品

在 App Store Connect → 我的 App → FocusFlow → 订阅

#### 1. 创建订阅群组
- 群组名称: FocusFlow Premium
- 群组参考名称: FocusFlow Premium Subscription

#### 2. 创建订阅产品

**月度订阅**
- 参考名称: FocusFlow Monthly
- 产品 ID: `com.fireny.focusflow2026.monthly`
- 订阅时长: 1 个月
- 价格: 
  - 中国区: ¥18.00
  - 美国: $2.99
  - 其他地区: 按 Apple 定价矩阵
- 本地化:
  - 中文: 月度订阅
  - 英文: Monthly Subscription
  - 描述: 每月自动续期，随时取消

**年度订阅**
- 参考名称: FocusFlow Yearly
- 产品 ID: `com.fireny.focusflow2026.yearly`
- 订阅时长: 1 年
- 价格:
  - 中国区: ¥128.00
  - 美国: $19.99
- 免费试用: 7 天
- 本地化:
  - 中文: 年度订阅（省50%）
  - 英文: Yearly Subscription (Save 50%)

**终身买断**（注意：这不是订阅，是一次性购买）
- 参考名称: FocusFlow Lifetime
- 产品 ID: `com.fireny.focusflow2026.lifetime`
- 类型: 非消耗型 App 内购买
- 价格:
  - 中国区: ¥328.00
  - 美国: $49.99

---

## 🚀 构建和上传流程

### 步骤 1: 配置签名

1. Xcode → 选择 FocusFlow target
2. Signing & Capabilities
3. Team: 选择你的开发者账号
4. Bundle Identifier: com.fireny.focusflow2026
5. 勾选 "Automatically manage signing"

### 步骤 2: Archive

1. 选择设备: "Any iOS Device (arm64)"
2. 菜单: Product → Archive
3. 等待构建完成

### 步骤 3: 上传到 App Store Connect

1. Archives 窗口自动打开
2. 选择刚构建的版本
3. 点击 "Distribute App"
4. 选择 "App Store Connect"
5. 选择 "Upload"
6. 保持默认选项，点击 Upload

### 步骤 4: 提交审核

1. 登录 App Store Connect
2. 选择 FocusFlow
3. 点击 "iOS App"
4. 选择构建版本
5. 填写:
   - 版本说明
   - 审核备注（见下方模板）
   - 联系信息
6. 提交审核

---

## 📋 审核备注模板

```
尊敬审核团队：

FocusFlow 是一款提升专注力的工具类应用。

【免费功能】
- 25分钟标准番茄钟
- 基础数据统计
- 1种白噪音（雨声）
- 成就系统
- 桌面小组件
- 实时活动

【付费功能】（可选）
- 自定义时长（15-90分钟）
- 完整数据分析
- 6种高品质白噪音
- 分类标签
- iCloud 同步

所有付费功能通过 App Store 内购实现，用户可以免费使用核心功能。
应用不包含第三方广告，不涉及用户账号系统。

如有任何问题，请随时联系：fireny@live.com

谢谢！
```

---

## ⏱️ 时间安排建议

### 今天/明天
1. ✅ 在 Xcode 中配置 Capabilities
2. ✅ 准备所有截图
3. ✅ 在 App Store Connect 创建订阅产品
4. ✅ Archive 并上传构建

### 审核期间 (24-48小时)
- 准备 TestFlight 测试
- 准备社交媒体宣传
- 准备应用截图用于推广

### 发布后
- 监控崩溃报告
- 收集用户反馈
- 准备第一次更新

---

## 🔍 常见问题

### Q: 审核被拒怎么办？
A: 查看拒绝原因，通常是：
- 元数据不完整
- 功能描述不清
- 隐私政策问题
- 订阅功能不符合指南 3.1.1

### Q: 如何测试订阅？
A: 使用 Sandbox 测试账号：
1. App Store Connect → 用户和访问 → Sandbox 测试员
2. 添加测试账号
3. 在设备上登录 Sandbox 账号测试购买

### Q: 需要支持 iPad 吗？
A: 应用已支持 iPad，建议至少提供 1 张 iPad 截图

### Q: 如何处理多语言审核？
A: 主要语言设为简体中文，英文为次要语言
审核团队会按主要语言审核

---

## 📞 需要帮助？

- **技术支持**: fireny@live.com
- **上架文档**: `/Users/fireny/Desktop/Qoder/FocusFlow/AppStore_Submission_Info.md`

---

**祝你上架顺利！** 🎉
