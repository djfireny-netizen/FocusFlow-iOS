#!/bin/bash

# FocusFlow 构建脚本
# 使用方法: ./build.sh

echo "🚀 开始构建 FocusFlow..."

# 检查 Xcode 是否安装
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ 错误: 未找到 xcodebuild，请确保已安装 Xcode"
    exit 1
fi

# 设置变量
PROJECT_NAME="FocusFlow"
SCHEME="FocusFlow"
SDK="iphonesimulator"
CONFIGURATION="Debug"

# 清理之前的构建
echo "🧹 清理之前的构建..."
xcodebuild clean -project "${PROJECT_NAME}.xcodeproj" -scheme "${SCHEME}"

# 构建项目
echo "🔨 构建项目..."
xcodebuild build \
    -project "${PROJECT_NAME}.xcodeproj" \
    -scheme "${SCHEME}" \
    -sdk "${SDK}" \
    -configuration "${CONFIGURATION}" \
    -derivedDataPath build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO

# 检查构建结果
if [ $? -eq 0 ]; then
    echo "✅ 构建成功!"
    echo "📱 App 位置: build/Build/Products/${CONFIGURATION}-${SDK}/${PROJECT_NAME}.app"
    echo ""
    echo "要在模拟器中运行，请执行:"
    echo "xcrun simctl install booted build/Build/Products/${CONFIGURATION}-${SDK}/${PROJECT_NAME}.app"
    echo "xcrun simctl launch booted com.focusflow.app"
else
    echo "❌ 构建失败! 请检查错误信息"
    exit 1
fi
