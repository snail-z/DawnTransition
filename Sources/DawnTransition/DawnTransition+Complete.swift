//
//  DawnTransition+Complete.swift
//  DawnTransition
//
//  Created by zhang on 2022/6/9.
//  Copyright (c) 2022 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

extension DawnTransition {

    public func complete(finished: Bool, automated: Bool = true) {
        guard state == .animating || state == .starting else { return }
        defer {
            inNavigationController = false
            transitionContext = nil
            fromViewController = nil
            toViewController = nil
            containerView = nil
            state = .possible
        }
        state = .completing
        
        let transitionCancelled = transitionContext!.transitionWasCancelled
        
        guard finished else {
            transitionContext!.cancelInteractiveTransition()
            transitionContext!.completeTransition(transitionCancelled)
            return
        }

        /// 导航转场的特殊处理，swizzle-push/pop
        if inNavigationController {
            if isPresenting {
                if toViewController!.dawn.isNavigationEnabled {
                    Dawn.unSwizzlePushViewController()
                    Dawn.swizzlePopViewController()
                }
            } else {
                if fromViewController!.dawn.shouldUnswizzled, !transitionCancelled {
                    Dawn.unSwizzlePopViewController()
                }
            }
        }
        
        /// 外部可选择转场结束后，是否由内部自动添加或删除子视图
        if automated {
            if transitionCancelled {
                addSubview(fromViewController!.view)
                removeSubview(toViewController!.view)
            } else {
                addSubview(toViewController!.view)
                removeSubview(fromViewController!.view)
            }
        }
        
        transitionContext!.completeTransition(!transitionCancelled)
    }
}

extension DawnTransition {
    
    fileprivate func addSubview(_ aView: UIView) {
        guard aView.superview != containerView else { return }
        aView.removeFromSuperview()
        aView.frame = containerView!.bounds
        containerView!.addSubview(aView)
    }
    
    fileprivate func removeSubview(_ aView: UIView) {
        guard aView.superview == containerView else { return }
        aView.removeFromSuperview()
    }
}
