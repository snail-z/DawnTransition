//
//  Sample5ViewController.swift
//  DawnTransition_Example
//
//  Created by zhang on 2023/8/11.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import DawnTransition

class Sample5ViewController: SmapleBaseViewController {

    var btn1: UILabel!
    var btn2: UILabel!
    var btn3: UILabel!
    var btn4: UILabel!
    
    override func setupViews() {
        view.backgroundColor = UIColor.hex(0x81B0B2)
        pageTip("Spring PageIn - 弹性PageIn动画演示")
        
        btn1 = createLabel(text: "Spring Left")
        btn1.addTapGesture { [weak self] _ in self?.jump1() }
        view.addSubview(btn1)
        
        btn2 = createLabel(text: "Spring Right")
        btn2.addTapGesture { [weak self] _ in self?.jump2() }
        view.addSubview(btn2)
        
        btn3 = createLabel(text: "Spring Up")
        btn3.addTapGesture { [weak self] _ in self?.jump3() }
        view.addSubview(btn3)
        
        btn4 = createLabel(text: "Spring Down")
        btn4.addTapGesture { [weak self] _ in self?.jump4() }
        view.addSubview(btn4)
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
        
        btn4.dw.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.top.equalTo(btn3.dw.bottom).offset(20)
        }
    }
}

extension Sample5ViewController {
    
    func jump1() {
        let vc = SpringDemo1ViewController()
        vc.dawn.isNavigationEnabled = true
        let springAnimation = DawnAnimationSpring()
        springAnimation.direction = .left
        springAnimation.scale = 0.9
        springAnimation.damping = 0.6
        springAnimation.velocity = 0.3
        springAnimation.duration = 0.8
        vc.dawn.transitionCapable = springAnimation
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func jump2() {
        let vc = SpringDemo2ViewController()
        vc.dawn.isModalEnabled = true
        let springAnimation = DawnAnimationSpring()
        springAnimation.direction = .right
        springAnimation.scale = 0.85
        springAnimation.damping = 0.4
        springAnimation.velocity = 0.5
        springAnimation.duration = 1.0
        vc.dawn.transitionCapable = springAnimation
        self.present(vc, animated: true)
    }
    
    func jump3() {
        let vc = SpringDemo3ViewController()
        vc.dawn.isNavigationEnabled = true
        let springAnimation = DawnAnimationSpring()
        springAnimation.direction = .up
        springAnimation.scale = 0.95
        springAnimation.damping = 0.5
        springAnimation.velocity = 0.1
        springAnimation.duration = 0.9
        vc.dawn.transitionCapable = springAnimation
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func jump4() {
        let vc = SpringDemo4ViewController()
        vc.dawn.isModalEnabled = true
        let springAnimation = DawnAnimationSpring()
        springAnimation.direction = .down
        springAnimation.scale = 0.88
        springAnimation.damping = 0.7
        springAnimation.velocity = 0.2
        springAnimation.duration = 0.7
        vc.dawn.transitionCapable = springAnimation
        self.present(vc, animated: true)
    }
}

fileprivate class SpringDemo1ViewController: SmapleBaseViewController {
    
    override func setGestures() {
        pageTip("Spring Left PageIn 弹性左侧进入")
        
        let pan = DawnPanGestureRecognizer(driver: self, type: .dismiss) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        pan.isRecognizeWhenEdges = true
        pan.recognizeDirection = .leftToRight
        view.dawn.addPanGestureRecognizer(pan)
    }
}

fileprivate class SpringDemo2ViewController: SmapleBaseViewController {
    
    override func setGestures() {
        pageTip("Spring Right PageIn 弹性右侧进入")
        
        let pan = DawnPanGestureRecognizer(driver: self, type: .dismiss) { [weak self] in
            self?.dismiss(animated: true)
        }
        pan.isRecognizeWhenEdges = false
        pan.recognizeDirection = .rightToLeft
        view.dawn.addPanGestureRecognizer(pan)
    }
}

fileprivate class SpringDemo3ViewController: SmapleBaseViewController {
    
    override func setGestures() {
        pageTip("Spring Up PageIn 弹性上方进入")
        
        let pan = DawnPanGestureRecognizer(driver: self, type: .dismiss) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        pan.isRecognizeWhenEdges = true
        pan.recognizeDirection = .leftToRight
        view.dawn.addPanGestureRecognizer(pan)
    }
}

fileprivate class SpringDemo4ViewController: SmapleBaseViewController {
    
    override func setGestures() {
        pageTip("Spring Down PageIn 弹性下方进入")
        
        let pan = DawnPanGestureRecognizer(driver: self, type: .dismiss) { [weak self] in
            self?.dismiss(animated: true)
        }
        pan.isRecognizeWhenEdges = false
        pan.recognizeDirection = .bottomToTop
        view.dawn.addPanGestureRecognizer(pan)
    }
}