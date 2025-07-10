//
//  DawnTransition.swift
//  DawnTransition
//
//  Created by zhang on 2020/6/9.
//  Copyright (c) 2020 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

public enum DawnTransitionState: Int {
  
    // 可以开始新的转场
    case possible

    // DawnTransition的`start`方法已被调用，准备动画
    case starting

    // DawnTransition的`animate`方法已被调用，动画中
    case animating

    // 已调用DawnTransition的`complete` 方法，转场结束正在清理
    case completing
}

public class Dawn: NSObject {
    
    public static var shared = DawnTransition()
}

public class DawnTransition: NSObject {
    
    public var isTransitioning: Bool { return state != .possible }
    
    public internal(set) var isPresenting: Bool = true
    
    /// 目标视图控制器
    public internal(set) var toViewController: UIViewController?
    
    /// 源视图控制器
    public internal(set) var fromViewController: UIViewController?

    /// 转场上下文对象
    public internal(set) weak var transitionContext: UIViewControllerContextTransitioning?
    
    /// 转场是否被取消
    public var isTransitionCancelled: Bool {
        return transitionContext?.transitionWasCancelled ?? true
    }
    
    /// 转场容器对象
    public internal(set) var containerView: UIView?
    
    /// 转场对象状态
    public internal(set) var state: DawnTransitionState = .possible
    
    internal var inNavigationController = false
    internal var driveninViewController: UIViewController?
    internal var drivenAdjustable: DawnTransitionAdjustable?
    internal var drivenChanged = false
}
