//
//  Sample3ViewController.swift
//  DawnTransition_Example
//
//  Created by zhang on 2023/8/11.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import DawnKit
import DawnTransition

class Sample3ViewController: SmapleBaseViewController {

    private var roundBtn: DawnButton!
    var btn1: UILabel!
    var btn2: DawnButton!
    
    override func setupViews() {
        view.backgroundColor = UIColor.hex(0x81B0B2)
        pageTip("自定义转场动画")
        
        roundBtn = DawnButton()
        roundBtn.backgroundColor = .appBlue()
        roundBtn.imageAndTitleSpacing = .zero
        roundBtn.imageView.image = UIImage(named: "plus_circle")
        roundBtn.layer.cornerRadius = 30
        roundBtn.layer.masksToBounds = true
        roundBtn.contentEdgeInsets = UIEdgeInsets.make(same: 10)
        roundBtn.addTapGesture { [weak self] _ in self?.jump3() }
        view.addSubview(roundBtn)
        
        btn1 = createLabel(text: "Page1")
        btn1.addTapGesture { [weak self] _ in self?.jump1() }
        view.addSubview(btn1)
        
        btn2 = DawnButton()
        btn2.backgroundColor = .white
        btn2.layer.cornerRadius = 10
        btn2.layer.masksToBounds = true
        btn2.imageAndTitleSpacing = .zero
        btn2.contentHorizontalAlignment = .center
        btn2.titleLabel.font = .gillSans()
        btn2.titleLabel.textColor = .black
        btn2.titleLabel.textAlignment = .center
        btn2.titleLabel.text = "Page2"
        btn2.addTapGesture { [weak self] _ in self?.jumpMy() }
        view.addSubview(btn2)
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
            make.height.equalTo(260)
            make.centerX.equalToSuperview()
            make.top.equalTo(btn1.dw.bottom).offset(20)
        }
        
        roundBtn.dw.makeConstraints { make in
            make.right.equalToSuperview().inset(10)
            make.top.equalTo(UIScreen.safeInsets.top)
            make.width.equalTo(60)
            make.height.equalTo(60)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}

extension Sample3ViewController {
    
    func jump1() {
        let vc = KlipageViewController()
        vc.dawn.isNavigationEnabled = true
        vc.dawn.transitionAnimationType = .pageIn(direction: .left)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func jump3() {
        let vc = DescIMGViewController(descItem: takeDescIMGModel())
        vc.dawn.isModalEnabled = true
        vc.dawn.transitionCapable = DawnAnimationDiffuse(diffuseOut: roundBtn, diffuseIn: roundBtn)
        vc.willDismiss = { [weak self] sender in
            guard let `self` = self else { return }
            sender.dawn.transitionCapable = DawnAnimationSpot(holeView: `self`.roundBtn)
        }
        self.present(vc, animated: true)
    }
    
    func takeDescIMGModel() -> DescIMGModel {
        return DescIMGModel(title: "这里是主标题", subTitle: "副标题", imageName: "image0", content: "在这个春意盎然的季节，我收获了几缕春风，他们轻轻地、悄悄地拂过我心田，停留在我记忆中，挥之不去。友情，是一缕春风，拂去我心灵的阴霾；亲情，是一缕春风，呵护是我心中的美好；关爱，是一缕春风，吹去刺骨的冰冷，带来温暖。\n繁花似锦，你我手拉手，肩并肩齐走在回家的那条平坦的小路上。你偶尔会摸摸我的头，掐掐我的脸，而我也尽力找话茬，希望不会太闷。“你说……我们长大了还能上同一间高中不？”我小心翼翼地问道。你抿了抿唇，苦涩的味道在你的声音里散开，“也许吧。”“但是……无论怎么样，我们都是好朋友。”看似平静的语调，在我心中激起万丈波澜，在昏暗的灯光下，我俩的手握的更紧了。百花争艳，友情更美。在我心中激起万丈波澜，在昏暗的灯光下，我俩的手握的更紧了。百花争艳，友情更美。在我心中激起万丈波澜，在昏暗的灯光下，我俩的手握的更紧了。百花争艳，友情更美。在我心中激起万丈波澜，在昏暗的灯光下，我俩的手握的更紧了。百花争艳，友情更美。")
    }
    
    func jumpMy() {
        breathe { [unowned self] in
            let vc = MyViewController()
            vc.dawn.isNavigationEnabled = true
            vc.dawn.transitionAnimationType = .pageIn(direction: .left)
            let pathway = DawnAnimationDissolve(sourceView: btn2)
            pathway.duration = 0.95
            pathway.overlayType = .blur(style: .light, color: .clear)
            pathway.usingSpring = (0.6, 0.2)
            vc.dawn.transitionCapable = pathway
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func breathe(work: (() -> Void)?) {
        func layout1() {
            btn2.dw.updateConstraints { make in
                make.width.equalTo(200-15)
                make.height.equalTo(260-20)
            }
        }
        
        func layout2() {
            btn2.dw.updateConstraints { make in
                make.width.equalTo(200)
                make.height.equalTo(260)
            }
        }
        
        layout1()
        UIView.animate(withDuration: 0.15) {
            self.view.layoutIfNeeded()
        } completion: { flag in
            layout2()
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
            DispatchQueue.asyncAfter(delay: 0.1) {
                work?()
            }
        }
    }
}

fileprivate class MyViewController: SmapleBaseViewController {
    
    override func setGestures() {
        pageTip("从屏幕边缘左侧向右滑动")
        backButton.isHidden = true
        
        let pan = DawnTodayGestureRecognizer(driver: self, type: .dismiss) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        pan.zoomScale = 0.7
        pan.isRecognizeWhenEdges = true
        pan.recognizeDirection = .leftToRight
        view.dawn.addPanGestureRecognizer(pan)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
}
