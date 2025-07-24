//
//  AnimationDemoViewController.swift
//  BibleAppTemplate
//
//  Created by bible-team on 2025/7/21.
//  Copyright (c) 2025 bible-team All rights reserved.
//

import UIKit
import BibleBaseKit
import DawnTransition

class AnimationDemoViewController: BKBaseViewController {
    
    private var currentAnimationIndex = 0
    
    private let animationTypes: [(String, DawnAnimationType)] = [
        ("PushLeft", .push(direction: .left)),
        ("PushRight", .push(direction: .right)),
        ("PushUp", .push(direction: .up)),
        ("PushDown", .push(direction: .down)),
        ("PullLeft", .pull(direction: .left)),
        ("PullRight", .pull(direction: .right)),
        ("PageInLeft", .pageIn(direction: .left)),
        ("PageInRight", .pageIn(direction: .right)),
        ("PageOutLeft", .pageOut(direction: .left)),
        ("PageOutRight", .pageOut(direction: .right)),
        ("ZoomSlideLeft", .zoomSlide(direction: .left, scale: 0.8)),
        ("ZoomSlideRight", .zoomSlide(direction: .right, scale: 0.8)),
        ("Fade", .fade),
        ("None", .none)
    ]
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap Tab to switch animations\nTap center button to execute"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var currentAnimationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private lazy var executeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Execute Transition", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.addTarget(self, action: #selector(executeAnimation), for: .touchUpInside)
        return button
    }()
    
    private lazy var previousButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Previous", for: .normal)
        button.backgroundColor = .systemGray5
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(previousAnimation), for: .touchUpInside)
        return button
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.backgroundColor = .systemGray5
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(nextAnimation), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateCurrentAnimation()
    }
    
    private func setupUI() {
        bk_navigationBar.setTitle("Interactive Transitions")
        
        view.addSubview(infoLabel)
        view.addSubview(currentAnimationLabel)
        view.addSubview(executeButton)
        view.addSubview(previousButton)
        view.addSubview(nextButton)
        
        infoLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(bk_navigationBar.snp.bottom).offset(40)
            make.left.right.equalToSuperview().inset(20)
        }
        
        currentAnimationLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(infoLabel.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(20)
        }
        
        executeButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(currentAnimationLabel.snp.bottom).offset(40)
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        
        let buttonStack = UIStackView(arrangedSubviews: [previousButton, nextButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 20
        buttonStack.distribution = .fillEqually
        
        view.addSubview(buttonStack)
        buttonStack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(executeButton.snp.bottom).offset(30)
            make.width.equalTo(200)
            make.height.equalTo(40)
        }
    }
    
    private func updateCurrentAnimation() {
        let (title, _) = animationTypes[currentAnimationIndex]
        currentAnimationLabel.text = title
        
        // 更新按钮颜色
        let colors: [UIColor] = [.systemBlue, .systemGreen, .systemOrange, .systemPurple, .systemRed, .systemTeal]
        executeButton.backgroundColor = colors[currentAnimationIndex % colors.count]
    }
    
    @objc private func previousAnimation() {
        currentAnimationIndex = (currentAnimationIndex - 1 + animationTypes.count) % animationTypes.count
        updateCurrentAnimation()
    }
    
    @objc private func nextAnimation() {
        currentAnimationIndex = (currentAnimationIndex + 1) % animationTypes.count
        updateCurrentAnimation()
    }
    
    @objc private func executeAnimation() {
        let (title, animationType) = animationTypes[currentAnimationIndex]
        
        let targetVC = AnimationTargetDemoViewController()
        targetVC.animationTitle = title
        
        // 使用 BaseKit 的便利方法设置转场动画
        targetVC.bk_setupCustomTransition(animationType)
        
        navigationController?.pushViewController(targetVC, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 设置 TabBar 代理，支持点击 Tab 切换动画
        if let tabBarController = self.tabBarController {
            tabBarController.delegate = self
        }
    }
}

// MARK: - UITabBarControllerDelegate

extension AnimationDemoViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // 检查是否在当前页面
        if let navController = viewController as? UINavigationController,
           let topVC = navController.topViewController,
           topVC == self {
            nextAnimation()
        }
    }
}
