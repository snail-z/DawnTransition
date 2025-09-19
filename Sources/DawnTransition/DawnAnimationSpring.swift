//
//  DawnAnimationSpring.swift
//  DawnTransition
//
//  Created by zhang on 2020/7/25.
//  Copyright (c) 2020 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

open class DawnAnimationSpring: DawnAnimationProducer {
    
    public enum Direction {
        case left, right, up, down
        
        public var reversed: Direction {
            switch self {
            case .left: return .right
            case .right: return .left
            case .up: return .down
            case .down: return .up
            }
        }
    }
    
    /// 设置动画转场方向，默认.left
    public var direction: Direction = .left { didSet { setupSpringAnimation() } }
    
    /// 动画是否自动按反方向消失，默认true
    public var isReversed: Bool = true { didSet { setupSpringAnimation() } }
    
    /// 设置动画持续时间
    public var duration: TimeInterval = 0.6 { didSet { setupSpringAnimation() } }
    
    /// 设置后方视图缩放比例，默认0.95
    public var scale: CGFloat = 0.95 { didSet { setupSpringAnimation() } }
    
    /// 圆角（默认与系统一致 6），可按需调大；会覆盖默认的 initialCorner/defaultCorner
    public var cornerRadius: CGFloat = 30 { didSet { setupSpringAnimation() } }
    
    /// 设置弹性阻尼参数，默认0.6
    public var damping: CGFloat = 0.6 { didSet { setupSpringAnimation() } }
    
    /// 设置弹性速度参数，默认0.2
    public var velocity: CGFloat = 0.2 { didSet { setupSpringAnimation() } }
    
    /// dismiss 阶段是否去除弹性（fromView 不弹），默认 true
    public var dismissingInanimate: Bool = true { didSet { setupSpringAnimation() } }
    
    public override init() {
        super.init()
        setupSpringAnimation()
    }
    
    private func setupSpringAnimation() {
        let pType: DawnAnimationType
        let dType: DawnAnimationType
        
        pType = .pageIn(direction: dawnDirection(direction), scale: scale)
        dType = isReversed ? pType.reversed() : pType
        
        presentingModifierStage = DawnAnimationType.stage(type: pType)
        dismissingModifierStage = DawnAnimationType.stage(type: dType)

        // 覆盖默认 corner 值为自定义的 cornerRadius
        func overrideCorner(_ mods: inout [DawnModifier]?, clips: Bool) {
            guard mods != nil else { return }
            mods!.append(.cornerRadius(cornerRadius))
            if clips { mods!.append(.clipsToBounds(true)) }
        }
        // presenting 阶段
        overrideCorner(&presentingModifierStage.fromViewBeginModifiers, clips: false)
        overrideCorner(&presentingModifierStage.fromViewEndModifiers, clips: true)
        overrideCorner(&presentingModifierStage.toViewBeginModifiers, clips: false)
        overrideCorner(&presentingModifierStage.toViewEndModifiers, clips: true)
        // dismissing 阶段
        overrideCorner(&dismissingModifierStage.fromViewBeginModifiers, clips: false)
        overrideCorner(&dismissingModifierStage.fromViewEndModifiers, clips: true)
        overrideCorner(&dismissingModifierStage.toViewBeginModifiers, clips: true)
        overrideCorner(&dismissingModifierStage.toViewEndModifiers, clips: false)
        
        let presentingHierarchy: [DawnTransitionAdjustable.Hierarchy] = [.from, .to]
        let dismissingHierarchy: [DawnTransitionAdjustable.Hierarchy] = [.to, .from]
        
        presentingAdjustable = DawnTransitionAdjustable(subviewsHierarchy: presentingHierarchy)
        dismissingAdjustable = DawnTransitionAdjustable(subviewsHierarchy: dismissingHierarchy)
        
        presentingAdjustable.duration = duration
        presentingAdjustable.curve = .easeInOut
        presentingAdjustable.spring = (damping, velocity)
        presentingAdjustable.snapshotType = .slowSnapshot
        sameDismissingAdjustable()
        if dismissingInanimate {
            dismissingAdjustable.spring = nil
        }
    }
    
    private func dawnDirection(_ direction: Direction) -> DawnAnimationType.Direction {
        switch direction {
        case .left: return .left
        case .right: return .right
        case .up: return .up
        case .down: return .down
        }
    }
    
    /// 更新动画配置（如果你是批量修改属性，也可手动调用）
    public func updateConfiguration() { setupSpringAnimation() }
}
