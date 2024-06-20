//
//  UINavigationController+Extension.swift
//  BaseApp
//
//  Created by Zvika on 10/2/23.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit

extension UINavigationController: UIGestureRecognizerDelegate {

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // To keep default swipe to back behavior
        interactivePopGestureRecognizer?.delegate = self
    }

    func updateStatusBarColor(color: UIColor) {
        if let statusBar = self.view.viewWithTag(-1) {
            statusBar.backgroundColor = color
        } else {
            let statusBar = UIView(frame: (UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.windowScene?.statusBarManager?.statusBarFrame)!)
            statusBar.tag = -1
            statusBar.backgroundColor = color
            view.addSubview(statusBar)
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

    // To keep default swipe to back behavior
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
