//
//  KliPageSnapshotCache.swift
//  DawnTransition_Example
//
//  Created by zhang on 2023/8/13.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

public class KliPageSnapshotCache {

    public static var shared = KliPageSnapshotCache()

    public private(set) lazy var cacheImages: [UIImage] = {
        var imgs = [UIImage]()
        imgs.append(UIImage(named: "defaultIMG1")!)
        imgs.append(UIImage(named: "defaultIMG3")!)
        return imgs
    }()
    
    public func addImage(_ image: UIImage?) {
        guard let img = image else { return }
        cacheImages.append(img)
    }
    
    public func clearImages() {
        cacheImages.removeAll()
    }
}
