import Foundation
import SwiftUI

// MARK: - 统计数据管理器
class StatsManager: ObservableObject {
    @Published var todayFocusTime: TimeInterval = 0
    @Published var totalFocusTime: TimeInterval = 0
    @Published var todaySessions: Int = 0
    @Published var totalSessions: Int = 0
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var weeklyData: [DayData] = []
    @Published var categoryStats: [CategoryStat] = []
    
    // MARK: - 加载数据
    func loadData(sessions: [FocusSession] = []) {
        calculateStats(from: sessions)
        generateWeeklyData(sessions: sessions)
        generateCategoryStats(sessions: sessions)
    }
    
    // MARK: - 获取今日统计（用于 Watch）
    func getTodayStats() -> TodayStatsData {
        return TodayStatsData(
            totalMinutes: Int(todayFocusTime / 60),
            sessionCount: todaySessions,
            categories: categoryStats.map { CategoryStatData(name: $0.name, minutes: Int($0.totalTime / 60), count: $0.count) }
        )
    }
    
    // MARK: - 计算统计
    private func calculateStats(from sessions: [FocusSession]) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // 今日数据
        let todaySessions = sessions.filter { 
            calendar.startOfDay(for: $0.startTime) == today && $0.completed 
        }
        todayFocusTime = todaySessions.reduce(0) { $0 + $1.duration }
        self.todaySessions = todaySessions.count
        
        // 总计数据
        let completedSessions = sessions.filter { $0.completed }
        totalFocusTime = completedSessions.reduce(0) { $0 + $1.duration }
        totalSessions = completedSessions.count
        
        // 连续天数
        calculateStreaks(sessions: completedSessions)
    }
    
    // MARK: - 计算连续天数
    private func calculateStreaks(sessions: [FocusSession]) {
        let calendar = Calendar.current
        var streak = 0
        var longestStreak = 0
        var currentStreak = 0
        
        // 获取所有有专注记录的日期
        var dates = Set<Date>()
        for session in sessions {
            let date = calendar.startOfDay(for: session.startTime)
            dates.insert(date)
        }
        
        // 计算当前连续天数
        var checkDate = calendar.startOfDay(for: Date())
        while dates.contains(checkDate) {
            currentStreak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }
        
        // 计算最长连续天数
        let sortedDates = Array(dates).sorted(by: >)
        if !sortedDates.isEmpty {
            streak = 1
            longestStreak = 1
            
            for i in 1..<sortedDates.count {
                let daysDiff = calendar.dateComponents([.day], from: sortedDates[i], to: sortedDates[i-1]).day
                if daysDiff == 1 {
                    streak += 1
                    longestStreak = max(longestStreak, streak)
                } else {
                    streak = 1
                }
            }
        }
        
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
    }
    
    // MARK: - 生成周数据
    private func generateWeeklyData(sessions: [FocusSession]) {
        let calendar = Calendar.current
        var weekData: [DayData] = []
        
        for i in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -i, to: Date()) else { continue }
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            let daySessions = sessions.filter {
                $0.startTime >= startOfDay && $0.startTime < endOfDay && $0.completed
            }
            let dayMinutes = daySessions.reduce(0) { $0 + $1.duration } / 60
            
            let weekday = calendar.component(.weekday, from: date)
            let weekdaySymbol = localizedWeekday(weekday)
            
            weekData.append(DayData(
                date: date,
                weekday: weekdaySymbol,
                minutes: Int(dayMinutes)
            ))
        }
        
        self.weeklyData = weekData
    }
    
    // MARK: - 生成分类统计
    private func generateCategoryStats(sessions: [FocusSession]) {
        let completedSessions = sessions.filter { $0.completed }
        var categoryMap: [String: TimeInterval] = [:]
        
        for session in completedSessions {
            categoryMap[session.category, default: 0] += session.duration
        }
        
        self.categoryStats = categoryMap
            .map { CategoryStat(category: $0.key, minutes: Int($0.value / 60)) }
            .sorted { $0.minutes > $1.minutes }
    }
    
    // MARK: - 格式化辅助
    func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)小时\(minutes)分钟"
        }
        return "\(minutes)分钟"
    }
}

// MARK: - 数据模型
struct DayData: Identifiable {
    let id = UUID()
    let date: Date
    let weekday: String
    let minutes: Int
}

struct CategoryStat: Identifiable {
    let id = UUID()
    let category: String
    let minutes: Int
}

// MARK: - Watch 通信数据模型
struct TodayStatsData {
    let totalMinutes: Int
    let sessionCount: Int
    let categories: [CategoryStatData]
}

struct CategoryStatData {
    let name: String
    let minutes: Int
    let count: Int
}

// MARK: - 星期本地化
private func localizedWeekday(_ weekday: Int) -> String {
    // weekday: 1=周日, 2=周一, ..., 7=周六
    let keys = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
    let index = (weekday - 1) % 7
    return L("weekday_" + keys[index])
}
