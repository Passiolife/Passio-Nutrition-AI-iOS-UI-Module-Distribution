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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var insetBackground: UIView!
    @IBOutlet weak var plusButton: UIButton!

    var passioIDForCell: PassioID?
    var onQuickAddFood: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        foodNameLabel.font = .inter(type: .semiBold, size: 14)
        foodNameLabel.textColor = .gray900
        brandNameLabel.font = .inter(type: .regular, size: 14)
        brandNameLabel.textColor = .gray500
        insetBackground.roundMyCornerWith(radius: 8)
        foodImgView.roundMyCorner()
        insetBackground.dropShadow(radius: 8,
                              offset: CGSize(width: 0, height: 1),
                              color: .black.withAlphaComponent(0.06),
                              shadowRadius: 2,
                              shadowOpacity: 1)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        DispatchQueue.main.async { [self] in
            insetBackground.layer.shadowPath = UIBezierPath(roundedRect: insetBackground.bounds,
                                                            cornerRadius: 8).cgPath
        }
    }

    override func prepareForReuse() {
        foodNameLabel.isHidden = false
        brandNameLabel.isHidden = false
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }

    @IBAction func onQuickAddFood(_ sender: UIButton) {
        onQuickAddFood?()
    }

    func setup(state: AdvancedTextSearchView.SearchState) {

        brandNameLabel.isHidden = true
        foodTypeImageView.image = nil

        foodImgView.image = state.image
        foodImgView.tintColor = .primaryColor
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
        plusButton.isHidden = false
    }

    func setup(foodRecord: FoodRecordV3,
               isFromSearch: Bool = false,
               isFavorite: Bool = false,
               isRecipe: Bool = false) {

        if isFromSearch {
            foodTypeImageView.image = isFavorite ? UIImage(resource: .favorites) : isRecipe ? UIImage(resource: .recipeSmall) : nil
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
        plusButton.isHidden = false
    }
}
