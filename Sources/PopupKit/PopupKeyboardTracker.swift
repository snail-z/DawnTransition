//
//  PopupKeyboardTracker.swift
//  PopupKit
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

final class PopupKeyboardTracker {

    var onKeyboardFrameChange: ((_ info: KeyboardInfo) -> Void)?
    var onKeyboardWillHide: ((_ info: KeyboardInfo) -> Void)?
    
    private var isResumedFromBackground = false

    init() {
        bindKeyboardNotifications()
        bindAppLifecycleNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func bindKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func bindAppLifecycleNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func appWillEnterForeground() {
        isResumedFromBackground = true
    }

    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let info = KeyboardInfo(notification) else { return }
        // 如果App是从后台回到前台，无论位置是否变化，都强制执行一次键盘回调（用于处理键盘切换、输入法变化等情况）
        if isResumedFromBackground {
            isResumedFromBackground = false
            onKeyboardFrameChange?(info)
            return
        }
        // 否则，只有当键盘位置或高度确实发生变化时才执行回调，避免动画抖动
        if (info.frameBegin.minY != info.frameEnd.minY) || (info.frameBegin.height != info.frameEnd.height) {
            onKeyboardFrameChange?(info)
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let info = KeyboardInfo(notification) else { return }
        onKeyboardWillHide?(info)
    }

    struct KeyboardInfo {
        var animationDuration: TimeInterval
        var animationOptions: UIView.AnimationOptions
        var frameBegin: CGRect
        var frameEnd: CGRect

        init?(_ notif: Notification) {
            guard let u = notif.userInfo,
                  let duration = u[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
                  let curve = u[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
                  let beginFrame = u[UIWindow.keyboardFrameBeginUserInfoKey] as? CGRect,
                  let endFrame = u[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return nil
            }

            self.animationDuration = duration
            self.animationOptions = UIView.AnimationOptions(rawValue: UInt(curve) << 16)
            self.frameBegin = beginFrame
            self.frameEnd = endFrame
        }
    }
}
