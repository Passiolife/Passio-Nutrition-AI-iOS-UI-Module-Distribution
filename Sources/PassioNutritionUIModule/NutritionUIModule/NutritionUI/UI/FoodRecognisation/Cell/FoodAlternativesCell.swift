//
//  FoodAlternativesCell.swift
//  BaseApp
//
//  Created by Harsh on 21/02/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif


class FoodAlternativesCell: UITableViewCell {

    @IBOutlet weak var labelFoodName: UILabel!
    @IBOutlet weak var imageFoodIcon: UIImageView!

    var onQuickAddAlternative: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        imageFoodIcon.roundMyCorner()
        selectionStyle = .none
    }

    @IBAction func onQuickAddAlternative(_ sender: UIButton) {
        onQuickAddAlternative?()
    }

    func setupNameAndImage(name: String, passioID: String){
        self.labelFoodName.text = name.capitalized
        self.imageFoodIcon.loadPassioIconBy(passioID: passioID, entityType: PassioIDEntityType.item) { id, image in
            DispatchQueue.main.async {
                self.imageFoodIcon.image = image
            }
        }
    }
}
