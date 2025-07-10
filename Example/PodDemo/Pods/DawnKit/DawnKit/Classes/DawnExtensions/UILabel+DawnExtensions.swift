//
//  UILabel+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit

public extension UILabel {
    
    /// 设置文本时显示淡出动画
    func set(text string: String?, duration: TimeInterval = 0.25) {
        let transition = CATransition()
        transition.duration = duration
        transition.type = .fade
        transition.subtype = .none
        self.layer.add(transition, forKey: nil)
        self.text = string
    }
    
    /// 获取自适应估算大小
    func estimatedSize(width: CGFloat = CGFloat.greatestFiniteMagnitude, height: CGFloat = CGFloat.greatestFiniteMagnitude) -> CGSize {
        self.sizeThatFits(CGSize(width: width, height: height))
    }
    
    /// 获取自适应估算宽度
    func estimatedWidth() -> CGFloat {
        self.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: self.bounds.height)).width
    }
    
    /// 获取自适应估算高度
    func estimatedHeight() -> CGFloat {
        self.sizeThatFits(CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)).height
    }
}

#endif
