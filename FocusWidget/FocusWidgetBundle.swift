//
//  FocusWidgetBundle.swift
//  FocusWidget
//
//  Created by 房亮 on 2026/4/8.
//

import WidgetKit
import SwiftUI

@main
struct FocusWidgetBundle: WidgetBundle {
    var body: some Widget {
        FocusWidget()
        FocusWidgetControl()
        // 实时活动由 FocusFlowLiveActivity 扩展处理
    }
}
