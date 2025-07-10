//
//  UIScreen+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit

public extension UIScreen {
    
    /// 屏幕尺寸
    static var size: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
    
    /// 交换屏幕尺寸宽高
    static var swapSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width)
    }
    
    /// 获取当前屏幕的安全区域
    static var safeInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return UIApplication.keyWindow()?.safeAreaInsets ?? UIEdgeInsets.zero
        } else {
            return UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        }
    }
    
    /// 获取当前屏幕下状态栏高度
    static var statusBarHeight: CGFloat {
        return safeInsets.top
    }
    
    /// 获取导航栏+状态栏高度
    static var totalNavHeight: CGFloat {
        return 44 + safeInsets.top
    }
    
    /// 获取tabbar+底部安全区高度
    static var totalTabbarHeight: CGFloat {
        return 49 + safeInsets.bottom
    }
}

public extension UIScreen {
    
    enum ScreenType {
        case isIpadClassic
        case isIpadRetina
        case isIpadPro
        case isIphone4    // iphone 4/4s
        case isIphone5    // iphone 5/5c/5s/se
        case isIphone6    // iphone 6/6s/7/8
        case isIphone6p   // iphone 6p/6sp/7p/8p
        case isIphoneX    // iphone 11pro/x/xs/
        case isIphoneXR   // iphone 11/xr
        case isIphoneMax  // iphone 11pro max/xs max
    }
    
    /// 判断当前设置类型
    static func type(_ type: ScreenType) -> Bool {
        let isIpad = UIDevice.current.userInterfaceIdiom == .phone
        let isIphone = UIDevice.current.userInterfaceIdiom == .phone
        let size: CGSize = UIScreen.main.bounds.size
        switch type {
        case .isIphone4:
            return isIphone && size.equalTo(CGSize(width: 320, height: 480))
        case .isIphone5:
            return isIphone && size.equalTo(CGSize(width: 320, height: 568))
        case .isIphone6:
            return isIphone && size.equalTo(CGSize(width: 375, height: 667))
        case .isIphone6p:
            return isIphone && size.equalTo(CGSize(width: 414, height: 736))
        case .isIphoneX:
            return isIphone && size.equalTo(CGSize(width: 375, height: 812))
        case .isIphoneXR:
            guard isIphone, size.equalTo(CGSize(width: 414, height: 896)) else {
                return false
            }
            guard let mode = UIScreen.main.currentMode else {
                return false
            }
            return mode.size.equalTo(CGSize(width: 828, height: 1792))
        case .isIphoneMax:
            guard isIphone, size.equalTo(CGSize(width: 414, height: 896)) else {
                return false
            }
            guard let mode = UIScreen.main.currentMode else {
                return false
            }
            return mode.size.equalTo(CGSize(width: 1242, height: 2688))
        case .isIpadPro:
            return isIpad && (size.equalTo(CGSize(width: 1112, height: 834))
                || size.equalTo(CGSize(width: 1366, height: 1024)))
        case .isIpadRetina:
            guard isIpad, size.equalTo(CGSize(width: 1024, height: 768)) else {
                return false
            }
            return UIScreen.main.scale == 1
        case .isIpadClassic:
            guard isIpad, size.equalTo(CGSize(width: 1024, height: 768)) else {
                return false
            }
            return UIScreen.main.scale != 1
        }
    }
    
    /// 判断当前设备是否为全面屏 (iphone 11/11pro/11pro max/x/xs/xs max/xr ...)
    static var isAllScreen: Bool {
        if #available(iOS 11.0, *) {
            let _safe = UIApplication.keyWindow()?.safeAreaInsets ?? UIEdgeInsets.zero
            return (_safe.bottom > 0) ? true : false
        }
        return false
    }
}

#endif
