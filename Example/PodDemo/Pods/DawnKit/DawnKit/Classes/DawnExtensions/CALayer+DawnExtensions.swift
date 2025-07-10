//
//  CALayer+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

import UIKit

public extension CALayer {
    
    /// 删除layer的所有子图层
    func removeAllSublayers() {
        while sublayers?.count ?? 0 > 0 {
            sublayers?.last?.removeFromSuperlayer()
        }
    }
    
    /// 返回对当前Layer的截图
    func screenshots() -> UIImage? {
        guard bounds.size.isValid else { return nil }
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

public extension CALayer {
    
    /// 禁止layer的隐式动画
    static func disableActions<T: CALayer>(layer: T, work: ((T) -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        work?(layer)
        CATransaction.commit()
    }
    
    /// 为layer添加fade动画，当图层内容变化时将以淡入淡出动画使内容渐变
    func fadeAnimation(duration: TimeInterval = 0.25, curve: CAMediaTimingFunctionName = .linear) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: curve)
        animation.type = .fade
        animation.duration = duration
        add(animation, forKey: nil)
    }
    
    /// 为layer添加旋转动画
    func rotateAnimation(duration: TimeInterval = 0.75,
                         curve: CAMediaTimingFunctionName = .linear,
                         clockwise: Bool = true) {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = (clockwise ? CGFloat.pi : -CGFloat.pi) * 2
        animation.duration = duration
        animation.repeatCount = Float.greatestFiniteMagnitude
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.timingFunction = CAMediaTimingFunction(name: curve)
        add(animation, forKey: nil)
    }
    
    enum ShakeDirection { case horizontal(offset: CGFloat), vertical(offset: CGFloat) }
    
    /// 为layer添加晃动动画
    func shakeAnimation(duration: TimeInterval = 0.25,
                        repeatCount: Float = .greatestFiniteMagnitude,
                        curve: CAMediaTimingFunctionName = .linear,
                        direction: ShakeDirection = .horizontal(offset: 10)) {
        var offsetX: CGFloat = 0
        var offsetY: CGFloat = 0
        switch direction {
        case .horizontal(let value): offsetX = value
        case .vertical(let value): offsetY = value
        }
        let p = position
        let values = [p, CGPoint(x: p.x - offsetX, y: p.y - offsetY), p, CGPoint(x: p.x + offsetX, y: p.y + offsetY), p]
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.values = values
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: curve)
        animation.repeatCount = repeatCount
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = true
        add(animation, forKey: nil)
    }
    
    /// 为layer添加缩放动画
    func scaleAnimation(duration: TimeInterval = 0.25,
                        repeatCount: Float = .greatestFiniteMagnitude,
                        curve: CAMediaTimingFunctionName = .linear,
                        scale: CGFloat = 1.25) {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [1, scale, 1]
        animation.keyTimes = [0, 0.5, 1]
        animation.duration = duration
        animation.repeatCount = repeatCount
        animation.fillMode = .forwards
        add(animation, forKey: nil)
    }
    
    enum AnimationType { case opacity, rotation }
    
    /// 为layer添加指定类型的动画
    func addAnimation(type: AnimationType,
                      duration: Double = 0.25, fromValue: Any?, toValue: Any?,
                      completion: ((Bool) -> Void)? = nil) {
        func pathName(by type: AnimationType) -> String {
            switch type {
            case .opacity: return "opacity"
            case .rotation: return "transform.rotation.z"
            }
        }
        let basic = CABasicAnimation(keyPath: pathName(by: type))
        basic.fromValue = fromValue
        basic.toValue = toValue
        basic.duration = duration
        basic.fillMode = .forwards
        basic.isRemovedOnCompletion = false
        add(basic, forKey: nil)
        DispatchQueue.asyncAfter(delay: duration) { completion?(true) }
    }
}

public extension CAShapeLayer {
    
    /// 自定义shapeLayer路径改变动画
    func addPathAnimation(from origin: CGPath?,
                          to target: CGPath?,
                          duration: TimeInterval = 0.5,
                          completion: ((Bool) -> Void)? = nil) {
        guard let fromPath = origin, let toPath = target else { return }
        let basic = CABasicAnimation(keyPath: "path")
        basic.fromValue = fromPath
        basic.toValue = toPath
        basic.duration = duration
        basic.fillMode = .forwards
        basic.isRemovedOnCompletion = false
        add(basic, forKey: nil)
        DispatchQueue.asyncAfter(delay: duration) { completion?(true) }
    }
}

public extension CALayer {
    
    var left: CGFloat {
        get {
            return self.frame.origin.x
        } set(value) {
            self.frame = CGRect(x: value, y: top, width: width, height: height)
        }
    }

    var right: CGFloat {
        get {
            return left + width
        } set(value) {
            left = value - width
        }
    }

    var top: CGFloat {
        get {
            return self.frame.origin.y
        } set(value) {
            self.frame = CGRect(x: left, y: value, width: width, height: height)
        }
    }

    var bottom: CGFloat {
        get {
            return top + height
        } set(value) {
            top = value - height
        }
    }

    var width: CGFloat {
        get {
            return self.frame.size.width
        } set(value) {
            self.frame = CGRect(x: left, y: top, width: value, height: height)
        }
    }

    var height: CGFloat {
        get {
            return self.frame.size.height
        } set(value) {
            self.frame = CGRect(x: left, y: top, width: width, height: value)
        }
    }
    
    var origin: CGPoint {
        get {
            return self.frame.origin
        } set(value) {
            self.frame = CGRect(origin: value, size: self.frame.size)
        }
    }
    
    var size: CGSize {
        get {
            return self.frame.size
        } set(value) {
            self.frame = CGRect(origin: self.frame.origin, size: value)
        }
    }

    var centerX: CGFloat {
        get {
            return self.frame.origin.x + self.frame.size.width * 0.5
        } set(value) {
            var frame = self.frame
            frame.origin.x = value - frame.size.width * 0.5
            self.frame = frame
        }
    }

    var centerY: CGFloat {
        get {
            return self.frame.origin.y + self.frame.size.height * 0.5;
        } set(value) {
            var frame = self.frame
            frame.origin.y = value - frame.size.height * 0.5;
            self.frame = frame
        }
    }
}
