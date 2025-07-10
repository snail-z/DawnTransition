//
//  BaseNavigationController.swift
//  DawnTransition_Example
//
//  Created by zhang on 2023/8/10.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import DawnKit

class BaseNavigationController: UINavigationController {

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.isTranslucent = false
        if #available(iOS 15.0, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithOpaqueBackground()
            navigationBarAppearance.backgroundColor = .white
            navigationBarAppearance.shadowImage = UIImage()
            navigationBarAppearance.shadowColor = .appBlue(0.25)
            navigationBar.standardAppearance = navigationBarAppearance
            navigationBar.scrollEdgeAppearance = navigationBarAppearance
            
        } else {
            navigationBar.shadowImage = UIImage.image(with: .appBlue(0.25))
        }
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.white
        }
    }
    
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if !self.viewControllers.isEmpty {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
}
