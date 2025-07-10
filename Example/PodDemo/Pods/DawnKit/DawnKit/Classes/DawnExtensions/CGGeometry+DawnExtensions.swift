//
//  CGGeometry+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

import UIKit

public extension CGFloat {
    
    /// 获取CGFloat的绝对值
    var abs: CGFloat {
        return Swift.abs(self)
    }
    
    /// 将CGFloat转Int
    func toInt() -> Int {
        return Int(self)
    }
    
    /// 将CGFloat转Double
    func toDouble() -> Double {
        return Double(self)
    }
    
    /// 将CGFloat转String
    func toString() -> String {
        return String(describing: self)
    }
    
    /// 返回CGFloat的倍数
    func scaled(_ scale: CGFloat) -> CGFloat {
        return self * scale
    }
    
    /// 将角度转弧度
    func degreesToRadians() -> CGFloat {
        return (.pi * self) / 180.0
    }
    
    /// 将弧度转角度
    func radiansToDegrees() -> CGFloat {
        return (180.0 * self) / .pi
    }
    
    #if os(iOS)

    /// 将CGFloat转像素点
    func toPixel() -> CGFloat {
        return scaled(UIScreen.main.scale)
    }
        
    /// 将像素点转换成CGFloat
    func fromPixel() -> CGFloat {
        return self / UIScreen.main.scale
    }
    
    /// 像素取整类型
    enum FlatType { case ceiled, floored, rounded }
    
    /// 基于指定的倍数，对CGFloat进行像素取整(默认向上取整)
    func flatted(scale factor: CGFloat = UIScreen.main.scale, type: FlatType = .ceiled) -> CGFloat {
        let value = (self == .leastNonzeroMagnitude || self == .leastNormalMagnitude) ? 0 : self
        let scale = factor > 0 ? factor : UIScreen.main.scale
        switch type {
        case .ceiled:
            return ceil(value * scale) / scale
        case .floored:
            return floor(value * scale) / scale
        case .rounded:
            return Double(value * scale).rounded() / scale
        }
    }
    
    #endif
}

public extension CGPoint {
    
    /// 获取圆上任意点坐标
    ///
    /// - Parameters:
    ///   - center: 圆心点坐标
    ///   - radius: 圆的半径
    ///   - radian: 该点所对应的弧度 (顺时针方向，水平第一象限开始)
    ///
    /// - Returns: 该点对应的坐标
    static func pointOnCircle(center: CGPoint, radius: CGFloat, radian: CGFloat) -> CGPoint {
        var result = CGPoint.zero
        let rad = radian + .pi / 2
        if rad < .pi / 2 {
            result.x = center.x + radius * sin(radian)
            result.y = center.y - radius * cos(radian)
        } else if rad < .pi {
            result.x = center.x + radius * sin(.pi - radian)
            result.y = center.y + radius * cos(.pi - radian)
        } else if rad < (.pi + .pi / 2) {
            result.x = center.x - radius * cos((.pi + .pi / 2) - radian)
            result.y = center.y + radius * sin((.pi + .pi / 2) - radian)
        } else {
            result.x = center.x - radius * sin(.pi * 2 - radian)
            result.y = center.y - radius * cos(.pi * 2 - radian)
        }
        return result
    }
    
    /// 返回两个点之间的距离
    static func distance(_ from: CGPoint, _ to: CGPoint) -> CGFloat {
        return sqrt(pow(to.x - from.x, 2) + pow(to.y - from.y, 2))
    }
    
    /// 返回两个点之间的中点
    static func center(_ p1: CGPoint, _ p2: CGPoint) -> CGPoint {
        let px = fmax(p1.x, p2.x) + fmin(p1.x, p2.x)
        let py = fmax(p1.y, p2.y) + fmin(p1.y, p2.y)
        return CGPoint(x: px * 0.5, y: py * 0.5)
    }

    /// 判断当前点是否在圆形内 (center: 圆心 radius: 半径)
    func within(center: CGPoint, radius: CGFloat) -> Bool {
        let dx = fabs(Double(x - center.x))
        let dy = fabs(Double(y - center.y))
        return hypot(dx, dy) <= Double(radius)
    }
    
    /// 将CGPoint放大指定的倍数
    func scaled(_ scale: CGFloat) -> CGPoint {
        return CGPoint(x: x * scale, y: y * scale)
    }
    
    /// 将CGPoint向上取整
    func ceiled() -> CGPoint {
        return CGPoint(x: ceil(x), y: ceil(y))
    }
    
    /// 将CGPoint向下取整
    func floored() -> CGPoint {
        return CGPoint(x: floor(x), y: floor(y))
    }
    
    /// 将CGPoint四舍五入
    func rounded() -> CGPoint {
        return CGPoint(x: round(x), y: round(y))
    }
}

public extension CGSize {
    
    /// 返回最大的有限CGSize
    static var greatestFiniteMagnitude: CGSize {
        return CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude)
    }
    
    /// 将CGSize放大指定的倍数
    func scaled(_ scale: CGFloat) -> CGSize {
        return CGSize(width: width * scale, height: height * scale)
    }
    
    /// 将CGSize向上取整
    func ceiled() -> CGSize {
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    /// 将CGSize向下取整
    func floored() -> CGSize {
        return CGSize(width: floor(width), height: floor(height))
    }
    
    /// 将CGSize四舍五入
    func rounded() -> CGSize {
        return CGSize(width: round(width), height: round(height))
    }
    
    /// 判断CGSize是否存在infinite
    var isInfinite: Bool {
        return width.isInfinite || height.isInfinite
    }
    
    /// 判断CGSize是否存在NaN
    var isNaN: Bool {
        return width.isNaN || height.isNaN
    }

    /// 判断CGSize是否为空(宽或高小于等于0)
    var isEmpty: Bool {
        return width <= 0 || height <= 0
    }
    
    /// 判断CGSize是否有效(不包含零值、不带无穷大的值、不带非法数字）
    var isValid: Bool {
        return !isEmpty && !isNaN && !isInfinite
    }
}

public extension CGRect {

    /// 使用宽高初始化CGRect
    init(w: CGFloat, h: CGFloat) {
        self.init(origin: .zero, size: CGSize(width: w, height: h))
    }
    
    /// 将CGRect放大指定的倍数
    func scaled(_ scale: CGFloat) -> CGRect {
        return CGRect(x: origin.x * scale, y: origin.y * scale,
                      width: size.width * scale, height: size.height * scale)
    }
    
    /// 将CGRect向上取整
    func ceiled() -> CGRect {
        return CGRect(x: ceil(origin.x), y: ceil(origin.y),
                      width: ceil(size.width), height: ceil(size.height))
    }
    
    /// 将CGRect向下取整
    func floored() -> CGRect {
        return CGRect(x: floor(origin.x), y: floor(origin.y),
                      width: floor(size.width), height: floor(size.height))
    }
    
    /// 将CGRect四舍五入
    func rounded() -> CGRect {
        return CGRect(x: round(origin.x), y: round(origin.y),
                      width: round(size.width), height: round(size.height))
    }
    
    /// 获取矩形中心点最大半径
    func maxRadius() -> CGFloat {
        let center = CGPoint(x: self.width / 2, y: self.height / 2)
        return sqrt(pow(center.x, 2) + pow(center.y, 2))
    }
}

public extension NSUIEdgeInsets {
    
    /// 获取NSUIEdgeInsets在水平方向上的值
    var horizontal: CGFloat {
        return self.left + self.right
    }
    
    /// 获取NSUIEdgeInsets在垂直方向上的值
    var vertical: CGFloat {
        return self.top + self.bottom
    }
    
    /// 返回反转后的NSUIEdgeInsets
    var invert: NSUIEdgeInsets {
        return NSUIEdgeInsets(top: -self.top, left: -self.left, bottom: -self.bottom, right: -self.right)
    }
    
    /// 使用相同的值返回NSUIEdgeInsets
    static func make(same value: CGFloat) -> NSUIEdgeInsets {
        return NSUIEdgeInsets(top: value, left: value, bottom: value, right: value)
    }
    
    /// 设置top值返回NSUIEdgeInsets
    static func make(top: CGFloat) -> NSUIEdgeInsets {
        return NSUIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
    }
    
    /// 设置left值返回NSUIEdgeInsets
    static func make(left: CGFloat) -> NSUIEdgeInsets {
        return NSUIEdgeInsets(top: 0, left: left, bottom: 0, right: 0)
    }
    
    /// 设置bottom值返回NSUIEdgeInsets
    static func make(bottom: CGFloat) -> NSUIEdgeInsets {
        return NSUIEdgeInsets(top: 0, left: 0, bottom: bottom, right: 0)
    }
    
    /// 设置right值返回NSUIEdgeInsets
    static func make(right: CGFloat) -> NSUIEdgeInsets {
        return NSUIEdgeInsets(top: 0, left: 0, bottom: 0, right: right)
    }
    
    /// 判断NSUIEdgeInsets是否相同
    func equalTo(_ insets2: NSUIEdgeInsets) -> Bool {
        return self == insets2
    }
}

// MARK: - CGHorizontalEquantLayout1

/// 水平分布
public struct CGHorizontalEquantLayout1 {
    
    public init(count: Int, leadSpacing: CGFloat, tailSpacing: CGFloat) {
        self.count = count
        self.leadSpacing = leadSpacing
        self.tailSpacing = tailSpacing
    }

    /// 最大布局宽度，默认屏幕宽
    public var maxLayoutWidth: CGFloat = UIScreen.main.bounds.size.width
    
    /// 水平均分数量 (count > 1)
    public let count: Int
    
    /// 起始位置间距
    public let leadSpacing: CGFloat
    
    /// 末尾位置间距
    public let tailSpacing: CGFloat
}

public extension CGHorizontalEquantLayout1 {
    
    /// 固定间距获取合适的宽度
    func equalWidthThatFits(_ fixedSpacing: CGFloat) -> CGFloat {
        let value = maxLayoutWidth - leadSpacing - tailSpacing
        guard count > 1 else { return value }
        let width =  (value - CGFloat(count - 1) * fixedSpacing) / CGFloat(count)
        return floor(width)
    }
    
    /// 固定宽度获取合适的间距
    func equalSpacingThatFits(_ fixedWidth: CGFloat) -> CGFloat {
        let value = maxLayoutWidth - leadSpacing - tailSpacing
        guard count > 1 else { return value }
        let spacing = (value - CGFloat(count) * fixedWidth) / CGFloat(count - 1)
        return floor(spacing)
    }
}
