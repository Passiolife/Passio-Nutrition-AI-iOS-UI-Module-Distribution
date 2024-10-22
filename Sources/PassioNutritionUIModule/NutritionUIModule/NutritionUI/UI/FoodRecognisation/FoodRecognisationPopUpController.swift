//
//  FoodRecognisationPopUpController.swift
//  BaseApp
//
//  Created by Harsh on 21/02/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit

protocol FoodRecognisationPopUpDelegate: NSObjectProtocol {
    func didCancelOnBarcodeFailure()
    func didAskForNutritionScanBarcodeFailure()
    func didAskNavigateToDiary()
    func didAskContinueScanning()
}

final class FoodRecognisationPopUpController: UIViewController {

    @IBOutlet weak var viewAddLog: UIView!
    @IBOutlet weak var viewBarcodeFailure: UIView!

    var launchOption: LaunchOption = .barcodeFailure
    enum LaunchOption {
        case barcodeFailure
        case loggedSuccessfully
    }
    weak var delegate: FoodRecognisationPopUpDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewAddLog.isHidden = !(launchOption == .loggedSuccessfully)
        viewBarcodeFailure.isHidden = !(launchOption == .barcodeFailure)
    }

    class func present(on: UIViewController?,
                       launchOption: FoodRecognisationPopUpController.LaunchOption) -> FoodRecognisationPopUpController {

        let foodRecoSB = UIStoryboard(name: "FoodRecognisation", bundle: .module)
        let foodRecoVC = foodRecoSB.instantiateViewController(
            withIdentifier: FoodRecognisationPopUpController.className
        ) as! FoodRecognisationPopUpController
        foodRecoVC.launchOption = launchOption
        foodRecoVC.modalTransitionStyle = .crossDissolve
        foodRecoVC.modalPresentationStyle = .overCurrentContext
        on?.present(foodRecoVC, animated: true)
        return foodRecoVC
    }

    @IBAction func buttonCancelTapped(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            delegate?.didCancelOnBarcodeFailure()
            delegate?.didAskContinueScanning()
        }
    }

    @IBAction func buttonScanNutritionFactsTapped(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            delegate?.didAskForNutritionScanBarcodeFailure()
        }
    }
}

//MARK: Button actions
extension FoodRecognisationPopUpController {

    @IBAction func buttonViewDiaryTapped(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            delegate?.didAskNavigateToDiary()
        }
    }

    @IBAction func buttonContinueScanningTapped(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            delegate?.didAskContinueScanning()
        }
    }
}
