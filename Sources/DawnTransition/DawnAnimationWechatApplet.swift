//
//  DawnAnimationWechatApplet.swift
//  DawnTransition
//
//  Created by zhang on 2020/2/23.
//  Copyright (c) 2020 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

open class DawnAnimationWechatApplet: DawnAnimationTransform, DawnAnimationCapable {
    
    public enum Direction {
        
        case left, right, top, bottom
        
        public var isVertical: Bool {
            switch self {
            case .left, .right: return false
            case .top, .bottom: return true
            }
        }
    }
    
    /// 设置动画转场方向，默认.left
    public var direction: Direction = .left
    
    /// 动画时长
    public var duration: TimeInterval = 0.325
    
    /// 后方视图圆角
    public var rearCornerRadius: CGFloat = .zero
    
    /// 前方视图圆角
    public var frontCornerRadius: CGFloat = .zero
    
    /// 后方区域占比「取值0～1」默认15%
    public var rearPercentage: CGFloat = 0.15
    
    /// 后方区域偏移占比「取值0～1」默认85% (不改变缩放比的情况下两者之和为1，则同时平行移动)
    public var rearOffsetPercentage: CGFloat = 0.85
    
    /// 设置后方视图缩放比例，默认1.0不缩放
    public var rearScale: CGFloat = 1
    
    /// 转场消失时是否关闭动画，默认false
    public var dismissingInanimate: Bool = false
    
    /// 蒙层颜色
    public var overlayBackgroundColor = UIColor.black.withAlphaComponent(0.6)
    
    /// 蒙层区域点击事件
    public var overlayTapAction: (() -> Void)?
    
    public init(overlayTapAction: (() -> Void)? = nil) {
        self.overlayTapAction = overlayTapAction
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
    
    public func dawnAnimationPresenting(_ dawn: DawnTransition) {
        let containerView = dawn.containerView!
        guard let fromSnoptView = dawn.fromViewController?.view else { return }
        guard let toSnoptView = dawn.toViewController?.view else { return }
        
        containerView.insertSubview(toSnoptView, aboveSubview: fromSnoptView)
        containerView.insertSubview(overlayView, belowSubview: toSnoptView)
        containerView.bringSubviewToFront(toSnoptView)
        toSnoptView.setNeedsUpdateConstraints()
        
        let initialFrame = dawn.transitionContext!.initialFrame(for: dawn.fromViewController!)
        fromSnoptView.frame = initialFrame
        toSnoptView.frame = initialFrame
        overlayView.frame = initialFrame
        
        let _size = containerView.frame.size
        let visibleWidth = (direction.isVertical ? _size.height : _size.width) * rearPercentage
        let visibleOffset = (direction.isVertical ? _size.height : _size.width) * rearOffsetPercentage
        
        let beginFromViewT: CATransform3D, endFromViewT: CATransform3D
        let beginToViewT: CATransform3D, endToViewT: CATransform3D
        switch direction {
        case .left:
            beginFromViewT = CATransform3DIdentity
            let tempT = translate(axis: .x, offset: visibleOffset)
            endFromViewT = scale(tempT, xy: rearScale)
            beginToViewT = translate(axis: .x, offset: -initialFrame.size.width)
            endToViewT = translate(axis: .x, offset: -visibleWidth)
        case .right:
            beginFromViewT = CATransform3DIdentity
            let tempT = translate(axis: .x, offset: -visibleOffset)
            endFromViewT = scale(tempT, xy: rearScale)
            beginToViewT = translate(axis: .x, offset: initialFrame.size.width)
            endToViewT = translate(axis: .x, offset: visibleWidth)
        case .top:
            beginFromViewT = CATransform3DIdentity
            let tempT = translate(axis: .y, offset: visibleOffset)
            endFromViewT = scale(tempT, xy: rearScale)
            beginToViewT = translate(axis: .y, offset: -initialFrame.size.height)
            endToViewT = translate(axis: .y, offset: .zero - visibleWidth)
        case .bottom:
            beginFromViewT = CATransform3DIdentity
            let tempT = translate(axis: .y, offset: -visibleOffset)
            endFromViewT = scale(tempT, xy: rearScale)
            beginToViewT = translate(axis: .y, offset: initialFrame.size.height)
            endToViewT = translate(axis: .y, offset: visibleWidth)
        }
        
        fromSnoptView.layer.transform = beginFromViewT
        toSnoptView.layer.transform = beginToViewT
        fromSnoptView.layer.cornerRadius = .zero
        fromSnoptView.layer.masksToBounds = true
        toSnoptView.layer.cornerRadius = .zero
        toSnoptView.layer.masksToBounds = true
        Dawn.animate(duration: duration, options: .curveEaseInOut) {
            fromSnoptView.layer.transform = endFromViewT
            toSnoptView.layer.transform = endToViewT
            fromSnoptView.layer.cornerRadius = self.rearCornerRadius
            toSnoptView.layer.cornerRadius = self.frontCornerRadius
            self.overlayView.backgroundColor = self.overlayBackgroundColor
        } completion: { finished in
            let done = !dawn.isTransitionCancelled
            dawn.complete(finished: finished)
            if done {
                fromSnoptView.layer.transform = CATransform3DIdentity
                toSnoptView.layer.transform = CATransform3DIdentity
                //`complete`方法在转场完成后会删除fromView，所以要重新添加子视图来保持最终样式
                containerView.insertSubview(fromSnoptView, at: 0)
                fromSnoptView.frame = initialFrame
                toSnoptView.frame = initialFrame
                //transform是基于frame的，所以要先还原视图，然后在设置frame后再次调整transform
                fromSnoptView.layer.transform = endFromViewT
                toSnoptView.layer.transform = endToViewT
            } else {
                self.overlayView.removeFromSuperview()
            }
        }
    }
    
    public func dawnAnimationDismissing(_ dawn: DawnTransition) {
        let containerView = dawn.containerView!
        guard let fromSnoptView = dawn.fromViewController?.view else { return }
        guard let toSnoptView = dawn.toViewController?.view else { return }
        fromSnoptView.layer.transform = CATransform3DIdentity
        toSnoptView.layer.transform = CATransform3DIdentity
        
        let initialFrame = dawn.transitionContext!.initialFrame(for: dawn.fromViewController!)
        fromSnoptView.frame = initialFrame
        let initialToFrame = containerView.frame
        toSnoptView.frame = initialToFrame
        
        let _size = containerView.frame.size
        let visibleWidth = (direction.isVertical ? _size.height : _size.width) * rearPercentage
        let visibleOffset = (direction.isVertical ? _size.height : _size.width) * rearOffsetPercentage
        
        let beginFromViewT: CATransform3D, endFromViewT: CATransform3D
        let beginToViewT: CATransform3D, endToViewT: CATransform3D
        switch direction {
        case .left:
            beginFromViewT = translate(axis: .x, offset: -visibleWidth)
            endFromViewT = translate(axis: .x, offset: -initialFrame.width)
            let tempT = translate(axis: .x, offset: visibleOffset)
            beginToViewT = scale(tempT, xy: rearScale)
            endToViewT = CATransform3DIdentity
        case .right:
            beginFromViewT = translate(axis: .x, offset: visibleWidth)
            endFromViewT = translate(axis: .x, offset: initialFrame.width)
            let tempT = translate(axis: .x, offset: -visibleOffset)
            beginToViewT = scale(tempT, xy: rearScale)
            endToViewT = CATransform3DIdentity
        case .top:
            beginFromViewT = translate(axis: .y, offset: -visibleWidth)
            endFromViewT = translate(axis: .y, offset: -initialFrame.height)
            let tempT = translate(axis: .y, offset: visibleOffset)
            beginToViewT = scale(tempT, xy: rearScale)
            endToViewT = CATransform3DIdentity
        case .bottom:
            beginFromViewT = translate(axis: .y, offset: visibleWidth)
            endFromViewT = translate(axis: .y, offset: initialFrame.height)
            let tempT = translate(axis: .y, offset: -visibleOffset)
            beginToViewT = scale(tempT, xy: rearScale)
            endToViewT = CATransform3DIdentity
        }
        
        fromSnoptView.layer.transform = beginFromViewT
        toSnoptView.layer.transform = beginToViewT
        toSnoptView.layer.cornerRadius = rearCornerRadius
        toSnoptView.layer.masksToBounds = true
        fromSnoptView.layer.cornerRadius = frontCornerRadius
        fromSnoptView.layer.masksToBounds = true
        Dawn.animate(duration: (dismissingInanimate ? .zero : duration), options: .curveEaseInOut) {
            fromSnoptView.layer.transform = endFromViewT
            toSnoptView.layer.transform = endToViewT
            toSnoptView.layer.cornerRadius = .zero
            fromSnoptView.layer.cornerRadius = .zero
            self.overlayView.backgroundColor = .clear
        } completion: { finished in
            let done = !dawn.isTransitionCancelled
            dawn.complete(finished: finished)
            if done {
                fromSnoptView.layer.transform = CATransform3DIdentity
                toSnoptView.layer.transform = CATransform3DIdentity
                self.overlayView.removeFromSuperview()
            } else {
                containerView.insertSubview(toSnoptView, at: 0)
            }
        }
    }
}
