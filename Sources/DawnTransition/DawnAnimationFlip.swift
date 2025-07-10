//
//  DawnAnimationFlip.swift
//  DawnTransition
//
//  Created by zhang on 2022/7/25.
//  Copyright (c) 2022 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

open class DawnAnimationFlip: DawnAnimationTransform, DawnAnimationCapable {

    public enum Direction {
        case left, right, top, bottom
        
        public var reversed: Direction {
            switch self {
            case .left: return .right
            case .right: return .left
            case .top: return .bottom
            case .bottom: return .top
            }
        }
        
        public var isVertical: Bool {
            switch self {
            case .left, .right: return false
            case .top, .bottom: return true
            }
        }
    }

    /// 动画从哪个方向翻转，默认水平往左
    public var direction: Direction = .left
    
    /// 按比例缩放来呈现视角的远近，perspective越大效果越明显，取值[0, 1]
    public enum FlipType {
        case door(perspective: Double = 0.25)
        case shutters(perspective: Double = 0)
    }
    
    /// 动画样式
    public var type: FlipType = .door()
    
    /// 动画时长
    public var duration: TimeInterval = 0.85
    
    /// 第二阶段动画相对总体进度，默认25%
    public var secondRelativeTimes: Double = 0.25
    
    /// 动画是否有淡入淡出效果，默认true
    public var isNeededFade: Bool = true
    
    /// 动画是否自动按反方向消失，默认true
    public var isReversed: Bool = true
    
    public func dawnAnimationPresenting(_ dawn: DawnTransition) {
        animateTransitioning(dawn, direction: direction)
    }
    
    public func dawnAnimationDismissing(_ dawn: DawnTransition) {
        animateTransitioning(dawn, direction: isReversed ? direction.reversed : direction)
    }
    
    private func animateTransitioning(_ dawn: DawnTransition, direction: Direction) {
        let containerView = dawn.containerView!
        guard let fromSnoptView = dawn.fromViewController?.view else { return }
        guard let toSnoptView = dawn.toViewController?.view else { return }
        containerView.addSubview(toSnoptView)
        containerView.sendSubviewToBack(toSnoptView)
        
        let initialFrame = dawn.transitionContext!.initialFrame(for: dawn.fromViewController!)
        fromSnoptView.frame = initialFrame
        toSnoptView.frame = initialFrame
        
        var beginFromViewT: CATransform3D, endFromViewT: CATransform3D
        var beginToViewT: CATransform3D, endToViewT: CATransform3D
        var fromViewAnchorPoint: CGPoint, toViewAnchorPoint: CGPoint
        switch direction {
        case .left:
            beginFromViewT = CATransform3DIdentity
            endFromViewT = rotate(axis: .y, angle: .pi / 2)
            beginToViewT = rotate(axis: .y, angle: -.pi / 2)
            endToViewT = CATransform3DIdentity
            fromViewAnchorPoint = anchorPoint(boundaries: .left)
            toViewAnchorPoint = anchorPoint(boundaries: .right)
        case .right:
            beginFromViewT = CATransform3DIdentity
            endFromViewT = rotate(axis: .y, angle: -.pi / 2)
            beginToViewT = rotate(axis: .y, angle: .pi / 2)
            endToViewT = CATransform3DIdentity
            fromViewAnchorPoint = anchorPoint(boundaries: .right)
            toViewAnchorPoint = anchorPoint(boundaries: .left)
        case .top:
            beginFromViewT = CATransform3DIdentity
            endFromViewT = rotate(axis: .x, angle: -.pi / 2)
            beginToViewT = rotate(axis: .x, angle: .pi / 2)
            endToViewT = CATransform3DIdentity
            fromViewAnchorPoint = anchorPoint(boundaries: .top)
            toViewAnchorPoint = anchorPoint(boundaries: .bottom)
        case .bottom:
            beginFromViewT = CATransform3DIdentity
            endFromViewT = rotate(axis: .x, angle: .pi / 2)
            beginToViewT = rotate(axis: .x, angle: -.pi / 2)
            endToViewT = CATransform3DIdentity
            fromViewAnchorPoint = anchorPoint(boundaries: .bottom)
            toViewAnchorPoint = anchorPoint(boundaries: .top)
        }
        
        adjustAnchorPointAndOffset(
            fromViewAnchorPoint,
            direction: direction.isVertical ? .vertical : .horizontal,
            view: fromSnoptView
        )
        adjustAnchorPointAndOffset(
            toViewAnchorPoint,
            direction: direction.isVertical ? .vertical : .horizontal,
            view: toSnoptView
        )

        func update(percentage: CGFloat) {
            beginFromViewT.m34 = -m34(percentage: percentage)
            beginToViewT.m34 = -m34(percentage: percentage)
            endFromViewT.m34 = -m34(percentage: percentage)
            endToViewT.m34 = -m34(percentage: percentage)
        }
        
        switch type {
        case .door(let perspective):
            update(percentage: .zero)
            containerView.layer.sublayerTransform.m34 = -m34(percentage: perspective)
        case .shutters(let perspective):
            update(percentage: perspective)
            containerView.layer.sublayerTransform.m34 = .zero
        }
        
        fromSnoptView.alpha = 1
        toSnoptView.alpha = isNeededFade ? 0 : 1
        fromSnoptView.layer.transform = beginFromViewT
        toSnoptView.layer.transform = beginToViewT
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeLinear) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: self.duration * 0.5) {
                fromSnoptView.layer.transform = endFromViewT
                fromSnoptView.alpha = self.isNeededFade ? 0 : 1
            }
            UIView.addKeyframe(withRelativeStartTime: self.duration * self.secondRelativeTimes,
                               relativeDuration: self.duration * 0.5) {
                toSnoptView.layer.transform = endToViewT
                toSnoptView.alpha = 1
            }
        } completion: { [unowned self] finished in
            unadjustedAnchorPointAndOffset(view: fromSnoptView)
            unadjustedAnchorPointAndOffset(view: toSnoptView)
            fromSnoptView.layer.transform = CATransform3DIdentity
            toSnoptView.layer.transform = CATransform3DIdentity
            containerView.layer.transform = CATransform3DIdentity
            fromSnoptView.layer.transform.m34 = .zero
            toSnoptView.layer.transform.m34 = .zero
            containerView.layer.sublayerTransform.m34 = .zero
            toSnoptView.removeFromSuperview()
            fromSnoptView.removeFromSuperview()
            dawn.complete(finished: finished)
        }
    }
}
