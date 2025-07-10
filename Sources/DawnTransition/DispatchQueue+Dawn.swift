//
//  DispatchQueue+Dawn.swift
//  DawnTransition
//
//  Created by zhang on 2022/7/20.
//  Copyright (c) 2022 snail-z <haozhang0770@163.com> All rights reserved.
//

import Foundation

internal extension DispatchQueue {
    
    private static var _dawn_onceTracker = [String]()

    class func _dawn_once(token: String, block: () -> Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        guard !_dawn_onceTracker.contains(token) else { return }
        _dawn_onceTracker.append(token)
        block()
    }

    class func _dawn_removeOnce(token: String, block: () -> Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        guard let index = _dawn_onceTracker.firstIndex(of: token) else { return }
        _dawn_onceTracker.remove(at: index)
        block()
    }
}
