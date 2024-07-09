//
//  ScanningHintViewController.swift
//  BaseApp
//
//  Created by Mind on 22/02/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit

class ScanningHintViewController: UIViewController {

    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var wholeFoodsImageView: UIImageView!
    @IBOutlet weak var drinkImageView: UIImageView!
    @IBOutlet weak var packageFoodsImageView: UIImageView!
    @IBOutlet weak var nutritionFactsImageView: UIImageView!
    @IBOutlet weak var barcodeImageView: UIImageView!

    var didDismissed: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        okButton.backgroundColor = .primaryColor
        wholeFoodsImageView.tintColor = .primaryColor
        drinkImageView.tintColor = .primaryColor
        packageFoodsImageView.tintColor = .primaryColor
        nutritionFactsImageView.tintColor = .primaryColor
        barcodeImageView.tintColor = .primaryColor
    }

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
        dismiss(animated: true) { [weak self] () in
            self?.didDismissed?()
        }
    }
}
