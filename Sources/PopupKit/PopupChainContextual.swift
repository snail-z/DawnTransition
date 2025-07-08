//
//  PopupChainContextual.swift
//  PopupKit
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

/// 弹窗链上下文提供者
public protocol PopupChainContextual {
    
    var popupChainContainerView: UIView { get }
}

extension UIViewController: @preconcurrency PopupChainContextual {
    
    public var popupChainContainerView: UIView {
        return self.view
    }
}

extension UIView: @preconcurrency PopupChainContextual {
    
    public var popupChainContainerView: UIView {
        return self
    }
}
