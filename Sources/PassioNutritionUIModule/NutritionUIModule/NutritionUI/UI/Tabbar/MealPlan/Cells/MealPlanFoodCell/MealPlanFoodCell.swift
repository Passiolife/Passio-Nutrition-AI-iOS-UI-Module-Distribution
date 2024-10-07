//
//  FoodRecordCollectionViewCell.swift
//  BaseApp
//
//  Created by Mind on 16/02/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit
import SwipeCellKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

final class MealPlanFoodCell: SwipeCollectionViewCell {

    @IBOutlet weak var imageFood: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelServing: UILabel!
    @IBOutlet weak var insetBackground: UIView!

    var passioIDForCell: PassioID?
    var onAddingMeal: (() -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()
        imageFood?.roundMyCorner()
    }

    func setup(foodResult: PassioFoodDataInfo) {

        passioIDForCell = foodResult.iconID
        imageFood.loadPassioIconBy(passioID: foodResult.iconID,
                                   entityType: PassioIDEntityType.item) { passioIDForImage, image in
            if passioIDForImage == self.passioIDForCell {
                DispatchQueue.main.async {
                    self.imageFood.image = image
                }
            }
        }
        labelName.text = foodResult.foodName.capitalized
        let quantity = (foodResult.nutritionPreview?.servingQuantity ?? 0).roundDigits(afterDecimal: 1).clean
        let unit = foodResult.nutritionPreview?.servingUnit ?? ""
        let weight = "\((foodResult.nutritionPreview?.weightQuantity ?? 0).roundDigits(afterDecimal: 1).clean) \(foodResult.nutritionPreview?.weightUnit ?? "")"
        let calories = "\(foodResult.nutritionPreview?.calories ?? 0) cal"
        labelServing.text = "\(quantity) \(unit) (\(weight)) | \(calories)"
    }

    @IBAction func onAddingMeal(_ sender: UIButton) {
        onAddingMeal?()
    }
}
