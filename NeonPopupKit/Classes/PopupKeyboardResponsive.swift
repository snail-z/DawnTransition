//
//  PopupKeyboardResponsive.swift
//  PopupKit
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

public protocol PopupKeyboardResponsive {
    
    /// 用于键盘响应的输入视图（如UITextField/UITextView）
    var popupKeyboardInputView: UIView? { get }
    
    /// 键盘弹出后，弹窗视图与键盘顶部的间距（默认0，表示贴合键盘）
    var popupKeyboardOffsetFromKeyboardTop: CGFloat { get }
    
    /// 是否在键盘弹出时联动弹窗布局，默认true
    var shouldTrackPopupKeyboard: Bool { get }
    
    /// 弹窗显示时是否立即让弹起键盘(成为第一响应者)，默认true
    var shouldBecomeFirstResponderOnPopupShow: Bool { get }
}

public extension PopupKeyboardResponsive {

    var popupKeyboardOffsetFromKeyboardTop: CGFloat { return .zero }
    
    var shouldTrackPopupKeyboard: Bool { return true }
    
    var shouldBecomeFirstResponderOnPopupShow: Bool { return true }
}
