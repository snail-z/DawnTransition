//
//  DawnAnimationCapable.swift
//  DawnTransition
//
//  Created by zhang on 2020/7/25.
//  Copyright (c) 2020 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

public protocol DawnAnimationCapable {

    /// 自定义控制器转场显示动画
    func dawnAnimationPresenting(_ dawn: DawnDriver)
   
    /// 自定义控制器转场消失动画
    func dawnAnimationDismissing(_ dawn: DawnDriver)
    
    /// 返回.none时，首选`dawnAnimationPresenting`实现，否则将使用`DawnAnimationType`动画
    func dawnAnimationPresentingAnimationType() -> DawnAnimationType
    
    /// 返回.none时，首选`dawnAnimationDismissing`实现，否则将使用`DawnAnimationType`动画
    func dawnAnimationDismissingAnimationType() -> DawnAnimationType
}

extension DawnAnimationCapable {
    
    public func dawnAnimationPresenting(_ dawn: DawnDriver) {
        guard dawnAnimationPresentingAnimationType() == .none else {
            return
        }
        fatalError("未实现`dawnAnimationPresenting`方法：「\(self)」")
    }
   
    public func dawnAnimationDismissing(_ dawn: DawnDriver) {
        guard dawnAnimationDismissingAnimationType() == .none else {
            return
        }
        fatalError("未实现`dawnAnimationDismissing`方法：「\(self)」")
    }
    
    public func dawnAnimationPresentingAnimationType() -> DawnAnimationType {
        return .none
    }
 
    public func dawnAnimationDismissingAnimationType() -> DawnAnimationType {
        return .none
    }
}
