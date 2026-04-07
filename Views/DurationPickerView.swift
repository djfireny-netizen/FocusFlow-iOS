import SwiftUI

// MARK: - 时长选择器 (底部 Sheet)
struct DurationPickerView: View {
    @Environment(\.dismiss) var dismiss
    
    let title: String
    let currentValue: Int
    let options: [Int]
    let onSelect: (Int) -> Void
    
    @State private var selectedValue: Int
    
    init(title: String, currentValue: Int, options: [Int], onSelect: @escaping (Int) -> Void) {
        self.title = title
        self.currentValue = currentValue
        self.options = options
        self.onSelect = onSelect
        self._selectedValue = State(initialValue: currentValue)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 当前选中值大显示
                VStack(spacing: 8) {
                    Text("\(selectedValue)")
                        .font(.system(size: 72, weight: .light, design: .rounded))
                        .foregroundColor(Color(hex: "667eea"))
                    
                    Text(L("minutes_plain"))
                        .font(.title3)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "667eea").opacity(0.1), Color(hex: "764ba2").opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // 快速选择网格
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
                        ForEach(options, id: \.self) { minutes in
                            TimeOptionButton(
                                minutes: minutes,
                                isSelected: selectedValue == minutes,
                                action: {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedValue = minutes
                                    }
                                }
                            )
                        }
                    }
                    .padding(20)
                }
                
                Spacer()
            }
            .background(AppTheme.backgroundPrimary)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L("cancel")) {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L("done")) {
                        onSelect(selectedValue)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "667eea"))
                }
            }
        }
    }
    
    private var isChinese: Bool {
        LanguageManager.shared.isChinese
    }
}

// MARK: - 时间选项按钮
struct TimeOptionButton: View {
    let minutes: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(minutes)")
                    .font(.system(size: 20, weight: isSelected ? .bold : .medium, design: .rounded))
                
                Text(L("minutes_plain"))
                    .font(.caption2)
            }
            .foregroundColor(isSelected ? .white : AppTheme.textPrimary)
            .frame(width: 80, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(hex: "667eea") : AppTheme.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.2), value: isSelected)
    }
}

#Preview {
    DurationPickerView(
        title: "专注时长",
        currentValue: 25,
        options: [15, 20, 25, 30, 45, 50, 60, 90]
    ) { _ in }
}
