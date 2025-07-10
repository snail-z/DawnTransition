//
//  NSUIColor+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

import UIKit

public extension NSUIColor {
    
    /// 返回相同RGB值对应的颜色
    static func rgb(same value: CGFloat) -> NSUIColor {
        return NSUIColor(red: value / 255, green: value / 255, blue: value / 255, alpha: 1)
    }
    
    /// 返回RGBA值对应的颜色
    static func rgba(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1) -> NSUIColor {
        return NSUIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
    }
    
    /// 返回十六进制颜色值对应的颜色
    static func hex(_ hexValue: Int) -> NSUIColor {
        let red = CGFloat(CGFloat((hexValue & 0xFF0000) >> 16)/255.0)
        let green = CGFloat(CGFloat((hexValue & 0x00FF00) >> 8)/255.0)
        let blue = CGFloat(CGFloat((hexValue & 0x0000FF) >> 0)/255.0)
        return NSUIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    /// 返回十六进制颜色字符串对应的RGBA颜色
    static func hex(_ hexString: String) -> NSUIColor? {
        var format = hexString.replacingOccurrences(of: "0x", with: "")
        format = format.replacingOccurrences(of: "#", with: "")
        guard let hexValue = Int(format, radix: 16) else { return nil }
        return hex(hexValue)
    }
    
    /// 返回随机颜色
    static func random(isRandomAlpha: Bool = false) -> NSUIColor {
        let randomRed = CGFloat(arc4random() % 255)
        let randomGreen = CGFloat(arc4random() % 255)
        let randomBlue = CGFloat(arc4random() % 255)
        let alpha = isRandomAlpha ? CGFloat.random(in: 0.0...1.0) : 1.0
        return rgba(red: randomRed, green: randomGreen, blue: randomBlue, alpha: alpha)
    }
    
    /// 返回颜色的Red值
    var redComponent: Int {
        var r: CGFloat = 0
        getRed(&r, green: nil, blue: nil, alpha: nil)
        return Int(r * 255)
    }

    /// 返回颜色的Green值
    var greenComponent: Int {
        var g: CGFloat = 0
        getRed(nil, green: &g, blue: nil, alpha: nil)
        return Int(g * 255)
    }

    /// 返回颜色的Blue值
    var blueComponent: Int {
        var b: CGFloat = 0
        getRed(nil, green: nil, blue: &b, alpha: nil)
        return Int(b * 255)
    }

    /// 返回颜色的Alpha值
    var alpha: CGFloat {
        var a: CGFloat = 0
        getRed(nil, green: nil, blue: nil, alpha: &a)
        return a
    }
    
    /// 返回增加透明度后的颜色值
    func alpha(_ value: CGFloat) -> NSUIColor {
        return withAlphaComponent(value)
    }
}

public extension NSUIColor {
 
    /// 判断颜色是否偏暗
    func isDrak() -> Bool {
        guard let colorComponents = cgColor.components else {
            return false
        }
        let colorBrightness = (colorComponents[0] * 299 + colorComponents[1] * 587 + colorComponents[2] * 114) / 1000
        return colorBrightness < 0.5
    }
}

public extension NSUIColor {
    
    /// 获取某套配色方法的随机色
    static func random(_ scheme: ColorSchemes) -> NSUIColor {
        let values = schemes(scheme)
        return NSUIColor.hex(values.randomElement()!)
    }
    
    /// 优秀配色方案
    enum ColorSchemes {
        case granite
        case tangerine
        case fairy
        case cooler
        case slate
        case docks
        case haze
        case sunset
        case moss
        case greenDominates
        case gentle
    }
    
    /// 获取一套配色方案
    static func schemes(_ scheme: ColorSchemes = .sunset) -> [Int] {
        switch scheme {
        case .granite:
            return [0x3B7B9A, 0x70AFCE, 0xA5DEF1, 0x89d4db]
        case .tangerine:
            return [0xFF6D00, 0xFF9201, 0xFFAB40, 0xFFD180]
        case .fairy:
            return [0xA163F7, 0x6F88FC, 0x45E3FF, 0xFF7582]
        case .cooler:
            return [0x4BB6F4, 0x1F9CE4, 0x3E60C1, 0x5983FC]
        case .slate:
            return [0x5B7FA7, 0x508DA3, 0xA5DEF1, 0xFFFFFF]
        case .docks:
            return [0x43506C, 0xEF4B4C, 0x3D619B, 0xE9E9EB]
        case .haze:
            return [0x0F6BAE, 0x248BD6, 0x83BBFF, 0xC6CDFF]
        case .sunset:
            return [0x355C7D, 0x725A7A, 0xC56C86, 0xFF7582]
        case .moss:
            return [0x006270, 0x009394, 0x00E0C7, 0xF0FFF0]
        case .greenDominates:
            return [0x00738C, 0x81B0B2, 0xD6EAD4, 0x5BA8A0, 0x97A675,
                    0x96CA00, 0xC5DF56, 0x3B5284, 0xB3C8CD, 0x8AB186,
                    0xB3DA61, 0xCDE460, 0x6ECD8E, 0x539D73, 0x2B7337,
                    0x1C5A41, 0x2A8F68, 0x5AAF76, 0x498428, 0x336A29]
        case .gentle:
            return [0x478BA2, 0xDE5B6D, 0xE97658, 0xF2A490, 0xB9D4DB, 0x89d4db]
        }
    }
}

public extension NSUIColor {
    
    /// 调试模式颜色便于搜查
    static func debugColor(_ color: UIColor) -> UIColor {
        return color
    }
}
