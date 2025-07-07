//
//  PopupChainContextual.swift
//  PopupKit
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z <haozhang0770@163.com> All rights reserved.
//

/// 弹窗链上下文提供者
public protocol PopupChainContextual {
    
    var popupChainContainerView: UIView { get }
}

extension UIViewController: @retroactive PopupChainContextual {
    
    public var popupChainContainerView: UIView {
        return self.view
    }
}

extension UIView: @retroactive PopupChainContextual {
    
    public var popupChainContainerView: UIView {
        return self
    }
}
