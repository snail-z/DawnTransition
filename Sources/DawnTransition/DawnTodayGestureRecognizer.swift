//
//  DawnTodayGestureRecognizer.swift
//  DawnTransition
//
//  Created by zhang on 2022/7/6.
//  Copyright (c) 2022 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

open class DawnTodayGestureRecognizer: DawnPanGestureRecognizer {

    /// 拖动到达缩放边界是否自动转场
    public var shouldAutoDissmiss = true
    
    /// 拖动缩放到达的最小比例，取值范围(0-1]
    public var zoomScale: CGFloat = 0.8
    
    /// 拖动缩放系数，该值越大缩放越快，取值范围(0-1]
    public var zoomFactor: CGFloat = 0.8
    
    /// 拖动中页面圆角变化最大值
    public var zoomMaxRadius: CGFloat = 20
    
    /// 将要识别手势缩放
    public var willZoom: (() -> Void)?
    
    /// 结束缩放手势
    public var endedZoom: (() -> Void)?
}

extension DawnTodayGestureRecognizer {
    
    override func handleLeft(_ g: UIPanGestureRecognizer) {
        switch g.state {
        case .began: willZoom?()
        case .changed: break
        default: endedZoom?()
        }
        let translation = g.translation(in: panView).x
        let distance = translation / panView.bounds.width
        zoom(progress: distance, gesture: g)
    }
    
    override func handleTop(_ g: UIPanGestureRecognizer) {
        switch g.state {
        case .began: willZoom?()
        case .changed: break
        default: endedZoom?()
        }
        let translation = g.translation(in: panView).y
        let distance = translation / panView.bounds.height
        zoom(progress: distance, gesture: g)
    }
}

extension DawnTodayGestureRecognizer {
    
    private func zoom(progress: CGFloat, gesture: UIPanGestureRecognizer) {
        let minScale: CGFloat = zoomScale, maxScale: CGFloat = 1
        let scale = 1 - progress * zoomFactor
        let minRadius: CGFloat = 0, maxRadius: CGFloat = zoomMaxRadius
        var shouldTransition = false
        if scale < minScale {
            panView.layer.transform = CATransform3DScale(
                CATransform3DIdentity,
                minScale, minScale, 1
            )
            panView.center = CGPoint(
                x: UIScreen.main.bounds.width / 2,
                y: UIScreen.main.bounds.height / 2
            )
            panView.layer.cornerRadius = maxRadius
            panView.layer.masksToBounds = true
            if shouldAutoDissmiss {
                startTransition?()
                return
            } else {
                shouldTransition = true
            }
        } else {
            panView.layer.transform = CATransform3DScale(
                CATransform3DIdentity,
                min(maxScale, scale), min(maxScale, scale), 1
            )
            panView.center = CGPoint(
                x: UIScreen.main.bounds.width / 2,
                y: UIScreen.main.bounds.height / 2
            )
            let cornerRadius = (1 - scale) / (1 - minScale) * maxRadius
            panView.layer.cornerRadius = max(minRadius, cornerRadius)
            panView.layer.masksToBounds = true
            shouldTransition = false
        }
        
        switch gesture.state {
        case .began, .changed: break
        default:
            let translation = gesture.translation(in: panView).x
            let velocity = gesture.velocity(in: panView)
            if ((translation + velocity.x) / panView.bounds.width) > 0.5 {
                startTransition?()
            } else if shouldTransition {
                startTransition?()
            } else {
                UIView.animate(withDuration: 0.15) {
                    self.panView.layer.transform = CATransform3DIdentity
                }
            }
        }
    }
}
