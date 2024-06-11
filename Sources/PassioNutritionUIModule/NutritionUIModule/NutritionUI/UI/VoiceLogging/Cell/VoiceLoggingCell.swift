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

    func configureUI(foodInfo: PassioFoodDataInfo, isSelected: Bool) {

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
            let servingUnitQty = "\(nutritionPreview.servingQuantity) \(nutritionPreview.servingUnit)"
            foodDetailsLabel.text = "\(servingUnitQty) | \(nutritionPreview.calories) cal"
        } else {
            foodDetailsLabel.text = ""
        }

        checkImage.image = UIImage(systemName: isSelected ? "circle.fill" : "circle")
        checkImage.tintColor = isSelected ? .indigo600 : .gray300
    }
}
