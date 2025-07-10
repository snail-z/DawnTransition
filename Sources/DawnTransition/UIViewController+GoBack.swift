//
//  UIViewController+GoBack.swift
//  DawnTransition
//
//  Created by zhang on 2020/6/9.
//  Copyright (c) 2020 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

extension DawnExtension where Base: UIViewController {
    
    /// 返回上一级视图控制器 (使用Dawn，配合此方法返回上一级操作)
    public func backToPreviousViewController(animated flag: Bool = true) {
        if (base.navigationController != nil) {
            base.navigationController?.popViewController(animated: flag)
        } else {
            /// fix: 当present被导航包装的vc后，继续push其他页面transitioningDelegate会被覆盖，
            /// -动画需要重新标记，所以在此做一个兼容方案
            if let nvc = base as? UINavigationController, nvc.dawn.isModalEnabled {
                nvc.dawn.setModalTransition(enabled: true)
            }
            base.presentingViewController?.dismiss(animated: flag)
        }
    }
    
    /// 返回至根视图控制器
    public func backToRootViewController(animated flag: Bool = true) {
        if (base.navigationController != nil) {
            base.navigationController?.popToRootViewController(animated: flag)
        } else {
            var presentingVC: UIViewController? = base
            if let nvc = base as? UINavigationController, nvc.dawn.isModalEnabled {
                nvc.dawn.setModalTransition(enabled: true)
            }
            while presentingVC?.presentingViewController != nil {
                presentingVC = presentingVC?.presentingViewController
            }
            presentingVC?.dismiss(animated: flag)
        }
    }
}
