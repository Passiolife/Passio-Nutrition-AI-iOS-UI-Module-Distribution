//
//  DetectedNutriFactResultViewController.swift
//  BaseApp
//
//  Created by Mind on 14/03/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

protocol DetectedNutriFactResultViewControllerDelegate: NSObjectProtocol{
    func onClickNext(dataset: NutritionFactsDataSet)
    func onClickCancel()
    func didNutriFactViewExpanded(isExpanded: Bool)
}

class DetectedNutriFactResultViewController: UIViewController {

    @IBOutlet weak var labelTrayInfo   : UILabel!
    @IBOutlet weak var buttonCancel    : UIButton!
    @IBOutlet weak var buttonNext      : UIButton!
    @IBOutlet weak var servingLabel    : UILabel!
    @IBOutlet weak var servingUnitLabel: UILabel!
    @IBOutlet weak var caloriesLabel   : UILabel!
    @IBOutlet weak var carbsLabel      : UILabel!
    @IBOutlet weak var proteinLabel    : UILabel!
    @IBOutlet weak var fatLabel        : UILabel!
    @IBOutlet weak var carbsUnitLabel      : UILabel!
    @IBOutlet weak var proteinUnitLabel    : UILabel!
    @IBOutlet weak var fatUnitLabel        : UILabel!

    private let passioSDK = PassioNutritionAI.shared
    private let connector = PassioInternalConnector.shared

    weak var delegate: DetectedNutriFactResultViewControllerDelegate?

    private var currentDataSet: NutritionFactsDataSet? = nil{
        didSet {
            updateNutritionData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        updateNutritionData()
        updateUI()
    }

    private func updateUI() {

        buttonNext.backgroundColor = .primaryColor
        buttonCancel.setTitleColor(.primaryColor, for: .normal)
        buttonCancel.applyBorder(width: 2, color: .primaryColor)
        caloriesLabel.textColor = .primaryColor
        carbsLabel.textColor = .primaryColor
        proteinLabel.textColor = .primaryColor
        fatLabel.textColor = .primaryColor
    }

    private func updateNutritionData() {
        guard let dataset = currentDataSet else {
            servingLabel.text = "--"
            caloriesLabel.text = "--"
            carbsLabel.text = "--"
            proteinLabel.text = "--"
            fatLabel.text = "--"
            return
        }
        servingLabel.text = (dataset.nutritionFacts?.servingSizeQuantity.roundDigits(afterDecimal: 2).clean ?? "")
        servingUnitLabel.text = (dataset.nutritionFacts?.servingSizeUnitName ?? "")
        caloriesLabel.text = dataset.calories?.text ?? "-"
        carbsLabel.text = dataset.carbs?.value?.roundDigits(afterDecimal: 0).clean ?? "-"
        proteinLabel.text = dataset.protein?.value?.roundDigits(afterDecimal: 0).clean ?? "-"
        fatLabel.text = dataset.fat?.value?.roundDigits(afterDecimal: 0).clean ?? "-"
        carbsUnitLabel.text = "g"
        proteinUnitLabel.text = "g"
        fatUnitLabel.text = "g"
    }

    @IBAction func onClickCancel() {
        delegate?.onClickCancel()
    }

    @IBAction func onClickNext() {
        guard let dataset = self.currentDataSet else { return }
        delegate?.onClickNext(dataset: dataset)
    }

    public func updateDataset(_ dataset: NutritionFactsDataSet?) {
        currentDataSet = dataset
    }
}
