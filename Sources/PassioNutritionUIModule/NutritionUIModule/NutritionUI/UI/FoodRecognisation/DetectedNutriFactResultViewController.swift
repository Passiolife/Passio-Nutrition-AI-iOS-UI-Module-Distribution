//
//  DetectedNutriFactResultViewController.swift
//  BaseApp
//
//  Created by Mind on 14/03/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit
import PassioNutritionAISDK

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

    // MANAGING STATES
    private var currentDataSet: NutritionFactsDataSet? = nil{
        didSet {
            self.updateUI()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    private func updateUI() {
        guard let dataset = currentDataSet else {
            self.servingLabel.text = "--"
            self.caloriesLabel.text = "--"
            self.carbsLabel.text = "--"
            self.proteinLabel.text = "--"
            self.fatLabel.text = "--"
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
