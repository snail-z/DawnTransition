//
//  DawnAnimationElasticSlide.swift
//  DawnTransition
//
//  Created by zhang on 2020/7/25.
//  Copyright (c) 2020 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

open class DawnAnimationElasticSlide: DawnAnimationProducer {
    
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
//    public var direction: Direction = .left
    
    /// 动画是否自动按反方向消失，默认true
    public var isReversed: Bool = true
    
    /// 设置动画持续时间
    public var duration: TimeInterval = 0.5
    
    /// 设置后方视图缩放比例，默认0.95
//    public var scale: CGFloat = 0.95
    
    /// 圆角，可按需调大；会覆盖默认的 initialCorner/defaultCorner
    public var cornerRadius: CGFloat = 30
    
    /// 设置弹性阻尼参数
    public var damping: CGFloat = 0.8
    
    /// 设置弹性速度参数
    public var velocity: CGFloat = 0.6
    
    /// 自定义动画类型
    public var presentType: DawnAnimationType = .push(direction: .left)
    
    public override init() {
        super.init()
        setupSpringAnimation()
    }
    
    private func setupSpringAnimation() {
        let pType: DawnAnimationType
        let dType: DawnAnimationType
        
        pType = presentType
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
        // 轻微阴影（仅在动画过程中可见，结束时清理）
        if presentingModifierStage.toViewBeginModifiers != nil {
            presentingModifierStage.toViewBeginModifiers!.append(.shadow(.black, opacity: 0.05, radius: 6, offset: .zero))
        }
        if presentingModifierStage.toViewEndModifiers != nil {
            presentingModifierStage.toViewEndModifiers!.append(.shadow(.clear, opacity: 0))
        }
        // dismissing 阶段
        overrideCorner(&dismissingModifierStage.fromViewBeginModifiers, clips: false)
        overrideCorner(&dismissingModifierStage.fromViewEndModifiers, clips: true)
        overrideCorner(&dismissingModifierStage.toViewBeginModifiers, clips: true)
        overrideCorner(&dismissingModifierStage.toViewEndModifiers, clips: false)
        
        // 轻微阴影（仅在动画过程中可见，结束时清理）
        if dismissingModifierStage.fromViewBeginModifiers != nil {
            dismissingModifierStage.fromViewBeginModifiers!.append(.shadow(.black, opacity: 0.06, radius: 6, offset: .zero))
        }
        if dismissingModifierStage.fromViewEndModifiers != nil {
            dismissingModifierStage.fromViewEndModifiers!.append(.shadow(.clear, opacity: 0))
        }
        
        let presentingHierarchy: [DawnTransitionAdjustable.Hierarchy] = [.from, .to]
        let dismissingHierarchy: [DawnTransitionAdjustable.Hierarchy] = [.to, .from]
        
        presentingAdjustable = DawnTransitionAdjustable(subviewsHierarchy: presentingHierarchy)
        dismissingAdjustable = DawnTransitionAdjustable(subviewsHierarchy: dismissingHierarchy)
        
        presentingAdjustable.duration = duration
        presentingAdjustable.curve = .easeInOut
        presentingAdjustable.spring = (damping, velocity)
        presentingAdjustable.snapshotType = .noSnapshot
        
        sameDismissingAdjustable()
    }
    
    private func dawnDirection(_ direction: Direction) -> DawnAnimationType.Direction {
        switch direction {
        case .left: return .left
        case .right: return .right
        case .up: return .up
        case .down: return .down
        }
    }
    
    /// 更新动画配置
    public func updateConfiguration() { setupSpringAnimation() }
}

extension DawnAnimationElasticSlide {
    
    public static func `default`() -> DawnAnimationElasticSlide {
        let springAnimation = DawnAnimationElasticSlide()
        springAnimation.presentType = .pageIn(direction: .left, scale: 0.95)
        springAnimation.damping = 0.85
        springAnimation.velocity = 0.2
        springAnimation.duration = 0.375
        springAnimation.updateConfiguration()
        return springAnimation
    }
}
