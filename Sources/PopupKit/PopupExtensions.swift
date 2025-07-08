//
//  PopupExtensions.swift
//  PopupKit
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

internal extension UIView {
    
    static func animate(
        duration: TimeInterval,
        delay: TimeInterval,
        spring: (damping: CGFloat, velocity: CGFloat)?,
        options: UIView.AnimationOptions,
        animations: @escaping () -> Void,
        completion: ((Bool) -> Void)?
    ) {
        if let springParameters = spring {
            UIView.animate(
                withDuration: duration,
                delay: delay,
                usingSpringWithDamping: springParameters.damping,
                initialSpringVelocity: springParameters.velocity,
                options: options,
                animations: animations,
                completion: completion
            )
        } else {
            UIView.animate(
                withDuration: duration,
                delay: delay,
                options: options,
                animations: animations,
                completion: completion
            )
        }
    }
}

public extension UIView {
    
    func firstSubview<T: UIView>(of type: T.Type) -> T? {
        for subview in subviews {
            if let match = subview as? T {
                return match
            }
            if let nested = subview.firstSubview(of: type) {
                return nested
            }
        }
        return nil
    }

    func lastSubview<T: UIView>(of type: T.Type) -> T? {
        for subview in subviews.reversed() {
            if let nested = subview.lastSubview(of: type) {
                return nested
            }
            if let match = subview as? T {
                return match
            }
        }
        return nil
    }
    
    func allSubviews<T: UIView>(of type: T.Type) -> [T] {
        var result: [T] = []
        var stack = [self]
        while let current = stack.popLast() {
            for sub in current.subviews {
                stack.append(sub)
                if let matched = sub as? T {
                    result.append(matched)
                }
            }
        }
        return result
    }
}

internal nonisolated(unsafe) var UIViewAssociatedIsPopupingKey: UInt8 = 0

internal extension UIView {
    
    var isPopupVisible: Bool {
        get {
            return (objc_getAssociatedObject(self, &UIViewAssociatedIsPopupingKey) as? Bool) ?? false
        }
        set {
            objc_setAssociatedObject(self, &UIViewAssociatedIsPopupingKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

internal extension PopupAnimationOptions {
    
    var spring: (CGFloat, CGFloat)? {
        return useSpringAnimation ? (usingSpringWithDamping, initialSpringVelocity) : nil
    }
}

internal struct Popupkit {
    
    static func log(_ message: @autoclosure () -> Any) {
    #if DEBUG
        print("[PopupKit] \(message())")
    #endif
    }
    
    static func log(_ anyObj: AnyObject, _ message: @autoclosure () -> Any) {
    #if DEBUG
        let type = String(describing: type(of: anyObj))
        print("[PopupKit] [\(type)] \(message())")
    #endif
    }
}
