//
//  UICollectionView+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit

public extension UICollectionView {

    /// 返回collectionView所有section中的所有条数
    func numberOfItems() -> Int {
        var section = 0
        var itemsCount = 0
        while section < numberOfSections {
            itemsCount += numberOfItems(inSection: section)
            section += 1
        }
        return itemsCount
    }
    
    /// 刷新数据完成处理回调
    func reloadData(_ completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0, animations: {
            self.reloadData()
        }, completion: { _ in
            completion()
        })
    }
    
    /// 使用类名出列可重用的UICollectionViewCell
    func dequeueReusableCell<T: UICollectionViewCell>(withClass desc: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: String(describing: desc), for: indexPath) as? T else {
            fatalError("Couldn't find UICollectionViewCell for \(String(describing: desc)), make sure the cell is registered with collection view")
        }
        return cell
    }
    
    enum ElementKind  { case sectionHeader, sectionFooter }
    
    /// 使用类名出列可重用的UICollectionReusableView - sectionHeader
    func dequeueReusableHeader<T: UICollectionReusableView>(withClass desc: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableSupplementaryView(ofKind: .sectionHeader, withClass: desc, for: indexPath)
    }
    
    /// 使用类名出列可重用的UICollectionReusableView - sectionFooter
    func dequeueReusableFooter<T: UICollectionReusableView>(withClass desc: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableSupplementaryView(ofKind: .sectionFooter, withClass: desc, for: indexPath)
    }

    /// 使用类名出列可重用的UICollectionReusableView
    private func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind kind: ElementKind, withClass desc: T.Type, for indexPath: IndexPath) -> T {
        let elementKind: String
        switch kind {
        case .sectionHeader:
            elementKind = UICollectionView.elementKindSectionHeader
        case .sectionFooter:
            elementKind = UICollectionView.elementKindSectionFooter
        }
        guard let cell = dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: String(describing: desc), for: indexPath) as? T else {
            fatalError("Couldn't find UICollectionReusableView for \(String(describing: desc)), make sure the view is registered with collection view")
        }
        return cell
    }
    
    /// 使用类名注册UICollectionViewCell
    func register<T: UICollectionViewCell>(cellWithClass desc: T.Type) {
        register(T.self, forCellWithReuseIdentifier: String(describing: desc))
    }
    
    /// 使用类名注册UICollectionReusableView - SectionHeader
    func register<T: UICollectionReusableView>(headerWithClass desc: T.Type) {
        return register(supplementaryViewOfKind: .sectionHeader, withClass: desc)
    }
    
    /// 使用类名注册UICollectionReusableView - SectionFooter
    func register<T: UICollectionReusableView>(footerWithClass desc: T.Type) {
        return register(supplementaryViewOfKind: .sectionFooter, withClass: desc)
    }
    
    /// 使用类名注册UICollectionReusableView
    private func register<T: UICollectionReusableView>(supplementaryViewOfKind kind: ElementKind, withClass desc: T.Type) {
        let elementKind: String
        switch kind {
        case .sectionHeader:
            elementKind = UICollectionView.elementKindSectionHeader
        case .sectionFooter:
            elementKind = UICollectionView.elementKindSectionFooter
        }
        register(T.self, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: String(describing: desc))
    }
    
    /// 安全滚动到目标位置 (检查IndexPath在CollectionView中是否有效)
    func safeScrollToItem(at indexPath: IndexPath, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        guard indexPath.item >= 0 &&
            indexPath.section >= 0 &&
            indexPath.section < numberOfSections &&
            indexPath.item < numberOfItems(inSection: indexPath.section) else {
                return
        }
        scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
    }
}

public extension UICollectionView {
    
    /// 水平方向滚动到指定的IndexPath
    @objc func scrollToVertically(_ indexPath: IndexPath, animated: Bool) {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let delegate = delegate as? UICollectionViewDelegateFlowLayout
        
        var inset = flowLayout.sectionInset
        if let value = delegate?.collectionView?(self, layout: flowLayout, insetForSectionAt: indexPath.section) {
            inset = value
        }
        
        var size = flowLayout.headerReferenceSize
        if let value = delegate?.collectionView?(self, layout: flowLayout, referenceSizeForHeaderInSection: indexPath.section) {
            size = value
        }
        
        var point = CGPoint.zero
        if numberOfItems(inSection: indexPath.section) > .zero {
            let layoutAttrib = flowLayout.layoutAttributesForItem(at: indexPath)!
            point = CGPoint(x: .zero, y: layoutAttrib.frame.minY - inset.top - size.height)
        } else {
            guard let layoutAttrib = flowLayout.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath) else { return }
            point = CGPoint(x: .zero, y: layoutAttrib.frame.minY - inset.top - size.height)
        }
        
        let boundaries = point.y + bounds.size.height;
        if boundaries > contentSize.height {
            point.y = contentSize.height - bounds.height + contentInset.bottom
        }
        setContentOffset(point, animated: false)
    }
    
    /// 根据当前滚动位置获取所在的布局分组
    @objc func verticallyLayoutSection(at point: CGPoint) -> NSNumber? {
        for (index, rect) in layoutSectionRects {
            guard rect.contains(point) else { continue }
            return NSNumber(value: index)
        }
        return nil
    }
    
    /// 获取每组对应的布局范围
    @objc var layoutSectionRects: [Int: CGRect] {
        let sectionRects: [Int: CGRect]
        if let existing = objc_getAssociatedObject(self, &UICollectionViewAssociatedLayoutSectionRectsKey) as? [Int: CGRect] {
            sectionRects = existing
        } else {
            sectionRects = verticallyLayoutSectionRects()
            objc_setAssociatedObject(self, &UICollectionViewAssociatedLayoutSectionRectsKey, sectionRects, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return sectionRects
    }
    
    /// 重新计算每组对应的布局范围
    @objc func invalidateLayoutSectionRects() {
        objc_setAssociatedObject(self, &UICollectionViewAssociatedLayoutSectionRectsKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func verticallyLayoutSectionRects() -> [Int: CGRect] {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return [:] }
        let delegate = delegate as? UICollectionViewDelegateFlowLayout
        
        var sectionOfRects = [Int: CGRect]()
        for section in 0..<numberOfSections {
            let indexPath = IndexPath.init(item: 0, section: section)
            
            var inset = flowLayout.sectionInset
            if let value = delegate?.collectionView?(self, layout: flowLayout, insetForSectionAt: indexPath.section) {
                inset = value
            }
            
            var size = flowLayout.headerReferenceSize
            if let value = delegate?.collectionView?(self, layout: flowLayout, referenceSizeForHeaderInSection: indexPath.section) {
                size = value
            }
            
            let numberOfItems = numberOfItems(inSection: section)
            if numberOfItems > .zero {
                let lastIndexPath = IndexPath(item: numberOfItems - 1, section: section)
                let lastLayoutAttrib = flowLayout.layoutAttributesForItem(at: lastIndexPath)!
                let firstLayoutAttrib = flowLayout.layoutAttributesForItem(at: indexPath)!
                var rect = firstLayoutAttrib.frame
                rect.origin.x = firstLayoutAttrib.frame.minX - inset.left
                rect.origin.y = firstLayoutAttrib.frame.minY - inset.top - size.height
                rect.size.height = lastLayoutAttrib.frame.maxY + inset.bottom - rect.origin.y
                sectionOfRects.updateValue(rect, forKey: section)
            } else {
                let layoutAttrib = flowLayout.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath)!
                sectionOfRects.updateValue(layoutAttrib.frame, forKey: section)
            }
        }
        return sectionOfRects
    }
}

private var UICollectionViewAssociatedLayoutSectionRectsKey: Void?

#endif
