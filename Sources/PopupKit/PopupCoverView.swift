//
//  PopupCoverView.swift
//  PopupKit
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

internal class PopupCoverView: UIView {
    
    var tapHandler: (() -> Void)?

    init(style: PopupConfiguration.CoverStyle) {
        super.init(frame: .zero)
        backgroundColor = .clear
        switch style {
        case .none:
            backgroundColor = .clear
        case .color(let color):
            backgroundColor = color
        case .blur(let style):
            let blurEffect = UIBlurEffect(style: style)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = bounds
            blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(blurView)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }

    @objc private func handleTap() {
        tapHandler?()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
