//
//  DawnAnimationTurn.swift
//  DawnTransition
//
//  Created by zhang on 2022/7/25.
//  Copyright (c) 2022 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

open class DawnAnimationTurn: DawnAnimationTransform, DawnAnimationCapable {

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
    }
    
    /// 动画方向，默认在水平往左翻转
    public var direction: Direction = .left
    
    /// 动画时长
    public var duration: TimeInterval = 0.65
    
    /// 动画是否有淡入淡出效果，默认true
    public var isNeededFade: Bool = true
    
    /// 动画是否自动按反方向消失，默认true
    public var isReversed: Bool = true
    
    /// 动画中视图缩放比例
    public var zoomScale: CGFloat = 0.8
    
    /// 用于呈现视角远近效果的系数，perspective越大效果越明显，取值[0, 1]
    public var perspective: CGFloat = 0.1
    
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

        var sublayerTransform = CATransform3DIdentity
        switch direction {
        case .left, .top:
            sublayerTransform.m34 = m34(percentage: perspective)
        case .right, .bottom:
            sublayerTransform.m34 = -m34(percentage: perspective)
        }
        containerView.layer.sublayerTransform = sublayerTransform
        
        var beginFromViewT: CATransform3D, endFromViewT: CATransform3D
        var beginToViewT: CATransform3D, endToViewT: CATransform3D
        switch direction {
        case .left, .right:
            beginFromViewT = CATransform3DIdentity
            endFromViewT = rotate(axis: .y, angle: .pi/2)
            beginToViewT = rotate(axis: .y, angle: -.pi/2)
            endToViewT = CATransform3DIdentity
        case .top, .bottom:
            beginFromViewT = CATransform3DIdentity
            endFromViewT = rotate(axis: .x, angle: -.pi/2)
            beginToViewT = rotate(axis: .x, angle: .pi/2)
            endToViewT = CATransform3DIdentity
        }
        fromSnoptView.layer.transform = beginFromViewT
        toSnoptView.layer.transform = beginToViewT
        fromSnoptView.alpha = 1
        toSnoptView.alpha = isNeededFade ? 0.5 : 1
        
        UIView.animate(withDuration: duration * 0.5) {
            containerView.layer.transform = self.scale(xy: self.zoomScale)
        }
        
        UIView.animate(withDuration: duration * 0.5, delay: duration * 0.5) {
            containerView.layer.transform =  CATransform3DIdentity
        }

        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeLinear) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                fromSnoptView.layer.transform = endFromViewT
                fromSnoptView.alpha = self.isNeededFade ? 0.5 : 1
            }
            UIView.addKeyframe(withRelativeStartTime:0.5, relativeDuration: 0.5) {
                toSnoptView.layer.transform = endToViewT
                toSnoptView.alpha = 1
            }
        } completion: { finished in
            fromSnoptView.layer.transform = CATransform3DIdentity
            toSnoptView.layer.transform = CATransform3DIdentity
            containerView.layer.transform = CATransform3DIdentity
            containerView.layer.sublayerTransform.m34 = .zero
            toSnoptView.removeFromSuperview()
            fromSnoptView.removeFromSuperview()
            dawn.complete(finished: finished)
        }
    }
}
