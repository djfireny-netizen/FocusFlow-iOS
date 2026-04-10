import SwiftUI

// MARK: - 声音选择器
struct SoundPickerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var soundManager: SoundManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    // 免费版声音（4 种）
    let freeSounds: [WhiteNoiseType] = [.rain, .ocean, .forest, .cafe]
    
    // Premium 声音（全部）
    var allSounds: [WhiteNoiseType] {
        WhiteNoiseType.allCases.filter { $0 != .none }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundPrimary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // 根据订阅状态显示不同声音
                        let sounds = subscriptionManager.isPremium ? allSounds : freeSounds
                        
                        ForEach(sounds) { sound in
                            SoundPickerRow(sound: sound, isPremium: subscriptionManager.isPremium)
                                .environmentObject(soundManager)
                        }
                        
                        // 如果免费版，显示升级提示
                        if !subscriptionManager.isPremium {
                            upgradeBanner
                        }
                        
                        // 音量控制
                        volumeControl
                    }
                    .padding()
                }
            }
            .navigationTitle(L("white_noise"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L("done")) {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.accentBlue)
                }
            }
        }
    }
    
    // MARK: - 升级提示
    private var upgradeBanner: some View {
        Button(action: {
            subscriptionManager.showSubscriptionSheet = true
        }) {
            HStack {
                Image(systemName: "crown.fill")
                    .foregroundColor(AppTheme.accentOrange)
                
                Text("解锁全部 7 种白噪音")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.accentOrange)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppTheme.accentOrange)
            }
            .padding()
            .background(AppTheme.accentOrange.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.accentOrange.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    // MARK: - 音量控制
    private var volumeControl: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "speaker.fill")
                    .foregroundColor(AppTheme.textSecondary)
                
                Slider(value: $soundManager.volume, in: 0...1) { editing in
                    soundManager.setVolume(soundManager.volume)
                }
                .accentColor(AppTheme.accentBlue)
                
                Image(systemName: "speaker.wave.3.fill")
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Text(L("volume"))
                .font(.caption)
                .foregroundColor(AppTheme.textTertiary)
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(16)
    }
}

// MARK: - 声音选择行
struct SoundPickerRow: View {
    @EnvironmentObject var soundManager: SoundManager
    let sound: WhiteNoiseType
    let isPremium: Bool
    
    var body: some View {
        Button(action: {
            soundManager.toggleSound(sound)
        }) {
            HStack(spacing: 15) {
                // 图标
                Image(systemName: soundIcon)
                    .font(.title2)
                    .foregroundColor(isPlaying ? AppTheme.accentBlue : AppTheme.textSecondary)
                    .frame(width: 50, height: 50)
                    .background(
                        isPlaying ?
                        AppTheme.accentBlue.opacity(0.2) : AppTheme.backgroundSecondary
                    )
                    .clipShape(Circle())
                
                // 文字
                VStack(alignment: .leading, spacing: 4) {
                    Text(sound.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text(isPlaying ? L("playing") : L("tap_to_play"))
                        .font(.caption)
                        .foregroundColor(isPlaying ? AppTheme.accentBlue : AppTheme.textTertiary)
                }
                
                Spacer()
                
                // 状态指示
                if isPlaying {
                    Image(systemName: "pause.circle.fill")
                        .font(.title2)
                        .foregroundColor(AppTheme.accentBlue)
                } else {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                        .foregroundColor(AppTheme.textTertiary)
                }
            }
            .padding()
            .background(
                isPlaying ?
                AppTheme.accentBlue.opacity(0.1) : AppTheme.cardBackground
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isPlaying ? AppTheme.accentBlue : Color.clear,
                        lineWidth: 2
                    )
            )
        }
    }
    
    private var isPlaying: Bool {
        return soundManager.currentSound == sound && soundManager.isPlaying
    }
    
    private var soundIcon: String {
        switch sound {
        case .rain: return "cloud.rain.fill"
        case .ocean: return "waveform.path.ecg"
        case .forest: return "tree.fill"
        case .cafe: return "cup.and.saucer.fill"
        case .fireplace: return "flame.fill"
        case .wind: return "wind"
        case .none: return "speaker.slash.fill"
        }
    }
}

#Preview {
    SoundPickerView()
        .environmentObject(SoundManager())
}
