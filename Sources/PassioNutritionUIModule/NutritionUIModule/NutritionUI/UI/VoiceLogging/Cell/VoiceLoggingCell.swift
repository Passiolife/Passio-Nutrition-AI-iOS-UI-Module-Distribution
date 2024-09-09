//
//  VoiceLoggingCell.swift
//  
//
//  Created by nikunj Prajapati on 10/06/24.
//

import UIKit

class VoiceLoggingCell: UITableViewCell {

    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var foodDetailsLabel: UILabel!
    @IBOutlet weak var checkImage: UIImageView!

    func configureUI(with foodLog: FoodLog) {

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

                let ratio = (Double(nutritionPreview.calories) / nutritionPreview.weightQuantity).roundDigits(afterDecimal: 2)
                foodDetailsLabel.text = "\(advisorInfo.weightGrams) g | \((ratio * advisorInfo.weightGrams).roundDigits(afterDecimal: 2)) cal"

            } else {
                foodDetailsLabel.text = ""
            }

            checkImage.image = UIImage(systemName: foodLog.isSelected ? "circle.fill" : "circle")
            checkImage.tintColor = foodLog.isSelected ? .primaryColor : .gray300
        } else {
            foodNameLabel.text = ""
            foodDetailsLabel.text = ""
        }
    }
}
