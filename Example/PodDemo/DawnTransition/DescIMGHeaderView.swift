//
//  DescIMGHeaderView.swift
//  DawnTransition_Example
//
//  Created by zhang on 2023/8/13.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

class DescIMGHeaderView: UIView {

    var item: DescIMGModel! {
        didSet {
            titleLabel.text = item.title
            subTitleLabel.text = item.subTitle
            bgImageView.image = UIImage(named: item.imageName)
        }
    }
    
    lazy var bgImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textColor = UIColor.white
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.white
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(bgImageView)
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        
        bgImageView.dw.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        titleLabel.dw.makeConstraints { (make) in
            make.top.equalToSuperview().offset(64)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        subTitleLabel.dw.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-20)
        }
    }
}
