//
//  PopupPresenter.swift
//  PopupKit
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

public enum PopupPresenter {
    
    /// 展示一个弹窗视图，并添加到指定父视图中
    /// - Parameters:
    ///   - view: 要显示的弹窗视图，需遵循 PopupPresentable 协议
    ///   - parent: 弹窗要添加到的父视图
    ///   - config: 弹窗展示配置（如动画、位置、自动关闭等）
    ///   - completion: 弹窗展示完成后的回调
    @MainActor public static func show(_ view: UIView & PopupPresentable, in parent: UIView, config: PopupConfiguration, completion: (() -> Void)? = nil) {
        guard view.isPopupVisible == false else { return }
        view.isPopupVisible = true

        let container = PopupContainer(contentView: view, config: config) {
            (config.onAutoDismiss != nil) ? config.onAutoDismiss?(view) : dismiss(view)
        }

        parent.addSubview(container)
        container.backgroundColor = .clear
        container.frame = parent.bounds
        container.layoutPopupIfNeeded()

        config.onWillPresent?(container.contentView)
        container.performShowAnimation {
            config.onDidPresent?(container.contentView)
            completion?()
        }
    }

    /// 关闭指定弹窗视图
    /// - Parameters:
    ///   - view: 要关闭的弹窗视图
    ///   - completion: 弹窗关闭完成后的回调
    @MainActor public static func dismiss(_ view: UIView & PopupPresentable, completion: (() -> Void)? = nil) {
        guard let container = view.superview as? PopupContainer else { return }
        
        container.config.onWillDismiss?(container.contentView)
        container.performDismissAnimation {
            container.removeFromSuperview()
            container.config.onDidDismiss?(container.contentView)
            view.isPopupVisible = false
            completion?()
        }
    }
    
    /// 指定关闭弹窗的目标方式
    public enum DismissTarget {
        case first, last, all
    }
    
    /// 关闭父视图中已显示的弹窗（如果存在）
    /// - Parameters:
    ///   - parent: 父视图中包含的弹窗将被关闭
    ///   - target: 指定关闭第一个、最后一个或全部弹窗
    ///   - completion: 弹窗关闭完成后的回调
    @MainActor public static func dismiss(in parent: UIView, matching target: DismissTarget = .first, completion: (() -> Void)? = nil) {
        switch target {
        case .first:
            guard let container = parent.firstSubview(of: PopupContainer.self) else { return }
            return dismiss(container.contentView)
        case .last:
            guard let container = parent.lastSubview(of: PopupContainer.self) else { return }
            return dismiss(container.contentView)
        case .all:
            let containers = parent.allSubviews(of: PopupContainer.self)
            guard !containers.isEmpty else { return }
            let group = DispatchGroup()
            for container in containers {
                group.enter()
                dismiss(container.contentView) {
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                completion?()
            }
        }
    }
}
