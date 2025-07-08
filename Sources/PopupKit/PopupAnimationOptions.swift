//
//  PopupAnimationOptions.swift
//  PopupKit
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z <haozhang0770@163.com> All rights reserved.
//

import Foundation
import UIKit

public struct PopupAnimationOptions: Sendable {
    
    public var duration: TimeInterval
    public var delay: TimeInterval
    public var options: UIView.AnimationOptions
    
    // 是否使用弹性动画，默认无弹性效果
    public var useSpringAnimation: Bool
    
    // 弹性动画专用参数
    public var usingSpringWithDamping: CGFloat
    public var initialSpringVelocity: CGFloat
    
    public static let `default` = PopupAnimationOptions()
    
    public init(
        duration: TimeInterval = 0.25,
        delay: TimeInterval = 0,
        options: UIView.AnimationOptions = [.curveEaseOut],
        useSpringAnimation: Bool = false,
        usingSpringWithDamping: CGFloat = 0.6,
        initialSpringVelocity: CGFloat = 0.25
    ) {
        self.duration = duration
        self.delay = delay
        self.options = options
        self.useSpringAnimation = useSpringAnimation
        self.usingSpringWithDamping = usingSpringWithDamping
        self.initialSpringVelocity = initialSpringVelocity
    }
}
