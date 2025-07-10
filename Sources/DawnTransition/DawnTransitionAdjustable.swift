//
//  DawnTransitionAdjustable.swift
//  DawnTransition
//
//  Created by zhang on 2020/6/26.
//  Copyright (c) 2020 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

public struct DawnTransitionAdjustable {
 
    /// 动画延迟
    public var delay: TimeInterval = 0
    
    /// 动画时长
    public var duration: TimeInterval = 0.295
    
    /// 动画曲线，默认慢快慢
    public var curve: DawnAnimationCurve = .easeInOut
    
    /// 使用自定义阻尼弹性动画
    public var spring: (damping: CGFloat, velocity: CGFloat)?
    
    /// 默认不使用快照，直接使用控制器view
    public var snapshotType: DawnAnimationSnapshotType = .noSnapshot
    
    /// 转场容器背景色
    public var containerBackgroundColor: UIColor = .black
    
    /// 转场容器子视图类型
    public enum Hierarchy { case from, to }
    
    /// 控制子视图添加顺序，默认addFromView、然后addToView
    public var subviewsHierarchy: [Hierarchy] = [.from, .to]
}

public enum DawnAnimationCurve {
    
    case linear
    case easeIn
    case easeOut
    case easeInOut
}

extension DawnAnimationCurve {
    
    public var options: UIView.AnimationOptions {
        switch self {
        case .linear: return .curveLinear
        case .easeIn: return .curveEaseIn
        case .easeOut: return .curveEaseOut
        case .easeInOut: return .curveEaseInOut
        }
    }
}

public enum DawnAnimationSnapshotType {
    
    /// 默认不创建快照，直接对视图做动画
    case noSnapshot
    
    /// 创建视图快照后再做动画
    case slowSnapshot
}
