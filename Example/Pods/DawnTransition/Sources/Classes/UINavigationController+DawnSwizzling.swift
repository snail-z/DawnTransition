//
//  UINavigationController+DawnMagic.swift
//  DawnTransition
//
//  Created by zhang on 2022/7/19.
//  Copyright (c) 2022 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

internal extension Dawn {
    
    static func swizzlePushViewController() {
        DispatchQueue._dawn_once(token: "UINavigationController.Dawn.pushViewController") {
            _dawn_swizzle(selector: #selector(UINavigationController.pushViewController(_:animated:)),
                          with: #selector(UINavigationController.dawn_pushViewController(_:animated:)),
                          inClass: UINavigationController.self,
                          usingClass: UINavigationController.self)
        }
    }
    
    static func unSwizzlePushViewController() {
        DispatchQueue._dawn_removeOnce(token: "UINavigationController.Dawn.pushViewController") {
            _dawn_swizzle(selector: #selector(UINavigationController.dawn_pushViewController(_:animated:)),
                          with: #selector(UINavigationController.pushViewController(_:animated:)),
                          inClass: UINavigationController.self,
                          usingClass: UINavigationController.self)
        }
    }
    
    static func swizzlePopViewController() {
        DispatchQueue._dawn_once(token: "UINavigationController.Dawn.popViewController") {
            _dawn_swizzle(selector: #selector(UINavigationController.popViewController(animated:)),
                          with: #selector(UINavigationController.dawn_popViewController(animated:)),
                          inClass: UINavigationController.self,
                          usingClass: UINavigationController.self)
        }
        swizzlePopToRootViewController()
    }
    
    static func swizzlePopToRootViewController() {
        DispatchQueue._dawn_once(token: "UINavigationController.Dawn.popToRootViewController") {
            _dawn_swizzle(selector: #selector(UINavigationController.popToRootViewController(animated:)),
                          with: #selector(UINavigationController.dawn_popToRootViewController(animated:)),
                          inClass: UINavigationController.self,
                          usingClass: UINavigationController.self)
        }
    }

    static func unSwizzlePopViewController() {
        DispatchQueue._dawn_removeOnce(token: "UINavigationController.Dawn.popViewController") {
            _dawn_swizzle(selector: #selector(UINavigationController.dawn_popViewController(animated:)),
                          with: #selector(UINavigationController.popViewController(animated:)),
                          inClass: UINavigationController.self,
                          usingClass: UINavigationController.self)
        }
        unSwizzlePopToRootViewController()
    }
    
    static func unSwizzlePopToRootViewController() {
        DispatchQueue._dawn_removeOnce(token: "UINavigationController.Dawn.popToRootViewController") {
            _dawn_swizzle(selector: #selector(UINavigationController.dawn_popToRootViewController(animated:)),
                          with: #selector(UINavigationController.popToRootViewController(animated:)),
                          inClass: UINavigationController.self,
                          usingClass: UINavigationController.self)
        }
    }
}

internal extension UINavigationController {
    
    @objc func dawn_pushViewController(_ viewController: UIViewController, animated: Bool) {
        defer {
            dawnTransition(enabled: false)
        }
        if viewController.dawn.isNavigationEnabled {
            dawnTransition(enabled: true)
        }
        dawn_pushViewController(viewController, animated: animated)
    }
    
    @objc func dawn_popViewController(animated: Bool) -> UIViewController? {
        defer {
            dawnTransition(enabled: false)
        }
        if let top = topViewController, top.dawn.isNavigationEnabled {
            dawnTransition(enabled: true)
            top.dawn.shouldUnswizzled = check_isUnSwizzled()
        }
        return dawn_popViewController(animated: animated)
    }
    
    @objc func dawn_popToRootViewController(animated: Bool) -> UIViewController? {
        defer {
            dawnTransition(enabled: false)
        }
        if let top = topViewController, top.dawn.isNavigationEnabled {
            dawnTransition(enabled: true)
            top.dawn.shouldUnswizzled = check_isUnSwizzled()
        }
        return dawn_popToRootViewController(animated: animated)
    }
    
    /// fix：连续push多个页面返回后，提前unSwizzle问题
    private func check_isUnSwizzled() -> Bool {
        guard !viewControllers.isEmpty else { return true }
        var isUnswizzled = true
        for index in 0..<(viewControllers.count - 1) {
            if viewControllers[index].dawn.isNavigationEnabled {
                isUnswizzled = false
                break
            }
        }
        return isUnswizzled
    }
}

fileprivate var DawnPopUnSwizzledKey: Void?
internal extension DawnExtension where Base: UIViewController {
    
     var shouldUnswizzled: Bool {
         get {
             return (objc_getAssociatedObject(base, &DawnPopUnSwizzledKey) as? Bool) ?? false
         }
         set {
             objc_setAssociatedObject(base, &DawnPopUnSwizzledKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
         }
    }
}

fileprivate var DawnPreviousNavigationControllerAssociatedKey: Void?
internal extension UINavigationController {
    
    func dawnTransition(enabled: Bool) {
        if enabled {
            self.transitioningDelegate = Dawn.shared
            self.dawnPrevNavigationDelegate = self.delegate
            self.delegate = Dawn.shared
        } else {
            self.transitioningDelegate = nil
            self.delegate = self.dawnPrevNavigationDelegate
            self.dawnPrevNavigationDelegate = nil
        }
    }
    
    var dawnPrevNavigationDelegate: UINavigationControllerDelegate? {
        get {
            return objc_getAssociatedObject(self, &DawnPreviousNavigationControllerAssociatedKey) as? UINavigationControllerDelegate
        }
        set {
            objc_setAssociatedObject(self, &DawnPreviousNavigationControllerAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
