//
//  VoiceLoggingCell.swift
//  
//
//  Created by Nikunj Prajapati on 10/06/24.
//

import UIKit

class VoiceLoggingCell: UITableViewCell {

    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var foodDetailsLabel: UILabel!
    @IBOutlet weak var checkImage: UIImageView!

    func configureCell(with foodLog: FoodLog) {

        let advisorInfo = foodLog.foodData.advisorFoodInfo

        if let foodInfo = advisorInfo.foodDataInfo {
            
            foodImageView.setFoodImage(id: foodInfo.iconID,
                                       passioID: foodInfo.iconID,
                                       entityType: .item,
                                       connector: PassioInternalConnector.shared) { [weak self] image in
                DispatchQueue.main.async {
                    self?.foodImageView.image = image
                }
            }

            foodNameLabel.text = foodInfo.foodName.capitalized

            if let nutritionPreview = foodInfo.nutritionPreview {
                foodDetailsLabel.text = "\(nutritionPreview.servingQuantity) \(nutritionPreview.servingUnit) | \(nutritionPreview.calories) \(UnitsTexts.cal)"
            } else {
                foodDetailsLabel.text = ""
            }

            checkImage.image = UIImage(systemName: foodLog.isSelected ? "circle.fill" : "circle")
            checkImage.tintColor = foodLog.isSelected ? .primaryColor : .gray300

        } else if let packagedFoodItem = advisorInfo.packagedFoodItem {

            foodImageView.setFoodImage(id: packagedFoodItem.scannedId,
                                       passioID: packagedFoodItem.scannedId,
                                       entityType: .item,
                                       connector: PassioInternalConnector.shared) { [weak self] image in
                DispatchQueue.main.async {
                    self?.foodImageView.image = image
                }
            }
            
            foodNameLabel.text = packagedFoodItem.name
            foodDetailsLabel.text = packagedFoodItem.details
            let calories = packagedFoodItem.nutrientsReference().calories()?.value.roundDigits(afterDecimal: 2) ?? 0
            foodDetailsLabel.text = "\(packagedFoodItem.amount.selectedQuantity) \(packagedFoodItem.amount.selectedUnit) | \(calories) \(UnitsTexts.cal)"
            
            checkImage.image = UIImage(systemName: foodLog.isSelected ? "circle.fill" : "circle")
            checkImage.tintColor = foodLog.isSelected ? .primaryColor : .gray300
            
        } else {
            foodNameLabel.text = ""
            foodDetailsLabel.text = ""
        }
    }
}
