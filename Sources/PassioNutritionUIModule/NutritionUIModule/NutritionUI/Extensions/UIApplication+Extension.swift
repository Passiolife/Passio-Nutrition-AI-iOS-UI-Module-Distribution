//
//  UIApplication+Extension.swift
//  BaseApp
//
//  Created by Zvika on 2/2/22.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit

extension UIApplication {

    static func topViewController(
        base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController //UIApplication.shared.delegate?.window??.rootViewController
    ) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

extension UIWindow {

    static func getTopViewController() -> UIViewController? {

        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        } else {
            return nil
        }
    }
}
