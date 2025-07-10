//
//  DawnTagContainerView.swift
//  DawnUI
//
//  Created by zhang on 2023/2/23.
//  Copyright © 2020 snail-z. All rights reserved.
//

import UIKit

/**
*  1. 类似`UIStackView`用法，根据子视图自撑开，自动排列换行 「子视图内须支持`sizeThatFits`方法」
*  2. 支持子视图隐藏显示，动态布局，无需调整约束
 「注意：若在UITableViewCell自适应高度中使用到MATagContainerView，
   外部可以二次视图封装提前约束好尺寸，参考MAWrapTagView使用 -
   由于UITableView.automaticDimension自适应高度，内部子视图约束会异步调用updateViewConstraints刷新布局，
   而MATagContainerView内部子视图也会异步调用layoutIfNeeded刷新布局，
   所以计算内容后的大小可能会晚于UITableView.automaticDimension的高度，导致不能有效撑开内容布局」
 */
@objc open class DawnTagContainerView: UIView {

    /// 设置水平方向间距
    @objc public var horizontalSpacing: CGFloat = .zero {
        didSet {
            guard oldValue != horizontalSpacing else { return }
            setNeedsLayout()
        }
    }
    
    /// 设置竖直方向间距
    @objc public var verticalSpacing: CGFloat = .zero {
        didSet {
            guard oldValue != verticalSpacing else { return }
            setNeedsLayout()
        }
    }
    
    /// 设置布局最大宽度 (若外部手动约束宽度则设为.zero即可，若外部需要自适应宽度，则需要设置该值)
    @objc public var preparedMaxLayoutWidth: CGFloat = .zero {
        didSet {
            guard oldValue != preparedMaxLayoutWidth else { return }
            setNeedsLayout()
        }
    }
    
    /// 设置四周内边距，默认.zero
    @objc public var contentEdgeInsets: UIEdgeInsets = .zero {
        didSet {
            guard oldValue != contentEdgeInsets else { return }
            setNeedsLayout()
        }
    }
    
    /// 水平方向以基准线排列方式
    @objc public enum BaselineArrangement: Int {
        /// 默认以基准线居顶/居下/居中
        case top, bottom, center
    }
    
    /// 设置水平方向以基准线排列方式
    @objc public var baselineArrangement: BaselineArrangement = .top {
        didSet {
            guard oldValue != baselineArrangement else { return }
            setNeedsLayout()
        }
    }
    
    /// 所有已添加排列的子视图
    @objc public private(set) lazy var arrangedSubviews: [UIView] = {
        return [UIView]()
    }()

    /// 监听内容布局大小发生改变
    @objc public var didIntrinsicSizeChanged: ((_ oldSize: CGSize, _ newSize: CGSize) -> Void)?
    
    private let observerKeys = ["hidden", "layer.opacity"]
    private var contentLayoutSize: CGSize = .zero
    
    open override var intrinsicContentSize: CGSize {
        guard !arrangedSubviews.isEmpty, contentLayoutSize.isValid else {
            return super.intrinsicContentSize
        }
        return contentLayoutSize
    }
    
    /// 添加需要自动排列的子视图
    @objc open func addArrangedSubview(_ aView: UIView) {
        guard aView.superview == nil else { return }
        addSubview(aView)
        arrangedSubviews.append(aView)
        for aKey in observerKeys {
            aView.addObserver(self, forKeyPath:aKey, options: [.new, .old], context: nil)
        }
    }
    
    /// 删除自动排列的子视图
    @objc open func removeArrangedSubview(_ aView: UIView) {
        guard let _ = aView.superview else { return }
        for index in 0..<arrangedSubviews.count {
            let v = arrangedSubviews[index]
            guard v == aView else { continue }
            aView.removeFromSuperview()
            arrangedSubviews.remove(at: index)
            contentLayoutSize = .zero
            invalidateIntrinsicContentSize()
            break
        }
    }
    
    /// 删除所有自排列的子视图
    @objc open func removeAllArrangedSubviews() {
        guard !arrangedSubviews.isEmpty else { return }
        for v in arrangedSubviews {
            v.removeFromSuperview()
        }
        arrangedSubviews.removeAll()
        contentLayoutSize = .zero
        invalidateIntrinsicContentSize()
    }
    
    open override func willRemoveSubview(_ subview: UIView) {
        if !arrangedSubviews.isEmpty {
            for aKey in observerKeys {
                subview.removeObserver(self, forKeyPath: aKey)
            }
        }
        return super.willRemoveSubview(subview)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let aKey = keyPath, observerKeys.contains(aKey) {
            setNeedsLayout()
            contentLayoutSize = .zero
            invalidateIntrinsicContentSize()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let _s = getIntrinsicSize()
        if !contentLayoutSize.equalTo(_s) {
            didIntrinsicSizeChanged?(contentLayoutSize, _s)
            contentLayoutSize = _s
            invalidateIntrinsicContentSize()
        }
    }
    
    private func baselineLayout(_ startIndex: Int, _ endIndex: Int, _ maxHeight: CGFloat) {
        switch baselineArrangement {
        case .top: return
        case .center:
            let minline = arrangedSubviews[startIndex].frame.minY
            for v in arrangedSubviews[startIndex...endIndex] {
                v.centerY = minline + maxHeight / 2
            }
        case .bottom:
            let minline = arrangedSubviews[startIndex].frame.minY
            for v in arrangedSubviews[startIndex...endIndex] {
                v.bottom = minline + maxHeight
            }
        }
    }
    
    /// 布局子视图并返回内容实际大小
    @discardableResult
    @objc public func getIntrinsicSize() -> CGSize {
        var linemax: (height: CGFloat, x: CGFloat) = (.zero, .zero)
        var different: (existed: Bool, height: CGFloat) = (false, .zero)
        var startIndex = Int.zero
        
        for idx in 0..<arrangedSubviews.count {
            let v = arrangedSubviews[idx]
            if !v.isHidden && v.alpha > .zero {
                let size = v.sizeThatFits(.greatestFiniteMagnitude).ceiled()
                different.height = size.height
                linemax.height = size.height
                startIndex = idx
                break
            }
        }
        
        guard !arrangedSubviews.isEmpty, startIndex < arrangedSubviews.endIndex else {
            return .zero
        }
        
        let maxLayoutWidth = preparedMaxLayoutWidth > .zero ? preparedMaxLayoutWidth : bounds.width
        guard maxLayoutWidth > .zero else {
            fatalError("若使内容自适应大小，必须设置最大布局宽度! preparedMaxLayoutWidth = \(preparedMaxLayoutWidth)")
        }
        
        var p = CGPoint(x: contentEdgeInsets.left, y: contentEdgeInsets.top)
        var newlineIndex = startIndex
        var lastableIndex = startIndex;
        for idx in startIndex..<arrangedSubviews.count {
            let v = arrangedSubviews[idx]
            guard !v.isHidden, v.alpha > .zero else { continue }
            lastableIndex = idx;
            var size = v.sizeThatFits(.greatestFiniteMagnitude).ceiled()
            size.width = min(size.width, maxLayoutWidth)
            if p.x + size.width + contentEdgeInsets.right > maxLayoutWidth {
                if different.existed {
                    baselineLayout(newlineIndex, idx - 1, linemax.height)
                    different.existed = false
                }
                newlineIndex = idx
                different.height = size.height
                
                p.x = contentEdgeInsets.left
                p.y += linemax.height + verticalSpacing
                linemax.height = size.height
            }
            v.frame = CGRect(origin: p, size: size)
            p.x += size.width + horizontalSpacing
            
            linemax.x = max(v.frame.maxX + contentEdgeInsets.right, linemax.x)
            linemax.height = max(size.height, linemax.height)
            
            guard size.height != different.height else { continue }
            different.existed = true
            different.height = linemax.height
        }
        defer {
            if different.existed {
                baselineLayout(newlineIndex, lastableIndex, linemax.height)
            }
        }
        return CGSize(width: linemax.x, height: arrangedSubviews[lastableIndex].frame.minY + linemax.height + contentEdgeInsets.bottom)
    }
}
