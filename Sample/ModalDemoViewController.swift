//
//  ModalDemoViewController.swift
//  DemoKit
//
//  Created by bible-team on 2025/7/21.
//  Copyright (c) 2025 bible-team All rights reserved.
//

import UIKit
import BibleBaseKit
import DawnTransition
import SnapKit

public class ModalDemoViewController: BKBaseViewController {
    
    private let modalAnimations: [(String, DawnAnimationType)] = [
        ("Modal Fade", .fade),
        ("Modal PageInUp", .pageIn(direction: .up)),
        ("Modal ZoomSlideUp", .zoomSlide(direction: .up, scale: 0.7)),
        ("Modal PushUp", .push(direction: .up)),
        ("Modal PullDown", .pull(direction: .down))
    ]
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "ModalCell")
        table.backgroundColor = .systemGroupedBackground
        return table
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        bk_navigationBar.setTitle("Modal Transitions")
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(bk_navigationBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ModalDemoViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modalAnimations.count
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Modal Transition Types"
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModalCell", for: indexPath)
        let (title, _) = modalAnimations[indexPath.row]
        
        cell.textLabel?.text = title
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.font = .systemFont(ofSize: 16)
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let (title, animationType) = modalAnimations[indexPath.row]
        
        let modalVC = ModalDetailViewController()
        modalVC.animationTitle = title
        modalVC.modalPresentationStyle = .fullScreen
        
        // 使用 BaseKit 的便利方法设置模态转场动画
        modalVC.bk_setupModalTransition(animationType)
        
        present(modalVC, animated: true)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

// MARK: - ModalDetailViewController

public class ModalDetailViewController: BKBaseViewController {
    
    public var animationTitle: String = "模态演示"
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.layer.shadowRadius = 20
        view.layer.shadowOpacity = 0.3
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "这是模态转场动画演示\n支持拖拽手势关闭"
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("关闭", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.systemBlue.withAlphaComponent(0.8).cgColor,
            UIColor.systemPurple.withAlphaComponent(0.8).cgColor
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
        // 隐藏导航栏，因为这是模态页面
        bk_navigationBar.isHidden = true
        
        // 添加渐变背景
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        titleLabel.text = animationTitle
        
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(closeButton)
        
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(40)
            make.height.greaterThanOrEqualTo(250)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.left.right.equalToSuperview().inset(20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-30)
        }
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    // 支持下拉手势关闭
    public override var bk_shouldDawnRecognizeWhenEdges: Bool {
        return false // 模态页面使用全屏手势
    }
    
    public override func bk_customDawnGestureRecognizer() -> DawnPanGestureRecognizer {
        let gesture = DawnPanGestureRecognizer(driver: self, type: .dismiss) { [weak self] in
            self?.dismiss(animated: true)
        }
        gesture.recognizeDirection = .topToBottom
        gesture.isRecognizeWhenEdges = false
        return gesture
    }
}
