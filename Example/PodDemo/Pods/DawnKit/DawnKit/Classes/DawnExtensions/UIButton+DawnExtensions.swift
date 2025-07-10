//
//  UIButton+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit

public extension UIButton {
    
    /// 设置背景色
    func setBackgroundColor(_ color: UIColor, forState: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()?.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        setBackgroundImage(colorImage, for: forState)
    }
}

public extension UIButton {
    

//    AmassingUI
//
//    MALogger
//
//    PKDebugger
//
//    PKLogger
    /// 判断活动指示器是否正在显示中
    var isShowingIndicator: Bool {
        objc_getAssociatedObject(self, &UIButtonAssociatedIndicatorShowingKey) as? Bool ?? false
    }

    /// 显示活动指示器 (显示时将置空标题图片，指示器消失则恢复)
    ///
    /// - Parameters:
    ///   - style: 指示器样式
    ///   - color: 颜色
    ///   - cleared: 是否清除背景色，默认false
    func showIndicator(style: UIActivityIndicatorView.Style, color: UIColor? = .white, cleared: Bool = false) {
        guard !isShowingIndicator else { return }
        if !translatesAutoresizingMaskIntoConstraints {
            superview?.layoutIfNeeded()
        }
        
        isUserInteractionEnabled = false
        
        func setAssociated(_ key: UnsafeRawPointer, _ value: Any?) {
            objc_setAssociatedObject(self, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        if let bgColor = backgroundColor, cleared {
            setAssociated(&UIButtonAssociatedIndicatorBgColorKey, bgColor)
            backgroundColor = .clear
        }
        
        if let title = title(for: .normal) {
            setAssociated(&UIButtonAssociatedNormalTitleKey, title)
            setTitle("", for: .normal)
        }
        
        if let image = image(for: .normal) {
            setAssociated(&UIButtonAssociatedNormalImageKey, image)
            setImage(nil, for: .normal)
        }

        let indicator = UIActivityIndicatorView(style: style)
        indicator.color = color
        indicator.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        indicator.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        indicator.startAnimating()
        addSubview(indicator)
        setAssociated(&UIButtonAssociatedIndicatorShowingKey, true)
        setAssociated(&UIButtonAssociatedIndicatorViewKey, indicator)
    }
    
    /// 显示活动指示器并自定义文本
    func showIndicatorText(_ text: String? = nil, style: UIActivityIndicatorView.Style, color: UIColor? = .white) {
        guard !isShowingIndicator else { return }
        if !translatesAutoresizingMaskIntoConstraints {
            superview?.layoutIfNeeded()
        }
        
        isUserInteractionEnabled = false
        
        func setAssociated(_ key: UnsafeRawPointer, _ value: Any?) {
            objc_setAssociatedObject(self, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        let indicator = UIActivityIndicatorView.init(style: style)
        indicator.color = color
        indicator.startAnimating()
        addSubview(indicator)
        setAssociated(&UIButtonAssociatedIndicatorShowingKey, true)
        setAssociated(&UIButtonAssociatedIndicatorViewKey, indicator)
        
        let title = title(for: .normal) ?? ""
        setAssociated(&UIButtonAssociatedNormalTitleKey, title)
        setAssociated(&UIButtonAssociatedTitleEdgeInsetsKey, titleEdgeInsets)
        setTitle(text, for: .normal)
        let size = titleLabel!.sizeThatFits(bounds.size)
        let padding = (bounds.size.width - size.width) / 2, spacing: CGFloat = 10.0;
        let offset = (bounds.width - indicator.bounds.width - size.width - spacing) / 2
        indicator.center = CGPoint(x: offset + indicator.bounds.width / 2, y: bounds.height / 2)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: -padding + offset * 2)
        
        if let image = image(for: .normal) {
            setAssociated(&UIButtonAssociatedNormalImageKey, image)
            setImage(nil, for: .normal)
        }
    }
    
    /// 隐藏指示器
    func hideIndicator() {
        guard isShowingIndicator else { return }
        
        if let indicator = objc_getAssociatedObject(self, &UIButtonAssociatedIndicatorViewKey) as? UIActivityIndicatorView {
            indicator.stopAnimating()
            indicator.removeFromSuperview()
        }
        
        if let bgColor = objc_getAssociatedObject(self, &UIButtonAssociatedIndicatorBgColorKey) {
            backgroundColor = bgColor as? UIColor
        }
        
        if let title = objc_getAssociatedObject(self, &UIButtonAssociatedNormalTitleKey) {
            setTitle(title as? String, for: .normal)
        }
        
        if let image = objc_getAssociatedObject(self, &UIButtonAssociatedNormalImageKey) {
            setImage(image as? UIImage, for: .normal)
        }
        
        if let titleInsets = objc_getAssociatedObject(self, &UIButtonAssociatedTitleEdgeInsetsKey) {
            titleEdgeInsets = titleInsets as? UIEdgeInsets ?? UIEdgeInsets.zero
        }
        
        if let imageInsets = objc_getAssociatedObject(self, &UIButtonAssociatedImageEdgeInsetsKey) {
            imageEdgeInsets = imageInsets as? UIEdgeInsets ?? UIEdgeInsets.zero
        }
        
        isUserInteractionEnabled = true
        objc_setAssociatedObject(self, &UIButtonAssociatedIndicatorShowingKey, false, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        func nilAssociated(_ key: UnsafeRawPointer) {
            objc_setAssociatedObject(self, key, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        nilAssociated(&UIButtonAssociatedIndicatorBgColorKey)
        nilAssociated(&UIButtonAssociatedNormalTitleKey)
        nilAssociated(&UIButtonAssociatedNormalImageKey)
        nilAssociated(&UIButtonAssociatedTitleEdgeInsetsKey)
        nilAssociated(&UIButtonAssociatedImageEdgeInsetsKey)
    }
}

private var UIButtonAssociatedIndicatorShowingKey: Void?
private var UIButtonAssociatedIndicatorViewKey: Void?
private var UIButtonAssociatedIndicatorBgColorKey: Void?
private var UIButtonAssociatedNormalTitleKey: Void?
private var UIButtonAssociatedNormalImageKey: Void?
private var UIButtonAssociatedTitleEdgeInsetsKey: Void?
private var UIButtonAssociatedImageEdgeInsetsKey: Void?

#endif
