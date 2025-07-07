//
//  PopupChainRepresentable.swift
//  PopupKit
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

/// 弹窗链节点协议，用于控制弹窗链中每个节点的展示条件与行为
public protocol PopupChainRepresentable {
    
    /// 是否应当在弹窗链中展示该弹窗节点
    func shouldShowInPopupChain() -> Bool
    
    /// 在指定view上展示弹窗节点
    /// - Parameters:
    ///   - view: 用于展示弹窗的容器视图
    ///   - completion: 弹窗展示完成后必须调用（如添加到视图并完成动画）
    ///   - moveToNext: 当前弹窗关闭后必须调用，用于通知调度器进入下一个节点；如果未调用，将导致链条中断且不会释放当前 owner 的调度状态
    func present(in view: UIView, completion: @escaping () -> Void, moveToNext: @escaping () -> Void)
}
