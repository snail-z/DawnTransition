//
//  DescIMGViewController.swift
//  DawnTransition_Example
//
//  Created by zhang on 2023/8/13.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import DawnTransition

class DescIMGViewController: UIViewController {
    
    public var willDismiss: ((DescIMGViewController) -> Void)?
    private let descItem: DescIMGModel
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "close"), for: .normal)
        button.addTarget(self, action: #selector(closeButtonClick(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: UIScreen.main.bounds)
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.backgroundColor = UIColor.white
        scrollView.showsVerticalScrollIndicator = false
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.delaysContentTouches = true
        return scrollView
    }()
    
    lazy var headerView: DescIMGHeaderView = {
        let headerView = DescIMGHeaderView(frame: CGRect.zero)
        headerView.item = self.descItem
        headerView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        return headerView
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = self.descItem.content + self.descItem.content
        label.backgroundColor = UIColor.white
        label.contentMode = .center
        label.font = .gillSans()
        return label
    }()
    
    init(descItem: DescIMGModel) {
        self.descItem = descItem
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupGestures()
    }
    
    private func setupGestures() {
        let pan = DawnPanGestureRecognizer(driver: self, type: .dismiss) { [weak self] in
            guard let `self` = self else { return }
            self.willDismiss?(`self`)
            self.dismiss(animated: true)
        }
        pan.isRecognizeWhenEdges = true
        pan.recognizeDirection = .leftToRight
        view.dawn.addPanGestureRecognizer(pan)
    }

    private func setupUI() {
        view.layer.masksToBounds = true
        view.contentMode = .center
        
        view.addSubview(scrollView)
        view.addSubview(closeButton)
        scrollView.addSubview(headerView)
        scrollView.addSubview(contentLabel)
        
        scrollView.dw.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        closeButton.dw.makeConstraints { (make) in
            make.top.equalTo(UIScreen.safeInsets.top)
            make.right.equalToSuperview().inset(10)
            make.width.equalTo(36)
            make.height.equalTo(36)
        }
        
        headerView.dw.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(headerView.dw.width).multipliedBy(1.34)
            make.centerX.equalToSuperview()
        }
        
        contentLabel.dw.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width)
            make.top.equalTo(headerView.dw.bottom).offset(30)
        }
    }
    
    var statusBarHidden = false {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statusBarHidden = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }
    
    @objc private func closeButtonClick(_ sender: UIButton) {
        willDismiss?(self)
        /// 当前页面截图
        let img = view.screenshots()
        let names = ["image3", "image4", "image5", "image6"]
        let img2 = UIImage(named: names[names.randomIndex])
        KliPageSnapshotCache.shared.addImage(img)
        KliPageSnapshotCache.shared.addImage(img2)
        dismiss(animated: true, completion: nil)
    }
}
