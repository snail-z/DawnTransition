//
//  ObjcDawnAnimationType.swift
//  DawnTransition
//
//  Created by zhang on 2020/7/25.
//  Copyright (c) 2020 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

@objc public enum ObjcDawnAnimationType: Int {
    case none
    case fade
    
    case push
    case pull
    
    case pageIn
    case pageOut
    
    case zoomSlide
    
    case pushLeftBackStandard
}

@objc public enum ObjcDawnAnimationDirection: Int {
    case left, right, up, down
}

@objc public class ObjcDawnAnimater: NSObject {
    
    internal var direction: ObjcDawnAnimationDirection = .left
    
    internal var type: ObjcDawnAnimationType = .none
    
    internal var scale: CGFloat = 0.95
    
    fileprivate init(direction: ObjcDawnAnimationDirection, type: ObjcDawnAnimationType, scale: CGFloat = 0.95) {
        self.direction = direction
        self.type = type
        self.scale = scale
    }
    
    @objc public static func push(direction: ObjcDawnAnimationDirection) -> ObjcDawnAnimater {
        return ObjcDawnAnimater(direction: direction, type: .push)
    }
    
    @objc public static func pageIn(direction: ObjcDawnAnimationDirection, scale: CGFloat) -> ObjcDawnAnimater {
        return ObjcDawnAnimater(direction: direction, type: .pageIn, scale: scale)
    }
    
    @objc public static var pushLeft: ObjcDawnAnimater {
        return ObjcDawnAnimater(direction: .left, type: .push)
    }
    
    @objc public static var pushRight: ObjcDawnAnimater {
        return ObjcDawnAnimater(direction: .right, type: .push)
    }
    
    @objc public static var pushLeftBackStandard: ObjcDawnAnimater {
        return ObjcDawnAnimater(direction:.left, type: .pushLeftBackStandard)
    }
    
    @objc public static var pageInUp: ObjcDawnAnimater {
        return ObjcDawnAnimater(direction: .up, type: .pageIn)
    }
    
    @objc public static var pageInDown: ObjcDawnAnimater {
        return ObjcDawnAnimater(direction: .down, type: .pageIn)
    }
    
    @objc public static var pageInLeft: ObjcDawnAnimater {
        return ObjcDawnAnimater(direction: .left, type: .pageIn)
    }
    
    @objc public static var pageInRight: ObjcDawnAnimater {
        return ObjcDawnAnimater(direction: .right, type: .pageIn)
    }
    
    @objc public static var zoomSlideLeft: ObjcDawnAnimater {
        return ObjcDawnAnimater(direction: .left, type: .zoomSlide)
    }
    
    @objc public static var zoomSlideRight: ObjcDawnAnimater {
        return ObjcDawnAnimater(direction: .right, type: .zoomSlide)
    }
    
    @objc public static var zoomSlideUp: ObjcDawnAnimater {
        return ObjcDawnAnimater(direction: .up, type: .zoomSlide, scale: 1)
    }
    
    @objc public static var zoomSlideDown: ObjcDawnAnimater {
        return ObjcDawnAnimater(direction: .down, type: .zoomSlide, scale: 1)
    }
}

internal extension ObjcDawnAnimater {
    
    var swiftDirection: DawnAnimationType.Direction {
        switch direction {
        case .left: return .left
        case .right: return .right
        case .up: return .up
        case .down: return .down
        }
    }
}
