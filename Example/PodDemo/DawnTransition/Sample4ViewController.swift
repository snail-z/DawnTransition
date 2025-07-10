//
//  Sample4ViewController.swift
//  DawnTransition_Example
//
//  Created by zhang on 2023/9/8.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import DawnKit
import DawnTransition

class Sample4ViewController: SmapleBaseViewController {

    var btn1: UILabel!
    var btn2: UILabel!
    var btn3: UILabel!
    var btn4: UILabel!
    
    override func setupViews() {
        view.backgroundColor = UIColor.hex(0x81B0B2)
        pageTip("- 测试Transform -")
        
        btn1 = createLabel(text: "Cube")
        btn1.addTapGesture { [weak self] _ in self?.jump1() }
        view.addSubview(btn1)
        
        btn2 = createLabel(text: "Flip")
        btn2.addTapGesture { [weak self] _ in self?.jump2() }
        view.addSubview(btn2)
        
        btn3 = createLabel(text: "Turn")
        btn3.addTapGesture { [weak self] _ in self?.jump3() }
        view.addSubview(btn3)
        
        btn4 = createLabel(text: "Card")
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

extension Sample4ViewController {
    
    func jump1() {
        let vc = Transform1ViewController()
        vc.dawn.isModalEnabled = true
        vc.dawn.transitionCapable = DawnAnimationCube()
        self.present(vc, animated: true)
    }
    
    func jump2() {
        let vc = Transform2ViewController()
        vc.dawn.isModalEnabled = true
        vc.dawn.transitionCapable = DawnAnimationFlip()
        self.present(vc, animated: true)
    }
    
    func jump3() {
        let vc = Transform3ViewController()
        vc.dawn.isModalEnabled = true
        let turn = DawnAnimationTurn()
        turn.isReversed = true
//        turn.direction = .top
        vc.dawn.transitionCapable = turn
        self.present(vc, animated: true)
    }
    
    func jump4() {
        let vc = Transform4ViewController()
        vc.dawn.isModalEnabled = true
        vc.dawn.transitionCapable =  DawnAnimationCard {
            vc.dismiss(animated: true)
        }
        self.present(vc, animated: true)
    }
}

fileprivate class Transform1ViewController: SmapleBaseViewController {
    
}

fileprivate class Transform2ViewController: SmapleBaseViewController {
    
}

fileprivate class Transform3ViewController: SmapleBaseViewController {
    
}

fileprivate class Transform4ViewController: SmapleBaseViewController {
    
    override func setGestures() {
        pageTip("从屏幕任意位置，从上向下滑动")
        
        let pan = DawnPanGestureRecognizer(driver: self, type: .dismiss) { [weak self] in
            self?.dismiss(animated: true)
        }
        pan.isRecognizeWhenEdges = false
        pan.recognizeDirection = .topToBottom
        view.dawn.addPanGestureRecognizer(pan)
    }
}
