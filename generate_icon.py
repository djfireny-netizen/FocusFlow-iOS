#!/usr/bin/env python3
"""
FocusFlow App Icon Generator
生成与 UI 风格一致的现代化图标
"""

from PIL import Image, ImageDraw, ImageFilter
import math
import os

def create_gradient_orb(size, center_x, center_y, radius):
    """创建渐变球体"""
    orb = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(orb)
    
    # 创建径向渐变
    for r in range(radius, 0, -1):
        # 从橙色到蓝色的渐变
        ratio = r / radius
        if ratio > 0.5:
            # 外圈：橙色
            r_color = int(255 * (ratio - 0.5) * 2)
            g_color = int(107 * (ratio - 0.5) * 2)
            b_color = int(53 * (ratio - 0.5) * 2)
        else:
            # 内圈：蓝色
            r_color = int(79 + (255 - 79) * ratio * 2)
            g_color = int(172 + (107 - 172) * ratio * 2)
            b_color = int(254 + (53 - 254) * ratio * 2)
        
        alpha = int(150 * (r / radius))
        color = (r_color, g_color, b_color, alpha)
        
        draw.ellipse([
            center_x - r, center_y - r,
            center_x + r, center_y + r
        ], fill=color)
    
    return orb

def create_decorative_lines(size):
    """创建装饰细线"""
    lines = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(lines)
    
    # 曲线1
    points1 = []
    for t in range(0, 100):
        x = int(size * 0.1 + (size * 0.8) * t / 100)
        y = int(size * 0.3 + size * 0.2 * math.sin(t * 0.1))
        points1.append((x, y))
    
    for i in range(len(points1) - 1):
        draw.line([points1[i], points1[i+1]], fill=(255, 255, 255, 25), width=2)
    
    # 曲线2
    points2 = []
    for t in range(0, 100):
        x = int(size * 0.1 + (size * 0.8) * t / 100)
        y = int(size * 0.6 + size * 0.15 * math.sin(t * 0.08 + 1))
        points2.append((x, y))
    
    for i in range(len(points2) - 1):
        draw.line([points2[i], points2[i+1]], fill=(255, 255, 255, 15), width=1)
    
    return lines

def draw_timer_icon(draw, size, center_x, center_y, icon_size):
    """绘制计时器图标"""
    # 外圈
    outer_radius = icon_size // 2
    draw.ellipse([
        center_x - outer_radius, center_y - outer_radius,
        center_x + outer_radius, center_y + outer_radius
    ], outline=(255, 255, 255, 200), width=8)
    
    # 顶部按钮
    button_width = 16
    button_height = 12
    draw.rectangle([
        center_x - button_width // 2, center_y - outer_radius - button_height + 4,
        center_x + button_width // 2, center_y - outer_radius + 4
    ], fill=(255, 255, 255, 200))
    
    # 指针
    hand_length = int(outer_radius * 0.6)
    angle = -45  # 45度角
    rad = math.radians(angle)
    end_x = int(center_x + hand_length * math.cos(rad))
    end_y = int(center_y + hand_length * math.sin(rad))
    
    draw.line([
        (center_x, center_y),
        (end_x, end_y)
    ], fill=(255, 255, 255, 255), width=6)
    
    # 中心点
    draw.ellipse([
        center_x - 6, center_y - 6,
        center_x + 6, center_y + 6
    ], fill=(255, 255, 255, 255))

def generate_icon(size):
    """生成指定尺寸的图标"""
    # 创建深色背景
    icon = Image.new('RGBA', (size, size), (10, 10, 10, 255))
    
    # 添加渐变球体
    orb_size = int(size * 0.7)
    orb_x = size // 2
    orb_y = int(size * 0.45)
    orb = create_gradient_orb(size, orb_x, orb_y, orb_size // 2)
    icon = Image.alpha_composite(icon, orb)
    
    # 添加装饰线
    lines = create_decorative_lines(size)
    icon = Image.alpha_composite(icon, lines)
    
    # 添加计时器图标
    icon_size = int(size * 0.35)
    icon_center_x = size // 2
    icon_center_y = int(size * 0.48)
    
    # 创建图标层
    icon_layer = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    icon_draw = ImageDraw.Draw(icon_layer)
    draw_timer_icon(icon_draw, size, icon_center_x, icon_center_y, icon_size)
    
    icon = Image.alpha_composite(icon, icon_layer)
    
    # 转换为 RGB（移除 alpha）
    icon_rgb = Image.new('RGB', (size, size), (10, 10, 10))
    icon_rgb.paste(icon, mask=icon.split()[3])
    
    return icon_rgb

def main():
    """主函数"""
    # 需要生成的尺寸
    sizes = {
        '1024.png': 1024,
        '180.png': 180,
        '167 1.png': 167,
        '152.png': 152,
        '120.png': 120,
        '114.png': 114,
        '87.png': 87,
        '80 1.png': 80,
        '80.png': 80,
        '60.png': 60,
        '58 1.png': 58,
        '58.png': 58,
        '57.png': 57,
        '40 1.png': 40,
        '40.png': 40,
        '29.png': 29,
    }
    
    output_dir = '/Users/fireny/Desktop/Qoder/FocusFlow/Assets.xcassets/AppIcon.appiconset'
    
    print("开始生成 FocusFlow 图标...")
    print("=" * 50)
    
    for filename, size in sizes.items():
        print(f"生成 {size}x{size} -> {filename}")
        icon = generate_icon(size)
        icon.save(os.path.join(output_dir, filename), 'PNG')
    
    print("=" * 50)
    print("✅ 所有图标生成完成！")
    print("\n下一步：")
    print("1. 在 Xcode 中清理构建缓存: Product → Clean Build Folder")
    print("2. 重新构建项目")
    print("3. 在模拟器或真机上查看新图标")

if __name__ == '__main__':
    main()
