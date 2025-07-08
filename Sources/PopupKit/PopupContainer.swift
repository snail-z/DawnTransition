//
//  PopupContainer.swift
//  PopupKit
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

@MainActor
internal class PopupContainer: UIView {

    let contentView: UIView & PopupPresentable
    let config: PopupConfiguration
    private var dismissTimer: Timer?
    private let onRequestDismiss: () -> Void
    private let coverView: PopupCoverView

    init(contentView: UIView & PopupPresentable, config: PopupConfiguration, onRequestDismiss: @escaping () -> Void) {
        self.contentView = contentView
        self.config = config
        self.onRequestDismiss = onRequestDismiss
        self.coverView = PopupCoverView(style: config.coverStyle)
        super.init(frame: .zero)

        addSubview(coverView)
        addSubview(contentView)
    
        coverView.tapHandler = { [weak self] in
            guard let self = self else { return }
            if self.config.dismissOnMaskTap {
                self.onRequestDismiss()
            }
        }

        setupKeyboardBindingIfNeeded()
    }
    
    func layoutPopupIfNeeded() {
        coverView.frame = bounds
        let size = contentView.preferredPopupSize(in: self)
        let origin = calculateContentOrigin(for: size)
        contentView.frame = CGRect(origin: origin, size: size)
    }

    private func calculateContentOrigin(for size: CGSize) -> CGPoint {
        switch config.placement {
        case .center:
            return CGPoint(x: (bounds.width - size.width)/2,
                           y: (bounds.height - size.height)/2 + config.placementOffset)
        case .bottom:
            return CGPoint(x: (bounds.width - size.width)/2,
                           y: bounds.height - size.height - config.placementOffset)
        case .top:
            return CGPoint(x: (bounds.width - size.width)/2,
                           y: config.placementOffset)
        case .left:
            return CGPoint(x: config.placementOffset,
                           y: (bounds.height - size.height)/2)
        case .right:
            return CGPoint(x: bounds.width - size.width - config.placementOffset,
                           y: (bounds.height - size.height)/2)
        }
    }
    
    func performShowAnimation(completion: @escaping () -> Void) {
        setupAutoDismissTimerIfNeeded()
        becomeKeyboardIfNeeded()
        let animator = config.animator ?? enterAnimator(from: config.animationType)
        animator.animateIn(container: self, coverView: coverView, contentView: contentView, completion: completion)
        Popupkit.log("[PopupPresenter] showing contentView: \(type(of: contentView)), placement: \(config.placement), animator: \(animator)")
    }

    func performDismissAnimation(completion: @escaping () -> Void) {
        clearAutoDismissTimerIfNeeded()
        resignKeyboardIfNeeded()
        let animator = config.animator ?? exitAnimator(from: config.animationType)
        animator.animateOut(container: self, coverView: coverView, contentView: contentView, completion: completion)
        Popupkit.log("[PopupPresenter] dismiss contentView: \(type(of: contentView)), placement: \(config.placement), animator: \(animator)")
    }

    private func enterAnimator(from type: PopupConfiguration.AnimationType) -> PopupAnimatable {
        switch type {
        case .slide(let direction):
            return PopupSlideAnimator(enter: .default, exit: .default, directions: .same(direction))
        case .scale(let scale):
            return PopupScaleAnimator(enter: .default, exit: .default, initialScale: scale)
        case .fade:
            return PopupFadeAnimator(enter: .default, exit: .default)
        case .none:
            return PopupFadeAnimator(
                enter: PopupAnimationOptions(duration: .zero),
                exit: PopupAnimationOptions(duration: .zero)
            )
        case .selectBy(let enter, _):
            return enterAnimator(from: enter)
        }
    }
    
    private func exitAnimator(from type: PopupConfiguration.AnimationType) -> PopupAnimatable {
        switch type {
        case .slide(let direction):
            return PopupSlideAnimator(enter: .default, exit: .default, directions: .same(direction))
        case .scale(let scale):
            return PopupScaleAnimator(enter: .default, exit: .default, initialScale: scale)
        case .fade:
            return PopupFadeAnimator(enter: .default, exit: .default)
        case .none:
            return PopupFadeAnimator(
                enter: PopupAnimationOptions(duration: .zero),
                exit: PopupAnimationOptions(duration: .zero)
            )
        case .selectBy(_, let exit):
            return exitAnimator(from: exit)
        }
    }

    private func setupAutoDismissTimerIfNeeded() {
        guard config.autoDismissDelay > .zero else {
            return
        }
        clearAutoDismissTimerIfNeeded()
        dismissTimer = Timer.scheduledTimer(withTimeInterval: config.autoDismissDelay, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.onRequestDismiss()
            }
        }
        if let timer = dismissTimer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    private func clearAutoDismissTimerIfNeeded() {
        dismissTimer?.invalidate()
        dismissTimer = nil
    }
    
    private var originalCenter: CGPoint?
    private var keyboardTracker: PopupKeyboardTracker?
    private func setupKeyboardBindingIfNeeded() {
        guard let keyboardAware = contentView as? PopupKeyboardResponsive,
              keyboardAware.shouldTrackPopupKeyboard else { return }
        keyboardTracker = PopupKeyboardTracker()

        keyboardTracker?.onKeyboardFrameChange = { [weak self] info in
            guard let `self` = self else { return }
            if originalCenter == nil {
                originalCenter = contentView.center
            }
            let frameConverted = coverView.convert(info.frameEnd, from: nil)
            let keyboardHeightConverted = coverView.bounds.height - frameConverted.minY
            guard keyboardHeightConverted > .zero else { return }
            let originY = contentView.frame.maxY - frameConverted.minY
            let newCenter = CGPoint(
                x: contentView.center.x,
                y: contentView.center.y - originY - keyboardAware.popupKeyboardOffsetFromKeyboardTop
            )
            UIView.animate(withDuration: info.animationDuration, delay: 0, options:info.animationOptions, animations: {
                self.contentView.center = newCenter
            }, completion: nil)
        }

        keyboardTracker?.onKeyboardWillHide = { [weak self] info in
            guard let `self` = self else { return }
            guard let original = originalCenter, contentView.isPopupVisible else { return }
            UIView.animate(withDuration: info.animationDuration, delay: 0, options:info.animationOptions, animations: {
                self.contentView.center = original
                self.originalCenter = nil
            }, completion: nil)
        }
    }
    
    private func becomeKeyboardIfNeeded() {
        if let keyboardAware = contentView as? PopupKeyboardResponsive,
           keyboardAware.shouldTrackPopupKeyboard, keyboardAware.shouldBecomeFirstResponderOnPopupShow {
            if let responder = keyboardAware.popupKeyboardInputView {
                responder.becomeFirstResponder()
            }
        }
    }
    
    private func resignKeyboardIfNeeded() {
        if let keyboardAware = contentView as? PopupKeyboardResponsive,
            keyboardAware.shouldTrackPopupKeyboard {
            keyboardAware.popupKeyboardInputView?.resignFirstResponder()
            if let responder = keyboardAware.popupKeyboardInputView {
                responder.resignFirstResponder()
            }
        }
    }
    
    deinit {
        Popupkit.log("[PopupPresenter] deinit🧹 [\(type(of: contentView))]")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
