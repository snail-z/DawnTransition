//
//  UIViewController+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit

public extension UIViewController {
    
    /// 返回当前实例的类名称
    var className: String {
        return String(describing: type(of: self))
    }
    
    /// 返回当前类名称
    static var className: String {
        return String(describing: Self.self)
    }
    
    /// 检查ViewController是否在屏幕上显示(当前控制器是否是可见的)
    var isVisible: Bool {
        // http://stackoverflow.com/questions/2777438/how-to-tell-if-uiviewcontrollers-view-is-visible
        return self.isViewLoaded && self.view.window != nil
    }
    
    /// 添加子控制器及视图
    func addChildViewController(_ child: UIViewController, toContainerView containerView: UIView) {
        self.addChild(child)
        containerView.addSubview(child.view)
        child.didMove(toParent: self)
    }

    /// 移除子控制器及视图
    func removeViewAndControllerFromParentViewController() {
        guard self.parent != nil else { return }
        self.willMove(toParent: nil)
        self.removeFromParent()
        self.view.removeFromSuperview()
    }
    
    /// 添加背景图
    @discardableResult
    func addBackgroundImage(_ named: String) -> UIView? {
        return addBackgroundImage(UIImage(named: named))
    }
    
    /// 添加背景图
    @discardableResult
    func addBackgroundImage(_ image: UIImage?) -> UIView? {
        guard let img = image else { return nil }
        let imageView = UIImageView(frame: self.view.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.image = img
        imageView.clipsToBounds = true
        self.view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
        return imageView
    }
}

#endif
