//
//  ViewControllerCell.swift
//  DawnTransition_Example
//
//  Created by zhang on 2023/8/10.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import DawnKit

class ViewControllerCell: UITableViewCell {

    var gradientView: DawnGradientView!
    var descLabel: DawnLabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .white
        commonInitialization()
        layoutInitialization()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInitialization()
        layoutInitialization()
    }
    
    func commonInitialization() {
        gradientView = DawnGradientView.init()
        gradientView.gradientClolors = [UIColor.appBlue(0.5), .appBlue(0.1)]
        gradientView.gradientDirection = .leftToRight
        gradientView.layer.cornerRadius = 2
        gradientView.layer.masksToBounds = true
        contentView.addSubview(gradientView)
        
        descLabel = DawnLabel()
        descLabel.contentEdgeInsets = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 40)
        descLabel.font = .gillSans(19)
        descLabel.textColor = .appBlue()
        contentView.addSubview(descLabel)
    }

    func layoutInitialization() {
        gradientView.dw.makeConstraints { make in
            make.left.equalTo(descLabel)
            make.right.equalTo(descLabel)
            make.bottom.equalTo(descLabel)
            make.height.equalTo(1/UIScreen.main.scale)
        }
        
        descLabel.dw.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(15)
            make.bottom.equalTo(-15)
        }
    }
}
