//
//  DawnTransition+Complete.swift
//  DawnTransition
//
//  Created by zhang on 2022/6/9.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2022 snail-z <haozhang0770@163.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

extension DawnTransition {

    internal func complete(finished: Bool) {
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
        
        if !transitionCancelled {
            addSubview(toViewController!.view)
            removeView(fromViewController!.view)
        }
        
        transitionContext!.completeTransition(!transitionCancelled)
        
        guard inNavigationController else { return }
        if isPresenting {
            if toViewController!.dawn.isNavigationEnabled {
                Dawn.unSwizzlePushViewController()
                Dawn.swizzlePopViewController()
            }
        } else {
            if fromViewController!.dawn.isNavigationEnabled, !transitionCancelled {
                Dawn.unSwizzlePopViewController()
            }
        }
    }
}

extension DawnTransition {
    
    fileprivate func addSubview(_ aView: UIView) {
        guard aView.superview != containerView else { return }
        aView.removeFromSuperview()
        aView.frame = containerView!.bounds
        containerView!.addSubview(aView)
    }
    
    fileprivate func removeView(_ aView: UIView) {
        guard aView.superview == containerView else { return }
        aView.removeFromSuperview()
    }
}
