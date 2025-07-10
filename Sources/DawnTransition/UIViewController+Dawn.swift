//
//  UIViewController+Dawn.swift
//  DawnTransition
//
//  Created by zhang on 2020/6/9.
//  Copyright (c) 2020 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

extension UIViewController: DawnCompatible {}

fileprivate var DawnIsModalEnabledUIViewControllerAssociatedKey: Void?
extension DawnExtension where Base: UIViewController {
    
    /// 启用模态转场动画
    public var isModalEnabled: Bool {
        get {
            return objc_getAssociatedObject(base, &DawnIsModalEnabledUIViewControllerAssociatedKey) as? Bool ?? false
        }
        set {
            if newValue {
                setModalTransition(enabled: true)
            }
            objc_setAssociatedObject(base, &DawnIsModalEnabledUIViewControllerAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    internal func setModalTransition(enabled: Bool) {
        if enabled {
            base.transitioningDelegate = Dawn.shared
            base.modalPresentationStyle = .fullScreen
        } else {
            base.transitioningDelegate = nil
            objc_setAssociatedObject(base, &DawnIsModalEnabledUIViewControllerAssociatedKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

fileprivate var DawnIsNavEnabledUIViewControllerAssociatedKey: Void?
extension DawnExtension where Base: UIViewController {
    
    /// 启用导航转场动画
    public var isNavigationEnabled: Bool {
        get {
            return objc_getAssociatedObject(base, &DawnIsNavEnabledUIViewControllerAssociatedKey) as? Bool ?? false
        }
        set {
            if newValue { // swizzling
                Dawn.swizzlePushViewController()
            }
            objc_setAssociatedObject(base, &DawnIsNavEnabledUIViewControllerAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

fileprivate var DawnTransitionAnimationTypeViewControllerAssociatedKey: Void?
fileprivate var DawnTransitionCapableViewControllerAssociatedKey: Void?
extension DawnExtension where Base: UIViewController {
    
    /// 设置模态转场动画类型
    public var transitionAnimationType: DawnAnimationType {
        get {
            return objc_getAssociatedObject(base, &DawnTransitionAnimationTypeViewControllerAssociatedKey) as? DawnAnimationType ?? .none
        }
        set {
            transitionCapable = newValue.toTransitionProducer()
            objc_setAssociatedObject(base, &DawnTransitionAnimationTypeViewControllerAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 自定义转场动画
    public var transitionCapable: DawnAnimationCapable? {
        get {
            return objc_getAssociatedObject(base, &DawnTransitionCapableViewControllerAssociatedKey) as? DawnAnimationCapable
        }
        set {
            objc_setAssociatedObject(base, &DawnTransitionCapableViewControllerAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

fileprivate var DawnInteractiveDriverViewControllerAssociatedKey: Void?
extension DawnExtension where Base: UIViewController {
    
    internal var interactiveDriver: UIPercentDrivenInteractiveTransition {
        get {
            if let driver = objc_getAssociatedObject(base, &DawnInteractiveDriverViewControllerAssociatedKey) as? UIPercentDrivenInteractiveTransition {
                return driver
            }
            let driver = UIPercentDrivenInteractiveTransition()
            self.interactiveDriver = driver
            return driver
        }
        set {
            objc_setAssociatedObject(base, &DawnInteractiveDriverViewControllerAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    internal func invalidateInteractiveDriver() {
        if let _ = objc_getAssociatedObject(base, &DawnInteractiveDriverViewControllerAssociatedKey) as? UIPercentDrivenInteractiveTransition {
            objc_setAssociatedObject(base, &DawnInteractiveDriverViewControllerAssociatedKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
