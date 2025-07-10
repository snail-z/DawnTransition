//
//  DawnGradientView.swift
//  DawnUI
//
//  Created by zhanghao on 2022/10/3.
//  Copyright © 2022 snail-z. All rights reserved.
//

import UIKit

/**
*  1. 提供自定义线性渐变方向和颜色
*  2. 提供设置线性渐变路径
*/
@objc open class DawnGradientView: UIView {
    
    /// 线性渐变方向
    @objc public enum GradientDirection: Int {
        /// 从左到右渐变
        case leftToRight
        /// 从右到左渐变
        case rightToLeft
        /// 从上到下渐变
        case topToBottom
        /// 从下到上渐变
        case bottomToTop
        /// 从左上到右下渐变
        case leftTopToRightBottom
        /// 从左下到右上渐变
        case leftBottomToRightTop
        /// 从右上到左下渐变
        case rightTopToLeftBottom
        /// 从右下到左上渐变
        case rightBottomToLeftTop
    }
    
    /// 线性渐变方向
    @objc public var gradientDirection: GradientDirection = .leftToRight {
        didSet {
            setLinear(gradientDirection)
        }
    }
    
    /// 渐变色数组
    @objc public var gradientClolors: [UIColor]? {
        didSet {
            setColors(gradientClolors)
        }
    }
    
    /// 设置渐变路径
    @objc public var gradientPath: CGPath? {
        didSet {
            setGradient(path: gradientPath, animation: .zero)
        }
    }
    
    /// 设置渐变路径和变化动画
    @objc public func setGradient(path: CGPath?, animation duration: TimeInterval) {
        setPath(path, duration)
    }
    
    open class override var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    private var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    private func setLinear(_ direction: GradientDirection) {
        switch direction {
        case .leftToRight:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        case .rightToLeft:
            gradientLayer.startPoint = CGPoint(x: 1, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0, y: 0)
        case .topToBottom:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        case .bottomToTop:
            gradientLayer.startPoint = CGPoint(x: 0, y: 1)
            gradientLayer.endPoint = CGPoint(x: 0, y: 0)
        case .leftTopToRightBottom:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        case .leftBottomToRightTop:
            gradientLayer.startPoint = CGPoint(x: 0, y: 1)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        case .rightTopToLeftBottom:
            gradientLayer.startPoint = CGPoint(x: 1, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        case .rightBottomToLeftTop:
            gradientLayer.startPoint = CGPoint(x: 1, y: 1)
            gradientLayer.endPoint = CGPoint(x: 0, y: 0)
        }
    }
    
    private func setColors(_ colors: [UIColor?]?) {
        gradientLayer.colors = colors?.map { $0?.cgColor ?? UIColor.black.cgColor }
    }
    
    private lazy var maskLayer: DawnShapeLayer = {
        let maskLayer = DawnShapeLayer()
        maskLayer.fillColor = UIColor.white.cgColor
        maskLayer.strokeColor = UIColor.clear.cgColor
        maskLayer.lineJoin  = .bevel
        maskLayer.lineCap = .square
        maskLayer.lineWidth = 0
        return maskLayer
    }()
    
    private func setPath(_ path: CGPath?, _ duration: TimeInterval) {
        guard
            let cgPath = path,
            let colors = gradientClolors, !colors.isEmpty else {
            clear()
            return
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.mask = maskLayer
        maskLayer.path = cgPath
        maskLayer.pathActions(duration: duration)
        CATransaction.commit()
    }
    
    private func clear() {
        maskLayer.path = nil
        gradientLayer.mask = nil
        gradientLayer.colors = nil
        gradientLayer.backgroundColor = nil
    }
}
