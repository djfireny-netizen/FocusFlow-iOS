import SwiftUI
import Charts

// MARK: - 统计页面
struct StatsView: View {
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var statsManager: StatsManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // 标题
                    HStack {
                        Text(L("statistics"))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Spacer()
                        
                        // 分享按钮
                        Button(action: {
                            ShareManager.shared.shareStats(
                                todayFocusTime: statsManager.todayFocusTime,
                                todaySessions: statsManager.todaySessions,
                                totalSessions: statsManager.totalSessions,
                                currentStreak: statsManager.currentStreak
                            )
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title2)
                                .foregroundColor(Color(hex: "667eea"))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // 今日概览
                    todayOverview
                    
                    // 周趋势图
                    weeklyChartSection
                    
                    // 分类统计
                    categoryStatsSection
                    
                    // 连续天数
                    streakSection
                }
            }
        }
        .onAppear {
            statsManager.loadData(sessions: timerManager.sessions)
        }
    }
    
    // MARK: - 今日概览
    private var todayOverview: some View {
        VStack(spacing: 15) {
            HStack(spacing: 15) {
                StatCard(
                    icon: "clock.fill",
                    title: L("today_focus"),
                    value: statsManager.formatTime(statsManager.todayFocusTime),
                    color: Color(hex: "667eea")
                )
                
                StatCard(
                    icon: "checkmark.circle.fill",
                    title: L("completed_count"),
                    value: "\(statsManager.todaySessions)",
                    color: AppTheme.accentGreen
                )
            }
            
            // 每日目标进度
            dailyGoalProgress
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - 每日目标进度
    private var dailyGoalProgress: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "target")
                        .foregroundColor(Color(hex: "667eea"))
                    Text(L("daily_goal"))
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                }
                
                Spacer()
                
                let goalMinutes = UserDefaults.standard.integer(forKey: "dailyGoalMinutes") > 0 ? UserDefaults.standard.integer(forKey: "dailyGoalMinutes") : 120
                let progress = min(1.0, statsManager.todayFocusTime / (Double(goalMinutes) * 60))
                Text("\(Int(progress * 100))%")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(progress >= 1.0 ? AppTheme.accentGreen : Color(hex: "667eea"))
            }
            
            // 进度条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "667eea").opacity(0.2))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "667eea"),
                                    Color(hex: "764ba2")
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * min(1.0, statsManager.todayFocusTime / (Double(UserDefaults.standard.integer(forKey: "dailyGoalMinutes") > 0 ? UserDefaults.standard.integer(forKey: "dailyGoalMinutes") : 120) * 60)),
                            height: 12
                        )
                }
            }
            .frame(height: 12)
            
            // 进度文字
            HStack {
                let goalMinutes = UserDefaults.standard.integer(forKey: "dailyGoalMinutes") > 0 ? UserDefaults.standard.integer(forKey: "dailyGoalMinutes") : 120
                let completedMinutes = Int(statsManager.todayFocusTime / 60)
                Text("\(completedMinutes) / \(goalMinutes) \(L("minutes_plain"))")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                
                Spacer()
                
                if statsManager.todayFocusTime >= Double(goalMinutes) * 60 {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppTheme.accentGreen)
                        Text(L("goal_achieved"))
                            .font(.caption)
                            .foregroundColor(AppTheme.accentGreen)
                    }
                } else {
                    Text(L("minutes_remaining", goalMinutes - Int(statsManager.todayFocusTime / 60)))
                        .font(.caption)
                        .foregroundColor(AppTheme.textTertiary)
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(16)
    }
    
    // MARK: - 周趋势图
    private var weeklyChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L("weekly_trend"))
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            VStack(spacing: 10) {
                ForEach(statsManager.weeklyData.reversed()) { day in
                    WeekDayRow(day: day, maxMinutes: maxMinutes)
                }
            }
            .padding()
            .background(AppTheme.cardBackground)
            .cornerRadius(16)
        }
        .padding(.horizontal, 20)
    }
    
    private var maxMinutes: Int {
        statsManager.weeklyData.map { $0.minutes }.max() ?? 1
    }
    
    // MARK: - 分类统计
    private var categoryStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L("category_stats"))
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            if statsManager.categoryStats.isEmpty {
                Text(L("no_data"))
                    .foregroundColor(AppTheme.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(statsManager.categoryStats.prefix(5)) { stat in
                    CategoryRow(stat: stat, totalMinutes: totalMinutes)
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
    
    private var totalMinutes: Int {
        statsManager.categoryStats.reduce(0) { $0 + $1.minutes }
    }
    
    // MARK: - 连续天数
    private var streakSection: some View {
        HStack(spacing: 15) {
            StatCard(
                icon: "flame.fill",
                title: L("current_streak"),
                value: "\(statsManager.currentStreak)" + L("days_unit"),
                color: AppTheme.accentOrange
            )
            
            StatCard(
                icon: "trophy.fill",
                title: L("longest_streak"),
                value: "\(statsManager.longestStreak)" + L("days_unit"),
                color: AppTheme.accentPurple
            )
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - 统计卡片
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(16)
    }
}

// MARK: - 周数据行
struct WeekDayRow: View {
    let day: DayData
    let maxMinutes: Int
    
    var body: some View {
        HStack(spacing: 12) {
            Text(day.weekday)
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
                .frame(width: 30)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.backgroundSecondary)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            AnyShapeStyle(
                                day.minutes > 0 ?
                                AnyShapeStyle(LinearGradient(
                                    colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )) : AnyShapeStyle(Color.clear)
                            )
                        )
                        .frame(width: barWidth)
                }
            }
            .frame(height: 24)
            
            Text(day.minutes > 0 ? "\(day.minutes)" + L("minutes_plain") : "-")
                .font(.caption)
                .foregroundColor(AppTheme.textTertiary)
                .frame(width: 60, alignment: .trailing)
        }
    }
    
    private var barWidth: CGFloat {
        guard maxMinutes > 0 else { return 0 }
        return CGFloat(day.minutes) / CGFloat(maxMinutes) * 200
    }
}

// MARK: - 分类统计行
struct CategoryRow: View {
    let stat: CategoryStat
    let totalMinutes: Int
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(L("cat_" + stat.category))
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Text("\(stat.minutes)" + L("minutes_plain"))
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.backgroundSecondary)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.primaryGradient)
                        .frame(width: barWidth)
                }
            }
            .frame(height: 8)
        }
    }
    
    private var percentage: Double {
        guard totalMinutes > 0 else { return 0 }
        return Double(stat.minutes) / Double(totalMinutes)
    }
    
    private var barWidth: CGFloat {
        return CGFloat(percentage) * 250
    }
}

#Preview {
    StatsView()
        .environmentObject(TimerManager())
        .environmentObject(StatsManager())
        .environmentObject(SubscriptionManager())
}
