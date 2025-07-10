//
//  KlipageModel.swift
//  DawnTransition_Example
//
//  Created by zhang on 2023/8/13.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

struct KlipageModel {
    
    var image: UIImage?
    var imgName: String?
    var title: String?
    
    init(name: String = "image0", tit: String = "title", imag: UIImage? = nil) {
        imgName = name
        title = tit
        image = imag
    }
    
    func takeImage() -> UIImage {
        if let img = image {
            return img
        } else if let name = imgName {
            return UIImage(named: name) ?? UIImage(named: "image0")!
        } else {
            return UIImage(named: "image0")!
        }
    }
}
