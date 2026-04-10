import Foundation
import SwiftUI
import UIKit

// MARK: - 数据导出管理器
class ExportManager {
    static let shared = ExportManager()
    
    // MARK: - 导出专注数据为 CSV
    func exportFocusDataAsCSV(sessions: [FocusSession]) -> URL? {
        // CSV 头部
        var csvText = "日期,开始时间,结束时间,专注时长(分钟),分类,是否完成,备注\n"
        
        // 按日期排序
        let sortedSessions = sessions.sorted { $0.startTime > $1.startTime }
        
        // 添加数据行
        for session in sortedSessions {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.string(from: session.startTime)
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm:ss"
            let startTime = timeFormatter.string(from: session.startTime)
            let endTime = timeFormatter.string(from: session.endTime)
            
            let durationMinutes = Int(session.duration / 60)
            let category = session.category
            let completed = session.completed ? "是" : "否"
            let notes = session.notes.replacingOccurrences(of: ",", with: "，")
            
            let row = "\(date),\(startTime),\(endTime),\(durationMinutes),\(category),\(completed),\(notes)\n"
            csvText += row
        }
        
        // 写入文件
        let filename = "FocusFlow_数据_\(Date().formatted(date: .numeric, time: .omitted)).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        
        do {
            try csvText.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            print("❌ 导出 CSV 失败: \(error)")
            return nil
        }
    }
    
    // MARK: - 导出统计数据为文本
    func exportStatsAsText(
        totalSessions: Int,
        totalFocusTime: TimeInterval,
        currentStreak: Int,
        longestStreak: Int,
        todaySessions: Int,
        todayFocusTime: TimeInterval
    ) -> URL? {
        let totalHours = Int(totalFocusTime) / 3600
        let totalMinutes = (Int(totalFocusTime) % 3600) / 60
        let todayHours = Int(todayFocusTime) / 3600
        let todayMinutes = (Int(todayFocusTime) % 3600) / 60
        
        var text = "FocusFlow 专注统计报告\n"
        text += "========================\n\n"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        text += "📅 生成时间: \(formatter.string(from: Date()))\n\n"
        
        text += "📊 累计统计\n"
        text += "--------\n"
        text += "总专注次数: \(totalSessions) 次\n"
        text += "总专注时长: \(totalHours) 小时 \(totalMinutes) 分钟\n"
        text += "当前连续: \(currentStreak) 天\n"
        text += "最长连续: \(longestStreak) 天\n\n"
        
        text += "📈 今日统计\n"
        text += "--------\n"
        text += "今日专注: \(todaySessions) 次\n"
        text += "今日时长: \(todayHours) 小时 \(todayMinutes) 分钟\n\n"
        
        text += "========\n"
        text += "通过 FocusFlow 生成\n"
        
        // 写入文件
        let filename = "FocusFlow_统计_\(Date().formatted(date: .numeric, time: .omitted)).txt"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        
        do {
            try text.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            print("❌ 导出统计失败: \(error)")
            return nil
        }
    }
    
    // MARK: - 分享文件
    func shareFile(url: URL) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return
        }
        
        let activityVC = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        
        // iPad 支持
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = window
            popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        rootViewController.present(activityVC, animated: true)
    }
}
