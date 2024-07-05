//
//  MicroNutritionsInfoCell.swift
//  BaseApp
//
//  Created by Nikunj Prajapati on 26/04/22.
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import UIKit

final class MicroNutrientsInfoCell: UITableViewCell {

    @IBOutlet weak var nutritionNameLabel: UILabel!
    @IBOutlet weak var consumedValueLabel: UILabel!
    @IBOutlet weak var remainingValueLabel: UILabel!
    @IBOutlet weak var nutrientValueProgressView: UIProgressView!

    override func awakeFromNib() {
        super.awakeFromNib()
        nutrientValueProgressView.roundMyCornerWith(radius: 7)
    }
}

// MARK: - Configure Cell
extension MicroNutrientsInfoCell {

    func configureCell(name: String, value: Double, unit: String, recommendedValue: Double) {

        let remainingValue = recommendedValue - value
        var progress: Float = 0

        nutritionNameLabel.text = name
        consumedValueLabel.text = "\(abs(value).formattedDecimalValue) \(unit)"
        remainingValueLabel.text = "\(remainingValue.formattedDecimalValue) \(unit)"

        if remainingValue < 0 && recommendedValue != 0 {
            remainingValueLabel.textColor = .red500
            nutrientValueProgressView.progressTintColor = .red500
        } else {
            remainingValueLabel.textColor = .gray900
            nutrientValueProgressView.progressTintColor = .primaryColor
        }

        progress = recommendedValue == 0 ? 0 : Float(value / recommendedValue)
        let finalProgress = (recommendedValue == 0) && (value == 0) ? 0 : progress
        nutrientValueProgressView.setProgress(finalProgress, animated: false)
    }
}
