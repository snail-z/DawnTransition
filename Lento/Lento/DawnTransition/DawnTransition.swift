//
//  DawnTransition.swift
//  Lento
//
//  Created by zhang on 2023/6/9.
//

import UIKit

public enum DawnTransitionState: Int {
  
    // 可以开始新的转场
    case possible

    // DawnTransition的`start`方法已被调用，准备动画
    case starting

    // DawnTransition的`animate`方法已被调用，动画中
    case animating

    // 已调用DawnTransition的`complete` 方法，转场结束或取消正在清理
    case completing
}

public class Dawn: NSObject {
  
    /// 用于控制转换的共享单例对象
    public static var shared = DawnTransition()
}

open class DawnTransition: NSObject {
    
    public var isTransitioning: Bool { return state != .possible }
    public internal(set) var isPresenting: Bool = true
    
    /// 目标视图控制器
    internal var toViewController: UIViewController?
    
    /// 源视图控制器
    internal var fromViewController: UIViewController?

    /// 转场上下文对象
    internal weak var transitionContext: UIViewControllerContextTransitioning?
    
    /// 转场容器对象
    internal var containerView: UIView?
    
    internal var state: DawnTransitionState = .possible
    internal var interactiveDriven: UIViewControllerInteractiveTransitioning?
}