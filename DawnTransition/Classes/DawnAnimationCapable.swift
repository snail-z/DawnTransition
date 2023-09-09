//
//  DawnAnimationCapable.swift
//  DawnTransition
//
//  Created by zhang on 2022/7/25.
//  Copyright (c) 2022 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

/// 自定义转场动画协议类
public protocol DawnAnimationCapable {

    /// 自定义转场动画，将要显示前
    func dawnAnimationPresenting(_ dawn: DawnTransition)
   
    /// 自定义转场动画，将要消失前
    func dawnAnimationDismissing(_ dawn: DawnTransition)
    
    /// 返回.none时，首选`dawnAnimationPresenting`实现，否则将使用`DawnAnimationType`动画
    func dawnAnimationPresentingAnimationType() -> DawnAnimationType
    
    /// 返回.none时，首选`dawnAnimationDismissing`实现，否则将使用`DawnAnimationType`动画
    func dawnAnimationDismissingAnimationType() -> DawnAnimationType
}

extension DawnAnimationCapable {
    
    public func dawnAnimationPresenting(_ dawn: DawnTransition) {
        guard dawnAnimationPresentingAnimationType() == .none else {
            /// 控制器转场显示动画，自定义实现...
            return
        }
        fatalError("未实现`dawnAnimationPresenting`方法：「\(self)」")
    }
   
    public func dawnAnimationDismissing(_ dawn: DawnTransition) {
        guard dawnAnimationDismissingAnimationType() == .none else {
            /// 控制器转场消失动画，自定义实现...
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
