import Foundation

// MARK: - 计时器状态同步数据
struct TimerStateSync: Codable {
    var state: String  // idle, focusing, paused, onBreak
    var timeRemaining: TimeInterval
    var progress: Double
    var currentSession: Int
    var focusDuration: TimeInterval
    var breakDuration: TimeInterval
    var selectedCategory: String
    var isPaused: Bool
    
    init(
        state: String,
        timeRemaining: TimeInterval,
        progress: Double = 0,
        currentSession: Int = 1,
        focusDuration: TimeInterval = 1500,
        breakDuration: TimeInterval = 300,
        selectedCategory: String = "工作",
        isPaused: Bool = false
    ) {
        self.state = state
        self.timeRemaining = timeRemaining
        self.progress = progress
        self.currentSession = currentSession
        self.focusDuration = focusDuration
        self.breakDuration = breakDuration
        self.selectedCategory = selectedCategory
        self.isPaused = isPaused
    }
}

// MARK: - 专注记录同步数据
struct SessionSync: Codable {
    var startTime: Date
    var endTime: Date
    var duration: TimeInterval
    var category: String
    var completed: Bool
    
    init(startTime: Date, endTime: Date, duration: TimeInterval, category: String, completed: Bool) {
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.category = category
        self.completed = completed
    }
}

// MARK: - 白噪音状态同步
struct SoundStateSync: Codable {
    var soundType: String
    var isPlaying: Bool
    var volume: Double
    
    init(soundType: String = "none", isPlaying: Bool = false, volume: Double = 0.5) {
        self.soundType = soundType
        self.isPlaying = isPlaying
        self.volume = volume
    }
}

// MARK: - 同步命令
enum SyncCommand: String, Codable {
    case startTimer = "start_timer"
    case pauseTimer = "pause_timer"
    case resumeTimer = "resume_timer"
    case stopTimer = "stop_timer"
    case skipToBreak = "skip_to_break"
    case startSound = "start_sound"
    case stopSound = "stop_sound"
    case updateSettings = "update_settings"
    case syncRequest = "sync_request"
    case syncResponse = "sync_response"
}

// MARK: - 同步消息
struct SyncMessage: Codable {
    var command: SyncCommand
    var timerState: TimerStateSync?
    var soundState: SoundStateSync?
    var sessions: [SessionSync]?
    var timestamp: Date
    
    init(command: SyncCommand, timerState: TimerStateSync? = nil, soundState: SoundStateSync? = nil, sessions: [SessionSync]? = nil) {
        self.command = command
        self.timerState = timerState
        self.soundState = soundState
        self.sessions = sessions
        self.timestamp = Date()
    }
}
