//
//  Push2ViewController.swift
//  DawnTransition_Example
//
//  Created by zhang on 2023/8/10.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import DawnTransition

class Sample2ViewController: SmapleBaseViewController {

    var btn1: UILabel!
    var btn2: UILabel!
    var btn3: UILabel!
    
    override func setupViews() {
        view.backgroundColor = UIColor.hex(0x81B0B2)
        pageTip("Modal - 测试模态跳转")
        
        btn1 = createLabel(text: "PageIn-Left")
        btn1.addTapGesture { [weak self] _ in self?.jump1() }
        view.addSubview(btn1)
        
        btn2 = createLabel(text: "PageIn-Up")
        btn2.addTapGesture { [weak self] _ in self?.jump2() }
        view.addSubview(btn2)
        
        btn3 = createLabel(text: "ZoomSlide-Right")
        btn3.addTapGesture { [weak self] _ in self?.jump3() }
        view.addSubview(btn3)
    }
    
    override func setupLayout() {
        btn1.dw.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.top.equalTo(backButton.dw.bottom).offset(20)
        }
        
        btn2.dw.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.top.equalTo(btn1.dw.bottom).offset(20)
        }
        
        btn3.dw.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.top.equalTo(btn2.dw.bottom).offset(20)
        }
    }
}

extension Sample2ViewController {
    
    func jump1() {
        let vc = Modal1ViewController()
        vc.dawn.isModalEnabled = true
        vc.dawn.transitionAnimationType = .pageIn(direction: .left)
        self.present(vc, animated: true)
    }
    
    func jump2() {
        let vc = Modal2ViewController()
        vc.dawn.isModalEnabled = true
        vc.dawn.transitionAnimationType = .pageIn(direction: .up)
        self.present(vc, animated: true)
    }
    
    func jump3() {
        let vc = Modal3ViewController()
        vc.dawn.isModalEnabled = true
        vc.dawn.transitionCapable = DawnAnimationProducer.using(
            type: .zoomSlide(direction: .right),
            duration: 0.55,
            snapshotType: .slowSnapshot
        )
        self.present(vc, animated: true)
    }
}

fileprivate class Modal1ViewController: SmapleBaseViewController {
    
    override func setGestures() {
        pageTip("从屏幕边缘左侧向右滑动")
        backButton.isHidden = true
        
        let pan = DawnPanGestureRecognizer(driver: self, type: .dismiss) { [weak self] in
            self?.dismiss(animated: true)
        }
        pan.isRecognizeWhenEdges = true
        pan.recognizeDirection = .leftToRight
        view.dawn.addPanGestureRecognizer(pan)
    }
}

fileprivate class Modal2ViewController: SmapleBaseViewController {
    
    override func setGestures() {
        pageTip("从屏幕任意位置，由上往下滑动")
        backButton.isHidden = true
        
        let pan = DawnPanGestureRecognizer(driver: self, type: .dismiss) { [weak self] in
            self?.dismiss(animated: true)
        }
        pan.isRecognizeWhenEdges = false
        pan.recognizeDirection = .topToBottom
        view.dawn.addPanGestureRecognizer(pan)
    }
}

fileprivate class Modal3ViewController: SmapleBaseViewController {
    
    override func setGestures() {
        pageTip("从屏幕任意位置，由右向左滑动")
        backButton.isHidden = true
        
        let pan = DawnPanGestureRecognizer(driver: self, type: .dismiss) { [weak self] in
            self?.dismiss(animated: true)
        }
        pan.isRecognizeWhenEdges = false
        pan.recognizeDirection = .rightToLeft
        view.dawn.addPanGestureRecognizer(pan)
    }
}
