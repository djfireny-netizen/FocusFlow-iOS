//
//  StatsView.swift
//  WatchFocusFlow Watch App
//
//  Created for FocusFlow Go
//

import SwiftUI

struct StatsView: View {
    @StateObject private var connectivityManager = WatchConnectivityManager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 标题
                Text("今日专注")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                // 加载状态
                if connectivityManager.todayStats == nil {
                    loadingView
                } else {
                    statsContent
                }
                
                // 刷新按钮
                Button {
                    connectivityManager.requestTodayStats()
                    connectivityManager.requestFocusSessions()
                } label: {
                    Label("刷新", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding()
        }
    }
    
    // MARK: - 加载视图
    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("加载中...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - 统计内容
    private var statsContent: some View {
        Group {
            guard let stats = connectivityManager.todayStats else {
                return AnyView(EmptyView())
            }
            
            return AnyView(
                VStack(spacing: 16) {
                    // 总览卡片
                    overviewCard(stats: stats)
                    
                    // 分类统计
                    if !stats.categories.isEmpty {
                        categoryStatsView(categories: stats.categories)
                    }
                    
                    // 最近专注记录
                    recentSessionsView
                }
            )
        }
    }
    
    // MARK: - 总览卡片
    private func overviewCard(stats: TodayStats) -> some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("专注时长")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(stats.totalMinutes)分钟")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                
                Divider()
                    .frame(height: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("专注次数")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(stats.sessionCount)次")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - 分类统计
    private func categoryStatsView(categories: [CategoryStats]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("分类统计")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ForEach(categories.prefix(4), id: \.name) { category in
                HStack {
                    Text(category.name)
                        .font(.caption)
                    
                    Spacer()
                    
                    Text("\(category.minutes)分钟")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                    
                    Text("(\(category.count)次)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - 最近专注记录
    private var recentSessionsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("最近专注")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if connectivityManager.focusSessions.isEmpty {
                Text("暂无记录")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(connectivityManager.focusSessions.prefix(3), id: \.id) { session in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(session.category)
                                .font(.caption)
                                .fontWeight(.medium)
                            
                            Text(formatDate(session.date))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("\(session.duration / 60)分钟")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(session.isCompleted ? .green : .orange)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - 辅助方法
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    StatsView()
}
