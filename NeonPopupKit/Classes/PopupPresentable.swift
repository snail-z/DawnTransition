//
//  PopupPresentable.swift
//  PopupKit
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

public protocol PopupPresentable {
    
    /// 用于布局计算：必须提供最终展示尺寸
    func preferredPopupSize(in container: UIView) -> CGSize
}
