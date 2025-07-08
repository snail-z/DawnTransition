//
//  PopupAnimatable.swift
//  PopupKit
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

public protocol PopupAnimatable {
    
    /// 自定义配置展示动画
    func animateIn(
        container: UIView,
        coverView: UIView,
        contentView: UIView,
        completion: @escaping () -> Void
    )
    
    /// 自定义配置消失动画
    func animateOut(
        container: UIView,
        coverView: UIView,
        contentView: UIView,
        completion: @escaping () -> Void
    )
}
