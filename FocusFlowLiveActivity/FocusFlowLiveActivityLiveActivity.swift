//
//  FocusFlowLiveActivityLiveActivity.swift
//  FocusFlowLiveActivity
//
//  Created by 房亮 on 2026/4/7.
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - 专注实时活动属性
struct FocusActivityAttributes: ActivityAttributes {
    // 静态数据（活动创建时确定，不会变化）
    let focusCategory: String
    let totalDuration: TimeInterval
    let isBreak: Bool
    
    // 动态数据（活动进行中会更新）
    struct ContentState: Codable, Hashable {
        var timeRemaining: TimeInterval
        var progress: Double
        var currentSession: Int
        var isPaused: Bool
    }
}

// MARK: - 实时活动视图
struct FocusLiveActivityView: View {
    let context: ActivityViewContext<FocusActivityAttributes>
    
    var body: some View {
        ZStack {
            // 深色背景
            Color(hex: "0a0a0a")
            
            // 渐变球体背景
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            context.attributes.isBreak ? Color(hex: "4facfe") : Color(hex: "ff6b35"),
                            context.attributes.isBreak ? Color(hex: "00f2fe") : Color(hex: "4facfe"),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 300
                    )
                )
                .frame(width: 600, height: 600)
                .offset(y: -50)
                .blur(radius: 80)
                .opacity(0.5)
            
            VStack(spacing: 16) {
                // 顶部信息
                HStack {
                    // 分类图标
                    Image(systemName: context.attributes.isBreak ? "cup.and.saucer.fill" : "brain.head.profile")
                        .font(.title3)
                    
                    Text(context.attributes.isBreak ? "休息时间" : context.attributes.focusCategory)
                        .font(.headline)
                    
                    Spacer()
                    
                    // 番茄钟计数
                    if !context.attributes.isBreak {
                        Text("第 \(context.state.currentSession) 个")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                    }
                    
                    // 暂停指示器
                    if context.state.isPaused {
                        Image(systemName: "pause.circle.fill")
                            .font(.title3)
                            .foregroundColor(.yellow)
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                // 进度条
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "ff6b35"), Color(hex: "4facfe")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * context.state.progress, height: 6)
                    }
                }
                .frame(height: 6)
                .padding(.horizontal, 20)
                
                // 倒计时
                Text(formattedTime(context.state.timeRemaining))
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                // 操作按钮
                HStack(spacing: 20) {
                    // 停止按钮
                    Button(action: {
                        // TODO: 调用停止方法
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "stop.fill")
                                .font(.title3)
                            Text("停止")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(12)
                    }
                    
                    // 暂停/继续按钮
                    Button(action: {
                        // TODO: 调用暂停/继续方法
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: context.state.isPaused ? "play.fill" : "pause.fill")
                                .font(.title3)
                            Text(context.state.isPaused ? "继续" : "暂停")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                    }
                }
                .padding(.top, 4)
            }
            .padding(.vertical, 20)
        }
    }
    
    private func formattedTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - 灵动岛视图
struct FocusIslandView: View {
    let context: ActivityViewContext<FocusActivityAttributes>
    let isCompact: Bool
    
    var body: some View {
        if isCompact {
            // 紧凑视图
            HStack(spacing: 6) {
                // 状态指示点
                Circle()
                    .fill(context.attributes.isBreak ? Color(hex: "4facfe") : Color(hex: "ff6b35"))
                    .frame(width: 6, height: 6)
                
                Text(formattedTime(context.state.timeRemaining))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                
                if context.state.isPaused {
                    Image(systemName: "pause.fill")
                        .font(.caption2)
                        .foregroundColor(Color(hex: "ff6b35"))
                }
            }
            .foregroundColor(.white)
        } else {
            // 展开视图
            HStack(spacing: 12) {
                // 左侧图标 - 渐变背景
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    context.attributes.isBreak ? Color(hex: "4facfe") : Color(hex: "ff6b35"),
                                    context.attributes.isBreak ? Color(hex: "00f2fe") : Color(hex: "4facfe")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: context.attributes.isBreak ? "cup.and.saucer.fill" : "brain.head.profile")
                        .font(.title3)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(context.attributes.isBreak ? "休息一下" : context.attributes.focusCategory)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(formattedTime(context.state.timeRemaining))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // 进度环 - 蓝橙渐变
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 2.5)
                    
                    Circle()
                        .trim(from: 0, to: context.state.progress)
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "ff6b35"), Color(hex: "4facfe")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                }
                .frame(width: 32, height: 32)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
    }
    
    private func formattedTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Widget 配置
struct FocusFlowLiveActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FocusActivityAttributes.self) { context in
            // 锁屏和通知中心视图
            FocusLiveActivityView(context: context)
                .activityBackgroundTint(Color.clear)
                .activitySystemActionForegroundColor(Color.white)
        } dynamicIsland: { context in
            // 灵动岛视图
            DynamicIsland {
                // 展开视图
                DynamicIslandExpandedRegion(.leading) {
                    EmptyView()
                }
                DynamicIslandExpandedRegion(.trailing) {
                    EmptyView()
                }
                DynamicIslandExpandedRegion(.center) {
                    FocusIslandView(context: context, isCompact: false)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    EmptyView()
                }
            } compactLeading: {
                // 紧凑前视图 - 图标
                Image(systemName: context.attributes.isBreak ? "cup.and.saucer.fill" : "brain.head.profile")
                    .font(.caption)
                    .foregroundColor(context.attributes.isBreak ? Color(hex: "4facfe") : Color(hex: "ff6b35"))
            } compactTrailing: {
                // 紧凑后视图
                Text(formattedTimeCompact(context.state.timeRemaining))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            } minimal: {
                // 最小视图
                Text(formattedTimeCompact(context.state.timeRemaining))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
    }
    
    private func formattedTimeCompact(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
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
extension FocusActivityAttributes {
    fileprivate static var preview: FocusActivityAttributes {
        FocusActivityAttributes(
            focusCategory: "工作",
            totalDuration: 1500,
            isBreak: false
        )
    }
}

extension FocusActivityAttributes.ContentState {
    fileprivate static var preview: FocusActivityAttributes.ContentState {
        FocusActivityAttributes.ContentState(
            timeRemaining: 900,
            progress: 0.4,
            currentSession: 3,
            isPaused: false
        )
    }
}

#Preview("Notification", as: .content, using: FocusActivityAttributes.preview) {
    FocusFlowLiveActivityLiveActivity()
} contentStates: {
    FocusActivityAttributes.ContentState.preview
}
