//
//  AnimationTargetDemoViewController.swift
//  DemoKit
//
//  Created by bible-team on 2025/7/21.
//  Copyright (c) 2025 bible-team All rights reserved.
//

import UIKit
import BibleBaseKit
import DawnTransition
import SnapKit

public class AnimationTargetDemoViewController: BKBaseViewController {
    
    public var animationTitle: String = "动画演示"
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "这是 DawnTransition 转场动画的演示\n支持手势滑动返回"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
        return view
    }()
    
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.systemBlue.withAlphaComponent(0.05).cgColor,
            UIColor.systemPurple.withAlphaComponent(0.05).cgColor
        ]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    private func setupUI() {
        bk_navigationBar.setTitle(animationTitle)
        
        // 添加渐变背景
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        titleLabel.text = animationTitle
        
        view.addSubview(infoView)
        infoView.addSubview(titleLabel)
        infoView.addSubview(descriptionLabel)
        
        infoView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(30)
            make.height.greaterThanOrEqualTo(160)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(35)
            make.left.right.equalToSuperview().inset(20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-30)
        }
    }
}
