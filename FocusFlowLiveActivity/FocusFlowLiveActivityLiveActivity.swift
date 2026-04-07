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
            // 背景渐变
            if context.attributes.isBreak {
                LinearGradient(
                    colors: [Color(hex: "4facfe"), Color(hex: "00f2fe")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                LinearGradient(
                    colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            
            VStack(spacing: 12) {
                // 顶部信息
                HStack {
                    // 分类图标
                    Image(systemName: context.attributes.isBreak ? "cup.and.saucer.fill" : "brain.head.profile")
                        .font(.title2)
                    
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
                
                // 进度条
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white)
                            .frame(width: geometry.size.width * context.state.progress, height: 8)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal, 20)
                
                // 倒计时
                HStack {
                    Spacer()
                    
                    Text(formattedTime(context.state.timeRemaining))
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
            }
            .padding(.vertical, 16)
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
            HStack(spacing: 8) {
                Image(systemName: context.attributes.isBreak ? "cup.and.saucer.fill" : "brain.head.profile")
                    .font(.title3)
                
                Text(formattedTime(context.state.timeRemaining))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                
                if context.state.isPaused {
                    Image(systemName: "pause.fill")
                        .font(.caption)
                }
            }
            .foregroundColor(.white)
        } else {
            // 展开视图
            HStack(spacing: 12) {
                // 左侧图标
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: context.attributes.isBreak ? "cup.and.saucer.fill" : "brain.head.profile")
                        .font(.title3)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(context.attributes.isBreak ? "休息一下" : context.attributes.focusCategory)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(formattedTime(context.state.timeRemaining))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // 进度环
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 3)
                    
                    Circle()
                        .trim(from: 0, to: context.state.progress)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                }
                .frame(width: 36, height: 36)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
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
                // 紧凑前视图
                Image(systemName: context.attributes.isBreak ? "cup.and.saucer.fill" : "brain.head.profile")
                    .foregroundColor(context.attributes.isBreak ? .cyan : .purple)
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
