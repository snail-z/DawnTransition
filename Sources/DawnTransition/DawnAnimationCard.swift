//
//  DawnAnimationCard.swift
//  DawnTransition
//
//  Created by zhang on 2022/7/25.
//  Copyright (c) 2022 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

open class DawnAnimationCard: DawnAnimationTransform, DawnAnimationCapable {

    /// 设置动画持续时间
    public var duration: TimeInterval = 0.85
    
    /// 设置视图高度在屏幕中所占比例
    public var heightPercentage: CGFloat = 0.8
    
    /// 设置后方视图位置偏移
    public var rearOffset: CGFloat = .zero
    
    /// 设置后方视图透明度
    public var rearAlpha: CGFloat = 0.6
    
    /// 设置后方视图一阶段缩放比例
    public var rearScale: CGFloat = 0.95
    
    /// 设置后方视图二阶段缩放比例
    public var rearFinalScale: CGFloat = 0.9

    /// 相较于平面180°的倾斜度，默认5°
    public var rearSlope: CGFloat = 5
    
    /// 后方视图一阶段动画呈现视角的远近，该值越大效果越明显，取值[0, 1]
    public var rearPerspective: CGFloat = 0.75
    
    /// 点击了后方视图蒙层区域
    public var overlayTapAction: (() -> Void)?
    
    public init(overlayTapAction: (() -> Void)? = nil) {
        self.overlayTapAction = overlayTapAction
    }
    
    public func dawnAnimationPresenting(_ dawn: DawnTransition) {
        let containerView = dawn.containerView!
        guard let fromSnoptView = dawn.fromViewController?.view else { return }
        guard let toSnoptView = dawn.toViewController?.view else { return }
        containerView.insertSubview(toSnoptView, aboveSubview: fromSnoptView)
        containerView.insertSubview(overlayView, belowSubview: toSnoptView)
        containerView.bringSubviewToFront(toSnoptView)
        overlayView.frame = containerView.bounds
        
        let initialFrame = dawn.transitionContext!.initialFrame(for: dawn.fromViewController!)
        fromSnoptView.frame = initialFrame
        var initialToFrame = containerView.frame
        initialToFrame.origin.y = initialToFrame.size.height;
        toSnoptView.frame = initialToFrame

        fromSnoptView.layer.zPosition = depth(.low)
        toSnoptView.layer.zPosition = depth(.high)
        toSnoptView.layer.masksToBounds = true
        toSnoptView.layer.cornerRadius = 12
        toSnoptView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let fromViewT1 = firstTransform()
        let fromViewT2 = secondTransform()
        
        var toViewOffset = containerView.frame.height * heightPercentage
        toViewOffset = containerView.frame.height - toViewOffset
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeLinear) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.4) {
                fromSnoptView.layer.transform = fromViewT1;
                fromSnoptView.alpha = self.rearAlpha
            }
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.4) {
                fromSnoptView.layer.transform = fromViewT2;
            }
            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.5) {
                toSnoptView.frame = containerView.frame.offsetBy(dx: .zero, dy: toViewOffset)
            }
        } completion: { finished in
            let done = !dawn.isTransitionCancelled
            dawn.complete(finished: finished)
            if done { /// fix: 系统在转场完成后会删除fromView，所以需要重新添加回子视图，以保持最终样式
                containerView.insertSubview(fromSnoptView, at: 0)
                fromSnoptView.layer.transform = fromViewT2
                toSnoptView.frame = containerView.frame.offsetBy(dx: .zero, dy: toViewOffset)
            }
        }
    }
    
    public func dawnAnimationDismissing(_ dawn: DawnTransition) {
        let containerView = dawn.containerView!
        guard let fromSnoptView = dawn.fromViewController?.view else { return }
        guard let toSnoptView = dawn.toViewController?.view else { return }
        containerView.sendSubviewToBack(toSnoptView)
        toSnoptView.alpha = rearAlpha
        
        let toViewT1 = secondTransform()
        let toViewT2 = firstTransform()
        toSnoptView.layer.transform = toViewT1
        
        var frowViewFinalrame = containerView.frame
        frowViewFinalrame.origin.y = containerView.frame.size.height;
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeLinear) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                fromSnoptView.frame = frowViewFinalrame
            }
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.4) {
                toSnoptView.layer.transform = toViewT2;
                toSnoptView.alpha = 1
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.4) {
                toSnoptView.layer.transform = CATransform3DIdentity;
            }
        } completion: { [unowned self] finished in
            /// fix：转场完成后恢复视图结构
            if !dawn.isTransitionCancelled {
                overlayView.removeFromSuperview()
                fromSnoptView.layer.cornerRadius = .zero
                fromSnoptView.layer.zPosition = depth(.normal)
                toSnoptView.layer.zPosition = depth(.normal)
                fromSnoptView.layer.transform = CATransform3DIdentity
                toSnoptView.layer.transform = CATransform3DIdentity;
                toSnoptView.removeFromSuperview()
                fromSnoptView.removeFromSuperview()
            }
            dawn.complete(finished: finished, automated: false)
        }
    }

    private func firstTransform() -> CATransform3D {
        var firstT = CATransform3DIdentity
        firstT.m34 = -m34(percentage: rearPerspective)
        firstT = CATransform3DScale(firstT, rearScale, rearScale, 1);
        firstT = CATransform3DRotate(firstT, rearSlope * .pi/180, 1, 0, 0)
        return firstT
    }
    
    private func secondTransform() -> CATransform3D {
        var secondT = CATransform3DIdentity
        secondT.m34 = firstTransform().m34
        secondT = CATransform3DTranslate(secondT, 0, rearOffset, 0)
        secondT = CATransform3DScale(secondT, rearFinalScale, rearFinalScale, 1)
        return secondT
    }
    
    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(_:))))
        return view
    }()
    
    @objc private func tapped(_ g: UITapGestureRecognizer) {
        overlayTapAction?()
    }
}
