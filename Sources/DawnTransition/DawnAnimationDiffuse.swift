//
//  DawnAnimationDiffuse.swift
//  DawnTransition
//
//  Created by zhang on 2020/7/25.
//  Copyright (c) 2020 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

/// DawnAnimationDiffuse暂不支持手势响应
/// 使用 CAAnimation/CAAnimationGroup 动画组暂不支持手势，需要结合CADisplayLink更新每一帧进度，todo...
open class DawnAnimationDiffuse: NSObject, DawnAnimationCapable {

    /// 动画时长
    public var duration: TimeInterval = 0.375
    
    /// 透明度动画时长占比，默认25%
    public var fadeDurationProportion: Double = 0.25
    
    public private(set) var diffuseOutView: UIView?
    public private(set) var diffuseInView: UIView?
    
    public init(diffuseOut: UIView?, diffuseIn: UIView?) {
        diffuseOutView = diffuseOut
        diffuseInView = diffuseIn
    }
    
    public func dawnAnimationPresenting(_ dawn: DawnTransition) {
        let containerView = dawn.containerView!
        let toView = dawn.toViewController!.view!
//        guard let tempView = toView.dawn.snapshotView() else { return }
        let tempView = toView
        guard let sourceView = diffuseOutView else { return }
        tempView.frame = containerView.bounds
        containerView.addSubview(tempView)

        let center = CGPoint(
            x: containerView.bounds.width / 2,
            y: containerView.bounds.height / 2
        )
        let raduius = sqrt(pow(center.x, 2) + pow(center.y, 2))
        let sourceFrame = sourceView.superview!.convert(sourceView.frame, to: containerView)
        let startPath = UIBezierPath(ovalIn: sourceFrame)
        let endPath = UIBezierPath(
            arcCenter: containerView.center,
            radius: raduius,
            startAngle: .zero,
            endAngle: CGFloat.pi*2,
            clockwise: true
        )

        let maskLayer = CAShapeLayer()
        maskLayer.path = endPath.cgPath
        tempView.layer.mask = maskLayer

        let pathAnim = CABasicAnimation(keyPath: "path")
        pathAnim.fromValue = startPath.cgPath
        pathAnim.toValue = endPath.cgPath
        pathAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 0
        opacityAnim.toValue = 1
        opacityAnim.beginTime = 0
        opacityAnim.duration = duration * fadeDurationProportion
        opacityAnim.timingFunction = CAMediaTimingFunction(name: .linear)

        Dawn.runningAnimations([pathAnim, opacityAnim], in: maskLayer, duration: duration) { flag in
            dawn.complete(finished: flag)
        }
    }
    
    public func dawnAnimationDismissing(_ dawn: DawnTransition) {
        let containerView = dawn.containerView!
        let fromView = dawn.fromViewController!.view!
        let toView = dawn.toViewController!.view!
        guard let tempView = fromView.dawn.snapshotView() else { return }
        guard let inView = diffuseInView else { return }
        toView.frame = containerView.bounds
        containerView.addSubview(toView)
        tempView.frame = containerView.bounds
        containerView.addSubview(tempView)
        
        let center = CGPoint(
            x: containerView.bounds.width / 2,
            y: containerView.bounds.height / 2
        )
        let raduius = sqrt(pow(center.x, 2) + pow(center.y, 2))
        let sourceFrame = inView.superview!.convert(inView.frame, to: containerView)
        let startPath = UIBezierPath(
            arcCenter: containerView.center,
            radius: raduius,
            startAngle: .zero,
            endAngle: CGFloat.pi*2,
            clockwise: true
        )
        let endPath = UIBezierPath(ovalIn: sourceFrame)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = endPath.cgPath
        tempView.layer.mask = maskLayer

        let pathAnim = CABasicAnimation(keyPath: "path")
        pathAnim.fromValue = startPath.cgPath
        pathAnim.toValue = endPath.cgPath
        pathAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 1
        opacityAnim.toValue = 0
        opacityAnim.beginTime = duration - duration * fadeDurationProportion
        opacityAnim.duration = duration * fadeDurationProportion
        opacityAnim.timingFunction = CAMediaTimingFunction(name: .linear)
        
        Dawn.runningAnimations([pathAnim, opacityAnim], in: maskLayer, duration: duration) { flag in
            tempView.removeFromSuperview()
            dawn.complete(finished: flag)
        }
    }
}
