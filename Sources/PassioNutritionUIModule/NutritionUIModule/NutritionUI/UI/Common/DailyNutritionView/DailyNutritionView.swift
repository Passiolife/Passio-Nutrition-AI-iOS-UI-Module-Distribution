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
    
    @IBOutlet weak var calorieLabel: UILabel!
    @IBOutlet weak var carbsLabel: UILabel!
    @IBOutlet weak var proteinlabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    
    @IBOutlet private weak var caloriesProgressView: CircleProgressView!
    @IBOutlet private weak var carbsProgressView: CircleProgressView!
    @IBOutlet private weak var proteinProgressView: CircleProgressView!
    @IBOutlet private weak var fatProgressView: CircleProgressView!

    var nutritionData: NutritionDataModal?

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }

    public func setupUI() {

        currentCaloriesLabel.font = .inter(type: .bold, size: 14)
        currentCarbsLabel.font = .inter(type: .bold, size: 14)
        currentProteinLabel.font = .inter(type: .bold, size: 14)
        currentFatLabel.font = .inter(type: .bold, size: 14)
        totalCaloriesLabel.font = .inter(type: .regular, size: 14)
        totalCarbsLabel.font = .inter(type: .regular, size: 14)
        totalProteinLabel.font = .inter(type: .regular, size: 14)
        totalFatLabel.font = .inter(type: .regular, size: 14)
        calorieLabel.font = .inter(type: .medium, size: 14)
        carbsLabel.font = .inter(type: .medium, size: 14)
        proteinlabel.font = .inter(type: .medium, size: 14)
        fatLabel.font = .inter(type: .medium, size: 14)

        caloriesProgressView.lineColor = .gray200
        carbsProgressView.lineColor = .gray200
        proteinProgressView.lineColor = .gray200
        fatProgressView.lineColor = .gray200

        caloriesProgressView.selectedLineColor = .yellow500
        carbsProgressView.selectedLineColor = .lightBlue
        proteinProgressView.selectedLineColor = .green500
        fatProgressView.selectedLineColor = .purple500

        caloriesProgressView.selectedDarkLineColor = UIColor.colorFromBundle(named: "yellow-900")
        carbsProgressView.selectedDarkLineColor = UIColor.colorFromBundle(named: "lightBlue-900")
        proteinProgressView.selectedDarkLineColor = UIColor.colorFromBundle(named: "green-900")
        fatProgressView.selectedDarkLineColor = UIColor.colorFromBundle(named: "purple-900")
    }

    public func setup(data: NutritionDataModal) {

        currentCaloriesLabel.text = "\(data.calory.consumed)"
        currentCarbsLabel.text = "\(data.carb.consumed)"
        currentProteinLabel.text = "\(data.protein.consumed)"
        currentFatLabel.text = "\(data.fat.consumed)"

        totalCaloriesLabel.text = "\(data.calory.target)"
        totalCarbsLabel.text = "\(data.carb.target)"
        totalProteinLabel.text = "\(data.protein.target)"
        totalFatLabel.text = "\(data.fat.target)"

        let caloriesProgress = CGFloat(data.calory.consumed) / CGFloat(data.calory.target)
        caloriesProgressView.progress = caloriesProgress
        carbsProgressView.progress = CGFloat(data.carb.consumed) / CGFloat(data.carb.target)
        proteinProgressView.progress = CGFloat(data.protein.consumed) / CGFloat(data.protein.target)
        fatProgressView.progress = CGFloat(data.fat.consumed) / CGFloat(data.fat.target)
    }
}
