#!/bin/bash

# 添加 Watch 相关文件到 Xcode 项目
# 使用方法: ./add_watch_files_to_project.sh

echo "🔧 正在添加 Watch 相关文件到 Xcode 项目..."

cd /Users/fireny/Desktop/Qoder/FocusFlow

# 使用 Xcode 命令行工具添加文件
# 注意：这需要手动在 Xcode 中操作，因为 pbxproj 文件格式复杂

echo ""
echo "⚠️  请在 Xcode 中手动添加以下文件到项目："
echo ""
echo "1. 打开 FocusFlow.xcodeproj"
echo "2. 右键点击 Managers 文件夹"
echo "3. 选择 'Add Files to FocusFlow...'"
echo "4. 添加以下文件："
echo "   - Managers/WatchSyncData.swift"
echo "   - Managers/iPhoneConnectivityManager.swift"
echo "5. 确保勾选 'Add to targets: FocusFlow'"
echo ""
echo "📋 或者使用以下步骤："
echo ""
echo "步骤 1: 在 Xcode 左侧项目导航中，找到 Managers 组"
echo "步骤 2: 右键点击 Managers"
echo "步骤 3: 选择 'Add Files to FocusFlow'"
echo "步骤 4: 选择上述两个文件"
echo "步骤 5: 确保 Target Membership 勾选了 FocusFlow"
echo ""
echo "✅ 添加完成后，编译应该就能通过了！"
echo ""
echo "💡 提示：这些文件已经存在于 Managers 文件夹中，只是没有被添加到 Xcode 项目的引用中。"
