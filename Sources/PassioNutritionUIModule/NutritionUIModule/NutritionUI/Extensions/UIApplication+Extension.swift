//
//  UIApplication+Extension.swift
//  BaseApp
//
//  Created by Zvika on 2/2/22.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit

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
