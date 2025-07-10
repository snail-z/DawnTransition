//
//  UINavigationBar+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

#if os(iOS)

import UIKit

public extension UINavigationBar {

    /// 设置导航栏标题字体和颜色
    func setTitleFont(_ font: UIFont, color: UIColor = .black) {
        var attrs = [NSAttributedString.Key: Any]()
        attrs[.font] = font
        attrs[.foregroundColor] = color
        self.titleTextAttributes = attrs
    }

    /// 设置导航栏背景和文本颜色
    func setColors(background: UIColor, text: UIColor) {
        self.isTranslucent = false
        self.backgroundColor = background
        self.barTintColor = background
        self.setBackgroundImage(UIImage(), for: .default)
        self.tintColor = text
        self.titleTextAttributes = [.foregroundColor: text]
    }

    /// 设置tintColor使导航栏透明
    func makeTransparent(withTint tint: UIColor = .white) {
        self.isTranslucent = true
        self.backgroundColor = .clear
        self.barTintColor = .clear
        self.setBackgroundImage(UIImage(), for: .default)
        self.tintColor = tint
        self.titleTextAttributes = [.foregroundColor: tint]
        self.shadowImage = UIImage()
    }
}

#endif
