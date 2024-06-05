//
//  UINavigationController+Extension.swift
//  BaseApp
//
//  Created by Zvika on 10/2/23.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit

public extension UINavigationController {
    
    func updateStatusBarColor(color: UIColor) {
        if #available(iOS 13, *) {
            if let statusBar = self.view.viewWithTag(-1) {
                statusBar.backgroundColor = color
            }else{
                let statusBar = UIView(frame: (UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.windowScene?.statusBarManager?.statusBarFrame)!)
                statusBar.tag = -1
                statusBar.backgroundColor = color
                view.addSubview(statusBar)
            }
        } else {
            let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
            if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
                statusBar.backgroundColor = UIColor.clear
            }
        }
    }
    
    func pushViewController(viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
        pushViewController(viewController, animated: animated)

        if animated, let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }

    func popViewController(animated: Bool, completion: @escaping () -> Void) {
        popViewController(animated: animated)

        if animated, let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }
}
