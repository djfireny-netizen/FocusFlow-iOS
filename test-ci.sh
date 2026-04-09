#!/bin/bash

# CI/CD 本地测试脚本
# 在推送前验证配置是否正确

set -e

echo "🧪 CI/CD 本地测试"
echo "================================"

# 1. 检查 SwiftLint 配置
echo "📋 检查 SwiftLint 配置..."
if command -v swiftlint &> /dev/null; then
    echo "✅ SwiftLint 已安装"
    echo "🔍 运行代码检查..."
    swiftlint || echo "⚠️  发现一些警告（非阻塞）"
else
    echo "⚠️  SwiftLint 未安装，跳过检查"
    echo "💡 安装方法: brew install swiftlint"
fi

echo ""

# 2. 验证 GitHub Actions 配置
echo "📋 验证 GitHub Actions 配置..."
if [ -f ".github/workflows/ios-ci.yml" ]; then
    echo "✅ CI/CD 工作流文件存在"
    
    # 检查 YAML 语法（如果安装了 yq）
    if command -v yq &> /dev/null; then
        echo "🔍 验证 YAML 语法..."
        yq eval '.' .github/workflows/ios-ci.yml > /dev/null && echo "✅ YAML 语法正确" || echo "❌ YAML 语法错误"
    else
        echo "ℹ️  跳过 YAML 验证（安装 yq: brew install yq）"
    fi
else
    echo "❌ CI/CD 工作流文件不存在"
    exit 1
fi

echo ""

# 3. 检查构建配置
echo "📋 检查构建配置..."
if [ -f "ExportOptions.plist" ]; then
    echo "✅ ExportOptions.plist 存在"
else
    echo "⚠️  ExportOptions.plist 不存在（Archive 导出将失败）"
fi

echo ""

# 4. 本地构建测试
echo "📋 本地构建测试..."
echo "🔨 清理构建..."
xcodebuild clean -project FocusFlow.xcodeproj -scheme FocusFlow > /dev/null 2>&1

echo "🔨 构建验证..."
if xcodebuild build \
    -project FocusFlow.xcodeproj \
    -scheme FocusFlow \
    -configuration Release \
    -destination 'generic/platform=iOS' \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO > /dev/null 2>&1; then
    echo "✅ 构建成功"
else
    echo "❌ 构建失败，请检查代码"
    exit 1
fi

echo ""

# 5. 统计信息
echo "📊 项目统计"
echo "================================"
swift_files=$(find . -name "*.swift" -not -path "./Pods/*" -not -path "./.build/*" | wc -l | xargs)
total_lines=$(find . -name "*.swift" -not -path "./Pods/*" -not -path "./.build/*" | xargs wc -l | tail -1 | awk '{print $1}')
managers=$(find Managers -name "*.swift" 2>/dev/null | wc -l | xargs)
views=$(find Views -name "*.swift" 2>/dev/null | wc -l | xargs)
models=$(find Models -name "*.swift" 2>/dev/null | wc -l | xargs)

echo "Swift 文件数: $swift_files"
echo "总代码行数: $total_lines"
echo "Managers: $managers 文件"
echo "Views: $views 文件"
echo "Models: $models 文件"

echo ""
echo "✅ 本地测试完成！"
echo "================================"
echo ""
echo "💡 提示："
echo "  - 推送代码后将自动触发 CI/CD 流程"
echo "  - 在 GitHub Actions 页面查看构建状态"
echo "  - URL: https://github.com/djfireny-netizen/FocusFlow-iOS/actions"
