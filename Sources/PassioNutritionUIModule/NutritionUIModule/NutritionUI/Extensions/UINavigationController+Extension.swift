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

    func updateStatusBarColor(color: UIColor = .white) {
        if let statusBar = self.view.viewWithTag(-1) {
            statusBar.backgroundColor = color
        } else {
            let frame = (UIApplication.shared.windows.filter {
                $0.isKeyWindow
            }.first?.windowScene?.statusBarManager?.statusBarFrame)!
            let statusBar = UIView(frame: frame)
            statusBar.tag = -1
            statusBar.backgroundColor = color
            view.addSubview(statusBar)
        }
    }
    
    func pushViewController(viewController: UIViewController,
                            animated: Bool,
                            completion: @escaping () -> Void) {
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

    func popToSpecificViewController(_ viewController: AnyClass, isAnimated: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            for element in viewControllers {
                if element.isKind(of: viewController) {
                    popToViewController(element, animated: isAnimated)
                    break
                }
            }
        }

    }

    func popUpToIndexControllers(popUptoIndex: Int, isAnimated: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if viewControllers.indices.contains(popUptoIndex) {
                let vcToPop = viewControllers[viewControllers.count-popUptoIndex]
                popToViewController(vcToPop, animated: isAnimated)
            }
        }
    }

    // To keep default swipe to back behavior
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
