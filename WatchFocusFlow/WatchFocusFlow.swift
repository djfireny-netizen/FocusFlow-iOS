//
//  WatchFocusFlow.swift
//  WatchFocusFlow
//
//  Created by 房亮 on 2026/4/10.
//

import AppIntents

struct WatchFocusFlow: AppIntent {
    static var title: LocalizedStringResource { "WatchFocusFlow" }
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
