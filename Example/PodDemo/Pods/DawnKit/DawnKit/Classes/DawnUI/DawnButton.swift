//
//  DawnButton.swift
//  DawnUI
//
//  Created by zhanghao on 2022/10/1.
//  Copyright © 2022 snail-z. All rights reserved.
//

import UIKit

/**
*  提供以下功能：
*  1. 支持设置图片相对于 titleLabel 的位置 (imagePlacement)
*  2. 支持设置图片和 titleLabel 之间的间距 (imageAndTitleSpacing)
*  3. 支持自定义图片尺寸大小 (imageFixedSize)
*  4. 支持图片和 titleLabel 居中对齐或边缘对齐 (Content...Alignment)
*  5. 支持图片和 titleLabel 各自对齐到两端 (.spaceBetween)
*  6. 支持调整内容内边距 (contentEdgeInsets)
*  7. 支持子视图排列样式 (arrangedAlignment)
*  8. 支持调整 cornerRadius 始终保持为高度的 1/2 (adjustsRoundedCornersAutomatically)
*  9. 支持 Auto Layout 自撑开 (以上设置可根据内容自适应)
* 10. 支持扩增手势事件的响应区域 (touchResponseInsets)
*/
@objc open class DawnButton: UIView {
    
    /// 图片与文字布局位置
    @objc public enum ImagePlacement: Int {
        /// 图片在上，文字在下
        case top
        /// 图片在左，文字在右
        case left
        /// 图片在下，文字在上
        case bottom
        /// 图片在右，文字在左
        case right
    }
    
    /// 设置按图标和文字的相对位置，默认为ImagePlacement.left
    @objc public var imagePlacement: ImagePlacement = .left {
        didSet {
            guard imagePlacement != oldValue else { return }
            imagePlacementUpdates()
        }
    }
    
    /// 设置图标和文字之间的间隔，默认为10 (与对齐到两端样式冲突时优先布局.spaceBetween样式)
    @objc public var imageAndTitleSpacing: CGFloat = 10 {
        didSet {
            stackView.spacing = imageAndTitleSpacing
        }
    }
    
    /// 设置图标固定尺寸，默认为zero图标尺寸自适应
    @objc public var imageFixedSize: CGSize = .zero {
        didSet {
            guard !imageFixedSize.equalTo(oldValue) else { return }
            imageFixedSizeUpdates()
        }
    }
    
    /// 设置四周内边距，默认.zero
    @objc public var contentEdgeInsets: UIEdgeInsets = .zero {
        didSet {
            guard contentEdgeInsets != oldValue else { return }
            layoutUpdates()
        }
    }
    
    /// 竖直方向对齐样式
    public enum ContentVerticalAlignment: Int {
        /// nature常用于视图自适应内容大小时 // center, left, right, spaceBetween常用于高度已被约束时
        case nature, center, top, bottom, spaceBetween
    }
    
    /// 水平方向对齐样式
    public enum ContentHorizontalAlignment: Int {
        /// nature常用于视图自适应内容大小时 // center, left, right, spaceBetween常用于宽度已被约束时
        case nature, center, left, right, spaceBetween
    }
        
    /// 竖直方向对齐样式，默认顶部对齐
    public var contentVerticalAlignment: ContentVerticalAlignment = .nature {
        didSet {
            guard contentVerticalAlignment != oldValue else { return }
            layoutUpdates()
        }
    }
    
    /// 水平方向对齐样式，默认居左对齐
    public var contentHorizontalAlignment: ContentHorizontalAlignment = .nature {
        didSet {
            guard contentHorizontalAlignment != oldValue else { return }
            layoutUpdates()
        }
    }
    
    /// 子视图排列对齐样式
    @objc public var arrangedAlignment: UIStackView.Alignment = .center {
        didSet {
            stackView.alignment = arrangedAlignment
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
    
    /// 设置扩增手势事件的响应区域，默认UIEdgeInsetsZero
    @objc public var touchResponseInsets:UIEdgeInsets = .zero
    
    @objc public private(set) var imageView: UIImageView!
    @objc public private(set) var titleLabel: UILabel!
    private var stackView: UIStackView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        privateInitialization()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        privateInitialization()
    }
    
    private func privateInitialization() {
        stackView = UIStackView()
        stackView.alignment = arrangedAlignment
        stackView.spacing = imageAndTitleSpacing
        addSubview(stackView)
        
        imageView = UIImageView()
        stackView.addArrangedSubview(imageView)
        
        titleLabel = UILabel()
        titleLabel.lineBreakMode = .byTruncatingTail
        stackView.addArrangedSubview(titleLabel)
        
        layoutUpdates()
    }
    
    private func imagePlacementUpdates() {
        imageView.removeFromSuperview()
        switch imagePlacement {
        case .left, .top:
            stackView.insertArrangedSubview(imageView, at: 0)
        case .right, .bottom:
            stackView.addArrangedSubview(imageView)
        }
        
        layoutUpdates()
    }
    
    private func layoutUpdates() {
        switch imagePlacement {
        case .top, .bottom:
            stackView.axis = .vertical
            stackView.distribution = contentVerticalAlignment == .spaceBetween ? .equalCentering : .fill
            imageView.setContentHuggingPriority(.required, for: .vertical)
            imageView.setContentCompressionResistancePriority(.required, for: .vertical)
            contentVerticalLayoutUpdates()
        case .left, .right:
            stackView.axis = .horizontal
            stackView.distribution = contentHorizontalAlignment == .spaceBetween ? .equalCentering : .fill
            imageView.setContentHuggingPriority(.required, for: .horizontal)
            imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
            contentHorizontalLayoutUpdates()
        }
    }
    
    private func contentHorizontalLayoutUpdates() {
        let inset = contentEdgeInsets
        switch contentHorizontalAlignment {
        case .nature, .spaceBetween:
            stackView.dw.remakeConstraints { make in
                make.top.equalTo(inset.top)
                make.bottom.equalToSuperview().inset(inset.bottom)
                make.left.equalTo(inset.left)
                make.right.equalToSuperview().inset(inset.right)
            }
        case .center:
            stackView.dw.remakeConstraints { make in
                make.top.equalTo(inset.top)
                make.bottom.equalToSuperview().inset(inset.bottom)
                make.centerX.equalToSuperview()
                make.left.greaterThanOrEqualToSuperview().offset(inset.left)
                make.right.lessThanOrEqualToSuperview().inset(inset.right)
            }
        case .left:
            stackView.dw.remakeConstraints { make in
                make.top.equalTo(inset.top)
                make.bottom.equalToSuperview().inset(inset.bottom)
                make.left.equalTo(inset.left)
                make.right.lessThanOrEqualToSuperview().inset(inset.right)
            }
        case .right:
            stackView.dw.remakeConstraints { make in
                make.top.equalTo(inset.top)
                make.bottom.equalToSuperview().inset(inset.bottom)
                make.left.greaterThanOrEqualToSuperview().offset(inset.left)
                make.right.equalToSuperview().inset(inset.right)
            }
        }
    }
    
    private func contentVerticalLayoutUpdates() {
        let inset = contentEdgeInsets
        switch contentVerticalAlignment {
        case .nature, .spaceBetween:
            stackView.dw.remakeConstraints { make in
                make.left.equalTo(inset.left)
                make.right.equalToSuperview().inset(inset.right)
                make.top.equalTo(inset.top)
                make.bottom.equalToSuperview().inset(inset.bottom)
            }
        case .center:
            stackView.dw.remakeConstraints { make in
                make.left.equalTo(inset.left)
                make.right.equalToSuperview().inset(inset.right)
                make.centerY.equalToSuperview()
                make.top.greaterThanOrEqualToSuperview().offset(inset.top)
                make.bottom.lessThanOrEqualToSuperview().inset(inset.bottom)
            }
        case .top:
            stackView.dw.remakeConstraints { make in
                make.left.equalTo(inset.left)
                make.right.equalToSuperview().inset(inset.right)
                make.top.equalTo(inset.top)
                make.bottom.lessThanOrEqualToSuperview().inset(inset.bottom)
            }
        case .bottom:
            stackView.dw.remakeConstraints { make in
                make.left.equalTo(inset.left)
                make.right.equalToSuperview().inset(inset.right)
                make.top.greaterThanOrEqualToSuperview().offset(inset.top)
                make.bottom.equalToSuperview().inset(inset.bottom)
            }
        }
    }
    
    private func imageFixedSizeUpdates() {
        imageView.dw.updateConstraints { make in
            make.size.equalTo(imageFixedSize)
        }
    }
    
    open override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        guard adjustsRoundedCornersAutomatically else { return }
        layer.cornerRadius = bounds.height / 2
    }
    
    private func increscent(rect: CGRect, by inset: UIEdgeInsets) -> CGRect {
        guard inset != UIEdgeInsets.zero else { return rect }
        return CGRect(x: rect.minX - inset.left,
                      y: rect.minY - inset.top,
                      width: rect.width + inset.left + inset.right,
                      height: rect.height + inset.top + inset.bottom)
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = increscent(rect: bounds, by: touchResponseInsets)
        guard rect.equalTo(bounds) else {
            return rect.contains(point)
        }
        return super.point(inside: point, with: event)
    }
}
