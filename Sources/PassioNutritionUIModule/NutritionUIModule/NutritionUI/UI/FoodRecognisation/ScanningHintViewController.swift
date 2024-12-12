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
    @IBOutlet weak var nutritionFactsImageView: UIImageView!
    @IBOutlet weak var barcodeImageView: UIImageView!
    @IBOutlet weak var nutritionFactStackViewContainer: UIStackView!
    @IBOutlet weak var quickScanNoteLabel: UILabel!
    
    var resultViewFor: DetectedFoodResultType = .addLog
    var didDismissed: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        okButton.backgroundColor = .primaryColor
        wholeFoodsImageView.tintColor = .primaryColor
        nutritionFactsImageView.tintColor = .primaryColor
        barcodeImageView.tintColor = .primaryColor
        
        if resultViewFor == .addIngredient {
            nutritionFactStackViewContainer.isHidden = true
            quickScanNoteLabel.text = "You can easily switch between different scanning modes to add ingredients to your recipe in various ways."
        }
    }

    class func presentHint(presentigVC: UIViewController?, resultViewFor: DetectedFoodResultType = .addLog, didDismissed: (() -> Void)?) {

        let foodRecoSB = UIStoryboard(name: "FoodRecognisation", bundle: .module)
        let hintVC = foodRecoSB.instantiateViewController(
            withIdentifier: "ScanningHintViewController"
        ) as! ScanningHintViewController
        hintVC.didDismissed = didDismissed
        hintVC.resultViewFor = resultViewFor
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
