//
//  PopupChainNode.swift
//  PopupKit
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

public class PopupChainNode: NSObject, @unchecked Sendable {
    
    /// 弹窗唯一标识
    let identifier: String
    
    /// 弹窗展示者和展示条件
    let representable: PopupChainRepresentable
    
    /// 弹窗结果回调，参数表示是否展示成功
    public var onPopupResult: ((Bool) -> Void)?
    
    /// 下一个弹窗节点
    public var next: PopupChainNode?

    public init(
        identifier: String,
        representable: PopupChainRepresentable,
        onPopupResult: ((Bool) -> Void)? = nil
    ) {
        self.identifier = identifier
        self.representable = representable
        self.onPopupResult = onPopupResult
    }
}

public extension PopupChainNode {
    
    /// 将一组弹窗节点顺序连接成链表，并返回头节点
    @objc public static func linkNodes(_ nodes: [PopupChainNode]) -> PopupChainNode? {
        guard !nodes.isEmpty else {
            return nil
        }
        for i in 0..<(nodes.count - 1) {
            nodes[i].next = nodes[i + 1]
        }
        if let last = nodes.last {
            last.next = nil
        }
        return nodes.first
    }
}
