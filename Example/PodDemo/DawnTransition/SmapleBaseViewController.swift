//
//  SmapleBaseViewController.swift
//  DawnTransition_Example
//
//  Created by zhang on 2023/8/10.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

public class SmapleBaseViewController: UIViewController {
    
    public func createLabel(text: String?) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .gillSans()
        label.textColor = .black
        label.backgroundColor = .white
        label.textAlignment = .center
        return label
    }
    
    public lazy var backButton: UILabel = {
        var btn = createLabel(text: "Back")
        btn.textColor = .appBlue()
        btn.backgroundColor = .white
        btn.addTapGesture(numberOfTaps: 1) { [weak self] _ in
            self?.backAction()
        }
        return btn
    }()
    
    private lazy var tipLabel: UILabel = {
        var label = createLabel(text: "")
        label.font = UIFont.italicSystemFont(ofSize: 12)
        label.textColor = .white
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()
    
    public func backAction() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        let colors = [0xC56C86, 0x70AFCE, 0x5B7FA7]
        view.backgroundColor = UIColor.hex(colors[safe: colors.randomIndex]!)
        view.addSubview(tipLabel)
        view.addSubview(backButton)
        
        tipLabel.dw.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalToSuperview().inset(20)
            make.top.equalTo(UIScreen.statusBarHeight + 20)
        }
        
        backButton.dw.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.top.equalTo(tipLabel.dw.bottom).offset(30)
        }
        setupViews()
        setupLayout()
        setGestures()
    }
    
    public func setupViews() {}
    public func setupLayout() {}
    public func setGestures() {}
    public func pageTip(_ tip: String?) {
        if let value = tip {
            tipLabel.text = "「 \(value) 」"
        }
    }
}
