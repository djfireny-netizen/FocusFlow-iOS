//
//  FocusFlowLiveActivityBundle.swift
//  FocusFlowLiveActivity
//
//  Created by 房亮 on 2026/4/7.
//

import WidgetKit
import SwiftUI

@main
struct FocusFlowLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        // 只保留实时活动
        FocusFlowLiveActivityLiveActivity()
    }
}
