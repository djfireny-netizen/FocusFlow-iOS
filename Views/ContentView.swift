import SwiftUI

// MARK: - 启动页面
struct LaunchScreenView: View {
    @State private var isActive = false
    @State private var opacity = 0.0
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                // 深色背景
                AppTheme.backgroundPrimary
                    .ignoresSafeArea()
                
                // 渐变球体背景
                AppTheme.gradientOrb(size: 400)
                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
                
                VStack(spacing: 24) {
                    // Logo 图标
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "timer")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(scale)
                    
                    // 应用名称
                    Text("FocusFlow")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    // 标语
                    Text(L("stay_focused"))
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                    
                    // 加载指示器
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "ff6b35")))
                        .scaleEffect(1.2)
                        .padding(.top, 40)
                }
                .opacity(opacity)
            }
            .onAppear {
                // 淡入动画
                withAnimation(.easeOut(duration: 0.8)) {
                    opacity = 1.0
                    scale = 1.0
                }
                
                // 2秒后跳转到主界面
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeIn(duration: 0.5)) {
                        isActive = true
                    }
                }
            }
        }
    }
}

// MARK: - 主界面
struct ContentView: View {
    @State private var selectedTab: Int = 0
    @StateObject private var languageManager = LanguageManager.shared
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 计时器页面
            TimerView()
                .tabItem {
                    Image(systemName: "timer")
                    Text(L("focus"))
                }
                .tag(0)
            
            // 统计页面
            StatsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text(L("statistics"))
                }
                .tag(1)
            
            // 成就页面
            AchievementsView()
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text(L("achievements"))
                }
                .tag(2)
            
            // 设置页面
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text(L("settings"))
                }
                .tag(3)
        }
        .accentColor(AppTheme.accentOrange)
        // 语言切换时强制刷新
        .id(languageManager.currentLanguage)
    }
}

// MARK: - 全屏专注模式
struct FullScreenFocusView: View {
    @EnvironmentObject var timerManager: TimerManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // 背景
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // 分类标签
                if timerManager.timerState == .focusing || timerManager.timerState == .paused {
                    Text(timerManager.selectedCategory)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                // 计时器圆环
                ZStack {
                    // 外圈
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 8)
                        .frame(width: 280, height: 280)
                    
                    // 进度圈
                    Circle()
                        .trim(from: 0, to: timerManager.progress)
                        .stroke(
                            AppTheme.primaryGradient,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 280, height: 280)
                        .animation(.linear(duration: 1), value: timerManager.progress)
                    
                    // 中心内容
                    VStack(spacing: 8) {
                        Text(timerManager.formattedTime)
                            .font(.system(size: 72, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        if timerManager.timerState == .onBreak {
                            Text(L("on_break"))
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                
                // 状态提示
                if timerManager.timerState == .focusing {
                    Text(L("focusing"))
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 20)
                } else if timerManager.timerState == .paused {
                    Text(L("paused"))
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 20)
                }
                
                Spacer()
                
                // 底部控制按钮
                HStack(spacing: 40) {
                    if timerManager.timerState == .focusing || timerManager.timerState == .paused {
                        // 停止按钮
                        Button(action: {
                            timerManager.stopTimer()
                            dismiss()
                        }) {
                            Image(systemName: "stop.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 70, height: 70)
                                .background(Color.red.opacity(0.8))
                                .clipShape(Circle())
                        }
                        
                        // 暂停/继续按钮
                        Button(action: {
                            if timerManager.timerState == .focusing {
                                timerManager.pauseTimer()
                            } else {
                                timerManager.resumeTimer()
                            }
                        }) {
                            Image(systemName: timerManager.timerState == .focusing ? "pause.fill" : "play.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 90, height: 90)
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Circle())
                                .shadow(color: Color(hex: "667eea").opacity(0.5), radius: 20, y: 10)
                        }
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    ContentView()
}
