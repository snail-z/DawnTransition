//
//  DawnAnimationType.swift
//  DawnTransition
//
//  Created by zhang on 2022/6/25.
//  Copyright (c) 2022 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

public enum DawnAnimationType: Equatable {
    
    public enum Direction {
        case left, right, up, down
    }
    
    case push(direction: Direction)
    case pull(direction: Direction)
    
    case pageIn(direction: Direction, scale: CGFloat = 0.95)
    case pageOut(direction: Direction, scale: CGFloat = 0.95)

    case zoomSlide(direction: Direction, scale: CGFloat = 0.85)
    case fade
    case none
    
    indirect case selectBy(presenting: DawnAnimationType, dismissing: DawnAnimationType)
}

extension DawnAnimationType {
    
    internal func reversed() -> DawnAnimationType {
        switch self {
        case .push(direction: .up):
            return .pull(direction: .down)
        case .push(direction: .down):
            return .pull(direction: .up)
        case .push(direction: .left):
            return .pull(direction: .right)
        case .push(direction: .right):
            return .pull(direction: .left)
        case .pull(direction: .left):
            return .push(direction: .right)
        case .pull(direction: .right):
            return .push(direction: .left)
        case .pull(direction: .up):
            return .push(direction: .down)
        case .pull(direction: .down):
            return .push(direction: .up)
        case .pageIn(direction: .left, let value):
            return .pageOut(direction: .right, scale: value)
        case .pageIn(direction: .right, let value):
            return .pageOut(direction: .left, scale: value)
        case .pageIn(direction: .up, let value):
            return .pageOut(direction: .down, scale: value)
        case .pageIn(direction: .down, let value):
            return .pageOut(direction: .up, scale: value)
        case .pageOut(direction: .left, let value):
            return .pageIn(direction: .right, scale: value)
        case .pageOut(direction: .right, let value):
            return .pageIn(direction: .left, scale: value)
        case .pageOut(direction: .up, let value):
            return .pageIn(direction: .down, scale: value)
        case .pageOut(direction: .down, let value):
            return .pageIn(direction: .up, scale: value)
        case .zoomSlide(direction: .left, let value):
            return .zoomSlide(direction: .right, scale: value)
        case .zoomSlide(direction: .right, let value):
            return .zoomSlide(direction: .left, scale: value)
        case .zoomSlide(direction: .up, let value):
            return .zoomSlide(direction: .down, scale: value)
        case .zoomSlide(direction: .down, let value):
            return .zoomSlide(direction: .up, scale: value)
        case .fade:
            return .fade
        default:
            return .none
        }
    }
    
    internal static func stage(type: DawnAnimationType) -> DawnModifierStage {
        let stage = DawnModifierStage()
        switch type {
        case .push(direction: .left):
            stage.fromViewBeginModifiers = [.position(.center)]
            stage.fromViewEndModifiers = [.defaultHorizontalOffset(-1)]
            stage.toViewBeginModifiers = [.position(.right), .defaultShadow(.black)]
            stage.toViewEndModifiers = [.position(.center), .defaultShadow(.clear)]
        case .push(direction: .right):
            stage.fromViewBeginModifiers = [.position(.center)]
            stage.fromViewEndModifiers = [.defaultHorizontalOffset(1)]
            stage.toViewBeginModifiers = [.position(.left), .defaultShadow(.black, .right)]
            stage.toViewEndModifiers = [.position(.center), .defaultShadow(.clear, .right)]
        case .push(direction: .up):
            stage.fromViewBeginModifiers = [.position(.center)]
            stage.fromViewEndModifiers = [.defaultVerticalOffset(-1)]
            stage.toViewBeginModifiers = [.position(.down), .defaultShadow(.black, .top)]
            stage.toViewEndModifiers = [.position(.center), .defaultShadow(.clear, .top)]
        case .push(direction: .down):
            stage.fromViewBeginModifiers = [.position(.center)]
            stage.fromViewEndModifiers = [.defaultVerticalOffset(1)]
            stage.toViewBeginModifiers = [.position(.up), .defaultShadow(.black, .bottom)]
            stage.toViewEndModifiers = [.position(.center), .defaultShadow(.clear, .bottom)]
            
        case .pull(direction: .left):
            stage.fromViewBeginModifiers = [.position(.center), .defaultShadow(.black, .right)]
            stage.fromViewEndModifiers = [.position(.left), .defaultShadow(.clear, .right)]
            stage.toViewBeginModifiers = [.defaultHorizontalOffset(1)]
            stage.toViewEndModifiers = [.position(.center)]
        case .pull(direction: .right):
            stage.fromViewBeginModifiers = [.position(.center), .defaultShadow(.black)]
            stage.fromViewEndModifiers = [.position(.right), .defaultShadow(.clear)]
            stage.toViewBeginModifiers = [.defaultHorizontalOffset(-1)]
            stage.toViewEndModifiers = [.position(.center)]
        case .pull(direction: .up):
            stage.fromViewBeginModifiers = [.position(.center), .defaultShadow(.black, .bottom)]
            stage.fromViewEndModifiers = [.position(.up), .defaultShadow(.clear, .bottom)]
            stage.toViewBeginModifiers = [.defaultVerticalOffset(1)]
            stage.toViewEndModifiers = [.position(.center)]
        case .pull(direction: .down):
            stage.fromViewBeginModifiers = [.position(.center), .defaultShadow(.black, .top)]
            stage.fromViewEndModifiers = [.position(.down), .defaultShadow(.clear, .top)]
            stage.toViewBeginModifiers = [.defaultVerticalOffset(-1)]
            stage.toViewEndModifiers = [.position(.center)]
        
        case .pageIn(direction: .left, let scale):
            stage.fromViewBeginModifiers = [.position(.center), .initialCorner(), .overlay(0)]
            stage.fromViewEndModifiers = [.scale(scale), .defaultCorner(), .defaultOverlay()]
            stage.toViewBeginModifiers = [.position(.right), .initialCorner()]
            stage.toViewEndModifiers = [.position(.center), .defaultCorner()]
        case .pageIn(direction: .right, let scale):
            stage.fromViewBeginModifiers = [.position(.center), .initialCorner(), .overlay(0)]
            stage.fromViewEndModifiers = [.scale(scale), .defaultCorner(), .defaultOverlay()]
            stage.toViewBeginModifiers = [.position(.left), .initialCorner()]
            stage.toViewEndModifiers = [.position(.center), .defaultCorner()]
        case .pageIn(direction: .up, let scale):
            stage.fromViewBeginModifiers = [.position(.center), .initialCorner(), .overlay(0)]
            stage.fromViewEndModifiers = [.scale(scale), .defaultCorner(), .defaultOverlay()]
            stage.toViewBeginModifiers = [.position(.down), .initialCorner()]
            stage.toViewEndModifiers = [.position(.center), .defaultCorner()]
        case .pageIn(direction: .down, let scale):
            stage.fromViewBeginModifiers = [.position(.center), .initialCorner(), .overlay(0)]
            stage.fromViewEndModifiers = [.scale(scale), .defaultCorner(), .defaultOverlay()]
            stage.toViewBeginModifiers = [.position(.up), .initialCorner()]
            stage.toViewEndModifiers = [.position(.center), .defaultCorner()]
            
        case .pageOut(direction: .right, let scale):
            stage.fromViewBeginModifiers = [.position(.center), .initialCorner()]
            stage.fromViewEndModifiers = [.position(.right), .defaultCorner()]
            stage.toViewBeginModifiers = [.scale(scale), .defaultCorner(), .defaultOverlay()]
            stage.toViewEndModifiers = [.transformIdentity, .initialCorner(), .overlay(0)]
        case .pageOut(direction: .left, let scale):
            stage.fromViewBeginModifiers = [.position(.center), .initialCorner()]
            stage.fromViewEndModifiers = [.position(.left), .defaultCorner()]
            stage.toViewBeginModifiers = [.scale(scale), .defaultCorner(), .defaultOverlay()]
            stage.toViewEndModifiers = [.transformIdentity, .initialCorner(), .overlay(0)]
        case .pageOut(direction: .down, let scale):
            stage.fromViewBeginModifiers = [.position(.center), .initialCorner()]
            stage.fromViewEndModifiers = [.position(.down), .defaultCorner()]
            stage.toViewBeginModifiers = [.scale(scale), .defaultCorner(), .defaultOverlay()]
            stage.toViewEndModifiers = [.transformIdentity, .initialCorner(), .overlay(0)]
        case .pageOut(direction: .up, let scale):
            stage.fromViewBeginModifiers = [.position(.center), .initialCorner()]
            stage.fromViewEndModifiers = [.position(.up), .defaultCorner()]
            stage.toViewBeginModifiers = [.scale(scale), .defaultCorner(), .defaultOverlay()]
            stage.toViewEndModifiers = [.transformIdentity, .initialCorner(), .overlay(0)]
            
        case .zoomSlide(direction: .left, let scale):
            stage.fromViewBeginModifiers = [.position(.center), .defaultShadow()]
            stage.fromViewEndModifiers = [.position(.left), .scale(scale), .defaultShadow()]
            stage.toViewBeginModifiers = [.position(.right), .scale(scale), .defaultShadow()]
            stage.toViewEndModifiers = [.position(.center), .transformIdentity, .defaultShadow()]
        case .zoomSlide(direction: .right, let scale):
            stage.fromViewBeginModifiers = [.position(.center), .defaultShadow()]
            stage.fromViewEndModifiers = [.position(.right), .scale(scale), .defaultShadow()]
            stage.toViewBeginModifiers = [.position(.left), .scale(scale), .defaultShadow()]
            stage.toViewEndModifiers = [.position(.center), .transformIdentity, .defaultShadow()]
        case .zoomSlide(direction: .up, let scale):
            stage.fromViewBeginModifiers = [.position(.center), .defaultShadow()]
            stage.fromViewEndModifiers = [.position(.up), .scale(scale), .defaultShadow()]
            stage.toViewBeginModifiers = [.position(.down), .scale(scale), .defaultShadow()]
            stage.toViewEndModifiers = [.position(.center), .transformIdentity, .defaultShadow()]
        case .zoomSlide(direction: .down, let scale):
            stage.fromViewBeginModifiers = [.position(.center), .defaultShadow()]
            stage.fromViewEndModifiers = [.position(.down), .scale(scale), .defaultShadow()]
            stage.toViewBeginModifiers = [.position(.up), .scale(scale), .defaultShadow()]
            stage.toViewEndModifiers = [.position(.center), .transformIdentity, .defaultShadow()]
           
        case .fade:
            stage.fromViewBeginModifiers = [.alpha(1)]
            stage.fromViewEndModifiers = [.alpha(0)]
            stage.toViewBeginModifiers = [.alpha(0)]
            stage.toViewEndModifiers = [.alpha(1)]
        default: break
        }
        return stage
    }
}

extension DawnAnimationType {
    
    public func toTransitionProducer() -> DawnAnimationProducer {
        let pType: DawnAnimationType, dType: DawnAnimationType
        switch self {
        case .selectBy(let presenting, let dismissing):
            pType = presenting
            dType = dismissing
        default:
            pType = self
            dType = reversed()
        }
        
        let producer = DawnAnimationProducer()
        producer.presentingModifierStage = DawnAnimationType.stage(type: pType)
        producer.dismissingModifierStage = DawnAnimationType.stage(type: dType)
        
        let presentingHierarchy: [DawnTransitionAdjustable.Hierarchy]
        let dismissingHierarchy: [DawnTransitionAdjustable.Hierarchy]
        
        switch pType {
        case .pull, .pageOut: presentingHierarchy = [.to, .from]
        default: presentingHierarchy = [.from, .to]
        }
        
        switch dType {
        case .pull, .pageOut: dismissingHierarchy = [.to, .from]
        default: dismissingHierarchy = [.from, .to]
        }
        
        producer.presentingAdjustable = DawnTransitionAdjustable(subviewsHierarchy: presentingHierarchy)
        producer.dismissingAdjustable = DawnTransitionAdjustable(subviewsHierarchy: dismissingHierarchy)
        return producer
    }
}
