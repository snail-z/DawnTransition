//
//  Utility.swift
//  DawnTransition_Example
//
//  Created by zhang on 2023/8/10.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import DawnKit

public extension UIColor {
    
    static var debugColorRandom: UIColor {
        return .debugColor(.random())
    }
    
    static func appBlue(_ alpha: CGFloat = 1) -> UIColor {
        return UIColor.systemBlue.withAlphaComponent(alpha)
    }
}

public extension UIFont {
    
    static func gillSans(_ fontSize: CGFloat = 18) -> UIFont? {
        return UIFont.fontName(.avenir, style: .blackOblique, size: fontSize)
    }
    
    static func appFont(_ fontSize: CGFloat = 16) -> UIFont? {
        return UIFont.fontName(.pingFangSC, style: .regular, size: fontSize)
    }
    
    static func appFont(_ fontSize: CGFloat = 16, style: FontStyle = .normal) -> UIFont? {
        return UIFont.fontName(.pingFangSC, style: style, size: fontSize)
    }
    
    static func pingFang(_ fontSize: CGFloat = 18) -> UIFont? {
        return UIFont.fontName(.pingFangSC, style: .light, size: fontSize)
    }
}
