import Foundation
import AVFoundation
import SwiftUI

// MARK: - 声音管理器
class SoundManager: ObservableObject {
    @Published var currentSound: WhiteNoiseType = .none
    @Published var isPlaying: Bool = false
    @Published var volume: Float = 0.5
    
    private var audioPlayer: AVAudioPlayer?
    private var wasPlayingBeforeInterruption = false
    
    init() {
        setupAudioSession()
        setupNotifications()
    }
    
    // MARK: - 设置通知监听
    private func setupNotifications() {
        // 监听音频中断通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioSessionInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
        
        // 监听应用进入前台
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func handleAudioSessionInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            // 中断开始,记录当前播放状态
            wasPlayingBeforeInterruption = isPlaying
        case .ended:
            // 中断结束,尝试恢复播放
            if wasPlayingBeforeInterruption {
                if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                    let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                    if options.contains(.shouldResume) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.resumeSound()
                        }
                    }
                }
            }
        @unknown default:
            break
        }
    }
    
    @objc private func handleAppDidBecomeActive() {
        // 应用回到前台时,如果应该播放但没有在播放,则恢复
        if currentSound != .none && !isPlaying {
            resumeSound()
        }
    }
    
    // MARK: - 设置音频会话(初始化时调用)
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .duckOthers])
            try session.setActive(true)
        } catch {
            print("初始化音频会话失败: \(error)")
        }
    }
    
    // MARK: - 播放控制
    func playSound(_ sound: WhiteNoiseType) {
        // 停止当前播放
        stopSound()
        
        guard sound != .none else {
            currentSound = .none
            isPlaying = false
            return
        }
        
        // 配置音频会话 - 确保后台播放和与其他音频混合
        configureAudioSession()
        
        // 加载音频文件
        guard let audioURL = Bundle.main.url(forResource: sound.fileName, withExtension: "mp3") else {
            print("音频文件未找到: \(sound.fileName)")
            currentSound = sound
            isPlaying = false
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.numberOfLoops = -1 // 无限循环
            audioPlayer?.volume = volume
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            currentSound = sound
            isPlaying = true
        } catch {
            print("播放音频失败: \(error)")
            currentSound = sound
            isPlaying = false
        }
    }
    
    // MARK: - 配置音频会话
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            // .playback 模式支持后台播放
            // .mixWithOthers 允许与其他音频(如音乐)同时播放
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("配置音频会话失败: \(error)")
        }
    }
    
    func stopSound() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentSound = .none
    }
    
    func pauseSound() {
        audioPlayer?.pause()
        isPlaying = false
    }
    
    func resumeSound() {
        audioPlayer?.play()
        isPlaying = true
    }
    
    func toggleSound(_ sound: WhiteNoiseType) {
        if currentSound == sound && isPlaying {
            stopSound()
        } else {
            playSound(sound)
        }
    }
    
    // MARK: - 音量控制
    func setVolume(_ volume: Float) {
        self.volume = volume
        audioPlayer?.volume = volume
    }
    
    // MARK: - 清理
    func cleanup() {
        stopSound()
    }
}
