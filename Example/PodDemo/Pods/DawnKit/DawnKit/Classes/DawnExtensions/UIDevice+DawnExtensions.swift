//
//  UIDevice+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit

extension UIDevice {
    
    /// 判断设备是否为iPhone
    static func isPhone() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    /// 判断设备是否为iPad
    static func isPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    /// 判断设备是否为模拟器
    static func isSimulator() -> Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }
}

#endif

