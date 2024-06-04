//
//  AdvancedTextSearchCell.swift
//  NutritionAISDK
//
//  Created by Nikunj Prajapati on 22/12/23.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

class AdvancedTextSearchCell: UITableViewCell {

    @IBOutlet weak var foodImgView: UIImageView!
    @IBOutlet weak var foodTypeImageView: UIImageView!
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var brandNameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var insetBackground: UIView!
    @IBOutlet weak var plusButton: UIButton!

    var passioIDForCell: PassioID?
    var onQuickAddFood: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        insetBackground.roundMyCornerWith(radius: 8)
        foodImgView.roundMyCorner()
        insetBackground.dropShadow()
    }

    @IBAction func onQuickAddFood(_ sender: UIButton) {
        onQuickAddFood?()
    }

    func setup(state: AdvancedTextSearchView.SearchState) {

        brandNameLabel.isHidden = true
        scoreLabel.isHidden = true
        foodTypeImageView.image = nil

        foodImgView.image = state.image
        foodNameLabel.text = state.message

        if state == .searching {
            activityIndicator.startRotating()
        }

        plusButton.isHidden = true
    }

    func setup(foodResult: PassioFoodDataInfo) {

        foodTypeImageView.image = nil

        passioIDForCell = foodResult.iconID
        foodImgView.loadPassioIconBy(passioID: foodResult.iconID,
                                     entityType: .item) { passioIDForImage, image in
            if passioIDForImage == self.passioIDForCell {
                DispatchQueue.main.async {
                    self.foodImgView.image = image
                }
            }
        }

        foodNameLabel.text = foodResult.foodName.capitalized
        brandNameLabel.text = foodResult.brandName.capitalized
        scoreLabel.isHidden = true
        plusButton.isHidden = false
    }

    func setup(foodRecord: FoodRecordV3,
               isFromSearch: Bool = false,
               isFavorite: Bool = false) {

        if isFromSearch {
            foodTypeImageView.image = isFavorite ? UIImage(resource: .favorites) : UIImage(resource: .customFood)
        } else {
            foodTypeImageView.image = nil
        }

        passioIDForCell = foodRecord.iconId
        foodImgView.setFoodImage(id: foodRecord.iconId,
                               passioID: foodRecord.iconId,
                               entityType: foodRecord.entityType,
                               connector: PassioInternalConnector.shared) { [weak self] foodImage in
            DispatchQueue.main.async {
                self?.foodImgView.image = foodImage
            }
        }

        foodNameLabel.text = foodRecord.name
        brandNameLabel.text = foodRecord.details
        scoreLabel.isHidden = true
        plusButton.isHidden = false
    }

    override func prepareForReuse() {
        foodNameLabel.isHidden = false
        brandNameLabel.isHidden = false
        scoreLabel.isHidden = true
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
}
