import SwiftUI

// MARK: - 成就页面
struct AchievementsView: View {
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var statsManager: StatsManager
    
    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // 标题
                    Text(L("achievements"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    // 成就统计
                    achievementSummary
                    
                    // 成就列表
                    achievementsList
                }
            }
        }
    }
    
    // MARK: - 成就统计
    private var achievementSummary: some View {
        HStack(spacing: 15) {
            VStack(spacing: 8) {
                Text("\(unlockedCount)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.accentOrange)
                
                Text(L("unlocked"))
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppTheme.cardBackground)
            .cornerRadius(16)
            
            VStack(spacing: 8) {
                Text("\(totalAchievements)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(L("total_achievements"))
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppTheme.cardBackground)
            .cornerRadius(16)
        }
        .padding(.horizontal, 20)
    }
    
    private var unlockedCount: Int {
        achievements.filter { $0.unlocked }.count
    }
    
    private var totalAchievements: Int {
        achievements.count
    }
    
    // MARK: - 成就列表
    private var achievementsList: some View {
        VStack(spacing: 12) {
            ForEach(Array(achievements.enumerated()), id: \.element.id) { index, achievement in
                AchievementCard(achievement: achievement)
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - 成就数据
    private var achievements: [AchievementItem] {
        [
            AchievementItem(
                icon: "play.circle.fill",
                title: L("ach_first_try"),
                achievementDescription: L("ach_first_try_desc"),
                unlocked: statsManager.totalSessions >= 1,
                color: AppTheme.accentGreen
            ),
            AchievementItem(
                icon: "number.circle.fill",
                title: L("ach_getting_better"),
                achievementDescription: L("ach_getting_better_desc"),
                unlocked: statsManager.totalSessions >= 10,
                color: AppTheme.accentBlue
            ),
            AchievementItem(
                icon: "star.circle.fill",
                title: L("ach_focus_expert"),
                achievementDescription: L("ach_focus_expert_desc"),
                unlocked: statsManager.totalSessions >= 50,
                color: AppTheme.accentPurple
            ),
            AchievementItem(
                icon: "crown.fill",
                title: L("ach_focus_master"),
                achievementDescription: L("ach_focus_master_desc"),
                unlocked: statsManager.totalSessions >= 100,
                color: AppTheme.accentOrange
            ),
            AchievementItem(
                icon: "arrow.3.trianglepath",
                title: L("ach_persistent"),
                achievementDescription: L("ach_persistent_desc"),
                unlocked: statsManager.currentStreak >= 5,
                color: .orange
            ),
            AchievementItem(
                icon: "flame.fill",
                title: L("ach_on_fire"),
                achievementDescription: L("ach_on_fire_desc"),
                unlocked: statsManager.currentStreak >= 30,
                color: .red
            ),
            AchievementItem(
                icon: "sunrise.fill",
                title: L("ach_early_bird"),
                achievementDescription: L("ach_early_bird_desc"),
                unlocked: false,
                color: .yellow
            ),
            AchievementItem(
                icon: "moon.zzz.fill",
                title: L("ach_night_owl"),
                achievementDescription: L("ach_night_owl_desc"),
                unlocked: false,
                color: .purple
            ),
            AchievementItem(
                icon: "hourglass",
                title: L("ach_marathon"),
                achievementDescription: L("ach_marathon_desc"),
                unlocked: false,
                color: AppTheme.accentBlue
            ),
            AchievementItem(
                icon: "clock.fill",
                title: L("ach_time_lord"),
                achievementDescription: L("ach_time_lord_desc"),
                unlocked: statsManager.totalFocusTime >= 360000,
                color: AppTheme.accentPurple
            ),
            AchievementItem(
                icon: "checkmark.circle.fill",
                title: L("ach_goal_achiever"),
                achievementDescription: L("ach_goal_achiever_desc"),
                unlocked: false,
                color: AppTheme.accentGreen
            ),
            AchievementItem(
                icon: "chart.line.uptrend.xyaxis",
                title: L("ach_weekly_star"),
                achievementDescription: L("ach_weekly_star_desc"),
                unlocked: false,
                color: .orange
            ),
            AchievementItem(
                icon: "star.fill",
                title: L("ach_monthly_star"),
                achievementDescription: L("ach_monthly_star_desc"),
                unlocked: false,
                color: .yellow
            ),
            AchievementItem(
                icon: "waveform.path.ecg.rectangle",
                title: L("ach_wh_noise_lover"),
                achievementDescription: L("ach_wh_noise_lover_desc"),
                unlocked: false,
                color: AppTheme.accentBlue
            ),
            AchievementItem(
                icon: "bolt.fill",
                title: L("ach_efficient"),
                achievementDescription: L("ach_efficient_desc"),
                unlocked: false,
                color: .red
            ),
            AchievementItem(
                icon: "book.fill",
                title: L("ach_study_expert"),
                achievementDescription: L("ach_study_expert_desc"),
                unlocked: false,
                color: AppTheme.accentPurple
            ),
            AchievementItem(
                icon: "briefcase.fill",
                title: L("ach_workaholic"),
                achievementDescription: L("ach_workaholic_desc"),
                unlocked: false,
                color: AppTheme.accentOrange
            ),
            AchievementItem(
                icon: "heart.fill",
                title: L("ach_balanced_life"),
                achievementDescription: L("ach_balanced_life_desc"),
                unlocked: false,
                color: .pink
            )
        ]
    }
}

// MARK: - 成就卡片
struct AchievementCard: View {
    let achievement: AchievementItem
    
    var body: some View {
        HStack(spacing: 15) {
            // 图标
            Image(systemName: achievement.icon)
                .font(.title)
                .foregroundColor(achievement.unlocked ? achievement.color : AppTheme.textTertiary)
                .frame(width: 50, height: 50)
                .background(
                    achievement.unlocked ?
                    achievement.color.opacity(0.2) : AppTheme.backgroundSecondary
                )
                .clipShape(Circle())
            
            // 文字
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(
                        achievement.unlocked ? AppTheme.textPrimary : AppTheme.textTertiary
                    )
                
                Text(achievement.achievementDescription)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
            
            // 状态
            if achievement.unlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(achievement.color)
            } else {
                Image(systemName: "lock.fill")
                    .font(.title2)
                    .foregroundColor(AppTheme.textTertiary)
            }
        }
        .padding()
        .background(
            achievement.unlocked ? AppTheme.cardBackground : AppTheme.cardBackground.opacity(0.5)
        )
        .cornerRadius(16)
    }
}

// MARK: - 成就模型
struct AchievementItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let achievementDescription: String
    let unlocked: Bool
    let color: Color
}

#Preview {
    AchievementsView()
        .environmentObject(TimerManager())
        .environmentObject(StatsManager())
}
