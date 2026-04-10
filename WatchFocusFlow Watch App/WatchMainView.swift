//
//  WatchMainView.swift
//  WatchFocusFlow Watch App
//
//  Created for FocusFlow Go
//

import SwiftUI

struct WatchMainView: View {
    @StateObject private var connectivityManager = WatchConnectivityManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 计时器标签页
            TimerView()
                .tabItem {
                    Image(systemName: "timer")
                    Text("计时器")
                }
                .tag(0)
            
            // 统计标签页
            StatsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("统计")
                }
                .tag(1)
            
            // 白噪音标签页
            SoundView()
                .tabItem {
                    Image(systemName: "waveform")
                    Text("白噪音")
                }
                .tag(2)
        }
        .onAppear {
            // 加载数据
            connectivityManager.requestTodayStats()
            connectivityManager.requestFocusSessions()
        }
    }
}

#Preview {
    WatchMainView()
}
