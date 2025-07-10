//
//  UIControl+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit

public extension ANControlExtensions where Base: UIControl {

    /// 为UIControl添加闭包点击事件
    func addAction(for controlEvents: UIControl.Event, handler: @escaping (_ sender: Base) -> Void) {
        base.an_addAction(for: controlEvents, handler: { handler($0 as! Base) })
    }
    
    /// 是否存在对应的闭包事件
    func hasAction(for controlEvents: UIControl.Event) -> Bool {
        base.an_hasAction(for: controlEvents)
    }
    
    /// 移除对应的闭包事件
    func removeAction(for controlEvents: UIControl.Event) {
        base.an_removeAction(for: controlEvents)
    }
}

private var UIControlAssociatedWrappersKey: Void?

private extension UIControl {
    
    var an_wrappers: [UInt:_ANControlWrapper]? {
        get {
            objc_getAssociatedObject(self, &UIControlAssociatedWrappersKey) as? [UInt:_ANControlWrapper]
        } set {
            objc_setAssociatedObject(self, &UIControlAssociatedWrappersKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func an_addAction(for controlEvents: UIControl.Event, handler: @escaping (_ sender: UIControl) -> Void) {
        if an_wrappers == nil { an_wrappers = Dictionary() }
        let key: UInt = controlEvents.rawValue
        let target = _ANControlWrapper(handler: handler, controlEvents: controlEvents)
        an_wrappers?.updateValue(target, forKey: key)
        self.addTarget(target, action: target.method, for: controlEvents)
    }
    
    func an_hasAction(for controlEvents: UIControl.Event) -> Bool {
        guard let events = an_wrappers else { return false }
        return events.keys.contains(controlEvents.rawValue)
    }
    
    func an_removeAction(for controlEvents: UIControl.Event) {
        if var events = an_wrappers, !events.isEmpty {
            for target in events.values {
                self.removeTarget(target, action: target.method, for: controlEvents)
            }
            events.removeValue(forKey: controlEvents.rawValue)
            if events.isEmpty { an_wrappers = nil }
        }
    }
}

private class _ANControlWrapper {
    var block: ((_ sender: UIControl) -> Void)?
    let method = #selector(invoke(_:))
    
    init(handler: @escaping (_ sender: UIControl) -> Void, controlEvents: UIControl.Event) {
        block = handler
    }
    
    @objc func invoke(_ sender: UIControl)  {
        block?(sender)
    }
}

public struct ANControlExtensions<Base> {
    var base: Base
    fileprivate init(_ base: Base) { self.base = base }
}

public protocol ANControlExtensionsCompatible {}

public extension ANControlExtensionsCompatible {
    static var events: ANControlExtensions<Self>.Type { ANControlExtensions<Self>.self }
    var events: ANControlExtensions<Self> { get{ ANControlExtensions(self) } set{} }
}

extension UIControl: ANControlExtensionsCompatible {}

#endif
