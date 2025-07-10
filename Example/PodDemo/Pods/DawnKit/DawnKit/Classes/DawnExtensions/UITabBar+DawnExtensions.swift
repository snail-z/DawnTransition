//
//  UITabBar+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

#if os(iOS)

import UIKit

public extension UITabBar {

    /// 设置标签栏颜色
    ///
    /// - Parameters:
    ///   - background: 标签背景颜色
    ///   - selectedBackground: 所选标签背景颜色
    ///   - item: 标签图标颜色
    ///   - selectedItem: 所选标签图标颜色
    func setColors(
        background: UIColor? = nil,
        selectedBackground: UIColor? = nil,
        item: UIColor? = nil,
        selectedItem: UIColor? = nil) {

        // background
        self.barTintColor = background ?? self.barTintColor

        // selectedItem
        self.tintColor = selectedItem ?? self.tintColor
        // shadowImage = UIImage()
        self.backgroundImage = UIImage()
        self.isTranslucent = false

        // selectedBackgoundColor
        guard let barItems = self.items else {
            return
        }

        if let selectedbg = selectedBackground {
            let rect = CGSize(width: self.frame.width/CGFloat(barItems.count), height: self.frame.height)
            self.selectionIndicatorImage = { (color: UIColor, size: CGSize) -> UIImage in
                UIGraphicsBeginImageContextWithOptions(size, false, 1)
                color.setFill()
                UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
                guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
                UIGraphicsEndImageContext()
                guard let aCgImage = image.cgImage else { return UIImage() }
                return UIImage(cgImage: aCgImage)
            }(selectedbg, rect)
        }

        if let itemColor = item {
            for barItem in barItems as [UITabBarItem] {
                // item
                guard let image = barItem.image else { continue }

                barItem.image = { (image: UIImage, color: UIColor) -> UIImage in
                    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
                    color.setFill()
                    guard let context = UIGraphicsGetCurrentContext() else {
                        return image
                    }

                    context.translateBy(x: 0, y: image.size.height)
                    context.scaleBy(x: 1.0, y: -1.0)
                    context.setBlendMode(CGBlendMode.normal)

                    let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
                    guard let mask = image.cgImage else { return image }
                    context.clip(to: rect, mask: mask)
                    context.fill(rect)

                    let newImage = UIGraphicsGetImageFromCurrentImageContext()!
                    UIGraphicsEndImageContext()
                    return newImage
                    }(image, itemColor).withRenderingMode(.alwaysOriginal)

                barItem.setTitleTextAttributes([.foregroundColor: itemColor], for: .normal)
                if let selected = selectedItem {
                    barItem.setTitleTextAttributes([.foregroundColor: selected], for: .selected)
                }
            }
        }
    }
}

#endif
