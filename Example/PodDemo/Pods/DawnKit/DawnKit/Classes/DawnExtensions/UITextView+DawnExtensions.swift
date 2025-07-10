//
//  UITextView+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit

public extension UITextView {
 
    /// 清除文本框
    func clear() {
        self.text = ""
        self.attributedText = NSAttributedString(string: "")
    }
    
    /// 检查文本框是否为空
    var isEmpty: Bool {
        return self.text?.isEmpty == true
    }
    
    /// 返回去除首尾空格及首尾换行符的文本
    var trimmedWhitespacesAndNewlinesText: String? {
        return self.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// 返回去除首尾空格符的文本
    var trimmedWhitespacesText: String? {
        return self.text?.trimmingCharacters(in: .whitespaces)
    }
    
    /// 滚动到文本视图的底部
    func scrollToBottom() {
        let range = NSMakeRange((self.text as NSString).length - 1, 1)
        self.scrollRangeToVisible(range)
    }

    /// 滚动到文本视图的顶部
    func scrollToTop() {
        let range = NSMakeRange(0, 1)
        self.scrollRangeToVisible(range)
    }

    /// 去除内容多余边距
    func invalidateContentMargins() {
        self.contentInset = .zero
        self.scrollIndicatorInsets = .zero
        self.contentOffset = .zero
        self.textContainerInset = .zero
        self.textContainer.lineFragmentPadding = 0
    }
}

#endif
