//
//  NAFoodItemCell.swift
//  
//
//  Created by Pratik on 17/09/24.
//

import UIKit

class NAFoodItemCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var foodInfoLabel: UILabel!
    @IBOutlet weak var radioButton: UIButton!
    @IBOutlet weak var tickImageView: UIImageView!

    var radioButtonTap: ((UIButton)->())? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        basicSetup()
    }
    
    func basicSetup() {
        self.selectionStyle = .none
        foodNameLabel.font = .inter(type: .semiBold, size: 13)
        foodInfoLabel.font = .inter(type: .regular, size: 12)
    }
    
    func load(foodItem: NAFoodItem, logStatus: LogStatus) {
        
        let advisorInfo = foodItem.food
        guard let foodInfo = advisorInfo.foodDataInfo else {
            foodImageView.image = nil
            foodNameLabel.text = "--"
            foodInfoLabel.text = "--"
            radioButton.isHidden = true
            tickImageView.isHidden = true
            return
        }

        // 1. Image
        foodImageView.setFoodImage(id: foodInfo.iconID,
                                   passioID: foodInfo.iconID,
                                   entityType: .item,
                                   connector: PassioInternalConnector.shared) { [weak self] image in
            DispatchQueue.main.async {
                self?.foodImageView.image = image
            }
        }
        
        // 2. Name
        foodNameLabel.text = foodInfo.foodName.capitalized
        
        // 3. Info
        if let nutritionPreview = foodInfo.nutritionPreview {
            let ratio = (Double(nutritionPreview.calories) / nutritionPreview.weightQuantity).roundDigits(afterDecimal: 2)
            foodInfoLabel.text = "\(advisorInfo.weightGrams) g | \((ratio * advisorInfo.weightGrams).roundDigits(afterDecimal: 2)) cal"
        } else {
            foodInfoLabel.text = ""
        }
        
        // 4. Radio button | Tick image
        
        switch logStatus {
            
        case .notLogged:
            tickImageView.isHidden = true
            radioButton.isHidden = false
            radioButton.isEnabled = true
            radioButton.isSelected = foodItem.isSelected
        
        case .logging:
            tickImageView.isHidden = true
            radioButton.isHidden = false
            radioButton.isEnabled = false
            radioButton.isSelected = foodItem.isSelected
            
        case .logged:
            tickImageView.isHidden = false
            radioButton.isHidden = true
        }
    }
    
    func updateRadioButton(isSelected: Bool) {
        UIView.transition(with: radioButton,
                          duration: 0.35,
                          options: .transitionCrossDissolve,
                          animations: {
            self.radioButton.isSelected = isSelected
        })
    }

    @IBAction func radioButtonTapped(_ sender: UIButton) {
        radioButtonTap?(sender)
    }
}
