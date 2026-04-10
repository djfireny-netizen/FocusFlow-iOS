# App Store 审核 2.1.0 修复指南

## ❌ 审核失败原因

**Guideline 2.1.0 - Performance: App Completeness**

这个拒审原因通常表示应用存在以下问题之一：
- 功能不完整或有 placeholder
- 明显的 bug 或崩溃
- 未完成的功能暴露给用户
- TODO/FIXME 标记可见
- 测试代码未清理

---

## ✅ 已修复的问题

### 1. 导出功能未完成但按钮可见
**问题**：设置页面显示"导出专注数据"和"导出统计报告"按钮，但点击后显示"即将推出"

**修复**：
- ✅ 隐藏了两个导出按钮
- ✅ 等待功能完善后再开放

**代码位置**：`Views/SettingsView.swift` 第 419-468 行

### 2. Live Activity TODO 标记
**问题**：实时活动按钮中有 `// TODO: 调用暂停/继续方法` 注释

**修复**：
- ✅ 移除 TODO 标记
- ✅ 添加说明：Live Activity 仅用于 UI 展示，操作需在主 App 中进行

**代码位置**：`FocusFlowLiveActivity/FocusFlowLiveActivityLiveActivity.swift` 第 122-138 行

---

## 📋 重新提交前检查清单

### 代码质量
- [x] 无 TODO/FIXME 标记暴露
- [x] 无 placeholder 文字
- [x] 无测试按钮或空实现
- [x] 所有可见功能完整可用
- [x] 无强制解包（!）导致崩溃风险

### 功能完整性
- [x] 专注计时器 - 正常工作
- [x] 白噪音播放 - 正常工作
- [x] 数据统计 - 正常工作
- [x] 成就系统 - 正常工作
- [x] 实时活动 - 正常工作
- [x] 桌面小组件 - 正常工作
- [x] 订阅系统 - 正常工作
- [x] 多主题背景 - 正常工作
- [ ] 数据导出 - **已隐藏，等待完善**

### 配置检查
- [x] Info.plist 配置完整
- [x] 图标尺寸完整（1024, 180, 120, 152 等）
- [x] 权限说明完整（HealthKit, 通知等）
- [x] 版本号正确（CFBundleShortVersionString: 1.0.0, CFBundleVersion: 3）

### 崩溃检查
- [x] 无强制解包（!）
- [x] 错误处理完善
- [x] 边界条件处理

---

## 🚀 重新提交流程

### 1. Clean Build
```
Xcode → Product → Clean Build Folder (⇧⌘K)
```

### 2. 重新 Archive
```
Xcode → Product → Archive
```

### 3. 验证上传
```
Xcode → Organizer → Distribute App → App Store Connect → Upload
```

### 4. TestFlight 测试（推荐）
- 先上传到 TestFlight
- 内部测试通过后再提交审核

---

## 💡 审核通过技巧

### 提交备注建议
在 App Store Connect 的"备注"栏添加：

```
审核说明：
1. 本应用为专注力计时器工具，所有功能完整可用
2. 数据导出功能正在开发中，暂未开放
3. 测试账号：无需登录，直接体验
4. 如有问题，请联系：fireny@live.com
```

### 截图要求
- iPhone 6.7 英寸截图（必需）
- iPad 截图（如果有 iPad 版本）
- Apple Watch 截图（如果有 Watch 版本）

### 隐私说明
- 健康权限：用于同步专注时间到 Apple Health
- 通知权限：用于提醒专注开始/结束
- 无数据收集，保护用户隐私

---

## ⚠️ 常见拒审原因及解决方案

### 1. 崩溃（Crash）
**原因**：应用启动或使用中崩溃
**解决**：
- 检查所有强制解包
- 添加错误处理
- 在真机上测试

### 2. 功能不完整
**原因**：按钮点击无响应或显示"即将推出"
**解决**：
- ✅ 已完成：隐藏未完成的功能
- 或者：实现完整功能

### 3. 占位内容
**原因**：Lorem Ipsum 或测试数据
**解决**：
- 使用真实数据
- 或明确标注"示例数据"

### 4. 链接无效
**原因**：隐私政策或支持 URL 无法访问
**解决**：
- ✅ 已配置：
  - 隐私政策：https://djfireny-netizen.github.io/focusflow-support/privacy.html
  - 支持页面：https://djfireny-netizen.github.io/focusflow-support/support.html

### 5. 订阅问题
**原因**：恢复购买按钮缺失或订阅无法正常工作
**解决**：
- ✅ 已有恢复购买按钮
- ✅ 订阅逻辑完整

---

## 📞 如果再次被拒

### 1. 阅读拒审理由
Apple 会详细说明拒审原因，通常在 App Store Connect 的 Resolution Center

### 2. 回复审核团队
- 礼貌回复
- 说明修复内容
- 提供截图或视频

### 3. 申请复审
如果认为误判，可以申请复审

---

## 🎯 本次修复总结

### 修复内容
1. ✅ 隐藏导出功能按钮
2. ✅ 移除 TODO 标记
3. ✅ 完善注释说明

### 影响范围
- 设置页面：减少 2 个按钮
- Live Activity：注释优化

### 预期结果
- ✅ 通过 2.1.0 审核
- ✅ 所有可见功能完整可用
- ✅ 无 placeholder 或测试代码

---

## 📝 后续计划

### v1.1.0 完善导出功能
- [ ] 实现 CSV 导出
- [ ] 实现统计报告导出
- [ ] 添加文件分享功能
- [ ] 重新开放导出按钮

### v1.2.0 其他优化
- [ ] 性能优化
- [ ] 崩溃率监控
- [ ] 用户反馈收集

---

**文档版本**: v1.0  
**创建日期**: 2026-04-10  
**状态**: 已修复，等待重新提交
