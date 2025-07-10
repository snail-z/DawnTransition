//
//  UIAlertController+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

#if canImport(UIKit) && !os(watchOS)

import UIKit

#if canImport(AudioToolbox)

import AudioToolbox

#endif

public extension UIAlertController {
    
    /// 显示信息提示框 (isVibrate: 是否震动)
    static func show(message: String? = nil, isVibrate: Bool = false) {
        let alertController = UIAlertController(title: nil, message: message ?? "null", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        UIApplication.keyWindow()?.rootViewController?.present(alertController, animated: true)
        
        guard isVibrate else { return }
        
        #if canImport(AudioToolbox)
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        #endif
    }
}

#endif
