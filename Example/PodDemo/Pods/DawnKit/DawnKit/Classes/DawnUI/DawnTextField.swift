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
*  1. 支持调整左视图边缘留白 (leftViewPadding)
*  2. 支持调整右视图边缘留白 (rightViewPadding)
*  3. 支持调整清除按钮边缘留白 (clearButtonPadding)
*  4. 支持输入框文本边缘留白 (textEdgeInsets)
*  5. 增加键盘删除按钮的响应事件 - MATextField.deleteBackward
*/
@objc open class DawnTextField: UITextField {
    
    /// 左视图边缘留白
    @objc public var leftViewPadding: CGFloat = 0
    
    /// 右视图边缘留白
    @objc public var rightViewPadding: CGFloat = 0
    
    /// 清除按钮边缘留白
    @objc public var clearButtonPadding: CGFloat = 0
    
    /// 文本边缘留白
    @objc public var textEdgeInsets: UIEdgeInsets = .zero
    
    open override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var leftRect = super.leftViewRect(forBounds: bounds)
        leftRect.origin.x += leftViewPadding
        return leftRect
    }
    
    open override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rightRect = super.rightViewRect(forBounds: bounds)
        rightRect.origin.x -= rightViewPadding
        return rightRect
    }
    
    open override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        var clearRect = super.clearButtonRect(forBounds: bounds)
        clearRect.origin.x = bounds.size.width - clearRect.size.width - clearButtonPadding
        return clearRect
    }
    
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        return takeInputRect(forBounds: bounds, modes: [.always])
    }
    
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return takeInputRect(forBounds: bounds, modes: [.always, .whileEditing])
    }
    
    open override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        guard isEditing else {
            return textRect(forBounds: bounds)
        }
        return editingRect(forBounds: bounds)
    }
    
    private func takeInputRect(forBounds bounds: CGRect, modes: [ViewMode]) -> CGRect {
        var insets = textEdgeInsets
        
        if let _ = leftView, modes.contains(leftViewMode) {
            insets.left += leftViewRect(forBounds: bounds).maxX
        }
        
        if let _ = rightView, modes.contains(rightViewMode) {
            insets.right += (bounds.width - rightViewRect(forBounds: bounds).minX)
        } else {
            if modes.contains(clearButtonMode) {
                insets.right += (bounds.width - clearButtonRect(forBounds: bounds).minX - 8)
            }
        }
        return bounds.inset(by: insets)
    }

    open override func deleteBackward() {
        super.deleteBackward()
        sendActions(for: DawnTextField.deleteBackward)
    }
    
    /// 键盘删除按钮的响应事件
    ///
    ///     Usage: textField.addTarget(self, action: #selector(textFieldDeleteBackward(_:)), for: MATextField.deleteBackward)
    @objc public static var deleteBackward: UIControl.Event {
        return UIControl.Event(rawValue: 1026)
    }
    
    @discardableResult
    open override func becomeFirstResponder() -> Bool {
        /// 调用'becomeFirstResponder'后，MLeaksFinder会检测系统TextField内存泄漏，可关掉自动纠错来解决此问题
        /// https://github.com/Tencent/MLeaksFinder/issues/80
        autocorrectionType = .no
        return super.becomeFirstResponder()
    }
}
