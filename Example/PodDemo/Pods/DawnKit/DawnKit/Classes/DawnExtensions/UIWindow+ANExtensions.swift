//
//  UIWindow+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit

public extension UIWindow {
    
    /// 切换当前的根视图控制器
    ///
    /// - Parameters:
    ///   - viewController: 新的视图控制器
    ///   - animated: 视图控制器更改动画
    ///   - duration: 动画持续时间
    ///   - options: 动画选项
    ///   - completion: 切换完成后回调
    func switchRootViewController(to viewController: UIViewController,
                                  animated: Bool = true,
                                  duration: TimeInterval = 0.5,
                                  options: UIView.AnimationOptions = .transitionFlipFromRight,
                                  _ completion: (() -> Void)? = nil) {
        guard animated else {
            self.rootViewController = viewController
            completion?()
            return
        }

        UIView.transition(with: self, duration: duration, options: options, animations: {
            let oldState = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            self.self.rootViewController = viewController
            UIView.setAnimationsEnabled(oldState)
        }, completion: { _ in
            completion?()
        })
    }
}

#endif
