//
//  ObjcDawnTransition.swift
//  DawnTransition
//
//  Created by zhang on 2020/7/25.
//  Copyright (c) 2020 snail-z <haozhang0770@163.com> All rights reserved.
//
//  Objc-bridge

import UIKit

fileprivate var ObjcDawnTransitionIsModalEnabledAssociatedKey: Void?
extension UIViewController {
    
    /// 启用模态转场动画
    @objc public var dawn_isModalEnabled: Bool {
        get {
            return objc_getAssociatedObject(self, &ObjcDawnTransitionIsModalEnabledAssociatedKey) as? Bool ?? false
        }
        set {
            self.dawn.isModalEnabled = newValue
            objc_setAssociatedObject(self, &ObjcDawnTransitionIsModalEnabledAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

fileprivate var ObjcDawnTransitionIsNavigationEnabledAssociatedKey: Void?
extension UIViewController {
    
    /// 启用导航转场动画
    @objc public var dawn_isNavigationEnabled: Bool {
        get {
            return objc_getAssociatedObject(self, &ObjcDawnTransitionIsNavigationEnabledAssociatedKey) as? Bool ?? false
        }
        set {
            self.dawn.isNavigationEnabled = newValue
            objc_setAssociatedObject(self, &ObjcDawnTransitionIsNavigationEnabledAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

fileprivate var ObjcDawnTransitionAnimaterVCAssociatedKey: Void?
extension UIViewController {
    
    /// 设置模态转场动画
    @objc public var dawn_transitionAnimater: ObjcDawnAnimater? {
        get {
            return objc_getAssociatedObject(self, &ObjcDawnTransitionAnimaterVCAssociatedKey) as? ObjcDawnAnimater
        }
        set {
            guard let animater = newValue else { return }
            var swiftType: DawnAnimationType = .none
            switch animater.type {
            case .fade:
                swiftType = .fade
            case .push:
                swiftType = .push(direction: animater.swiftDirection)
            case .pull:
                swiftType = .pull(direction: animater.swiftDirection)
            case .pageIn:
                swiftType = .pageIn(direction: animater.swiftDirection, scale: animater.scale)
            case .pageOut:
                swiftType = .pageOut(direction: animater.swiftDirection, scale: animater.scale)
            case .zoomSlide:
                swiftType = .zoomSlide(direction: animater.swiftDirection, scale: animater.scale)
            case .pushLeftBackStandard:
                swiftType = .selectBy(presenting: .push(direction: .left), dismissing: .push(direction: .left))
            default:
                swiftType = .none
            }
            
            self.dawn.transitionCapable = swiftType.toTransitionProducer()
            objc_setAssociatedObject(self, &ObjcDawnTransitionAnimaterVCAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
