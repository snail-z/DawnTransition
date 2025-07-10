//
//  DawnAnimationDissolve.swift
//  DawnTransition
//
//  Created by zhang on 2022/6/27.
//  Copyright (c) 2022 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

open class DawnAnimationDissolve: DawnAnimationCapable {
    
    /// 动画时长
    public var duration: TimeInterval = 0.275
    
    /// 动画弹性效果，默认nil不使用弹性效果
    public var usingSpring: (damping: CGFloat, velocity: CGFloat)?
    
    /// 背景层蒙版层样式
    public enum OverlayType {
        case clear
        case translucent(opacity: CGFloat, color: UIColor)
        case blur(style: UIBlurEffect.Style, color: UIColor)
    }
    public var overlayType: OverlayType = .clear
    
    private let kSnapshotKey = 2606, kOverlayKey = 2607
    public private(set) var pathSourceView: UIView?
    
    public init(sourceView: UIView) {
        self.pathSourceView = sourceView
    }
    
    // swiftlint:disable function_body_length cyclomatic_complexity
    public func dawnAnimationPresenting(_ dawn: DawnTransition) {
        let containerView = dawn.containerView!
        let fromView = dawn.fromViewController!.view!
        let toView = dawn.toViewController!.view!
        
        guard let sourceView = pathSourceView else { return }
        guard let targetView = dawn.toViewController?.view else { return }
        guard let sourceSnapshot = sourceView.dawn.snapshotView() else { return }
        guard let targetSnapshot = targetView.dawn.snapshotView() else { return }
        
        toView.frame = containerView.bounds
        containerView.addSubview(toView)
        toView.isHidden = true
        toView.layoutIfNeeded()
        
        let sourceFrame = sourceView.superview!.convert(sourceView.frame, to: containerView)
        let sourceScale = sourceView.bounds.width / sourceView.bounds.height
        let targetScale = targetView.bounds.width / targetView.bounds.height
        
        let tempView = UIView(frame: sourceFrame)
        tempView.backgroundColor = .white
        tempView.clipsToBounds = true
        tempView.layer.masksToBounds = true
        tempView.layer.cornerRadius = sourceView.layer.cornerRadius
        containerView.addSubview(tempView)
        
        targetSnapshot.frame = CGRect(
            x: .zero, y: .zero,
            width: tempView.bounds.width,
            height: tempView.bounds.width / targetScale
        )
        targetSnapshot.alpha = 0
        tempView.addSubview(targetSnapshot)
        
        sourceSnapshot.frame = CGRect(origin: .zero, size: tempView.bounds.size)
        sourceSnapshot.alpha = 1
        tempView.addSubview(sourceSnapshot)
        
        Dawn.animate(duration: duration,
                     delay: 0,
                     options: .curveEaseInOut,
                     springParameters: usingSpring) {
            tempView.frame = containerView.frame
            tempView.layer.cornerRadius = toView.layer.cornerRadius
            
            sourceSnapshot.frame = CGRect(
                x: .zero, y: .zero,
                width: tempView.bounds.width,
                height: tempView.bounds.width / sourceScale
            )
            targetSnapshot.frame = CGRect(
                x: .zero, y: .zero,
                width: tempView.bounds.width,
                height: tempView.bounds.width / targetScale
            )
            targetSnapshot.alpha = 1
            sourceSnapshot.alpha = 0
        } completion: { finished in
            tempView.removeFromSuperview()
            toView.isHidden = false
            fromView.layer.transform = CATransform3DIdentity
            addFake()
            dawn.complete(finished: finished)
        }
        
        func addFake() {
            defer { sourceView.isHidden = false }
            guard !dawn.isTransitionCancelled else { return }
            /// fix：在截图前将sourceView隐藏，避免出现视觉重叠
            sourceView.isHidden = true
            guard let fromSnapshotView = fromView.dawn.snapshotView() else { return }
            sourceView.isHidden = false
            fromSnapshotView.frame = containerView.bounds
            fromSnapshotView.tag = kSnapshotKey
            containerView.insertSubview(fromSnapshotView, at: 0)
            switch self.overlayType {
            case .clear: break
            case .translucent(let opacity, let color):
                let overlayView = UIView(frame: containerView.bounds)
                overlayView.backgroundColor = color
                overlayView.alpha = opacity
                overlayView.tag = kOverlayKey
                containerView.insertSubview(overlayView, aboveSubview: fromSnapshotView)
            case .blur(let style, let color):
                let effectView = UIVisualEffectView(frame: containerView.bounds)
                effectView.backgroundColor = color
                effectView.effect = UIBlurEffect(style: style)
                effectView.tag = kOverlayKey
                containerView.insertSubview(effectView, aboveSubview: fromSnapshotView)
            }
        }
    }
    
    // swiftlint:disable function_body_length cyclomatic_complexity
    public func dawnAnimationDismissing(_ dawn: DawnTransition) {
        let containerView = dawn.containerView!
        let fromView = dawn.fromViewController!.view!
        let toView = dawn.toViewController!.view!
        
        guard let sourceView = pathSourceView else { return }
        guard let targetView = dawn.fromViewController?.view else { return }
        guard let sourceSnapshot = sourceView.dawn.snapshotView() else { return }
        guard let targetSnapshot = targetView.dawn.snapshotView() else { return }
        toView.isHidden = true
        toView.layoutIfNeeded()
        fromView.isHidden = true
        
        let targetFrame = sourceView.superview!.convert(sourceView.frame, to: containerView)
        let sourceScale = sourceView.bounds.width / sourceView.bounds.height
        let targetScale = targetView.bounds.width / targetView.bounds.height
        
        let tempView = UIView(frame: fromView.frame)
        tempView.backgroundColor = .white
        tempView.layer.masksToBounds = true
        tempView.clipsToBounds = true
        tempView.layer.cornerRadius = fromView.layer.cornerRadius
        containerView.addSubview(tempView)
        
        sourceSnapshot.frame = CGRect(
            x: .zero, y: .zero,
            width: tempView.bounds.width,
            height: targetView.bounds.width / sourceScale
        )
        sourceSnapshot.alpha = 0
        tempView.addSubview(sourceSnapshot)
        
        targetSnapshot.frame = CGRect(
            x: .zero, y: .zero,
            width: tempView.bounds.width,
            height: tempView.bounds.height
        )
        targetSnapshot.alpha = 1
        tempView.addSubview(targetSnapshot)
        
        let snapsView = containerView.viewWithTag(kSnapshotKey)
        let overlayView = containerView.viewWithTag(kOverlayKey)
        Dawn.animate(duration: duration,
                     delay: 0,
                     options: .curveEaseInOut,
                     springParameters: usingSpring) {
            tempView.frame = targetFrame
            tempView.layer.cornerRadius = sourceView.layer.cornerRadius
            
            targetSnapshot.frame = CGRect(
                x: .zero, y: .zero,
                width: tempView.bounds.width,
                height: tempView.bounds.width / targetScale
            )
            sourceSnapshot.frame = tempView.bounds
            sourceSnapshot.alpha = 1
            targetSnapshot.alpha = 0
            overlayView?.alpha = 0
        } completion: { finished in
            if !dawn.isTransitionCancelled {
                snapsView?.removeFromSuperview()
                overlayView?.removeFromSuperview()
            }
            tempView.removeFromSuperview()
            toView.isHidden = false
            fromView.isHidden = false
            dawn.complete(finished: finished)
        }
    }
}
