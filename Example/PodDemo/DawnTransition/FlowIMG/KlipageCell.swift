//
//  KlipageCell.swift
//  DawnTransition_Example
//
//  Created by zhang on 2023/8/13.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

class AlipageCell: UICollectionViewCell {
    
    var model: KlipageModel? {
        didSet { dataUpdates() }
    }
    
    var bgImageView: UIImageView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
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
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
        
        bgImageView = UIImageView()
        bgImageView.clipsToBounds = true
        contentView.addSubview(bgImageView)
    }
    
    func layoutInitialization() {
        bgImageView.dw.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func dataUpdates() {
        bgImageView.image = model?.takeImage()
    }
}
