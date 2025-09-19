//
//  DawnAnimationSpring.swift
//  DawnTransition
//
//  Created by zhang on 2020/7/25.
//  Copyright (c) 2020 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

open class DawnAnimationSpring: DawnAnimationTransform, DawnAnimationCapable {
    
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
    public var direction: Direction = .left
    
    /// 动画是否自动按反方向消失，默认true
    public var isReversed: Bool = true
    
    /// 设置动画持续时间
    public var duration: TimeInterval = 0.6
    
    /// 设置后方视图缩放比例，默认0.95
    public var scale: CGFloat = 0.95
    
    /// 设置弹性阻尼参数，默认0.6
    public var damping: CGFloat = 0.6
    
    /// 设置弹性速度参数，默认0.2
    public var velocity: CGFloat = 0.2

    public func dawnAnimationPresenting(_ dawn: DawnDriver) {
        pageInAnimation(dawn, direction: direction)
    }
    
    public func dawnAnimationDismissing(_ dawn: DawnDriver) {
        pageOutAnimation(dawn, direction: isReversed ? direction.reversed : direction)
    }
    
    private func pageInAnimation(_ dawn: DawnDriver, direction: Direction) {
        let containerView = dawn.containerView!
        guard let fromSnoptView = dawn.fromViewController?.view else { return }
        guard let toSnoptView = dawn.toViewController?.view else { return }
        
        containerView.insertSubview(toSnoptView, aboveSubview: fromSnoptView)
        containerView.bringSubviewToFront(toSnoptView)
        
        let initialFrame = dawn.transitionContext!.initialFrame(for: dawn.fromViewController!)
        fromSnoptView.frame = initialFrame
        
        var initialToFrame = containerView.frame
        switch direction {
        case .left:
            initialToFrame.origin.x = containerView.frame.width
        case .right:
            initialToFrame.origin.x = -containerView.frame.width
        case .up:
            initialToFrame.origin.y = containerView.frame.height
        case .down:
            initialToFrame.origin.y = -containerView.frame.height
        }
        toSnoptView.frame = initialToFrame
        
        fromSnoptView.layer.zPosition = depth(.low)
        toSnoptView.layer.zPosition = depth(.high)
        toSnoptView.layer.masksToBounds = true
        toSnoptView.layer.cornerRadius = 6
        
        // 创建蒙层
        let overlayView = UIView(frame: fromSnoptView.bounds)
        overlayView.backgroundColor = UIColor.black
        overlayView.alpha = 0
        fromSnoptView.addSubview(overlayView)
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: damping,
            initialSpringVelocity: velocity,
            options: [.curveEaseInOut, .allowUserInteraction],
            animations: {
                fromSnoptView.transform = CGAffineTransform(scaleX: self.scale, y: self.scale)
                fromSnoptView.layer.cornerRadius = 6
                fromSnoptView.layer.masksToBounds = true
                overlayView.alpha = 0.1
                toSnoptView.frame = containerView.frame
                toSnoptView.layer.cornerRadius = 6
            },
            completion: { finished in
                fromSnoptView.transform = CGAffineTransform.identity
                fromSnoptView.layer.cornerRadius = 0
                fromSnoptView.layer.masksToBounds = false
                toSnoptView.layer.cornerRadius = 0
                overlayView.removeFromSuperview()
                toSnoptView.removeFromSuperview()
                fromSnoptView.removeFromSuperview()
                dawn.complete(finished: finished)
            }
        )
    }
    
    private func pageOutAnimation(_ dawn: DawnDriver, direction: Direction) {
        let containerView = dawn.containerView!
        guard let fromSnoptView = dawn.fromViewController?.view else { return }
        guard let toSnoptView = dawn.toViewController?.view else { return }
        
        // Ensure the destination view is in the transition container during dismiss.
        // Not doing so would reveal the container's black background when the from-view moves away.
        if toSnoptView.superview !== containerView {
            containerView.insertSubview(toSnoptView, belowSubview: fromSnoptView)
        } else {
            containerView.sendSubviewToBack(toSnoptView)
        }
        toSnoptView.alpha = 1.0
        toSnoptView.transform = CGAffineTransform(scaleX: scale, y: scale)
        toSnoptView.layer.cornerRadius = 6
        toSnoptView.layer.masksToBounds = true
        
        // Recreate a dimming overlay for the underlying view so it can fade out during pop.
        let overlayView: UIView = {
            let v = UIView(frame: toSnoptView.bounds)
            v.backgroundColor = .black
            v.alpha = 0.1
            return v
        }()
        toSnoptView.addSubview(overlayView)
        
        var fromViewFinalFrame = containerView.frame
        switch direction {
        case .left:
            fromViewFinalFrame.origin.x = -containerView.frame.width
        case .right:
            fromViewFinalFrame.origin.x = containerView.frame.width
        case .up:
            fromViewFinalFrame.origin.y = -containerView.frame.height
        case .down:
            fromViewFinalFrame.origin.y = containerView.frame.height
        }
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: damping,
            initialSpringVelocity: velocity,
            options: [.curveEaseInOut, .allowUserInteraction],
            animations: {
                fromSnoptView.frame = fromViewFinalFrame
                toSnoptView.transform = CGAffineTransform.identity
                toSnoptView.layer.cornerRadius = 0
                toSnoptView.layer.masksToBounds = false
                overlayView.alpha = 0
            },
            completion: { [unowned self] finished in
                overlayView.removeFromSuperview()
                fromSnoptView.layer.cornerRadius = 0
                fromSnoptView.layer.zPosition = depth(.normal)
                toSnoptView.layer.zPosition = depth(.normal)
                fromSnoptView.transform = CGAffineTransform.identity
                toSnoptView.transform = CGAffineTransform.identity
                toSnoptView.removeFromSuperview()
                fromSnoptView.removeFromSuperview()
                dawn.complete(finished: finished)
            }
        )
    }
}

// 让 Spring 在手势交互阶段可转换为线性 Producer（pageIn/pageOut）
extension DawnAnimationSpring: DawnInteractiveConvertible {
    public func dawnInteractiveProducer() -> DawnAnimationProducer? {
        // 将内部方向映射为 DawnAnimationType.Direction
        let dir: DawnAnimationType.Direction
        switch direction {
        case .left: dir = .left
        case .right: dir = .right
        case .up: dir = .up
        case .down: dir = .down
        }
        // 使用 pageIn/pageOut，并沿用当前 scale；交互阶段会在 driven 时被线性化（regenerate）
        let t: DawnAnimationType = .selectBy(
            presenting: .pageIn(direction: dir, scale: self.scale),
            dismissing: .pageOut(direction: dir, scale: self.scale)
        )
        // 这里设置一个初始线性，无弹性；最终以 driven(regenerate) 的线性参数为准
        return DawnAnimationProducer.using(type: t, duration: 0.325, curve: .linear, snapshotType: .slowSnapshot)
    }
}
