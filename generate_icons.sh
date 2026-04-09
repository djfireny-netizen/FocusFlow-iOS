#!/bin/bash
# FocusFlow App Icon Generator
# 使用 macOS 原生工具生成图标

echo "开始生成 FocusFlow 图标..."
echo "=========================================="

# 检查是否有 1024.png 源文件
SOURCE_DIR="/Users/fireny/Desktop/Qoder/FocusFlow/Assets.xcassets/AppIcon.appiconset"

if [ ! -f "$SOURCE_DIR/1024.png" ]; then
    echo "❌ 错误: 找不到 1024.png 源文件"
    echo "请先创建或替换 1024.png"
    exit 1
fi

echo "使用 1024.png 作为源文件生成其他尺寸..."

# 定义需要生成的尺寸
sizes=(180 167 152 120 114 87 80 60 58 57 40 29)

for size in "${sizes[@]}"; do
    filename="${size}.png"
    if [ $size -eq 80 ] || [ $size -eq 58 ] || [ $size -eq 40 ]; then
        filename="${size} 1.png"
    fi
    
    echo "生成 ${size}x${size} -> $filename"
    
    sips -z $size $size "$SOURCE_DIR/1024.png" --out "$SOURCE_DIR/$filename" >/dev/null 2>&1
done

echo "=========================================="
echo "✅ 所有图标生成完成！"
echo ""
echo "下一步："
echo "1. 在 Xcode 中: Product → Clean Build Folder (Shift+Cmd+K)"
echo "2. 重新构建项目"
echo "3. 在模拟器或真机上查看新图标"
