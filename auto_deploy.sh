#!/bin/bash

# FocusFlow 自动构建和推送脚本
# 使用方法：./auto_deploy.sh

set -e  # 遇到错误立即退出

echo "🚀 FocusFlow 自动部署脚本"
echo "================================"

# 1. 清理构建
echo "🧹 清理构建缓存..."
xcodebuild clean -project FocusFlow.xcodeproj -scheme FocusFlow

# 2. 构建验证
echo "🔨 构建验证..."
xcodebuild -project FocusFlow.xcodeproj -scheme FocusFlow -configuration Release -destination 'generic/platform=iOS' build

# 3. Git 操作
echo "📦 Git 操作..."
git add -A

# 检查是否有更改
if git diff --staged --quiet; then
    echo "⚠️  没有新的更改，跳过提交"
else
    echo "💾 提交更改..."
    git commit -m "chore: 自动提交 $(date '+%Y-%m-%d %H:%M:%S')"
    
    echo "📤 推送到 GitHub..."
    git push origin main
fi

echo ""
echo "✅ 部署完成！"
echo "================================"
