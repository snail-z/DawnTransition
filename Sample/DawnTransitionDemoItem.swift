//
//  DawnTransitionDemoItem.swift
//  DemoKit
//
//  Created by bible-team on 2025/7/22.
//  Copyright (c) 2025 bible-team All rights reserved.
//

import UIKit
import BibleBaseKit

/// DawnTransition 转场动画示例
public class DawnTransitionDemoItem: BaseDemoItem {
    
    public init() {
        super.init(
            title: "DawnTransition 转场动画",
            description: "展示 DawnTransition 库的各种转场动画效果，包括 Push、Modal、TabBar 切换等",
            category: .animations,
            tags: ["转场", "动画", "DawnTransition", "iOS动画", "交互"]
        )
    }
    
    public override func createViewController() -> UIViewController {
        return DawnTransitionExampleViewController()
    }
}
