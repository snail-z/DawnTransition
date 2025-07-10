//
//  Timer+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

import Foundation

public extension Timer {
    
    /// 测试闭包内运行耗时(单位:毫秒)
    static func runThisElapsed(_ handler: @escaping () -> Void) -> Double {
        let a = CFAbsoluteTimeGetCurrent()
        handler()
        let b = CFAbsoluteTimeGetCurrent()
        return (b - a) * 1000.0; // to millisecond
    }
    
    /// 重复运行闭包任务 seconds：间隔时间，取消运行：timer.invalidate()
    static func runThisRepeats(seconds: TimeInterval, handler: @escaping (Timer?) -> Void) -> Timer {
        let fireDate = CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, seconds, 0, 0, handler)
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, CFRunLoopMode.commonModes)
        return timer!
    }
}
