//
//  NSUIGestureRecognizer+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

import Foundation

public extension ANGestureRecognizerExtensions where Base: NSUIGestureRecognizer {
    
    /// 并添加手势闭包事件
    static func gestureClosure(_ handler: @escaping (_ sender: Base) -> Void) -> Base {
        let owner = Base()
        owner.an_addGesture(handler: { handler($0 as! Base) })
        return owner
    }
    
    /// 为手势识别器并添加闭包事件
    func gestureClosure(_ handler: @escaping (_ sender: Base) -> Void) {
        base.an_addGesture(handler: { handler($0 as! Base) })
    }
    
    /// 移除所有手势识别器闭包事件
    func clearGestureClosures() {
        base.an_removeGestureHandlers()
    }
}

private var UIGestureRecognizerAssociatedWrappersKey: Void?

private extension NSUIGestureRecognizer {
    
    var an_wrappers: [_ANGestureRecognizerWrapper<NSUIGestureRecognizer>]? {
        get {
            return objc_getAssociatedObject(self, &UIGestureRecognizerAssociatedWrappersKey) as? [_ANGestureRecognizerWrapper]
        } set {
            objc_setAssociatedObject(self, &UIGestureRecognizerAssociatedWrappersKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    #if os(iOS) || os(tvOS)
    
    func an_addGesture(handler: @escaping (_ sender: NSUIGestureRecognizer) -> Void) {
        if an_wrappers == nil { an_wrappers = Array() }
        let target = _ANGestureRecognizerWrapper(handler: handler)
        an_wrappers?.append(target)
        self.addTarget(target, action: target.method)
    }
    
    func an_removeGestureHandlers() {
        if var events = an_wrappers, !events.isEmpty {
            for target in events {
                self.removeTarget(target, action: target.method)
            }
            events.removeAll()
            an_wrappers = nil
        }
    }
    
    #endif
    
    #if os(OSX)
    
    func an_addGesture(handler: @escaping (_ sender: NSUIGestureRecognizer) -> Void) {
        if an_wrappers == nil { an_wrappers = Array() }
        let target = _ANGestureRecognizerWrapper(handler: handler)
        an_wrappers?.append(target)
        self.target = target
        self.action = target.method
    }
    
    func an_removeGestureHandlers() {
        if var events = an_wrappers, !events.isEmpty {
            self.target = nil
            self.action = nil
            events.removeAll()
            an_wrappers = nil
        }
    }
    
    #endif
}

private class _ANGestureRecognizerWrapper<T> {
    var block: ((_ sender: T) -> Void)?
    let method = #selector(invoke(_:))
    
    init(handler: @escaping (_ sender: T) -> Void) {
        block = handler
    }
    
    @objc func invoke(_ sender: NSUIGestureRecognizer)  {
        block?(sender as! T)
    }
}

public struct ANGestureRecognizerExtensions<Base> {
    fileprivate var base: Base
    fileprivate init(_ base: Base) { self.base = base }
}

public protocol ANGestureRecognizerExtensionsCompatible {}

public extension ANGestureRecognizerExtensionsCompatible {
    static var action: ANGestureRecognizerExtensions<Self>.Type { ANGestureRecognizerExtensions<Self>.self }
    var action: ANGestureRecognizerExtensions<Self> { get{ ANGestureRecognizerExtensions(self) } set{} }
}

extension NSUIGestureRecognizer: ANGestureRecognizerExtensionsCompatible {}
