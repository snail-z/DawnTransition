//
//  DawnTransitionExampleViewController.swift
//  DemoKit
//
//  Created by bible-team on 2025/7/21.
//  Copyright (c) 2025 bible-team All rights reserved.
//

import UIKit
import BibleBaseKit
import DawnTransition
import SnapKit

public class DawnTransitionExampleViewController: BKBaseViewController {
    
    private let animations: [(String, DawnAnimationType)] = [
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
        ("None", .none),
        ("Modal Demo", .none) // 特殊标记
    ]
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "AnimationCell")
        table.backgroundColor = .systemGroupedBackground
        return table
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        bk_navigationBar.setTitle("DawnTransition 示例")
        setupRightButton()
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(bk_navigationBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    public func setupRightButton() {
        let image = UIImage(systemName: "doc.text")?.withRenderingMode(.alwaysTemplate)
        bk_navigationBar.setRightButton(image: image)
        bk_navigationBar.rightButton.tintColor = .systemBlue
    }
    
    public override func bk_didTapNavigationRightItem() {
        showDocumentation()
    }
    
    // 支持边缘滑动手势返回
    public override var bk_shouldDawnRecognizeWhenEdges: Bool {
        return true
    }
    
    @objc private func showDocumentation() {
        let docVC = DawnTransitionDocumentationViewController()
        navigationController?.pushViewController(docVC, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension DawnTransitionExampleViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return animations.count - 1 // 排除最后一个模态演示
        } else {
            return 1 // 模态演示
        }
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Navigation Transitions" : "Modal Transitions"
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnimationCell", for: indexPath)
        
        if indexPath.section == 0 {
            let (title, _) = animations[indexPath.row]
            cell.textLabel?.text = title
        } else {
            cell.textLabel?.text = "Modal Demo"
        }
        
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.font = .systemFont(ofSize: 16)
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            // 导航转场动画
            let (title, animationType) = animations[indexPath.row]
            let targetVC = AnimationTargetDemoViewController()
            targetVC.animationTitle = title
            targetVC.bk_setupCustomTransition(animationType)
            navigationController?.pushViewController(targetVC, animated: true)
        } else {
            // 模态演示
            let modalDemoVC = ModalDemoViewController()
            modalDemoVC.bk_setupCustomTransition(.push(direction: .left))
            navigationController?.pushViewController(modalDemoVC, animated: true)
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
