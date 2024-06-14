//
//  IngredientHeaderTableViewself.swift
//  PassioPassport
//
//  Created by zvika on 2/14/19.
//  Copyright © 2023 PassioLife Inc. All rights reserved.
//

import UIKit

#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

class IngredientHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var imageFood: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelServing: UILabel!
    @IBOutlet weak var labelCalories: UILabel!
    @IBOutlet weak var insetBackground: UIView!
    var passioIDForCell: PassioID?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageFood?.roundMyCorner()
//        insetBackground?.roundMyCorner()
    }
    
    func setup(ingredient: FoodRecordIngredient){
        self.labelName.text = ingredient.name.capitalized
        let quantity = ingredient.selectedQuantity
        let unitName = ingredient.selectedUnit.capitalized
        let weight = String(Int(ingredient.computedWeight.value))
        let textAmount = quantity == Double(Int(quantity)) ? String(Int(quantity)) :
        String(quantity.roundDigits(afterDecimal: 2))
        let weightText = unitName == "g" ? "" : "(" + weight + " " + "g".localized + ") "
        self.labelServing.text = textAmount + " " + unitName + " " + weightText

        var calStr = "0"
        if let cal = ingredient.nutrients.calories()?.value, 0 < cal, cal < 1e6 {
            calStr = cal.roundDigits(afterDecimal: 0).clean
        }
        self.labelCalories.text = calStr + " cal"
        let imageId = ingredient.iconId
        self.passioIDForCell = imageId
        self.imageFood.loadPassioIconBy(passioID: imageId,
                                        entityType: ingredient.entityType) { passioIDForImage, image in
            if passioIDForImage == self.passioIDForCell {
                DispatchQueue.main.async {
                    self.imageFood.image = image
                }
            }
        }
        self.imageFood.roundMyCorner()
        self.selectionStyle = .none
        self.insetBackground.backgroundColor = .passioInsetColor
        self.contentView.roundMyCornerWith(radius: Custom.insetBackgroundRadius)
    }
}
