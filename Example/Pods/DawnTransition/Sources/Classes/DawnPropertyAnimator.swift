//
//  DawnPropertyAnimator.swift
//  DawnTransition
//
//  Created by zhang on 2025/1/23.
//  Copyright (c) 2022 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

class DawnPropertyAnimator: UIPercentDrivenInteractiveTransition {

    var animator: UIViewPropertyAnimator?
    var isInteracting = false
    var shouldCompleteTransition = false

    func handleGesture(_ gesture: UIPanGestureRecognizer, in view: UIView, transitionContext: UIViewControllerContextTransitioning?) {
        let translation = gesture.translation(in: view)
        let progress = min(max(translation.y / view.bounds.height, 0), 1)
        
        switch gesture.state {
        case .began:
            isInteracting = true
        case .changed:
            animator?.fractionComplete = progress
            shouldCompleteTransition = progress > 0.5
        case .ended, .cancelled:
            isInteracting = false
            if shouldCompleteTransition {
                animator?.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            } else {
                animator?.isReversed = true
                animator?.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            }
        default:
            break
        }
    }
    
    func animateBlock(_ anim: (() -> Void)? = nil) {
        animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.8) {
            anim?()
        }
    }
    
    func completeBlock(_ block: ((Bool) -> Void)? = nil) {
        animator?.addCompletion({ position in
            switch position {
            case .end: block?(true)
            case .start: block?(false)
            case .current: block?(false)
            }
        })
    }
    
    func start() {
        animator?.startAnimation()
    }
}
