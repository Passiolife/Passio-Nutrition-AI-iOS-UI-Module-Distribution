//
//  ProgressHUD.swift
//  BaseApp
//
//  Created by Mind on 01/04/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit

public final class ProgressHUD {

    public static func show(presentingVC: UIViewController) {

        DispatchQueue.main.async {

            let viewController = UIViewController()
            viewController.view.backgroundColor = .white.withAlphaComponent(0.5)

            guard let containerView = viewController.view else { return }

            let spinnerView = UIActivityIndicatorView()

            containerView.addSubview(spinnerView)
            spinnerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addConstraint(NSLayoutConstraint(item: spinnerView, attribute: .centerX, relatedBy: .equal, toItem: containerView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
            containerView.addConstraint(NSLayoutConstraint(item: spinnerView, attribute: .centerY, relatedBy: .equal, toItem: containerView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
            containerView.addConstraint(NSLayoutConstraint(item: spinnerView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50))
            containerView.addConstraint(NSLayoutConstraint(item: spinnerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50))
            spinnerView.layoutIfNeeded()

            viewController.modalTransitionStyle = .crossDissolve
            viewController.modalPresentationStyle = .overCurrentContext

            presentingVC.present(viewController, animated: false)
            spinnerView.startAnimating()
            spinnerView.color = .primaryColor
            spinnerView.style = .medium
        }
    }

    public static func hide(presentedVC: UIViewController) {
        DispatchQueue.main.async {
            presentedVC.dismiss(animated: false)
        }
    }
}
