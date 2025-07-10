//
//  NSUIApplication+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit

public extension NSUIApplication {
    
    /// 获取应用程序的主窗口
    static func keyWindow() -> UIWindow? {
        if #available(iOS 13, *) {
            if #available(iOS 15, *) {
                let scenes =  UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
                let windows = scenes.flatMap { $0.windows }
                return windows.first(where: { $0.isKeyWindow })
            }
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }

    /// 获取当前程序的顶层控制器
    static func topViewController() -> UIViewController? {
        func findTopViewController(_ current: UIViewController?) -> UIViewController? {
            if let presented = current?.presentedViewController {
                return findTopViewController(presented)
            }
            
            if let tabbarController = current as? UITabBarController {
                return findTopViewController(tabbarController.selectedViewController)
            }
            
            if let navigationController = current as? UINavigationController {
                return findTopViewController(navigationController.topViewController)
            }
            return current
        }
        return findTopViewController(keyWindow()?.rootViewController)
    }
    
    /// 程序后台挂起时运行该闭包任务
    func runInBackground(_ closure: @escaping () -> Void, expirationHandler: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let taskID: UIBackgroundTaskIdentifier
            if let expirationHandler = expirationHandler {
                taskID = self.beginBackgroundTask(expirationHandler: expirationHandler)
            } else {
                taskID = self.beginBackgroundTask(expirationHandler: { })
            }
            closure()
            self.endBackgroundTask(taskID)
        }
    }
}

public extension NSUIApplication {
    
    /// 打开指定链接
    static func open(link: String?) {
        guard let res = link else { return }
        let schemes = URL(string:res)!
        guard UIApplication.shared.canOpenURL(schemes) else {
            return
        }
        UIApplication.shared.open(schemes, options: [.universalLinksOnly: false]) { _ in
            #if DEBUG
            print("open link sucess! - \(schemes)")
            #endif
        }
    }
    
    /// 调起拨打电话
    static func open(telprompt phoneNumber: String?) {
        guard let res = phoneNumber else { return }
        open(link: "telprompt://" + res)
    }
}

#endif

import Foundation

public extension NSUIApplication {
    
    enum Environment {
        
        /// 应用程序在调试模式下运行
        case debug
        
        /// 应用程序从TestFlight安装
        case testFlight
        
        /// 应用程序从AppStore安装
        case appStore
    }
    
    /// 获取应用程序运行环境
    func inferredEnvironment() -> Environment {
        #if DEBUG
        return .debug

        #elseif targetEnvironment(simulator)
        return .debug

        #else
        if Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") != nil {
            return .testFlight
        }

        guard let appStoreReceiptUrl = Bundle.main.appStoreReceiptURL else {
            return .debug
        }

        if appStoreReceiptUrl.lastPathComponent.lowercased() == "sandboxreceipt" {
            return .testFlight
        }

        if appStoreReceiptUrl.path.lowercased().contains("simulator") {
            return .debug
        }

        return .appStore
        #endif
    }
    
    /// 获取设备语言
    var language: String {
        return Bundle.main.preferredLocalizations[0]
    }
    
    /// 获取应用名称
    var displayName: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }

    /// 获取应用构建版本号(包括发布与未发布)
    var buildNumber: String? {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
    }

    /// 获取应用当前版本号(发布版本号)
    var version: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
