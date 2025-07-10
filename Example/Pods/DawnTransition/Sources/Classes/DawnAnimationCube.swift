//
//  DawnAnimationCube.swift
//  DawnTransition
//
//  Created by zhang on 2022/7/25.
//  Copyright (c) 2022 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

open class DawnAnimationCube: DawnAnimationTransform, DawnAnimationCapable {
    
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
    
    /// 设置动画转场方向，默认.left
    public var direction: Direction = .left
    
    /// 动画是否自动按反方向消失，默认true
    public var isReversed: Bool = true
    
    /// 设置动画持续时间
    public var duration: TimeInterval = 0.325
    
    /// 动画曲线，默认慢快慢
    public var curve: DawnAnimationCurve = .easeInOut
    
    /// 按比例缩放来呈现视角的远近，perspective越大效果越明显，取值[0, 1]
    public var perspective: CGFloat = 0.5

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
        
        let beginFromViewT: CATransform3D, endFromViewT: CATransform3D
        let beginToViewT: CATransform3D, endToViewT: CATransform3D
        let beginContainerT: CATransform3D, endContainerT: CATransform3D
        let fromViewAnchorPoint: CGPoint, toViewAnchorPoint: CGPoint
        switch direction {
        case .left:
            beginFromViewT = CATransform3DIdentity
            endFromViewT = rotate(axis: .y, angle: -.pi/2)
            beginToViewT = rotate(axis: .y, angle: .pi/2)
            endToViewT = CATransform3DIdentity
            beginContainerT = translate(axis: .x, offset: containerView.bounds.width / 2)
            endContainerT = translate(axis: .x, offset: -(containerView.bounds.width / 2))
            fromViewAnchorPoint = anchorPoint(boundaries: .right)
            toViewAnchorPoint = anchorPoint(boundaries: .left)
        case .right:
            beginFromViewT = CATransform3DIdentity
            endFromViewT = rotate(axis: .y, angle: .pi/2)
            beginToViewT = rotate(axis: .y, angle: -.pi/2)
            endToViewT = CATransform3DIdentity
            beginContainerT = translate(axis: .x, offset: -(containerView.bounds.width / 2))
            endContainerT = translate(axis: .x, offset: containerView.bounds.width / 2)
            fromViewAnchorPoint = anchorPoint(boundaries: .left)
            toViewAnchorPoint = anchorPoint(boundaries: .right)
        case .top:
            beginFromViewT = CATransform3DIdentity
            endFromViewT = rotate(axis: .x, angle: -.pi/2)
            beginToViewT = rotate(axis: .x, angle: .pi/2)
            endToViewT = CATransform3DIdentity
            beginContainerT = translate(axis: .y, offset: containerView.bounds.height / 2)
            endContainerT = translate(axis: .y, offset: -(containerView.bounds.height / 2))
            fromViewAnchorPoint = anchorPoint(boundaries: .bottom)
            toViewAnchorPoint = anchorPoint(boundaries: .top)
        case .bottom:
            beginFromViewT = CATransform3DIdentity
            endFromViewT = rotate(axis: .x, angle: .pi/2)
            beginToViewT = rotate(axis: .x, angle: -.pi/2)
            endToViewT = CATransform3DIdentity
            beginContainerT = translate(axis: .y, offset: -(containerView.bounds.height / 2))
            endContainerT = translate(axis: .y, offset: containerView.bounds.height / 2)
            fromViewAnchorPoint = anchorPoint(boundaries: .top)
            toViewAnchorPoint = anchorPoint(boundaries: .bottom)
        }
        
        fromSnoptView.layer.anchorPoint = fromViewAnchorPoint
        toSnoptView.layer.anchorPoint = toViewAnchorPoint
        fromSnoptView.layer.transform = beginFromViewT
        toSnoptView.layer.transform = beginToViewT
        containerView.layer.transform = beginContainerT
        containerView.layer.sublayerTransform.m34 = m34(percentage: perspective) * (direction.isVertical ? 1 : -1)
        Dawn.animate(duration: duration, options: curve.options) {
            fromSnoptView.layer.transform = endFromViewT
            toSnoptView.layer.transform = endToViewT
            containerView.layer.transform = endContainerT
        } completion: { [unowned self] finished in
            fromSnoptView.layer.anchorPoint = anchorPoint(boundaries: .center)
            toSnoptView.layer.anchorPoint = anchorPoint(boundaries: .center)
            fromSnoptView.layer.transform = CATransform3DIdentity
            containerView.layer.transform = CATransform3DIdentity
            containerView.layer.sublayerTransform.m34 = .zero
            toSnoptView.removeFromSuperview()
            fromSnoptView.removeFromSuperview()
            dawn.complete(finished: finished)
        }
    }
}
