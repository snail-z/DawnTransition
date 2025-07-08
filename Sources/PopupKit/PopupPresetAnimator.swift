//
//  PopupPresetAnimator.swift
//  PopupKit
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

// MARK: - FadeAnimator
public final class PopupFadeAnimator: @preconcurrency PopupAnimatable {
    
    let enterOptions: PopupAnimationOptions
    let exitOptions: PopupAnimationOptions
    
    public init(enter: PopupAnimationOptions, exit:PopupAnimationOptions) {
        self.enterOptions = enter
        self.exitOptions = exit
    }
    
    @MainActor
    public func animateIn(container: UIView, coverView: UIView, contentView: UIView, completion: @escaping () -> Void) {
        let opt = enterOptions
        container.alpha = 0
        UIView.animate(duration: opt.duration, delay: opt.delay, spring: opt.spring, options: opt.options) {
            container.alpha = 1
        } completion: { _ in
            completion()
        }
    }
    
    @MainActor
    public func animateOut(container: UIView, coverView: UIView, contentView: UIView, completion: @escaping () -> Void) {
        let opt = exitOptions
        UIView.animate(duration: opt.duration, delay: opt.delay, spring: opt.spring, options: opt.options) {
            container.alpha = 0
        } completion: { _ in
            completion()
        }
    }
}

// MARK: - ScaleAnimator
public final class PopupScaleAnimator: @preconcurrency PopupAnimatable {
    
    let initialScale: CGFloat
    let enterOptions: PopupAnimationOptions
    let exitOptions: PopupAnimationOptions
    
    public init(enter: PopupAnimationOptions, exit:PopupAnimationOptions, initialScale: CGFloat = 0.85) {
        self.enterOptions = enter
        self.exitOptions = exit
        self.initialScale = initialScale
    }
    
    @MainActor
    public func animateIn(container: UIView, coverView: UIView, contentView: UIView, completion: @escaping () -> Void) {
        let opt = enterOptions
        container.alpha = 0
        contentView.transform = CGAffineTransform(scaleX: initialScale, y: initialScale)
        UIView.animate(duration: opt.duration, delay: opt.delay, spring: opt.spring, options: opt.options) {
            container.alpha = 1
            contentView.transform = .identity
        } completion: { _ in
            completion()
        }
    }

    @MainActor
    public func animateOut(container: UIView, coverView: UIView, contentView: UIView, completion: @escaping () -> Void) {
        let opt = exitOptions
        UIView.animate(duration: opt.duration, delay: opt.delay, spring: opt.spring, options: opt.options) {
            container.alpha = 0
            contentView.transform = CGAffineTransform(scaleX: self.initialScale, y: self.initialScale)
        } completion: { _ in
            contentView.transform = .identity
            completion()
        }
    }
}

// MARK: - SlideAnimator
public final class PopupSlideAnimator: @preconcurrency PopupAnimatable {

    public enum Direction {
        case top, bottom, left, right
    }
    
    public struct DirectionPair {
        let enter: Direction
        let exit: Direction

        public init(enter: Direction, exit: Direction) {
            self.enter = enter
            self.exit = exit
        }

        public static func same(_ direction: Direction) -> DirectionPair {
            return .init(enter: direction, exit: direction)
        }
    }
    
    let directions: DirectionPair
    let enterOptions: PopupAnimationOptions
    let exitOptions: PopupAnimationOptions
    
    public init(enter: PopupAnimationOptions, exit:PopupAnimationOptions, directions: DirectionPair = .same(.bottom)) {
        self.enterOptions = enter
        self.exitOptions = exit
        self.directions = directions
    }

    @MainActor
    public func animateIn(container: UIView, coverView: UIView, contentView: UIView, completion: @escaping () -> Void) {
        let finalFrame = contentView.frame
        var startFrame = finalFrame
        switch directions.enter {
        case .top:
            startFrame.origin.y = -finalFrame.height
        case .bottom:
            startFrame.origin.y = coverView.bounds.height
        case .left:
            startFrame.origin.x = -finalFrame.width
        case .right:
            startFrame.origin.x = coverView.bounds.width
        }

        // 设置起始状态
        contentView.frame = startFrame
        coverView.alpha = 0

        // 执行动画到目标位置
        let opt = enterOptions
        UIView.animate(duration: opt.duration, delay: opt.delay, spring: opt.spring, options: opt.options) {
            contentView.frame = finalFrame
            coverView.alpha = 1
        } completion: { _ in
            completion()
        }
    }

    @MainActor
    public func animateOut(container: UIView, coverView: UIView, contentView: UIView, completion: @escaping () -> Void) {
        var endFrame = contentView.frame
        switch directions.exit {
        case .top:
            endFrame.origin.y = -endFrame.height
        case .bottom:
            endFrame.origin.y = coverView.bounds.height
        case .left:
            endFrame.origin.x = -endFrame.width
        case .right:
            endFrame.origin.x = coverView.bounds.width
        }

        let opt = exitOptions
        UIView.animate(duration: opt.duration, delay: opt.delay, spring: opt.spring, options: opt.options) {
            contentView.frame = endFrame
            coverView.alpha = 0
        } completion: { _ in
            completion()
        }
    }
}
