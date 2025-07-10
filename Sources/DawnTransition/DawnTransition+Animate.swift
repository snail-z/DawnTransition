//
//  DawnTransition+Animate.swift
//  DawnTransition
//
//  Created by zhang on 2020/6/9.
//  Copyright (c) 2020 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

extension DawnDriver {
    
    internal func start() {
        guard state == .starting else { return }
        state = .animating
        // DispatchQueue.main.async { self.animate() }
        // BUG inNavigationController `snapshotView(afterScreenUpdates: true)`
        // Hero <https://github.com/HeroTransitions/Hero/blob/develop/Sources/Transition/HeroTransition%2BStart.swift>
        // When animating within navigationController, we have to dispatch later into the main queue.
        // otherwise snapshots will be pure white. Possibly a bug with UIKit
        // It solves the snapshots issue, But this solution leads to inaccurate gesture response.
        animate()
        // DispatchQueue.main.async { self.animate() }
    }
    
    internal func animate() {
        guard let fromVC = fromViewController, let toVC = toViewController else {
            complete(finished: false)
            return
        }
        
        if isPresenting {
            let type = toVC.dawn.transitionCapable?.dawnAnimationPresentingAnimationType() ?? .none
            switch type {
            case .none:
                toVC.dawn.transitionCapable?.dawnAnimationPresenting(self)
            default:
                type.toTransitionProducer().dawnAnimationPresenting(self)
            }
        } else { // dismissing
            let type = fromVC.dawn.transitionCapable?.dawnAnimationDismissingAnimationType() ?? .none
            switch type {
            case .none:
                fromVC.dawn.transitionCapable?.dawnAnimationDismissing(self)
            default:
                type.toTransitionProducer().dawnAnimationDismissing(self)
            }
        }
    }
}
