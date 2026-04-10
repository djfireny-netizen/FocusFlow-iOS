//
//  FocusWidget.swift
//  FocusWidget
//
//  Created by 房亮 on 2026/4/8.
//

import WidgetKit
import SwiftUI

// MARK: - 小组件提供者
struct FocusWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> FocusWidgetEntry {
        FocusWidgetEntry(date: Date(), focusTime: 120, focusSessions: 3)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (FocusWidgetEntry) -> ()) {
        let entry = FocusWidgetEntry(date: Date(), focusTime: 120, focusSessions: 3)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<FocusWidgetEntry>) -> ()) {
        // 从 UserDefaults 读取数据
        let focusTime = UserDefaults(suiteName: "group.com.fireny.focusflow2026")?.integer(forKey: "widgetFocusTime") ?? 0
        let focusSessions = UserDefaults(suiteName: "group.com.fireny.focusflow2026")?.integer(forKey: "widgetFocusSessions") ?? 0
        
        let entry = FocusWidgetEntry(
            date: Date(),
            focusTime: focusTime,
            focusSessions: focusSessions
        )
        
        // 每小时更新一次
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - 小组件条目
struct FocusWidgetEntry: TimelineEntry {
    let date: Date
    let focusTime: Int // 分钟
    let focusSessions: Int
}

// MARK: - 小组件视图
struct FocusWidgetEntryView: View {
    var entry: FocusWidgetProvider.Entry
    
    var focusTimeText: String {
        let hours = entry.focusTime / 60
        let minutes = entry.focusTime % 60
        if hours > 0 {
            return String(format: "%d时%d分", hours, minutes)
        }
        return String(format: "%d分钟", minutes)
    }
    
    var body: some View {
        ZStack {
            // 透明背景（使用系统小组件背景）
            Color.clear
            
            // 渐变球体
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "ff6b35"), Color(hex: "4facfe"), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .blur(radius: 40)
                .opacity(0.6)
                .offset(x: -20, y: -20)
            
            // 装饰细线
            Path { path in
                path.move(to: CGPoint(x: 0, y: 40))
                path.addQuadCurve(to: CGPoint(x: 170, y: 60), control: CGPoint(x: 85, y: 20))
            }
            .stroke(Color.white.opacity(0.1), lineWidth: 1)
            
            // 内容
            VStack(alignment: .leading, spacing: 12) {
                // 标题
                HStack {
                    Image(systemName: "timer")
                        .font(.title2)
                        .foregroundColor(Color(hex: "ff6b35"))
                    Text("FocusFlow Go")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                
                Spacer()
                
                // 统计数据
                HStack(spacing: 20) {
                    // 专注时间
                    VStack(alignment: .leading, spacing: 4) {
                        Text(focusTimeText)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("今日专注")
                            .font(.caption)
                            .foregroundColor(Color(hex: "a0a0a0"))
                    }
                    
                    Spacer()
                    
                    // 专注次数
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(entry.focusSessions)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "4facfe"))
                        Text("完成次数")
                            .font(.caption)
                            .foregroundColor(Color(hex: "a0a0a0"))
                    }
                }
                
                Spacer()
                
                // 底部提示
                HStack {
                    Image(systemName: "arrow.forward.circle.fill")
                        .foregroundColor(Color(hex: "ff6b35"))
                    Text("打开应用开始专注")
                        .font(.caption)
                        .foregroundColor(Color(hex: "a0a0a0"))
                    Spacer()
                }
            }
            .padding(16)
        }
        .containerBackground(.clear, for: .widget)
    }
}

// MARK: - 小组件定义
struct FocusWidget: Widget {
    let kind: String = "FocusWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FocusWidgetProvider()) { entry in
            if #available(iOS 17.0, *) {
                FocusWidgetEntryView(entry: entry)
                    .containerBackground(.clear, for: .widget)
            } else {
                FocusWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("FocusFlow Go")
        .description("查看今日专注统计")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - 颜色扩展
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - 预览
#Preview(as: .systemMedium) {
    FocusWidget()
} timeline: {
    FocusWidgetEntry(date: .now, focusTime: 120, focusSessions: 3)
    FocusWidgetEntry(date: .now, focusTime: 180, focusSessions: 5)
}
