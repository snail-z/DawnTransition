//
//  DawnSwizzling.swift
//  DawnTransition
//
//  Created by zhang on 2022/7/20.
//  Copyright (c) 2022 snail-z <haozhang0770@163.com> All rights reserved.
//

import Foundation

internal func _dawn_swizzle(selector originalSelector: Selector, with swizzledSelector: Selector, inClass: AnyClass, usingClass: AnyClass) {
    guard let originalMethod = class_getInstanceMethod(inClass, originalSelector),
          let swizzledMethod = class_getInstanceMethod(usingClass, swizzledSelector) else { return }
    if class_addMethod(inClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod)) {
        class_replaceMethod(inClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}
