//
//  Push1ViewController.swift
//  DawnTransition_Example
//
//  Created by zhang on 2023/8/10.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import DawnTransition

class Sample1ViewController: SmapleBaseViewController {

    var btn1: UILabel!
    var btn2: UILabel!
    var btn3: UILabel!
    
    override func setupViews() {
        view.backgroundColor = UIColor.hex(0x81B0B2)
        pageTip("Push - 测试导航跳转")
        
        btn1 = createLabel(text: "PageIn-Left")
        btn1.addTapGesture { [weak self] _ in self?.jump1() }
        view.addSubview(btn1)
        
        btn2 = createLabel(text: "Fade-Up")
        btn2.addTapGesture { [weak self] _ in self?.jump2() }
        view.addSubview(btn2)
        
        btn3 = createLabel(text: "ZoomSlide-Left")
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
        
        addEdgeRecognizer()
    }
    
    func addEdgeRecognizer() {
        let label = createLabel(text: "从\n此\n处\n边\n缘\n向\n左\n滑\n动")
        label.font = UIFont.italicSystemFont(ofSize: 11)
        label.textColor = .white
        label.backgroundColor = .clear
        label.numberOfLines = 0
        view.addSubview(label)
        label.dw.makeConstraints { make in
            make.right.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        
        let pan = DawnPanGestureRecognizer(driver: self, type: .present) { [weak self] in
            self?.jump3()
        }
        pan.isRecognizeWhenEdges = true
        pan.recognizeDirection = .rightToLeft
        view.dawn.addPanGestureRecognizer(pan)
    }
}

extension Sample1ViewController {
    
    func jump1() {
        let vc = Push1ViewController()
        vc.dawn.isNavigationEnabled = true
        vc.dawn.transitionAnimationType = .pageIn(direction: .left)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func jump2() {
        let vc = Push2ViewController()
        vc.dawn.isNavigationEnabled = true
        vc.dawn.transitionAnimationType = .selectBy(presenting: .fade, dismissing: .push(direction: .up))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func jump3() {
        let vc = Push3ViewController()
        vc.dawn.isNavigationEnabled = true
        vc.dawn.transitionAnimationType = .zoomSlide(direction: .left)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

fileprivate class Push1ViewController: SmapleBaseViewController {
    
    override func setGestures() {
        pageTip("从屏幕边缘左侧向右滑动")
        backButton.isHidden = true
        
        let pan = DawnPanGestureRecognizer(driver: self, type: .dismiss) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        pan.isRecognizeWhenEdges = true
        pan.recognizeDirection = .leftToRight
        view.dawn.addPanGestureRecognizer(pan)
    }
}


fileprivate class Push2ViewController: SmapleBaseViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func setGestures() {
        pageTip("从屏幕任意位置，由下向上滑动")
        backButton.isHidden = true
     
        let pan = DawnPanGestureRecognizer(driver: self, type: .dismiss) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        pan.isRecognizeWhenEdges = false
        pan.recognizeDirection = .bottomToTop
        view.dawn.addPanGestureRecognizer(pan)
    }
}

fileprivate class Push3ViewController: SmapleBaseViewController {
    
    override func setGestures() {
        pageTip("从屏幕边缘左侧向右滑动")
        backButton.isHidden = true
        
        let pan = DawnPanGestureRecognizer(driver: self, type: .dismiss) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        pan.isRecognizeWhenEdges = true
        pan.recognizeDirection = .leftToRight
        view.dawn.addPanGestureRecognizer(pan)
    }
}
