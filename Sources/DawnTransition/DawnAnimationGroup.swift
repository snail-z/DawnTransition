//
//  DawnAnimationGroup.swift
//  DawnTransition
//
//  Created by zhang on 2020/7/25.
//  Copyright (c) 2020 snail-z <haozhang0770@163.com> All rights reserved.
//

import UIKit

public class DawnAnimationGroup: NSObject {

    public var duration: CFTimeInterval = 0.5
    public var fillMode: CAMediaTimingFillMode = .forwards
    public var timingFunction: CAMediaTimingFunction = CAMediaTimingFunction(name: .linear)
    public var didStart: ((CAAnimation) -> Void)?
    public var didStop: ((CAAnimation, Bool) -> Void)?
    
    internal weak var weakLayer: CALayer?
    internal lazy var group: CAAnimationGroup = {
        let group = CAAnimationGroup()
        group.isRemovedOnCompletion = false
        group.delegate = self
        return group
    }()
    
    public func setAnimations(_ animations: [CAAnimation]?) {
        guard let values = animations, !values.isEmpty else { return }
        group.animations = values
        group.fillMode = fillMode
        group.duration = duration
        group.timingFunction = timingFunction
    }
    
    internal func bind(key: String?) {
        weakLayer?.add(group, forKey: key)
    }
    
    internal func unbind(key: String?) {
        guard let aKey = key else { return }
        weakLayer?.removeAnimation(forKey: aKey)
    }
}

extension DawnAnimationGroup: CAAnimationDelegate {
    
    public func animationDidStart(_ anim: CAAnimation) {
        didStart?(anim)
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        didStop?(anim, flag)
        group.delegate = nil
    }
}

fileprivate var DawnCALayerStorageAnimGroupAssociatedKey: Void?
internal extension DawnExtension where Base: CALayer {
    
    fileprivate var storageAnimGroup: DawnAnimationGroup? {
        get {
            return objc_getAssociatedObject(base, &DawnCALayerStorageAnimGroupAssociatedKey) as? DawnAnimationGroup
        }
        set {
            objc_setAssociatedObject(base, &DawnCALayerStorageAnimGroupAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension CALayer: DawnCompatible {}
extension DawnExtension where Base: CALayer {
    
    public func add(_ group: DawnAnimationGroup, forKey key: String?) {
        group.weakLayer = base
        group.bind(key: key)
        storageAnimGroup = group
    }
    
    public func removeAnimation(forKey key: String) {
        guard let group = storageAnimGroup else { return }
        group.unbind(key: key)
        storageAnimGroup = nil
    }
}

internal extension Dawn {
    
    static func runningAnimations(
        _ animations: [CAAnimation]?,
        in layer: CALayer,
        duration: TimeInterval,
        completion: ((Bool) -> Void)? = nil
    ) {
        let aKey = "dawn.anim.group.layer"
        let group = DawnAnimationGroup()
        group.duration = duration
        group.setAnimations(animations)
        group.didStop = { [weak layer] _, flag in
            completion?(flag)
            layer?.dawn.removeAnimation(forKey: aKey)
        }
        layer.dawn.add(group, forKey: aKey)
    }
}

public extension Dawn {
    
    static func animate(
        parameters: DawnTransitionAdjustable,
        animations: @escaping () -> Void,
        completion: ((Bool) -> Void)?
    ) {
         animate(
            duration: parameters.duration,
            delay: parameters.delay,
            options: parameters.curve.options,
            springParameters: parameters.spring,
            animations: animations,
            completion: completion
        )
    }
    
    static func animate(
        duration: TimeInterval,
        delay: TimeInterval = 0,
        options: UIView.AnimationOptions,
        springParameters: (damping: CGFloat, velocity: CGFloat)? = nil,
        animations: @escaping () -> Void,
        completion: ((Bool) -> Void)?
    ) {
        if let spring = springParameters {
            UIView.animate(
                withDuration: duration,
                delay: delay,
                usingSpringWithDamping: spring.damping,
                initialSpringVelocity: spring.velocity,
                options: options,
                animations: animations,
                completion: completion
            )
        } else {
            UIView.animate(
                withDuration: duration,
                delay: delay,
                options: options,
                animations: animations,
                completion: completion
            )
        }
    }
}
