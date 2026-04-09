import Foundation
import SwiftData

// MARK: - 成就检查器
class AchievementChecker {
    static let shared = AchievementChecker()
    
    // MARK: - 检查并解锁成就
    func checkAndUnlockAchievements(context: ModelContext, stats: StatsManager) {
        checkSessionAchievements(context: context, stats: stats)
        checkStreakAchievements(context: context, stats: stats)
        checkDurationAchievements(context: context, stats: stats)
        checkSpecialAchievements(context: context, stats: stats)
    }
    
    // MARK: - 专注次数成就
    private func checkSessionAchievements(context: ModelContext, stats: StatsManager) {
        let totalSessions = stats.totalSessions
        
        unlockIfConditionMet(context: context, type: .firstSession, condition: totalSessions >= 1)
        unlockIfConditionMet(context: context, type: .tenSessions, condition: totalSessions >= 10)
        unlockIfConditionMet(context: context, type: .fiftySessions, condition: totalSessions >= 50)
        unlockIfConditionMet(context: context, type: .hundredSessions, condition: totalSessions >= 100)
        unlockIfConditionMet(context: context, type: .twoHundredSessions, condition: totalSessions >= 200)
        unlockIfConditionMet(context: context, type: .fiveHundredSessions, condition: totalSessions >= 500)
    }
    
    // MARK: - 连续专注成就
    private func checkStreakAchievements(context: ModelContext, stats: StatsManager) {
        let currentStreak = stats.currentStreak
        
        unlockIfConditionMet(context: context, type: .fiveDayStreak, condition: currentStreak >= 5)
        unlockIfConditionMet(context: context, type: .sevenDayStreak, condition: currentStreak >= 7)
        unlockIfConditionMet(context: context, type: .fourteenDayStreak, condition: currentStreak >= 14)
        unlockIfConditionMet(context: context, type: .thirtyDayStreak, condition: currentStreak >= 30)
        unlockIfConditionMet(context: context, type: .sixtyDayStreak, condition: currentStreak >= 60)
        unlockIfConditionMet(context: context, type: .hundredDayStreak, condition: currentStreak >= 100)
    }
    
    // MARK: - 专注时长成就
    private func checkDurationAchievements(context: ModelContext, stats: StatsManager) {
        let totalHours = stats.totalFocusTime / 3600
        
        unlockIfConditionMet(context: context, type: .tenHoursFocus, condition: totalHours >= 10)
        unlockIfConditionMet(context: context, type: .fiftyHoursFocus, condition: totalHours >= 50)
        unlockIfConditionMet(context: context, type: .twoHundredHoursFocus, condition: totalHours >= 200)
        unlockIfConditionMet(context: context, type: .fiveHundredHoursFocus, condition: totalHours >= 500)
        unlockIfConditionMet(context: context, type: .thousandHoursFocus, condition: totalHours >= 1000)
    }
    
    // MARK: - 特殊成就
    private func checkSpecialAchievements(context: ModelContext, stats: StatsManager) {
        // 这些成就需要在特定操作时手动调用解锁
    }
    
    // MARK: - 解锁成就（如果满足条件）
    private func unlockIfConditionMet(context: ModelContext, type: AchievementType, condition: Bool) {
        guard condition else { return }
        
        let fetchDescriptor = FetchDescriptor<Achievement>(
            predicate: #Predicate<Achievement> { $0.type == type }
        )
        
        guard let achievements = try? context.fetch(fetchDescriptor),
              let achievement = achievements.first,
              !achievement.unlocked else {
            return
        }
        
        // 解锁成就
        achievement.unlocked = true
        achievement.unlockedDate = Date()
        
        // 保存
        try? context.save()
        
        // 通知 UI
        NotificationCenter.default.post(
            name: NSNotification.Name("AchievementUnlocked"),
            object: nil,
            userInfo: ["achievement": achievement]
        )
        
        print("🏆 成就解锁: \(achievement.title)")
    }
    
    // MARK: - 手动解锁特殊成就
    func unlockSpecialAchievement(context: ModelContext, type: AchievementType) {
        unlockIfConditionMet(context: context, type: type, condition: true)
    }
}
