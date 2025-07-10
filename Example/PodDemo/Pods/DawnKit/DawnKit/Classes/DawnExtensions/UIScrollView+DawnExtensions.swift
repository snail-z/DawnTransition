//
//  UIScrollView+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit

public extension UIScrollView {

    /// 获取整个滚动视图快照 (UIScrollView滚动内容区)
    func snapshot() -> UIImage? { // https://gist.github.com/thestoics/1204051
        UIGraphicsBeginImageContextWithOptions(self.contentSize, false, 0)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        let previousFrame = self.frame
        self.frame = CGRect(origin: self.frame.origin, size: self.contentSize)
        self.layer.render(in: context)
        self.frame = previousFrame
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

public extension UIScrollView {

    /// 消除滚动视图自动调整的Insets
    func removeAutomaticallyAdjustsInsets() {
        if #available(iOS 11.0, *) {
            self.contentInsetAdjustmentBehavior = .never
        } else {
            self.respondedViewController()?.automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    /// 视图的四周边界
    var boundaries: UIEdgeInsets {
        let top = 0 - self.contentInset.top
        let left = 0 - self.contentInset.left
        let bottom = self.contentSize.height - self.bounds.size.height + self.contentInset.bottom
        let right = self.contentSize.width - self.bounds.size.width + self.contentInset.right
        return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
    
    /// 边界类型(上左下右)
    enum BoundariesType {
        case top, left, bottom, right
    }
    
    /// 使视图滚动到指定边界
    func scroll(to type: BoundariesType, animated: Bool = true) {
        var offset = self.contentOffset
        switch type {
        case .top: offset.y = boundaries.top
        case .left: offset.x = boundaries.left
        case .bottom: offset.y = boundaries.bottom
        case .right: offset.x = boundaries.right
        }
        self.setContentOffset(offset, animated: animated)
    }
}
 
extension UIScrollView {
 
    public enum IndexStatus { case end, scrolling }
    
    /// 当前滚动索引
    public func currentIndex(of status: IndexStatus = .end, numberOfPages: Int) -> Int {
        var page = contentOffset.x / bounds.size.width
        if status == .scrolling { page = page + 0.5 }
        var intPage = Int(page)
        if intPage >= numberOfPages { intPage = numberOfPages - 1 }
        if intPage < 0 { intPage = 0 }
        return 0
    }
}

#endif
