import Foundation
import MediaPlayer
import AVFoundation

// MARK: - 锁屏控制中心
class LockScreenManager {
    static let shared = LockScreenManager()
    
    private let commandCenter = MPRemoteCommandCenter.shared()
    private var nowPlayingInfo = [String: Any]()
    private var audioSession: AVAudioSession?
    
    // MARK: - 激活音频会话 (让锁屏显示)
    func activateAudioSession() {
        do {
            audioSession = AVAudioSession.sharedInstance()
            try audioSession?.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession?.setActive(true)
        } catch {
            print("激活音频会话失败: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 停用音频会话
    func deactivateAudioSession() {
        do {
            try audioSession?.setActive(false)
        } catch {
            print("停用音频会话失败: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 配置锁屏控制
    func configureLockScreenControls(
        timerTitle: String,
        isPlaying: Bool,
        elapsedTime: TimeInterval,
        totalDuration: TimeInterval,
        playHandler: @escaping () -> Void,
        pauseHandler: @escaping () -> Void,
        stopHandler: @escaping () -> Void
    ) {
        // 更新正在播放信息
        updateNowPlayingInfo(
            title: timerTitle,
            isPlaying: isPlaying,
            elapsedTime: elapsedTime,
            totalDuration: totalDuration
        )
        
        // 播放按钮
        commandCenter.playCommand.isEnabled = !isPlaying
        commandCenter.playCommand.removeTarget(nil)
        commandCenter.playCommand.addTarget { _ in
            playHandler()
            return .success
        }
        
        // 暂停按钮
        commandCenter.pauseCommand.isEnabled = isPlaying
        commandCenter.pauseCommand.removeTarget(nil)
        commandCenter.pauseCommand.addTarget { _ in
            pauseHandler()
            return .success
        }
        
        // 停止按钮
        commandCenter.stopCommand.isEnabled = true
        commandCenter.stopCommand.removeTarget(nil)
        commandCenter.stopCommand.addTarget { _ in
            stopHandler()
            return .success
        }
    }
    
    // MARK: - 更新锁屏信息
    func updateNowPlayingInfo(
        title: String,
        isPlaying: Bool,
        elapsedTime: TimeInterval,
        totalDuration: TimeInterval
    ) {
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = "FocusFlow"
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = "专注计时器"
        
        // 关键: 设置已播放时间和播放速率,让系统自动更新倒计时
        if #available(iOS 10.0, *) {
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: elapsedTime)
        }
        
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = NSNumber(value: totalDuration)
        // 播放速率: 1.0 = 正在播放, 0.0 = 暂停
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        
        // 应用更新
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    // MARK: - 清除锁屏信息
    func clearLockScreenInfo() {
        nowPlayingInfo.removeAll()
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        
        commandCenter.playCommand.isEnabled = false
        commandCenter.pauseCommand.isEnabled = false
        commandCenter.stopCommand.isEnabled = false
    }
}
