# ⚠️ 重要：在 Xcode 中添加新文件

## 问题说明
新创建的文件没有被自动添加到 Xcode 项目引用中，导致编译失败。

## 需要添加的文件

### 1. ExportManager.swift（数据导出功能）
**路径**: `Managers/ExportManager.swift`

**添加步骤**:
1. 打开 Xcode，打开 `FocusFlow.xcodeproj`
2. 在左侧项目导航中，找到 `Managers` 文件夹
3. 右键点击 `Managers`
4. 选择 `Add Files to "FocusFlow"...`
5. 选择 `Managers/ExportManager.swift`
6. **确保勾选**:
   - ✅ Add to targets: FocusFlow
   - ✅ Copy items if needed
7. 点击 `Add`

### 2. Watch 相关文件（可选，暂时不需要）
**路径**: 
- `Managers/WatchSyncData.swift`
- `Managers/iPhoneConnectivityManager.swift`

这两个文件暂时被注释掉了，等你准备好配置 Watch Target 时再添加。

## 验证是否添加成功

添加完成后，在终端运行：
```bash
cd /Users/fireny/Desktop/Qoder/FocusFlow
xcodebuild -project FocusFlow.xcodeproj -scheme FocusFlow -configuration Release -destination 'generic/platform=iOS' build
```

如果看到 `** BUILD SUCCEEDED **` 就说明添加成功了！

## 新增功能预览

### 数据导出功能
添加 ExportManager 后，设置页面会出现两个新选项：

1. **导出专注数据 (CSV)**
   - 导出所有专注记录为 CSV 格式
   - 包含：日期、时间、时长、分类、是否完成、备注
   - 可以用 Excel/Numbers 打开

2. **导出统计报告**
   - 生成文本格式的统计报告
   - 包含：累计统计 + 今日统计
   - 可以分享到微信、邮件等

## 下次启动
添加文件后，重新编译运行即可看到新功能！
