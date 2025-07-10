//
//  UINavigationController+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

#if os(iOS)

import UIKit

public extension UINavigationController {

    /// 为导航控制器pop动画增加完成回调
    func popViewController(animated: Bool = true, _ completion: (() -> Void)?) {
        guard animated, completion != nil else {
            self.popViewController(animated: animated)
            return
        }
        // https://github.com/cotkjaer/UserInterface/blob/master/UserInterface/UIViewController.swift
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popViewController(animated: animated)
        CATransaction.commit()
    }

    /// 为导航控制器push动画增加完成回调
    func pushViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard animated, completion != nil else {
            self.pushViewController(viewController, animated: animated)
            return
        }
        // https://github.com/cotkjaer/UserInterface/blob/master/UserInterface/UIViewController.swift
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }

    /// 设置当前控制器导航栏为透明
    func makeTransparent(withTint tint: UIColor = .white) {
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        self.navigationBar.tintColor = tint
        self.navigationBar.titleTextAttributes = [.foregroundColor: tint]
    }
}

#endif
