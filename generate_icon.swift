#!/usr/bin/env xcrun swift
import Foundation
import AppKit

// MARK: - 图标生成器
struct IconGenerator {
    
    static func generate(size: CGSize) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        
        // 深色背景
        NSColor(calibratedRed: 0.039, green: 0.039, blue: 0.039, alpha: 1.0).set()
        NSRect(origin: .zero, size: size).fill()
        
        // 渐变球体
        drawGradientOrb(in: size)
        
        // 装饰线
        drawDecorativeLines(in: size)
        
        // 计时器图标
        drawTimerIcon(in: size)
        
        image.unlockFocus()
        return image
    }
    
    static func drawGradientOrb(in size: CGSize) {
        let orbSize = size.width * 0.85
        let centerX = size.width / 2
        let centerY = size.height / 2  // 完全居中
        
        let orbRect = NSRect(
            x: centerX - orbSize / 2,
            y: centerY - orbSize / 2,
            width: orbSize,
            height: orbSize
        )
        
        // 创建径向渐变
        let colors = [
            NSColor(calibratedRed: 1.0, green: 0.42, blue: 0.21, alpha: 0.6).cgColor,  // 橙色
            NSColor(calibratedRed: 0.31, green: 0.67, blue: 0.99, alpha: 0.6).cgColor,  // 蓝色
            NSColor.clear.cgColor
        ]
        
        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: colors as CFArray,
            locations: [0.0, 0.5, 1.0]
        )!
        
        let context = NSGraphicsContext.current!.cgContext
        context.drawRadialGradient(
            gradient,
            startCenter: CGPoint(x: orbRect.midX, y: orbRect.midY),
            startRadius: 0,
            endCenter: CGPoint(x: orbRect.midX, y: orbRect.midY),
            endRadius: orbSize / 2,
            options: .drawsAfterEndLocation
        )
    }
    
    static func drawDecorativeLines(in size: CGSize) {
        let path = NSBezierPath()
        
        // 曲线1
        path.move(to: CGPoint(x: size.width * 0.1, y: size.height * 0.3))
        path.curve(
            to: CGPoint(x: size.width * 0.9, y: size.height * 0.5),
            controlPoint1: CGPoint(x: size.width * 0.3, y: size.height * 0.2),
            controlPoint2: CGPoint(x: size.width * 0.7, y: size.height * 0.4)
        )
        
        NSColor(white: 1.0, alpha: 0.1).setStroke()
        path.lineWidth = size.width * 0.002  // 动态线条宽度
        path.stroke()
        
        // 曲线2
        let path2 = NSBezierPath()
        path2.move(to: CGPoint(x: size.width * 0.1, y: size.height * 0.6))
        path2.curve(
            to: CGPoint(x: size.width * 0.9, y: size.height * 0.7),
            controlPoint1: CGPoint(x: size.width * 0.3, y: size.height * 0.8),
            controlPoint2: CGPoint(x: size.width * 0.7, y: size.height * 0.6)
        )
        
        NSColor(white: 1.0, alpha: 0.05).setStroke()
        path2.lineWidth = size.width * 0.001  // 更细的线条
        path2.stroke()
    }
    
    static func drawTimerIcon(in size: CGSize) {
        let iconSize = size.width * 0.55
        let center = CGPoint(x: size.width / 2, y: size.height / 2)  // 完全居中
        let radius = iconSize / 2
        
        // 根据图标尺寸动态计算线条粗细
        let circleLineWidth = size.width * 0.012  // 加粗外圈线条（原 0.008）
        let handLineWidth = size.width * 0.010     // 加粗指针线条（原 0.006）
        let dotSize = size.width * 0.018           // 增大中心点（原 0.012）
        let buttonWidth = size.width * 0.024       // 增大顶部按钮（原 0.016）
        let buttonHeight = size.width * 0.018      // 增大顶部按钮（原 0.012）
        
        // 外圈
        let circlePath = NSBezierPath(ovalIn: NSRect(
            x: center.x - radius,
            y: center.y - radius,
            width: iconSize,
            height: iconSize
        ))
        
        NSColor(white: 1.0, alpha: 0.8).setStroke()
        circlePath.lineWidth = circleLineWidth
        circlePath.stroke()
        
        // 顶部按钮（macOS 坐标系 Y 轴向上）
        let buttonOffset = size.width * 0.004  // 按钮与圆的间距
        let buttonRect = NSRect(
            x: center.x - buttonWidth / 2,
            y: center.y + radius + buttonOffset,  // 在圆的上方
            width: buttonWidth,
            height: buttonHeight
        )
        NSColor(white: 1.0, alpha: 0.8).setFill()
        buttonRect.fill()
        
        // 指针（增长长度）
        let handLength = radius * 0.75  // 增长指针（原 0.6）
        let angle = -45.0 * .pi / 180.0
        let endX = center.x + handLength * cos(angle)
        let endY = center.y + handLength * sin(angle)
        
        let handPath = NSBezierPath()
        handPath.move(to: center)
        handPath.line(to: CGPoint(x: endX, y: endY))
        
        NSColor.white.setStroke()
        handPath.lineWidth = handLineWidth
        handPath.lineCapStyle = .round
        handPath.stroke()
        
        // 中心点
        let dotPath = NSBezierPath(ovalIn: NSRect(
            x: center.x - dotSize / 2,
            y: center.y - dotSize / 2,
            width: dotSize,
            height: dotSize
        ))
        NSColor.white.setFill()
        dotPath.fill()
    }
}

// MARK: - 主函数
func main() {
    let outputDir = "/Users/fireny/Desktop/Qoder/FocusFlow/Assets.xcassets/AppIcon.appiconset"
    
    let sizes: [(name: String, size: CGFloat)] = [
        ("1024.png", 1024),
        ("180.png", 180),
        ("167 1.png", 167),
        ("152.png", 152),
        ("120.png", 120),
        ("114.png", 114),
        ("87.png", 87),
        ("80 1.png", 80),
        ("80.png", 80),
        ("60.png", 60),
        ("58 1.png", 58),
        ("58.png", 58),
        ("57.png", 57),
        ("40 1.png", 40),
        ("40.png", 40),
        ("29.png", 29)
    ]
    
    print("开始生成 FocusFlow 图标...")
    print("=" .padding(toLength: 50, withPad: "=", startingAt: 0))
    
    for (name, size) in sizes {
        print("生成 \(Int(size))x\(Int(size)) -> \(name)")
        
        let icon = IconGenerator.generate(size: CGSize(width: size, height: size))
        
        guard let tiffData = icon.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
            print("  ❌ 失败")
            continue
        }
        
        let url = URL(fileURLWithPath: outputDir).appendingPathComponent(name)
        try? pngData.write(to: url)
    }
    
    print("=" .padding(toLength: 50, withPad: "=", startingAt: 0))
    print("✅ 所有图标生成完成！")
    print("\n下一步：")
    print("1. 在 Xcode 中: Product → Clean Build Folder (⇧⌘K)")
    print("2. 重新构建项目")
    print("3. 在模拟器或真机上查看新图标")
}

main()
