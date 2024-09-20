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
    @IBOutlet weak var insetBackground: UIView!
    @IBOutlet weak var plusButton: UIButton!

    var passioIDForCell: PassioID?
    var onQuickAddFood: (() -> Void)?
    private var isFirstTime = true

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
        super.prepareForReuse()

        foodNameLabel.isHidden = false
        brandNameLabel.isHidden = false
        foodTypeImageView.image = nil
    }

    @IBAction func onQuickAddFood(_ sender: UIButton) {
        onQuickAddFood?()
    }

    // MARK: Configure Cell

    // Searching state setup
    func setup(state: SearchState) {

        foodImgView.clipsToBounds = false
        brandNameLabel.isHidden = true
        foodNameLabel.text = state.message
        foodImgView.image = state.image
        foodImgView.contentMode = .scaleAspectFit
        foodImgView.tintColor = .primaryColor
        foodTypeImageView.image = nil
        plusButton.isHidden = true

        if #available(iOS 17.0, *) {

            foodImgView.removeAllSymbolEffects()

            switch state {
            case .noResult, .searched:
                break
            case .startTyping:
                foodImgView.addSymbolEffect(.bounce.down.wholeSymbol,
                                            options: .speed(0.8))
            case .typing:
                foodImgView.addSymbolEffect(.variableColor.iterative.dimInactiveLayers.nonReversing,
                                            options: .speed(0.8))
            case .searching:
                foodImgView.addSymbolEffect(.pulse.byLayer,
                                            options: .repeating)
            }
        }
    }

    // Search Results
    func setup(passioFoodDataInfo: PassioFoodDataInfo,
               isFromSearch: Bool = false,
               isRecipe: Bool = false) {

        foodImgView.clipsToBounds = true
        foodImgView.image = nil

        if isFromSearch {
            foodTypeImageView.image = if isRecipe {
                UIImage(resource: .recipeSmall)
            } else {
                nil
            }
        } else {
            foodTypeImageView.image = nil
        }

        passioIDForCell = passioFoodDataInfo.iconID
        foodImgView.loadPassioIconBy(passioID: passioFoodDataInfo.iconID,
                                     entityType: .item) { passioIDForImage, image in
            if passioIDForImage == self.passioIDForCell {
                DispatchQueue.main.async {
                    self.foodImgView.image = image
                    self.foodImgView.contentMode = .scaleAspectFill
                }
            }
        }

        foodNameLabel.text = passioFoodDataInfo.foodName.capitalized
        brandNameLabel.text = passioFoodDataInfo.brandName.capitalized
        plusButton.isHidden = false
    }

    // My Foods
    func setup(foodRecord: FoodRecordV3,
               isFromSearch: Bool = false,
               isRecipe: Bool = false) {

        foodImgView.clipsToBounds = true

        if isFromSearch {
            foodTypeImageView.image = if isRecipe {
                UIImage(resource: .recipeSmall)
            } else {
                nil
            }
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
                self?.foodImgView.contentMode = .scaleAspectFill
            }
        }

        foodNameLabel.text = foodRecord.name
        brandNameLabel.text = foodRecord.details
        plusButton.isHidden = false
    }
}
