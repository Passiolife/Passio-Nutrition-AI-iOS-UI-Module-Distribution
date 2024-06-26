//
//  NutritionAdvisorIngredientCell.swift
//  BaseApp
//
//  Created by Mind on 30/04/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit
import PassioNutritionUIModule

class NutritionAdvisorIngredientCell: UITableViewCell {

    @IBOutlet weak var ingridientNameLable: UILabel!
    @IBOutlet weak var portionLabel: UILabel!
    @IBOutlet weak var imageFood: UIImageView!
    @IBOutlet weak var labelName: UILabel!

    var passioIDForCell: PassioID?

    override func layoutSubviews() {
        super.layoutSubviews()
        imageFood?.roundMyCorner()
    }

    func setup(ingiridient: PassioAdvisorFoodInfo) {
        ingridientNameLable.text = ingiridient.recognisedName.capitalized
        portionLabel.text = "Portion: \(ingiridient.portionSize) (\(ingiridient.weightGrams.clean) g)"
        setup(foodResult: ingiridient.foodDataInfo)
    }

    func setup(foodResult: PassioFoodDataInfo) {
        passioIDForCell = foodResult.iconID
        imageFood.loadPassioIconBy(passioID: foodResult.iconID,
                                   entityType: .item) { passioIDForImage, image in
            if passioIDForImage == self.passioIDForCell {
                DispatchQueue.main.async {
                    self.imageFood.image = image
                }
            }
        }
        labelName.text = foodResult.foodName.capitalized
    }
}
