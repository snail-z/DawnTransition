//
//  DawnTextView.swift
//  DawnUI
//
//  Created by zhanghao on 2022/10/1.
//  Copyright © 2022 snail-z. All rights reserved.
//

import UIKit

/**
*  提供以下功能：
*  1. 支持设置占位文本 (placeholder)
*  2. 支持设置占位文本颜色 (placeholderColor)
*  3. 支持设置占位文本内边距 (placeholderInsets)
*  4. 支持设置文本框是否需要自适应内容高度 (adjustsToFitContentHeightAutomatically)
*  5. 输入框 contentSize 改变回调 - didContentSizeChanged(oldSize, newSize)
*  6. 输入框变化增加删除事件 - deleteBackward
*/
@objc open class DawnTextView: UITextView, UITextViewDelegate {
    
    /// 设置占位文本
    @objc public var placeholder: String? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// 设置占位文本颜色
    @objc public var placeholderColor: UIColor? = .gray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// 调整占位文本内边距
    @objc public var placeholderInset: UIEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 8) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// 是否自适应内容高度，默认false (需要固定水平约束)
    @objc public var adjustsToFitContentHeightAutomatically = false

    /// 内容自适应限制的最大行数，默认0无限制
    @objc public var maxOfLinesToAutomaticallyLimit: NSInteger = 0 {
        didSet {
            guard oldValue != maxOfLinesToAutomaticallyLimit else {
                return
            }
            let oldSize = bounds.size
            invalidateIntrinsicContentSize()
            didContentSizeChanged?(oldSize, getIntrinsicContentSize())
        }
    }
    
    /// 输入框 contentSize 改变回调
    @objc public var didContentSizeChanged: ((_ oldSize: CGSize, _ newSize: CGSize) -> Void)? = nil
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        layoutManager.allowsNonContiguousLayout = false
        bindNotifications()
    }
    
    public required init?(coder: NSCoder) { super.init(coder: coder) }
    
    public override func draw(_ rect: CGRect) {
        guard !hasText else { return }
        guard let textValue = placeholder else { return }
        let fontValue = font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
        let colorValue = placeholderColor ?? UIColor.gray
        let attributedText = NSMutableAttributedString(string: textValue)
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.addAttribute(.font, value: fontValue, range: range)
        attributedText.addAttribute(.foregroundColor, value: colorValue, range: range)
        let rect = CGRect(x: placeholderInset.left + 8, // 优化占位文本偏移问题
                          y: placeholderInset.top,
                          width: bounds.width - placeholderInset.left - placeholderInset.right,
                          height: bounds.height - placeholderInset.top - placeholderInset.bottom)
        attributedText.draw(in: rect)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    public override var font: UIFont? {
        get {
            return super.font
        } set {
            super.font = newValue
            setNeedsDisplay()
        }
    }
    
    public override var attributedText: NSAttributedString! {
        get {
            return super.attributedText
        } set {
            setNeedsDisplay()
        }
    }
    
    public override var text: String! {
        get {
            return super.text
        } set {
            setNeedsDisplay()
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        return getIntrinsicContentSize()
    }
    
    private func heightForNumberOfLines(_ lines: NSInteger) -> CGFloat {
        return ceil((font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)).lineHeight * CGFloat(lines) + textContainerInset.top + textContainerInset.bottom)
    }
    
    private func getIntrinsicContentSize() -> CGSize {
        var size = self.contentSize
        size.height = max(heightForNumberOfLines(1), size.height)
        if maxOfLinesToAutomaticallyLimit > 0 {
            size.height = min(heightForNumberOfLines(maxOfLinesToAutomaticallyLimit), size.height)
        }
        return size;
    }
    
    private func bindNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: UITextView.textDidChangeNotification, object: nil)
        addObserver(self, forKeyPath: "contentSize", options: [.old, .new], context: nil)
    }
    
    private func unbindNotifications() {
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: nil)
        removeObserver(self, forKeyPath: "contentSize")
    }
    
    @objc private func textDidChange(_ notif: Notification) {
        setNeedsDisplay()
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            guard adjustsToFitContentHeightAutomatically else { return }
            if let oldSize = change?[.oldKey] as? CGSize,
               let newSize = change?[.newKey] as? CGSize,
                !oldSize.equalTo(newSize), newSize.width > 0, newSize.height > 0 {
                invalidateIntrinsicContentSize()
                didContentSizeChanged?(oldSize, getIntrinsicContentSize())
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    deinit {
        unbindNotifications()
    }
    
    public override func deleteBackward() {
        super.deleteBackward()
        delegate?.textViewDidChange?(self)
    }
}
