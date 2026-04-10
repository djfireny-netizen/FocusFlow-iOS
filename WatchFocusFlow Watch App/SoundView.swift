//
//  SoundView.swift
//  WatchFocusFlow Watch App
//
//  Created for FocusFlow Go
//

import SwiftUI

struct SoundView: View {
    @StateObject private var connectivityManager = WatchConnectivityManager.shared
    @State private var isPlaying = false
    @State private var selectedSound: String? = nil
    
    let sounds: [(id: String, name: String, icon: String)] = [
        ("rain", "雨声", "cloud.rain"),
        ("ocean", "海浪", "wave"),
        ("forest", "森林", "tree"),
        ("fire", "篝火", "flame"),
        ("cafe", "咖啡厅", "cup.and.saucer"),
        ("wind", "风声", "wind")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 标题
                Text("白噪音")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                // 播放状态
                if isPlaying, let selected = selectedSound {
                    nowPlayingView(sound: selected)
                }
                
                // 声音列表
                soundList
                
                // 控制按钮
                if isPlaying {
                    Button("停止播放") {
                        connectivityManager.controlSound(play: false)
                        isPlaying = false
                        selectedSound = nil
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
            }
            .padding()
        }
    }
    
    // MARK: - 正在播放视图
    private func nowPlayingView(sound: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "speaker.wave.3.fill")
                .font(.system(size: 32))
                .foregroundColor(.orange)
            
            Text("正在播放")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(soundName(for: sound))
                .font(.headline)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - 声音列表
    private var soundList: some View {
        VStack(spacing: 8) {
            ForEach(sounds, id: \.id) { sound in
                SoundButton(
                    icon: sound.icon,
                    name: sound.name,
                    isSelected: selectedSound == sound.id,
                    isPlaying: isPlaying
                ) {
                    if selectedSound == sound.id && isPlaying {
                        // 停止当前声音
                        connectivityManager.controlSound(play: false)
                        isPlaying = false
                        selectedSound = nil
                    } else {
                        // 播放新声音
                        connectivityManager.controlSound(play: true, soundID: sound.id)
                        selectedSound = sound.id
                        isPlaying = true
                    }
                }
            }
        }
    }
    
    // MARK: - 辅助方法
    
    private func soundName(for id: String) -> String {
        sounds.first { $0.id == id }?.name ?? ""
    }
}

// MARK: - 声音按钮组件
struct SoundButton: View {
    let icon: String
    let name: String
    let isSelected: Bool
    let isPlaying: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .frame(width: 32)
                
                Text(name)
                    .font(.subheadline)
                
                Spacer()
                
                if isSelected && isPlaying {
                    Image(systemName: "pause.fill")
                        .foregroundColor(.orange)
                } else if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(isSelected ? Color.orange.opacity(0.2) : Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

#Preview {
    SoundView()
}
