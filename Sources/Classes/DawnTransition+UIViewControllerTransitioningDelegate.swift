//
//  DawnTransition+UIViewControllerTransitioningDelegate.swift
//  DawnTransition
//
//  Created by zhang on 2022/6/9.
//  Copyright (c) 2022 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

extension DawnTransition: UIViewControllerTransitioningDelegate {
 
    internal var interactiveTransitioning: UIViewControllerInteractiveTransitioning? {
        return driveninViewController?.dawn.interactiveDriver
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard !isTransitioning else { return nil }
        self.state = .starting
        self.isPresenting = true
        self.fromViewController = fromViewController ?? presenting
        self.toViewController = toViewController ?? presented
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard !isTransitioning else { return nil }
        self.state = .starting
        self.isPresenting = false
        self.fromViewController = fromViewController ?? dismissed
        return self
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransitioning
    }
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransitioning
    }
}

extension DawnTransition: UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.375
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        fromViewController = fromViewController ?? transitionContext.viewController(forKey: .from)
        toViewController = toViewController ?? transitionContext.viewController(forKey: .to)
        containerView = transitionContext.containerView
        start()
    }
    
    public func animationEnded(_ transitionCompleted: Bool) {
        self.state = .possible
    }
}

extension DawnTransition: UIViewControllerInteractiveTransitioning {
    
    public var wantsInteractiveStart: Bool {
        return true
    }
    
    public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        animateTransition(using: transitionContext)
    }
}
