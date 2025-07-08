//
//  PopupChainDispatcher.swift
//  PopupKit
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z <haozhang0770@163.com> All rights reserved.
//

import Foundation

/// 弹窗展示策略
public enum PopupChainStrategy: Int, Sendable {
    
    // 只弹第一个符合条件的弹窗
    case single
    
    // 所有符合条件的弹窗，顺序弹出
    case sequence
}

/// 链式弹窗调度器：
final public class PopupChainDispatcher: NSObject, @unchecked Sendable {
    
    public static let shared = PopupChainDispatcher()
    
    private let syncQueue = DispatchQueue(label: "com.popupchaindispatcher.syncqueue", attributes: .concurrent)
    
    private let ownerMap = NSMapTable<AnyObject, NSMutableArray>.weakToStrongObjects()
    
    private var currentNodeMap = NSMapTable<AnyObject, PopupChainNode>.weakToStrongObjects()
    
    private var strategyMap = NSMapTable<AnyObject, NSNumber>.weakToStrongObjects()
    
    public typealias OwnerObject = AnyObject & PopupChainContextual
    
    /// 添加一组可展示的弹窗链节点
    /// - Parameters:
    ///   - representables: 弹窗链节点数组
    ///   - owner: 任务归属者，控制其生命周期与展示容器
    /// - Note: 会自动为每个节点生成 identifier 并包装为 PopupChainNode，简化外部调用
    public func addRepresentables(_ representables: [PopupChainRepresentable], owner: OwnerObject) {
        let ownerType = String(describing: type(of: owner))
        let nodes = representables.enumerated().map { index, item in
            let identifier = "\(ownerType)-\(type(of: item))-\(index)"
            return PopupChainNode(identifier: identifier, representable: item)
        }
        addNodes(nodes, owner: owner)
    }
    
    /// 添加节点并绑定 owner
    public func addNodes(_ nodes: [PopupChainNode], owner: OwnerObject) {
        syncQueue.async(flags: .barrier) {
            let nodeArray: NSMutableArray
            if let existingArray = self.ownerMap.object(forKey: owner) {
                nodeArray = existingArray
            } else {
                nodeArray = NSMutableArray()
                self.ownerMap.setObject(nodeArray, forKey: owner)
            }
            nodeArray.addObjects(from: nodes)
            let ownerType = String(describing: type(of: owner))
            let nodeRepresentables = nodes.map { $0.representable }
            Popupkit.log(self, "addNodes: Owner=\(ownerType) Representable=\(nodeRepresentables)")
        }
    }
    
    /// 启动弹窗调度
    public func start(owner: OwnerObject, strategy: PopupChainStrategy = .single) {
        syncQueue.async(flags: .barrier) {
            self.strategyMap.setObject(NSNumber(value: strategy.rawValue), forKey: owner)
            let ownerType = String(describing: type(of: owner))
            Popupkit.log(self, "start: Owner=\(ownerType) with strategy=\(strategy)")
            if let nodeArray = self.ownerMap.object(forKey: owner) as? [PopupChainNode] {
                let headNode = PopupChainNode.linkNodes(nodeArray)
                if let headNode = headNode {
                    self.currentNodeMap.setObject(headNode, forKey: owner)
                } else {
                    self.currentNodeMap.removeObject(forKey: owner)
                }
            } else {
                self.currentNodeMap.removeObject(forKey: owner)
            }
            
            DispatchQueue.main.async {
                self.triggerNext(owner: owner)
            }
        }
    }
    
    /// 查询指定owner当前的节点
    public func currentNode(for owner: OwnerObject) -> PopupChainNode? {
        var result: PopupChainNode?
        syncQueue.sync {
            result = self.currentNodeMap.object(forKey: owner)
        }
        return result
    }
    
    /// 查询owner当前的策略
    public func strategy(for owner: OwnerObject) -> PopupChainStrategy {
        if let number = strategyMap.object(forKey: owner) {
            return PopupChainStrategy(rawValue: number.intValue) ?? .single
        }
        return .single
    }

    /// 检查节点是否属于有效owner
    private func isNodeValid(_ node: PopupChainNode) -> Bool {
        for owner in self.ownerMap.keyEnumerator() {
            if let owner = owner as? AnyObject,
               let nodeArray = self.ownerMap.object(forKey: owner),
               nodeArray.contains(node) {
                return true
            }
        }
        return false
    }

    private func triggerNext(owner: OwnerObject) {
        syncQueue.async {
            var node = self.currentNodeMap.object(forKey: owner)
            let ownerType = String(describing: type(of: owner))
            while let currentNode = node {
                if !self.isNodeValid(currentNode) {
                    Popupkit.log(self, "moveToNext: Owner=\(ownerType) skipping invalid node \(currentNode.representable)")
                    node = currentNode.next
                    self.currentNodeMap.setObject(node, forKey: owner)
                    continue
                }
                if !currentNode.representable.shouldShowInPopupChain() {
                    Popupkit.log(self, "moveToNext: Owner=\(ownerType) skipping node \(currentNode.representable) due to shouldShowInPopupChain=false")
                    node = currentNode.next
                    self.currentNodeMap.setObject(node, forKey: owner)
                    continue
                }
                Popupkit.log(self, "moveToNext: Owner=\(ownerType) ready to present node \(currentNode.representable)")
                DispatchQueue.main.async {
                    self.handleNodePresentation(currentNode, owner: owner)
                }
                return
            }
            self.ownerMap.removeObject(forKey: owner)
            self.currentNodeMap.removeObject(forKey: owner)
            self.strategyMap.removeObject(forKey: owner)
            Popupkit.log(self, "moveToNext: Owner=\(ownerType) no more nodes to present - cleanup completed.<END>")
        }
    }
 
    private func handleNodePresentation(_ currentNode: PopupChainNode, owner: OwnerObject) {
        let ownerType = String(describing: type(of: owner))
        currentNode.representable.present(in: owner.popupChainContainerView) {
            Popupkit.log(self, "presentation completed: Owner=\(ownerType) node=\(currentNode.representable)")
            currentNode.onPopupResult?(true)
        } moveToNext: {
            self.syncQueue.async(flags: .barrier) {
                if self.strategy(for: owner) == .single {
                    Popupkit.log(self, "proceed called: Owner=\(ownerType) strategy=single")
                    self.currentNodeMap.removeObject(forKey: owner)
                } else {
                    if let next = currentNode.next {
                        Popupkit.log(self, "proceed called: Owner=\(ownerType) strategy=sequence")
                        self.currentNodeMap.setObject(next, forKey: owner)
                    } else {
                        Popupkit.log(self, "proceed called: Owner=\(ownerType) strategy=sequence - chain ended no more nodes.")
                        self.currentNodeMap.removeObject(forKey: owner)
                    }
                }
                DispatchQueue.main.async {
                    self.triggerNext(owner: owner)
                }
            }
        }
    }
}
