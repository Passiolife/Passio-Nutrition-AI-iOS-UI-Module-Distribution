//
//  LogFoodItemTableViewCell.swift
//  
//
//  Created by Davido Hyer on 6/24/24.
//

import UIKit

class LogFoodItemTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var radioImage: UIImageView!
    
    func setup(info: PassioAdvisorFoodInfo) {
        var details = info.portionSize
        if let cal = info.foodDataInfo.nutritionPreview?.calories {
            details.append(" | \(cal) cal")
        }
        infoLabel.text = details
        
        nameLabel.text = info.recognisedName
        
        let icon = PassioCoreSDK.shared.iconURLFor(passioID: info.foodDataInfo.iconID,
                                                   size: .px360)
        foodImage.loadPassioIconBy(passioID: info.foodDataInfo.iconID,
                                   entityType: .item) { [weak self] id, image in
            self?.foodImage.image = image
        }
    }
}
