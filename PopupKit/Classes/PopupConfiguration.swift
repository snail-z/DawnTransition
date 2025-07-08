//
//  PopupConfiguration.swift
//  PopupKit
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

public struct PopupConfiguration {
    
    /// 遮罩样式
    public enum CoverStyle {
        case none
        case color(UIColor)
        case blur(UIBlurEffect.Style)
    }
    
    /// 遮罩视图样式，默认为黑色半透明
    public var coverStyle: CoverStyle = .color(.black.withAlphaComponent(0.5))
    
    /// 弹窗最终出现的位置
    public enum Placement {
        case top, left, bottom, right, center
    }
    
    /// 弹窗视图的展示位置，默认为 center
    public var placement: Placement = .center

    /// 对最终展示位置进行偏移调整
    public var placementOffset: CGFloat = .zero
    
    /// 是否点击遮罩时自动关闭，默认true
    public var dismissOnMaskTap: Bool = true
    
    /// 自动消失时间，0表示不自动消失
    public var autoDismissDelay: TimeInterval = 0
    
    /// 动画类型
    public enum AnimationType: Equatable {
        case slide(_ direction: PopupSlideAnimator.Direction)
        case scale(_ scale: CGFloat = 0.85)
        case fade
        case none
        
        indirect case selectBy(enter: AnimationType, exit: AnimationType)
    }
    
    /// 动画类型
    public var animationType: AnimationType = .none
    
    /// 自定义动画
    public var animator: PopupAnimatable?
    
    /// 内部触发关闭时回调 (用于替换默认关闭行为)
    public var onAutoDismiss: ((UIView) -> ())?//UIView is contentView.
    
    /// 弹窗即将展示时回调
    public var onWillPresent: ((UIView) -> ())?
    
    /// 弹窗已经展示时回调
    public var onDidPresent: ((UIView) -> ())?
    
    /// 弹窗即将关闭时回调
    public var onWillDismiss: ((UIView) -> ())?

    /// 弹窗已经关闭时回调
    public var onDidDismiss: ((UIView) -> ())?
    
    /// 初始化配置
    public init(
        coverStyle: CoverStyle = .color(.black.withAlphaComponent(0.5)),
        placement: Placement = .center,
        placementOffset: CGFloat = .zero,
        dismissOnMaskTap: Bool = true,
        autoDismissDelay: TimeInterval = 0,
        animationType: AnimationType = .none,
        animator: PopupAnimatable? = nil,
        onAutoDismiss: ((UIView) -> Void)? = nil,
        onWillPresent: ((UIView) -> Void)? = nil,
        onDidPresent: ((UIView) -> Void)? = nil,
        onWillDismiss: ((UIView) -> Void)? = nil,
        onDidDismiss: ((UIView) -> Void)? = nil
    ) {
        self.coverStyle = coverStyle
        self.placement = placement
        self.autoDismissDelay = autoDismissDelay
        self.dismissOnMaskTap = dismissOnMaskTap
        self.placementOffset = placementOffset
        self.animationType = animationType
        self.animator = animator
        self.onAutoDismiss = onAutoDismiss
        self.onWillPresent = onWillPresent
        self.onDidPresent = onDidPresent
        self.onWillDismiss = onWillDismiss
        self.onDidDismiss = onDidDismiss
    }
}
