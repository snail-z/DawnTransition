//
//  DawnTransition+Interactive.swift
//  DawnTransition
//
//  Created by zhang on 2020/6/9.
//  Copyright (c) 2020 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

// 当自定义动画不走 DawnAnimationProducer 管线时，可通过实现该协议
// 在手势交互开始时提供一个可被 "regenerate" 的 Producer，以获得线性、无弹性的手势体验。
public protocol DawnInteractiveConvertible {
    /// 返回一个用于手势交互阶段的 Producer（例如将自定义弹性动画替换为 pageIn/pageOut 的线性动画）
    func dawnInteractiveProducer() -> DawnAnimationProducer?
}

extension DawnDriver {
    
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
        // 若已有转场正在进行，忽略新的交互驱动，避免系统进入无动画但持有交互驱动的异常状态
        if isTransitioning { return }
        driveninViewController = viewController
        if let producer = viewController.dawn.transitionCapable as? DawnAnimationProducer {
            // Producer 动画：直接线性化参数
            drivenAdjustable = presenting ?
                producer.presentingAdjustable.regenerate() :
                producer.dismissingAdjustable.regenerate()
        } else if let convertible = viewController.dawn.transitionCapable as? DawnInteractiveConvertible,
                  let producer = convertible.dawnInteractiveProducer() {
            // 自定义动画：在交互阶段临时切换为 Producer，以获得线性手势体验
            viewController.dawn._interactiveBackupTransitionCapable = viewController.dawn.transitionCapable
            viewController.dawn.transitionCapable = producer
            drivenAdjustable = presenting ?
                producer.presentingAdjustable.regenerate() :
                producer.dismissingAdjustable.regenerate()
        }
    }
    
    internal func drivenComplete() {
        // 交互结束后，若曾临时切换为 Producer，则还原为原来的自定义动画
        if let vc = driveninViewController, let backup = vc.dawn._interactiveBackupTransitionCapable {
            vc.dawn.transitionCapable = backup
            vc.dawn._interactiveBackupTransitionCapable = nil
        }
        drivenAdjustable = nil
        drivenChanged = false
        driveninViewController?.dawn.invalidateInteractiveDriver()
        driveninViewController = nil
    }
}

public extension Dawn {

    static let willInteractiveNotification = Notification.Name("dawn.willInteractive.notifi")
    static let didInteractivePercentageNotification = Notification.Name("dawn.interactivePercentage.notifi")
    static let didFinishInteractiveNotification = Notification.Name("dawn.finishedInteractive.notifi")
    
    static let interactiveIsPresentingKey = "isPresenting"
    static let interactivePercentageKey = "percentage"
    static let interactiveIsFinishedKey = "isFinished"
}

extension DawnDriver {
    
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

extension DawnDriver {
    
    fileprivate var drivable: UIPercentDrivenInteractiveTransition? {
        return driveninViewController?.dawn.interactiveDriver
    }
}

extension DawnTransitionAdjustable {
    
    fileprivate func regenerate() -> DawnTransitionAdjustable {
        return DawnTransitionAdjustable(
            delay: self.delay,
            duration: self.spring == nil ? self.duration : 0.325,
            curve: .linear,
            spring: nil,
            snapshotType: self.snapshotType,
            containerBackgroundColor: self.containerBackgroundColor,
            subviewsHierarchy: self.subviewsHierarchy
        )
    }
}
