//
//  ScanningHintViewController.swift
//  BaseApp
//
//  Created by Mind on 22/02/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit

class ScanningHintViewController: UIViewController {

    var didDismissed: (() -> Void)?

    class func presentHint(presentigVC: UIViewController?, didDismissed: (() -> Void)?) {

        let foodRecoSB = UIStoryboard(name: "FoodRecognisation", bundle: .module)
        let hintVC = foodRecoSB.instantiateViewController(
            withIdentifier: "ScanningHintViewController"
        ) as! ScanningHintViewController
        hintVC.didDismissed = didDismissed
        hintVC.modalPresentationStyle = .overCurrentContext
        hintVC.modalTransitionStyle = .crossDissolve
        presentigVC?.present(hintVC, animated: true)
    }

    @IBAction func onClickOkay() {
        self.dismiss(animated: true) { [weak self] () in
            self?.didDismissed?()
        }
    }
}
