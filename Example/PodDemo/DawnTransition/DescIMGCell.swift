//
//  DescIMGCell.swift
//  DawnTransition_Example
//
//  Created by zhang on 2023/8/13.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

class DescIMGCell: UITableViewCell {

    var item: DescIMGModel! {
        didSet {
            titleLabel.text = item.title
            subTitleLabel.text = item.subTitle
            if let img = UIImage(named: item.imageName) {
                bgImageView.image = img
            } else {
                bgImageView.image = UIImage(named: "image0")
            }
        }
    }
    
    lazy var bgImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth,UIView.AutoresizingMask.flexibleHeight]
        imageView.clipsToBounds = true
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupUI() {
        selectionStyle = .none
        contentView.clipsToBounds = true
        
        contentView.addSubview(bgImageView)
        bgImageView.addSubview(titleLabel)
        bgImageView.addSubview(subTitleLabel)

        
        bgImageView.dw.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        titleLabel.dw.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(20)
            
        }

        subTitleLabel.dw.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
}
