//
//  TimerView.swift
//  WatchFocusFlow Watch App
//
//  Created for FocusFlow Go
//

import SwiftUI

struct TimerView: View {
    @StateObject private var connectivityManager = WatchConnectivityManager.shared
    @State private var selectedDuration: TimeInterval = 25 * 60 // 25 分钟
    @State private var selectedCategory = "工作"
    
    let durations: [(TimeInterval, String)] = [
        (15 * 60, "15分钟"),
        (25 * 60, "25分钟"),
        (45 * 60, "45分钟"),
        (60 * 60, "60分钟")
    ]
    
    let categories = ["工作", "学习", "阅读", "运动", "冥想"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 标题
                Text("FocusFlow Go")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                // 计时器状态显示
                if connectivityManager.timerState == .idle {
                    idleView
                } else {
                    runningTimerView
                }
                
                // 时长选择
                if connectivityManager.timerState == .idle {
                    durationPicker
                }
                
                // 分类选择
                if connectivityManager.timerState == .idle {
                    categoryPicker
                }
                
                // 操作按钮
                actionButtons
            }
            .padding()
        }
    }
    
    // MARK: - 空闲状态视图
    private var idleView: some View {
        VStack(spacing: 8) {
            Image(systemName: "timer")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text(formatDuration(selectedDuration))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .monospacedDigit()
        }
        .padding(.vertical, 12)
    }
    
    // MARK: - 运行中计时器视图
    private var runningTimerView: some View {
        VStack(spacing: 8) {
            // 状态图标
            Image(systemName: timerIcon)
                .font(.system(size: 36))
                .foregroundColor(timerColor)
            
            // 分类标签
            Text(selectedCategory)
                .font(.caption)
                .foregroundColor(.secondary)
            
            // 剩余时间（从 iPhone 同步）
            Text("计时中...")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(timerColor)
        }
        .padding(.vertical, 12)
    }
    
    // MARK: - 时长选择器
    private var durationPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("时长")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Picker("时长", selection: $selectedDuration) {
                ForEach(durations, id: \.0) { duration, label in
                    Text(label).tag(duration)
                }
            }
            .pickerStyle(.wheel)
        }
    }
    
    // MARK: - 分类选择器
    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("分类")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Picker("分类", selection: $selectedCategory) {
                ForEach(categories, id: \.self) { category in
                    Text(category).tag(category)
                }
            }
            .pickerStyle(.wheel)
        }
    }
    
    // MARK: - 操作按钮
    private var actionButtons: some View {
        VStack(spacing: 8) {
            switch connectivityManager.timerState {
            case .idle:
                Button("开始专注") {
                    connectivityManager.startFocus(
                        duration: selectedDuration,
                        category: selectedCategory
                    )
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                
            case .focusing:
                HStack(spacing: 12) {
                    Button("暂停") {
                        connectivityManager.pauseTimer()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("停止") {
                        connectivityManager.stopTimer()
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
                
            case .paused:
                HStack(spacing: 12) {
                    Button("继续") {
                        connectivityManager.resumeTimer()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    
                    Button("停止") {
                        connectivityManager.stopTimer()
                    }
                    .buttonStyle(.bordered)
                }
                
            case .onBreak:
                Text("休息中...")
                    .font(.headline)
                    .foregroundColor(.green)
            }
        }
    }
    
    // MARK: - 辅助方法
    
    private var timerIcon: String {
        switch connectivityManager.timerState {
        case .focusing: return "play.circle.fill"
        case .paused: return "pause.circle.fill"
        case .onBreak: return "cup.and.saucer.fill"
        case .idle: return "timer"
        }
    }
    
    private var timerColor: Color {
        switch connectivityManager.timerState {
        case .focusing: return .orange
        case .paused: return .yellow
        case .onBreak: return .green
        case .idle: return .primary
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes)分钟"
    }
}

#Preview {
    TimerView()
}
