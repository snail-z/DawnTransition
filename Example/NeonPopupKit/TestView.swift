//
//  TestView.swift
//  NeonPopupKit
//
//  Created by zhanghao on 2025/7/8.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import NeonPopupKit

class TestView: UIView {
    
}

extension TestView: PopupPresentable {
    
    func preferredPopupSize(in container: UIView) -> CGSize {
        let maxW = UIScreen.main.bounds.width - 100
//        let size = systemLayoutSizeFitting(
//            CGSize(width: maxW, height: 300)
//        )
        return CGSize(width: maxW, height: 400)
    }
}
