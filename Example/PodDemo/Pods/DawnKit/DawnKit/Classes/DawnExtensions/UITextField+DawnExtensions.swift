//
//  UITextField+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit

public extension UITextField {

    /// UITextField文本类型 (邮件地址/密码/通用文本)
    enum TextType {
        case emailAddress, password, generic
    }
    
    /// 设置文本类型
    var textType: TextType {
        get {
            if self.keyboardType == .emailAddress {
                return .emailAddress
            } else if self.isSecureTextEntry {
                return .password
            }
            return .generic
        }
        set {
            switch newValue {
            case .emailAddress:
                self.keyboardType = .emailAddress
                self.autocorrectionType = .no
                self.autocapitalizationType = .none
                self.isSecureTextEntry = false
                self.placeholder = "Email Address"

            case .password:
                self.keyboardType = .asciiCapable
                self.autocorrectionType = .no
                self.autocapitalizationType = .none
                self.isSecureTextEntry = true
                self.placeholder = "Password"

            case .generic:
                self.isSecureTextEntry = false
            }
        }
    }

    /// 检查文本框是否为空
    var isEmpty: Bool {
        return self.text?.isEmpty == true
    }
    
    /// 返回无空格换行符的文本
    var trimmedText: String? {
        return self.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// 清除文本框
    func clear() {
        self.text = ""
        self.attributedText = NSAttributedString(string: "")
    }
    
    /// 设置占位符文本及颜色
    func setPlaceholder(_ string: String?, color: UIColor? = nil) {
        guard let holder = string, !holder.isEmpty else { return }
        let foregroundColor = color ?? UIColor.gray.withAlphaComponent(0.7)
        self.attributedPlaceholder = NSAttributedString(string: string!, attributes: [.foregroundColor: foregroundColor])
    }
}

#endif
