//
//  DawnLabel.swift
//  DawnUI
//
//  Created by zhanghao on 2022/10/3.
//  Copyright © 2022 snail-z. All rights reserved.
//

import UIKit

/**
*  1. 提供调整文本内边距 (contentEdgeInsets)
*  2. 提供调整文本竖直方向对齐样式 (contentVerticalAlignment)
*  3. 支持调整 cornerRadius 始终保持为高度的 1/2 (adjustsRoundedCornersAutomatically)
*/
@objc open class DawnLabel: UILabel {

    /// 设置文本内边距
    @objc public var contentEdgeInsets: UIEdgeInsets = .zero {
        didSet {
            guard contentEdgeInsets != oldValue else { return }
            setNeedsDisplay()
            invalidateIntrinsicContentSize()
        }
    }
        
    /// 竖直方向对齐样式
    @objc public enum ContentVerticalAlignment: Int {
        /// 默认不处理/居中对齐/居顶对齐/居下对齐
        case nature, middle, top, bottom
    }
    
    /// 设置文本竖直方向对齐样式
    @objc public var contentVerticalAlignment: ContentVerticalAlignment = .nature {
        didSet {
            guard oldValue.rawValue != contentVerticalAlignment.rawValue else { return }
            setNeedsDisplay()
        }
    }
    
    /// 是否自动调整 `cornerRadius` 使其始终保持为高度的 1/2
    @objc public var adjustsRoundedCornersAutomatically: Bool = false {
        didSet {
            guard adjustsRoundedCornersAutomatically else { return }
            layer.masksToBounds = true
            setNeedsLayout()
        }
    }
    
    open override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        guard adjustsRoundedCornersAutomatically else { return }
        layer.cornerRadius = bounds.height / 2
    }
    
    open override func drawText(in rect: CGRect) {
        switch contentVerticalAlignment {
        case .top, .middle, .bottom:
            super.drawText(in: textRect(forBounds: rect, limitedToNumberOfLines: numberOfLines))
        default:
            super.drawText(in: rect.inset(by: contentEdgeInsets))
        }
    }
    
    open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        guard contentVerticalAlignment != .nature else {
            return natureTextRect(bounds: bounds, numberOfLines: numberOfLines)
        }
        var rect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        switch contentVerticalAlignment {
        case .top:
            rect.origin.y = bounds.origin.y + contentEdgeInsets.top
        case .middle:
            rect.origin.y = bounds.origin.y + (bounds.size.height - rect.size.height) / 2.0
        case .bottom:
            rect.origin.y = bounds.origin.y + bounds.size.height - rect.size.height - contentEdgeInsets.bottom
        default: break
        }
        rect.origin.x = bounds.origin.x + contentEdgeInsets.left
        rect.size.width = min(rect.width, bounds.width - contentEdgeInsets.left - contentEdgeInsets.right)
        rect.size.height = min(rect.height, bounds.height - contentEdgeInsets.top - contentEdgeInsets.bottom)
        return rect
    }
    
    private func natureTextRect(bounds: CGRect, numberOfLines: Int) -> CGRect {
        guard contentEdgeInsets != .zero else {
            return super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        }
        let insets = contentEdgeInsets
        var rect = super.textRect(forBounds: bounds.inset(by: insets), limitedToNumberOfLines: numberOfLines)
        rect.origin.x -= insets.left
        rect.origin.y -= insets.top
        rect.size.width += (insets.left + insets.right)
        rect.size.height += (insets.top + insets.bottom)
        return rect
    }
}
