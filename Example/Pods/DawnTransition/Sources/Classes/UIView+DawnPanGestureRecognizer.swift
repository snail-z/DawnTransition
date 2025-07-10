//
//  UIView+DawnPanGestureRecognizer.swift
//  DawnTransition
//
//  Created by zhang on 2022/7/5.
//  Copyright (c) 2022 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

extension DawnExtension where Base: UIView {

    /// 添加转场驱动手势
    public func addPanGestureRecognizer(_ gestureRecognizer: DawnPanGestureRecognizer, forPresenting: Bool = false) {
        var isAllowable = true
        if !forPresenting { // fix：Presenting手势转场时，无法自动识别Dawn绑定手势问题 (处理成-直接添加手势 不校验isModalEnabled/isNavigationEnabled)
            let modalEnabled = gestureRecognizer.driverViewController.dawn.isModalEnabled
            let navigationEnabled = gestureRecognizer.driverViewController.dawn.isNavigationEnabled
            isAllowable = modalEnabled || navigationEnabled
        }
        guard isAllowable else { return }
        removePanGestureRecognizer(gestureRecognizer)
        gestureRecognizer.bindPanRecognizer(base)
        panGestures?.append(gestureRecognizer)
    }
    
    /// 删除转场驱动手势
    public func removePanGestureRecognizer(_ gestureRecognizer: DawnPanGestureRecognizer) {
        guard let _ = panGestures else { return }
        let gr = panGestures!.first(where: { $0 == gestureRecognizer })
        gr?.unbindPanRecognizer(base)
        panGestures!.removeAll(where: { $0 == gestureRecognizer })
        guard panGestures!.isEmpty else { return }
        panGestures = nil
    }
    
    /// 删除全部驱动手势
    public func removeAllPanGestureRecognizers() {
        guard let _ = panGestures else { return }
        for gr in panGestures! {
            gr.unbindPanRecognizer(base)
        }
        panGestures?.removeAll()
        panGestures = nil
    }
}

fileprivate var UIViewAssociatedDawnPanGestureRecognizerKey: Void?
extension DawnExtension where Base: UIView {
    
    fileprivate var panGestures: [DawnPanGestureRecognizer]? {
        get {
            if let value = objc_getAssociatedObject(base, &UIViewAssociatedDawnPanGestureRecognizerKey) as? [DawnPanGestureRecognizer] {
                return value
            }
            let values = [DawnPanGestureRecognizer]()
            self.panGestures = values
            return values
        }
        set {
            objc_setAssociatedObject(base, &UIViewAssociatedDawnPanGestureRecognizerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

@objc open class DawnPanGestureRecognizer: NSObject {
    
    /// 默认true只在屏幕边缘识别手势，若设为false则全屏幕识别
    @objc public var isRecognizeWhenEdges: Bool = true

    @objc public enum Direction: Int {
        case leftToRight, rightToLeft, topToBottom, bottomToTop
    }
    /// 设置手势从某个方向开始识别
    @objc public var recognizeDirection: Direction = .leftToRight
    
    /// 是否停用手势，默认false
    @objc public var isDeactivated: Bool = false {
        didSet {
            panGestureRecognizer?.isEnabled = !isDeactivated
        }
    }
    
    /// 将要识别手势转场，可用于提前更改动画类型
    @objc public var willTransition: (() -> Void)?
    
    @objc public enum TransitioningType: Int {
        case present, dismiss
    }
    @objc public internal(set) var transitionType: TransitioningType
    @objc public internal(set) weak var driverViewController: UIViewController!

    @objc public internal(set) weak var panView: UIView!
    internal var panGestureRecognizer: UIPanGestureRecognizer?
    internal var startTransition: (() -> Void)?
    
    @objc public init(driver: UIViewController, type: TransitioningType, prepare: (() -> Void)!) {
        self.driverViewController = driver
        self.transitionType = type
        self.startTransition = prepare
    }
    
    /// 当ScrollView滚动到边缘时，优先响应DawnPanGestureRecognizer手势
    @objc public func shouldPrioritize(by scrollView: UIScrollView?) {
        trackingView = scrollView
    }
    
    internal weak var trackingView: UIScrollView?
}

public final class _DawnPanGestureRecognizer: UIPanGestureRecognizer {}
public final class _DawnEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer {}

extension DawnPanGestureRecognizer {
    
    fileprivate func bindPanRecognizer(_ view: UIView) {
        panView = view
        isRecognizeWhenEdges ? addEdgePanRecognizer(inView: view) : addPanRecognizer(inView: view)
    }
    
    fileprivate func unbindPanRecognizer(_ view: UIView) {
        guard let pan = panGestureRecognizer else { return }
        view.removeGestureRecognizer(pan)
    }
    
    private func addPanRecognizer(inView view: UIView) {
        panGestureRecognizer = _DawnPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGestureRecognizer!.delegate = self
        view.addGestureRecognizer(panGestureRecognizer!)
    }
    
    private func addEdgePanRecognizer(inView view: UIView) {
        let edgePan = _DawnEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePan(_:)))
        edgePan.delegate = self
        edgePan.edges = directionToEdge()
        panGestureRecognizer = edgePan
        view.addGestureRecognizer(panGestureRecognizer!)
    }
    
    private func directionToEdge() -> UIRectEdge {
        switch recognizeDirection {
        case .leftToRight: return .left
        case .rightToLeft: return .right
        case .topToBottom: return .top
        case .bottomToTop: return .bottom
        }
    }
}

extension DawnPanGestureRecognizer {
    
    @objc private func handlePan(_ g: UIPanGestureRecognizer) {
        handle(gesture: g)
    }
    
    @objc private func handleEdgePan(_ g: UIScreenEdgePanGestureRecognizer) {
        handle(gesture: g)
    }
    
    private func handle(gesture g: UIPanGestureRecognizer) {
        switch recognizeDirection {
        case .leftToRight: handleLeft(g)
        case .rightToLeft: handleRight(g)
        case .topToBottom: handleTop(g)
        case .bottomToTop: handleBottom(g)
        }
    }
}

extension DawnPanGestureRecognizer {
    
    @objc internal func prepare() {
        willTransition?()
        switch transitionType {
        case .present:
            Dawn.shared.driven(presenting: driverViewController)
        case .dismiss:
            Dawn.shared.driven(dismissing: driverViewController)
        }
        startTransition?()
    }
    
    @objc internal func handleLeft(_ g: UIPanGestureRecognizer) {
        let translation = g.translation(in: panView).x
        let distance = translation / panView.bounds.width
        switch g.state {
        case .began:
            prepare()
        case .changed:
            Dawn.shared.update(distance)
        default:
            let velocity = g.velocity(in: panView)
            if ((translation + velocity.x) / panView.bounds.width) > 0.5 {
                Dawn.shared.finish()
            } else {
                Dawn.shared.cancel()
            }
        }
    }
    
    @objc internal func handleRight(_ g: UIPanGestureRecognizer) {
        let translation = abs(g.translation(in: panView).x)
        let migratory = min(.zero, g.translation(in: panView).x)
        let distance = abs(migratory / panView.bounds.width)
        switch g.state {
        case .began:
            prepare()
        case .changed:
            Dawn.shared.update(distance)
        default:
            let velocity = g.velocity(in: panView)
            if ((translation - velocity.x) / panView.bounds.width) > 0.5 {
                Dawn.shared.finish()
            } else {
                Dawn.shared.cancel()
            }
        }
    }
    
    @objc internal func handleTop(_ g: UIPanGestureRecognizer) {
        let translation = g.translation(in: panView).y
        let distance = translation / panView.bounds.height
        switch g.state {
        case .began:
            prepare()
        case .changed:
            Dawn.shared.update(distance)
        default:
            let velocity = g.velocity(in: panView)
            if ((translation + velocity.y) / panView.bounds.height) > 0.5 {
                Dawn.shared.finish()
            } else {
                Dawn.shared.cancel()
            }
        }
    }
    
    @objc internal func handleBottom(_ g: UIPanGestureRecognizer) {
        let translation = abs(g.translation(in: panView).y)
        let migratory = min(.zero, g.translation(in: panView).y)
        let distance = abs(migratory / panView.bounds.height)
        switch g.state {
        case .began:
            prepare()
        case .changed:
            Dawn.shared.update(distance)
        default:
            let velocity = g.velocity(in: panView)
            if ((translation - velocity.y) / panView.bounds.height) > 0.5 {
                Dawn.shared.finish()
            } else {
                Dawn.shared.cancel()
            }
        }
    }
}

extension DawnPanGestureRecognizer {
    
    private func boundaries(_ scrollView: UIScrollView) -> UIEdgeInsets {
        let top = 0 - scrollView.contentInset.top
        let left = 0 - scrollView.contentInset.left
        let bottom = scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom
        let right = scrollView.contentSize.width - scrollView.bounds.size.width + scrollView.contentInset.right
        return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
    
    private func isActive(_ g: UIGestureRecognizer) -> Bool {
        guard let v = trackingView else { return false }
        let p = g.location(in: panView) //不在tracking区域，直接返回false
        if let trackRect = v.superview?.convert(v.frame, to: panView), !trackRect.contains(p) {
            return false
        }
        let boundaries = boundaries(v)
        switch recognizeDirection {
        case .topToBottom:
            return v.contentOffset.y > boundaries.top || v.contentOffset.y < boundaries.top
        case .bottomToTop:
            return v.contentOffset.y > boundaries.bottom || v.contentOffset.y < boundaries.bottom
        case .leftToRight:
            return v.contentOffset.x > boundaries.left || v.contentOffset.x < boundaries.left
        case .rightToLeft:
            return v.contentOffset.x > boundaries.right || v.contentOffset.x < boundaries.right
        }
    }
}

extension DawnPanGestureRecognizer: UIGestureRecognizerDelegate {
    
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard !isActive(gestureRecognizer) else { return false }
        guard !isRecognizeWhenEdges else { return true }
        let g = gestureRecognizer as! UIPanGestureRecognizer
        let velocity = g.velocity(in: panView)
        switch recognizeDirection {
        case .leftToRight:
            return (velocity.x > .zero) && (abs(velocity.x) > abs(velocity.y))
        case .rightToLeft:
            return (velocity.x < .zero) && (abs(velocity.x) > abs(velocity.y))
        case .topToBottom:
            return (velocity.y > .zero) && (abs(velocity.y) > abs(velocity.x))
        case .bottomToTop:
            return (velocity.y < .zero) && (abs(velocity.y) > abs(velocity.x))
        }
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer == trackingView?.panGestureRecognizer
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return !isActive(gestureRecognizer)
    }
}
