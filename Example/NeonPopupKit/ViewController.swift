//
//  ViewController.swift
//  NeonPopupKit
//
//  Created by zhanghao on 07/08/2025.
//  Copyright © 2017年 snail-z. All rights reserved.
//

import UIKit
import NeonPopupKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(button)
        button.frame = CGRect(x: UIScreen.main.bounds.width / 2 - 60, y: 200, width: 120, height: 50)
    }
    
    lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .blue
        button.setTitle("popup", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(popupAction), for: .touchUpInside)
        return button
    }()
    
    lazy var testView: TestView = {
        let aView = TestView()
        aView.backgroundColor = .orange
        return aView
    }()
}

extension ViewController {
    
    @objc func popupAction() {
        var config = PopupConfiguration()
        config.coverStyle = .color(.black.withAlphaComponent(0.7))
        config.placement = .center
        config.dismissOnMaskTap = true
//        config.animationType = .selectBy(enter: .slide(.top), exit: .slide(.bottom))
        
        config.animator = PopupSlideAnimator(
            enter: .init(duration: 0.75, useSpringAnimation: true),
            exit: .default,
            directions: .init(enter: .top, exit: .bottom)
        )
        
        PopupPresenter.show(testView, in: self.view, config: config)
    }
}
