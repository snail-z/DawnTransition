//
//  DawnTransition+Interactive.swift
//  DawnTransition
//
//  Created by zhang on 2020/6/9.
//  Copyright (c) 2020 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

extension DawnTransition {
    
    public func driven(presenting viewController: UIViewController) {
        postWillInteractive(isPresenting: true)
        drivenChanged = false
        driven(viewController, presenting: true)
    }
    
    public func driven(dismissing viewController: UIViewController) {
        postWillInteractive(isPresenting: false)
        drivenChanged = false
        driven(viewController, presenting: false)
    }
    
    public func update(_ percentageComplete: CGFloat) {
        postPercentageInteractive(percentage: percentageComplete)
        drivenChanged = true
        drivable?.update(percentageComplete)
    }
    
    public func finish() {
        func work() {
            drivable?.completionSpeed =  1 - (drivable?.percentComplete ?? 0)
            drivable?.finish()
            drivenComplete()
            postFinishInteractive(isFinished: true)
        }
        drivenChanged ? work() : sudden(work)
    }

    public func cancel() {
        func work() {
            drivable?.completionSpeed = drivable?.percentComplete ?? 1
            drivable?.cancel()
            drivenComplete()
            postFinishInteractive(isFinished: false)
        }
        drivenChanged ? work() : sudden(work)
    }
    
    /// fix: 手指快速扫动未调用update(percentage:)动画不执行问题
    internal func sudden(_ work: @escaping () -> Void) {
        drivable?.update(0.01)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.025, execute: work)
    }
    
    internal func driven(_ viewController: UIViewController, presenting: Bool) {
        driveninViewController = viewController
        if let producer = viewController.dawn.transitionCapable as? DawnAnimationProducer {
            /// 手势拖动时使用.linear动画，保持与手指同步的效果
            drivenAdjustable = presenting ?
            producer.presentingAdjustable.regenerate() : producer.dismissingAdjustable.regenerate()
        }
    }
    
    internal func drivenComplete() {
        drivenAdjustable = nil
        drivenChanged = false
        driveninViewController?.dawn.invalidateInteractiveDriver()
        driveninViewController = nil
    }
}

public extension Dawn {

    public static let willInteractiveNotification = Notification.Name("dawn.willInteractive.notifi")
    public static let didInteractivePercentageNotification = Notification.Name("dawn.interactivePercentage.notifi")
    public static let didFinishInteractiveNotification = Notification.Name("dawn.finishedInteractive.notifi")
    
    public static let interactiveIsPresentingKey = "isPresenting"
    public static let interactivePercentageKey = "percentage"
    public static let interactiveIsFinishedKey = "isFinished"
}

extension DawnTransition {
    
    fileprivate func postWillInteractive(isPresenting: Bool) {
        let userInfo: [AnyHashable: Any] = [Dawn.interactiveIsPresentingKey: isPresenting]
        NotificationCenter.default.post(
            name: Dawn.willInteractiveNotification,
            object: nil, userInfo: userInfo
        )
    }
    
    fileprivate func postPercentageInteractive(percentage: CGFloat) {
        let userInfo: [AnyHashable: Any] = [Dawn.interactivePercentageKey: percentage]
        NotificationCenter.default.post(
            name: Dawn.didInteractivePercentageNotification,
            object: nil, userInfo: userInfo
        )
    }
    
    fileprivate func postFinishInteractive(isFinished: Bool) {
        let userInfo: [AnyHashable: Any] = [Dawn.interactiveIsFinishedKey: isFinished]
        NotificationCenter.default.post(
            name: Dawn.didFinishInteractiveNotification,
            object: nil, userInfo: userInfo
        )
    }
}

extension DawnTransition {
    
    fileprivate var drivable: UIPercentDrivenInteractiveTransition? {
        return driveninViewController?.dawn.interactiveDriver
    }
}

extension DawnTransitionAdjustable {
    
    fileprivate func regenerate() -> DawnTransitionAdjustable {
        return DawnTransitionAdjustable(
            delay: self.delay,
            duration: self.duration,
            curve: .linear,
            spring: self.spring,
            snapshotType: self.snapshotType,
            containerBackgroundColor: self.containerBackgroundColor,
            subviewsHierarchy: self.subviewsHierarchy
        )
    }
}
