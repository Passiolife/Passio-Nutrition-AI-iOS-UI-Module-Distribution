//
//  NutritionStackView.swift
//  Nutritaion-ai
//
//  Created by Mind on 12/02/24.
//

import UIKit

class DailyNutritionView: ViewFromXIB {

    @IBOutlet private weak var currentCaloriesLabel: UILabel!
    @IBOutlet private weak var currentCarbsLabel: UILabel!
    @IBOutlet private weak var currentProteinLabel: UILabel!
    @IBOutlet private weak var currentFatLabel: UILabel!

    @IBOutlet private weak var totalCaloriesLabel: UILabel!
    @IBOutlet private weak var totalCarbsLabel: UILabel!
    @IBOutlet private weak var totalProteinLabel: UILabel!
    @IBOutlet private weak var totalFatLabel: UILabel!

    @IBOutlet private weak var caloriesProgressView: CircleProgressView!
    @IBOutlet private weak var carbsProgressView: CircleProgressView!
    @IBOutlet private weak var proteinProgressView: CircleProgressView!
    @IBOutlet private weak var fatProgressView: CircleProgressView!

    var nutritionData: NutritionDataModal?

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupUI()
    }

    public func setupUI() {
        caloriesProgressView.lineColor = UIColor.colorFromBundle(named: "gray-200")
        carbsProgressView.lineColor = UIColor.colorFromBundle(named: "gray-200")
        proteinProgressView.lineColor = UIColor.colorFromBundle(named: "gray-200")
        fatProgressView.lineColor = UIColor.colorFromBundle(named: "gray-200")

        caloriesProgressView.selectedLineColor = UIColor.colorFromBundle(named: "yellow-500")
        carbsProgressView.selectedLineColor = UIColor.colorFromBundle(named: "lightBlue")
        proteinProgressView.selectedLineColor = UIColor.colorFromBundle(named: "green-500")
        fatProgressView.selectedLineColor = UIColor.colorFromBundle(named: "purple500")

        caloriesProgressView.selectedDarkLineColor = UIColor.colorFromBundle(named: "yellow-900")
        carbsProgressView.selectedDarkLineColor = UIColor.colorFromBundle(named: "lightBlue-900")
        proteinProgressView.selectedDarkLineColor = UIColor.colorFromBundle(named: "green-900")
        fatProgressView.selectedDarkLineColor = UIColor.colorFromBundle(named: "purple-900")
    }

    public func setup(data: NutritionDataModal) {

        self.currentCaloriesLabel.text = "\(data.calory.consumed)"

        self.currentCaloriesLabel.text = "\(data.calory.consumed)"
        self.currentCarbsLabel.text = "\(data.carb.consumed)"
        self.currentProteinLabel.text = "\(data.protein.consumed)"
        self.currentFatLabel.text = "\(data.fat.consumed)"

        self.totalCaloriesLabel.text = "\(data.calory.target)"
        self.totalCarbsLabel.text = "\(data.carb.target)"
        self.totalProteinLabel.text = "\(data.protein.target)"
        self.totalFatLabel.text = "\(data.fat.target)"

        let caloriesProgress = CGFloat(data.calory.consumed) / CGFloat(data.calory.target)
        self.caloriesProgressView.progress = caloriesProgress
        self.carbsProgressView.progress = CGFloat(data.carb.consumed) / CGFloat(data.carb.target)
        self.proteinProgressView.progress = CGFloat(data.protein.consumed) / CGFloat(data.protein.target)
        self.fatProgressView.progress = CGFloat(data.fat.consumed) / CGFloat(data.fat.target)
    }
}
