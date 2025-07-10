//
//  DawnToast.swift
//  DawnUI
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit

/// Toast全局管理者
public class DawnToastManage: NSObject {
    
    public static let shared: DawnToastManage = DawnToastManage()
    
    /// 设置Toast外观样式
    public var style: DawnToastStyle = DawnToastStyle()
    
    /// Toast图片位置
    public enum ImagePlacement: Int {
        case top, left, bottom, right
    }
    
    /// 设置Toast图片位置
    public var placement: ImagePlacement = .top
    
    /// Toast显示位置
    public enum ToastPosition {
        case top(offset: CGFloat), center(offset: CGFloat), bottom(offset: CGFloat)
    }
    
    /// 设置Toast显示位置
    public var position: ToastPosition = .center(offset: 0)
}

/// Toast样式
public class DawnToastStyle: NSObject {
    
    /// 背景色
    public var backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.9)
    
    /// 周围阴影半径
    public var shadowRadius: CGFloat = 10
    
    /// 周围阴影颜色
    public var shadowColor: UIColor? = UIColor.black.withAlphaComponent(0.12)
    
    /// 设置周围圆角
    public var cornerRadius: CGFloat = 4
    
    /// 设置内容周围内边距，默认.zero
    public var contentEdgeInsets = UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20)
    
    /// 图片与文字间距
    public var imageAndTextSpacing: CGFloat = 10
    
    /// 设置图片颜色 (默认nil不做任何修改)
    public var imageTintColor: UIColor? = nil
    
    /// 设置图片大小 (默认为0自适应)
    public var imageFixedSize: CGSize = .zero
    
    /// 设置文本行间距
    public var lineSpacing: CGFloat = 5
    
    /// 设置文本颜色
    public var textColor: UIColor = .white
    
    /// 设置文本字体
    public var textFont: UIFont = .systemFont(ofSize: 15.0)
    
    /// 文本对齐样式
    public var textAlignment: NSTextAlignment = .center
    
    /// 文本最大行数 (默认无限制)
    public var textNumberOfLines: Int = 0
    
    /// 文本自适应最大宽度限制 (默认0无限制)
    public var textMaxLayoutWidth: CGFloat = 0
    
    /// 文本固定宽度 (默认为0自适应)
    public var textFixedLayoutWidth: CGFloat = 0
    
    /// 动画显示时长
    public var animateDuration: TimeInterval = 0.2
    
    /// 动画选项
    public enum AnimationOptions {
        case fade, drop, transform(scale: CGFloat = 0.85)
    }
    
    /// 设置动画选项，默认淡入淡出
    public var animationOptions: AnimationOptions = .fade
    
    /// 显示Toast时是否响应交互事件，默认YES isUserInteractionEnabled
    public var isRespondWhenDisplayed: Bool = true
    
    /// 是否只显示一个Toast
    public var alwaysOnlyOneToast: Bool = false
}

public extension DawnViewExtensions where Base: UIView {
    
    /// 图片文本样式Toast (delay设置为0则不自动隐藏)
    func showToast(message: String?,
                   image: UIImage?,
                   delay: TimeInterval = 2,
                   rotateAnimated: Bool = false,
                   placement: DawnToastManage.ImagePlacement = DawnToastManage.shared.placement,
                   position: DawnToastManage.ToastPosition = DawnToastManage.shared.position,
                   style: DawnToastStyle = DawnToastManage.shared.style) {
        if let msg = message, let img = image {
            return _perfectToast(text: msg, image: img, delay: delay, rotateAnimated: rotateAnimated, placement: placement, position: position, style: style)
        }
        
        if let msg = message {
            return _messageToast(message: msg, delay: delay, position: position, style: style)
        }
        
        if let img = image {
            return _imageToast(image: img, delay: delay, rotateAnimated: rotateAnimated, position: position, style: style)
        }
    }
    
    /// 仅图片样式Toast (delay设置为0则不自动隐藏)
    func showToast(image: UIImage?,
                   delay: TimeInterval = 2,
                   rotateAnimated: Bool = false, /// 是否启用旋转动画
                   position: DawnToastManage.ToastPosition = DawnToastManage.shared.position,
                   style: DawnToastStyle = DawnToastManage.shared.style) {
        guard let img = image else { return }
        _imageToast(image: img, delay: delay, rotateAnimated: rotateAnimated, position: position, style: style)
    }
    
    /// 仅文本样式Toast (delay设置为0则不自动隐藏)
    func showToast(message: String?,
                   delay: TimeInterval = 2,
                   position: DawnToastManage.ToastPosition = DawnToastManage.shared.position,
                   style: DawnToastStyle = DawnToastManage.shared.style) {
        guard let msg = message else { return }
        _messageToast(message: msg, delay: delay, position: position, style: style)
    }
    
    /// 隐藏Toast
    func hideToast() {
        guard let activeToast = base.pk_activeToasts.firstObject as? UIView else { return }
        _hideToast(activeToast)
    }
    
    /// 隐藏所有Toast
    func hideAllToasts() {
        base.pk_activeToasts.compactMap { $0 as? UIView } .forEach { _hideToast($0) }
    }
    
    // MARK: - private -
    
    private func _messageToast(message: String, delay: TimeInterval, position: DawnToastManage.ToastPosition, style: DawnToastStyle) {
        let contentView = UIView()
        contentView.isUserInteractionEnabled = false
        contentView.addShadow(radius: style.shadowRadius, opacity: 1, offset: .zero, color: style.shadowColor)
        base.addSubview(contentView)
        base.pk_activeToasts.add(contentView)
        
        let hud = UIView()
        hud.backgroundColor = style.backgroundColor
        hud.layer.cornerRadius = style.cornerRadius
        hud.clipsToBounds = true
        contentView.addSubview(hud)
        
        let label = UILabel()
        label.text = message
        label.textColor = style.textColor
        label.font = style.textFont
        label.numberOfLines = style.textNumberOfLines
        label.textAlignment = style.textAlignment
        label.preferredMaxLayoutWidth = style.textMaxLayoutWidth
        hud.addSubview(label)
        
        contentView.dw.makeConstraints { (make) in
            if let scrollView = self.base as? UIScrollView {
                let insets = scrollView.contentInset
                make.left.equalToSuperview().offset(-insets.left)
                make.right.equalToSuperview().offset(insets.right)
                make.top.equalToSuperview().offset(-insets.top)
                make.bottom.equalToSuperview().offset(insets.bottom)
                make.size.equalToSuperview()
            } else {
                make.edges.equalToSuperview()
            }
        }
        
        label.dw.makeConstraints { (make) in
            make.center.equalToSuperview()
            if style.textFixedLayoutWidth > 0 {
                make.width.equalTo(style.textFixedLayoutWidth)
            }
        }
        
        hud.dw.makeConstraints { (make) in
            let insets = style.contentEdgeInsets
            make.left.equalTo(label).offset(-insets.left)
            make.right.equalTo(label).offset(insets.right)
            make.top.equalTo(label).offset(-insets.top)
            make.bottom.equalTo(label).offset(insets.bottom)
        }
        
        _adjustToast(hud, position)
        
        hud.alpha = 0
        UIView.animate(withDuration: style.animateDuration, delay: 0, options: .curveEaseOut, animations: {
            hud.alpha = 1.0
        })
        
        guard delay > 0 else { return }
        
        DispatchQueue.asyncAfter(delay: delay) {
            self._hideToast(contentView)
        }
    }
    
    private func _imageToast(image: UIImage, delay: TimeInterval, rotateAnimated: Bool, position: DawnToastManage.ToastPosition, style: DawnToastStyle) {
        let contentView = UIView()
        contentView.isUserInteractionEnabled = false
        contentView.addShadow(radius: style.shadowRadius, opacity: 1, offset: .zero, color: style.shadowColor)
        base.addSubview(contentView)
        base.pk_activeToasts.add(contentView)
        
        let hud = UIView()
        hud.backgroundColor = style.backgroundColor
        hud.layer.cornerRadius = style.cornerRadius
        hud.clipsToBounds = true
        contentView.addSubview(hud)
        
        let imgView = UIImageView()
        if let tintColor = style.imageTintColor {
            imgView.image = image.withRenderingMode(.alwaysTemplate)
            imgView.tintColor = tintColor
        } else {
            imgView.image = image
        }
        hud.addSubview(imgView)
            
        contentView.dw.makeConstraints { (make) in
            if let scrollView = self.base as? UIScrollView {
                let insets = scrollView.contentInset
                make.left.equalToSuperview().offset(-insets.left)
                make.right.equalToSuperview().offset(insets.right)
                make.top.equalToSuperview().offset(-insets.top)
                make.bottom.equalToSuperview().offset(insets.bottom)
                make.size.equalToSuperview()
            } else {
                make.edges.equalToSuperview()
            }
        }
        
        imgView.dw.makeConstraints { (make) in
            if style.imageFixedSize.isValid {
                make.size.equalTo(style.imageFixedSize)
            }
            make.center.equalToSuperview()
        }
        
        hud.dw.makeConstraints { (make) in
            let insets = style.contentEdgeInsets
            make.left.equalTo(imgView).offset(-insets.left)
            make.right.equalTo(imgView).offset(insets.right)
            make.top.equalTo(imgView).offset(-insets.top)
            make.bottom.equalTo(imgView).offset(insets.bottom)
        }
        
        _adjustToast(hud, position)
        
        if rotateAnimated {
            imgView.layer.rotateAnimation()
        }
        
        hud.alpha = 0
        UIView.animate(withDuration: style.animateDuration, delay: 0, options: .curveEaseOut, animations: {
            hud.alpha = 1.0
        })
        
        guard delay > 0 else { return }
        
        DispatchQueue.asyncAfter(delay: delay) {
            self._hideToast(contentView)
        }
    }
    
    private func animationOptionsValue(for tag: Int) -> DawnToastStyle.AnimationOptions{
        switch tag {
        case 102: return .drop
        case 103: return .transform(scale: 0.75)
        default: return .fade
        }
    }
    
    private func tagValue(for options: DawnToastStyle.AnimationOptions) -> Int {
        switch options {
        case .fade: return 101
        case .drop: return 102
        case .transform(_): return 103
        }
    }
    
    private func _perfectToast(text: String, image: UIImage, delay: TimeInterval, rotateAnimated: Bool,
                               placement: DawnToastManage.ImagePlacement, position: DawnToastManage.ToastPosition, style: DawnToastStyle) {
        if style.alwaysOnlyOneToast {
            guard base.pk_activeToasts.count < 1 else { return }
        }
        
        let contentView = UIView()
        contentView.isUserInteractionEnabled = !style.isRespondWhenDisplayed
        base.addSubview(contentView)
        base.pk_activeToasts.add(contentView)
        
        let shadowHud = UIView()
        shadowHud.backgroundColor = .clear
        shadowHud.clipsToBounds = true
        contentView.addSubview(shadowHud)
        
        let hud = UIView()
        hud.backgroundColor = style.backgroundColor
        hud.layer.cornerRadius = style.cornerRadius
        hud.addShadow(radius: 30, opacity: 1, offset: .zero, color: style.shadowColor)
        contentView.addSubview(hud)
        
        let button = DawnButton()
        button.isUserInteractionEnabled = false
        button.layer.cornerRadius = style.cornerRadius
        button.imageFixedSize = style.imageFixedSize
        button.imageAndTitleSpacing = style.imageAndTextSpacing
        button.imagePlacement = DawnButton.ImagePlacement(rawValue: placement.rawValue)!
        let attrText = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = style.lineSpacing
        attrText.paragraphStyle(paragraphStyle)
        button.titleLabel.attributedText = attrText
        button.titleLabel.textColor = style.textColor
        button.titleLabel.font = style.textFont
        button.titleLabel.numberOfLines = style.textNumberOfLines
        button.titleLabel.textAlignment = style.textAlignment
        button.titleLabel.preferredMaxLayoutWidth = style.textMaxLayoutWidth
        hud.addSubview(button)
        
        if let colorValue = style.imageTintColor {
            button.imageView.image = image.withRenderingMode(.alwaysTemplate)
            button.imageView.tintColor = colorValue
        } else {
            button.imageView.image = image
        }
    
        contentView.dw.makeConstraints { (make) in
            if let scrollView = self.base as? UIScrollView {
                let insets = scrollView.contentInset
                make.left.equalToSuperview().offset(-insets.left)
                make.right.equalToSuperview().offset(insets.right)
                make.top.equalToSuperview().offset(-insets.top)
                make.bottom.equalToSuperview().offset(insets.bottom)
                make.size.equalToSuperview()
            } else {
                make.edges.equalToSuperview()
            }
        }
        
        button.dw.makeConstraints { (make) in
            make.center.equalToSuperview()
            if style.textFixedLayoutWidth > 0 {
                make.width.equalTo(style.textFixedLayoutWidth)
            }
        }
        
        hud.dw.makeConstraints { (make) in
            let inset = style.contentEdgeInsets
            make.left.lessThanOrEqualTo(button).inset(inset.left)
            make.right.greaterThanOrEqualTo(button).offset(inset.right)
            make.top.lessThanOrEqualTo(button).inset(inset.top)
            make.bottom.greaterThanOrEqualTo(button).offset(inset.bottom)
        }
        
        shadowHud.dw.makeConstraints { make in
            make.edges.equalTo(hud.dw.edges)
        }
        
        _adjustToast(hud, position)

        if rotateAnimated { button.imageView.layer.rotateAnimation() }

        style.animationOptions = .transform(scale: 0.75)
        switch style.animationOptions {
        case .fade:
            contentView.alpha = 0
            UIView.animate(withDuration: style.animateDuration, delay: 0, options: .curveEaseOut, animations: {
                contentView.alpha = 1
            })
        case .drop:
            var finalHeight: CGFloat
            if style.textFixedLayoutWidth > 0 {
                finalHeight = text.boundingHeight(with: style.textFixedLayoutWidth, font: style.textFont)
            } else if style.textMaxLayoutWidth > 0 {
                finalHeight = text.boundingHeight(with: style.textMaxLayoutWidth, font: style.textFont)
            } else {
                finalHeight = text.boundingHeight(with: .greatestFiniteMagnitude, font: style.textFont)
            }
            if style.imageFixedSize.height > 0 {
                finalHeight += style.imageAndTextSpacing + style.imageFixedSize.height
            } else {
                if let _ = button.imageView.image {
                    finalHeight += style.imageAndTextSpacing + button.imageView.image!.size.height
                }
            }
            finalHeight += style.contentEdgeInsets.vertical
            let translationY: CGFloat
            switch position {
            case .top(let offset):
                translationY = finalHeight + offset
            case .center(let offset):
                translationY = UIScreen.main.bounds.height * 0.5 + offset
            case .bottom(let offset):
                translationY = UIScreen.main.bounds.height + offset
            }
            contentView.transform = CGAffineTransform.init(translationX: 0, y: -translationY)
            contentView.associatedValue = translationY.toString()
            UIView.animate(withDuration: style.animateDuration) {
                contentView.transform = .identity
            }
        case .transform(let value):
            contentView.alpha = 0.7
            let scale = min(max(0, value), 1)
            contentView.transform = CGAffineTransform(scaleX: scale, y: scale)
            UIView.animate(withDuration: style.animateDuration, delay: 0, options: .curveEaseOut, animations: {
                contentView.alpha = 1.0
                contentView.transform = .identity
            })
        }

        guard delay > 0 else { return }

        DispatchQueue.asyncAfter(delay: delay) {
            self._hideToast(contentView, style: style)
        }
    }
    
    private func _adjustToast(_ toast: UIView, _ position: DawnToastManage.ToastPosition) {
        switch position {
        case .top(offset: let value):
            toast.dw.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(value)
            }
        case .center(offset: let value):
            toast.dw.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(value)
            }
        case .bottom(offset: let value):
            toast.dw.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().offset(value)
            }
        }
    }
    
    private func _hideToast(_ toast: UIView, style: DawnToastStyle) {
        guard base.pk_activeToasts.contains(toast) else { return }
        let closure: ((Bool) -> Void)? = { _ in
            toast.removeFromSuperview()
            self.base.pk_activeToasts.remove(toast)
        }
        switch style.animationOptions {
        case .fade:
            UIView.animate(withDuration: style.animateDuration, delay: 0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
                toast.alpha = 0
            }, completion: closure)
        case .drop:
            UIView.animate(withDuration: style.animateDuration, delay: 0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                let translationY = toast.associatedValue?.toCGFloat() ?? 0
                toast.transform = CGAffineTransform.init(translationX: 0, y: -translationY)
            }, completion: closure)
        case .transform(let value):
            UIView.animate(withDuration: style.animateDuration, delay: 0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                toast.alpha = 0
                toast.transform = CGAffineTransform(scaleX: value, y: value)
            }, completion: closure)
        }
    }
    
    private func _hideToast(_ toast: UIView) {
        guard base.pk_activeToasts.contains(toast) else { return }
        _sshideToast(toast, options: animationOptionsValue(for: toast.tag), duration: 0.25)
        
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
            toast.alpha = 0
            toast.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            toast.transform = CGAffineTransform.init(translationX: 0, y: -100)
        }) { _ in
            toast.removeFromSuperview()
            self.base.pk_activeToasts.remove(toast)
        }
    }
    
    private func _sshideToast(_ toast: UIView, options: DawnToastStyle.AnimationOptions, duration: TimeInterval) {
        guard base.pk_activeToasts.contains(toast) else {
            return
        }
        
        let closure: ((Bool) -> Void)? = { _ in
            toast.removeFromSuperview()
            self.base.pk_activeToasts.remove(toast)
        }
        switch options {
        case .fade:
            UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
                toast.alpha = 0
            }, completion: closure)
        case .drop:
            UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                let translationY = toast.associatedValue?.toCGFloat() ?? 0
                toast.transform = CGAffineTransform.init(translationX: 0, y: -translationY)
            }, completion: closure)
        case .transform(let value):
            UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                toast.alpha = 0
                toast.transform = CGAffineTransform(scaleX: value, y: value)
            }, completion: closure)
        }
    }
}

private var UIViewAssociatedPKToastViewsKey: Void?

private extension UIView {
    
    var pk_activeToasts: NSMutableArray {
        get {
            if let activeToasts = objc_getAssociatedObject(self, &UIViewAssociatedPKToastViewsKey) as? NSMutableArray {
                return activeToasts
            } else {
                let activeToasts = NSMutableArray()
                objc_setAssociatedObject(self, &UIViewAssociatedPKToastViewsKey, activeToasts, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return activeToasts
            }
        }
    }
}

#endif

