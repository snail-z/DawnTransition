//
//  DawnAnimationTransform.swift
//  DawnTransition
//
//  Created by zhang on 2022/7/25.
//  Copyright (c) 2022 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

open class DawnAnimationTransform: NSObject {

    public enum Axis { case x, y, z }
    
    /// 设置在axis轴上的旋转角度
    public func rotate(
        _ transform: CATransform3D = CATransform3DIdentity,
        axis: Axis,
        angle: CGFloat
    ) -> CATransform3D {
        switch axis {
        case .x:
            return CATransform3DRotate(transform, angle, 1, 0, 0)
        case .y:
            return CATransform3DRotate(transform, angle, 0, 1, 0)
        case .z:
            return CATransform3DRotate(transform, angle, 0, 0, 1)
        }
    }
    
    /// 设置在axis轴上的平移距离
    public func translate(
        _ transform: CATransform3D = CATransform3DIdentity,
        axis: Axis,
        offset: CGFloat
    ) -> CATransform3D {
        switch axis {
        case .x:
            return CATransform3DTranslate(transform, offset, 0, 0)
        case .y:
            return CATransform3DTranslate(transform, 0, offset, 0)
        case .z:
            return CATransform3DTranslate(transform, 0, 0, offset)
        }
    }
    
    /// 设置在xy轴上的缩放比例
    public func scale(
        _ transform: CATransform3D = CATransform3DIdentity,
        xy: CGFloat
    ) -> CATransform3D {
        return CATransform3DScale(transform, xy, xy, 1)
    }
    
    /// 返回将百分比转化成矩阵变换中的m34值
    public func m34(percentage: CGFloat) -> CGFloat {
        let factor: CGFloat = 1 - min(1, max(0, percentage))
        let total: CGFloat = 1000
        let percentage = 1.0 / (total * factor)
        let m34Value = factor > 0 ? percentage : 0.01
        return m34Value
    }
    
    public enum Direction {
        case horizontal, vertical
    }
    
    /// 调整锚点并更新frame来抵消产生的偏移，使视图可以围绕正确的边缘旋转，默认(0.5, 0.5)
    public func adjustAnchorPointAndOffset(_ anchorPoint: CGPoint, direction: Direction, view: UIView) {
        view.layer.anchorPoint = anchorPoint
        switch direction {
        case .horizontal:
            let xOffset = anchorPoint.x - 0.5
            view.frame = view.frame.offsetBy(dx: xOffset * view.frame.size.width, dy: 0)
        case .vertical:
            let yOffset = anchorPoint.y - 0.5
            view.frame = view.frame.offsetBy(dx: 0, dy: yOffset * view.frame.size.height)
        }
    }
    
    /// 恢复锚点并调整到之前位置
    public func unadjustedAnchorPointAndOffset(view: UIView) {
        let p = CGPoint(x: 0.5, y: 0.5)
        adjustAnchorPointAndOffset(p, direction: .horizontal, view: view)
        adjustAnchorPointAndOffset(p, direction: .vertical, view: view)
    }
    
    public enum Boundaries {
        case left, right, top, bottom, center
    }
    
    /// 锚点在基于视图的边缘，默认中间.center (0.5, 0.5)
    public func anchorPoint(boundaries: Boundaries) -> CGPoint {
        switch boundaries {
        case .left:
            return CGPoint(x: 0, y: 0.5)
        case .right:
            return CGPoint(x: 1, y: 0.5)
        case .top:
            return CGPoint(x: 0.5, y: 0)
        case .bottom:
            return CGPoint(x: 0.5, y: 1)
        case .center:
            return CGPoint(x: 0.5, y: 0.5)
        }
    }
    
    public enum DepthPriority {
        case low, normal, high
    }
    
    /// 设置三维坐标系中，z轴深度优先级
    public func depth(_ priority: DepthPriority) -> CGFloat {
        switch priority {
        case .low:  return -2022
        case .normal: return .zero
        case .high: return 2022
        }
    }
}
