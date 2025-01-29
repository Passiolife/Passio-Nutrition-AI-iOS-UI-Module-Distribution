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

class IngredientInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var imageFood: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelServing: UILabel!
    @IBOutlet weak var labelCalories: UILabel!
    @IBOutlet weak var insetBackground: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    var passioIDForCell: PassioID?
    private var isLastCell = false

    override func awakeFromNib() {
        super.awakeFromNib()

        imageFood.roundMyCorner()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        DispatchQueue.main.async { [self] in
            insetBackground.dropShadow(radius: isLastCell ? 8 : 0,
                                       offset: CGSize(width: 0, height: 1),
                                       color: .black.withAlphaComponent(0.06),
                                       shadowRadius: 2,
                                       shadowOpacity: isLastCell ? 1 : 0,
                                       istopBottomRadius: isLastCell ? true : false,
                                       isDownRadius: isLastCell ? true : false)
            insetBackground.layer.shadowPath = UIBezierPath(
                roundedRect: isLastCell ? insetBackground.bounds : .zero,
                cornerRadius: isLastCell ? 8 : 0
            ).cgPath
        }
    }

    func setup(ingredient: FoodRecordIngredient, isLastCell: Bool) {

        self.isLastCell = isLastCell
        bottomConstraint.constant = isLastCell ? 2 : 0
        labelName.text = ingredient.name.capitalized
        let quantity = ingredient.selectedQuantity
        let unitName = ingredient.selectedUnit.capitalized
        let weight = String(Int(ingredient.computedWeight.value))
        let textAmount = quantity == Double(Int(quantity)) ? String(Int(quantity)) :
        String(quantity.roundDigits(afterDecimal: 2))
        let weightText = unitName == UnitsTexts.g ? "" : "(" + weight + " " + UnitsTexts.g + ") "
        labelServing.text = textAmount + " " + unitName + " " + weightText

        var calStr = "0"
        if let cal = ingredient.nutrients.calories()?.value, 0 < cal, cal < 1e6 {
            calStr = cal.roundDigits(afterDecimal: 0).clean
        }
        labelCalories.text = calStr + " \(UnitsTexts.cal)"

        let imageId = ingredient.iconId
        passioIDForCell = imageId

        imageFood.setFoodImage(id: imageId,
                               passioID: imageId,
                               entityType: ingredient.entityType,
                               connector: NutritionUIModule.shared) { image in
            DispatchQueue.main.async {
                self.imageFood.image = image
            }
        }
    }
}
