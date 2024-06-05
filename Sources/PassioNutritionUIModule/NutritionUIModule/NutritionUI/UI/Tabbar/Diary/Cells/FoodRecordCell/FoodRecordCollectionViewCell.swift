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

class FoodRecordCollectionViewCell: SwipeCollectionViewCell {

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
    }

    override open func prepareForReuse() {
        super.prepareForReuse()
        invalidateIntrinsicContentSize()
    }

    func setup(_ foodRecord: FoodRecordV3) {

        labelName.text = foodRecord.name.capitalized
        labelServing.text = foodRecord.getServingInfo
        labelCalories.text = foodRecord.getCalories

        let pidForImage = foodRecord.iconId
        passioIDForCell = pidForImage

        imageFood.setFoodImage(id: foodRecord.iconId,
                               passioID: pidForImage,
                               entityType: foodRecord.entityType,
                               connector: PassioInternalConnector.shared) { [weak self] foodImage in
            DispatchQueue.main.async {
                self?.imageFood.image = foodImage
            }
        }
    }
}
