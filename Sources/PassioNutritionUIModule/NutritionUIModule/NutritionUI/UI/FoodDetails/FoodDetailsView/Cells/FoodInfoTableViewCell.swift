//
//  FoodHeaderMiniTableViewself.swift
//  PassioPassport
//
//  Created by zvika on 2/14/19.
//  Copyright © 2023 PassioLife Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

class FoodInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var imageFood: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelShortName: UILabel!
    @IBOutlet weak var nutritionView: DonutProgressView!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var carbsLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var protienLabel: UILabel!
    @IBOutlet weak var carbsPercentLabel: UILabel!
    @IBOutlet weak var fatPercentLabel: UILabel!
    @IBOutlet weak var protienPercentLabel: UILabel!
    @IBOutlet weak var insetBackground: UIView!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var openFoodFactsButton: UIButton!
    @IBOutlet weak var moreDetailsButton: UIButton!

    var passioIDForCell: PassioID?

    override func awakeFromNib() {
        super.awakeFromNib()

        openFoodFactsButton.setTitleColor(.primaryColor, for: .normal)
        moreDetailsButton.setTitleColor(.primaryColor, for: .normal)
        openFoodFactsButton.underline()
        moreDetailsButton.underline()
        imageFood.roundMyCorner()
        insetBackground.roundMyCornerWith(radius: 8)
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

    func setup(foodRecord: FoodRecordV3) {

        labelName.text = foodRecord.name
        labelShortName.text = foodRecord.details

        if labelName.text?.lowercased() == self.labelShortName.text?.lowercased()
            || foodRecord.entityType == .recipe {
            labelShortName.isHidden = true
        } else {
            labelShortName.isHidden = false
        }

        let pidForImage = foodRecord.iconId == "" ? foodRecord.passioID : foodRecord.iconId
        passioIDForCell = pidForImage

        imageFood.setFoodImage(id: foodRecord.iconId,
                               passioID: pidForImage,
                               entityType: foodRecord.entityType,
                               connector: PassioInternalConnector.shared) { [weak self] foodImage in
            DispatchQueue.main.async {
                self?.imageFood.image = foodImage
            }
        }

        imageFood.isUserInteractionEnabled = false
        imageFood.roundMyCorner()

        openFoodFactsButton.isHidden = !foodRecord.isOpenFood

        let percents = macronutrientPercentages(carbsG: foodRecord.totalCarbs,
                                                fatG: foodRecord.totalFat,
                                                proteinG: foodRecord.totalProteins,
                                                totalCalories: foodRecord.totalCalories)
        let c = DonutProgressView.Datasource(color: .lightBlue,
                                             percent: percents.carbPercentage)
        let p = DonutProgressView.Datasource(color: .green500,
                                             percent: percents.proteinPercentage)
        let f = DonutProgressView.Datasource(color: .purple500,
                                             percent: percents.fatPercentage)

        nutritionView.updateData(data: [c,p,f])
        caloriesLabel.text = foodRecord.totalCalories.roundDigits(afterDecimal: 0).clean
        carbsLabel.text = foodRecord.totalCarbs.roundDigits(afterDecimal: 1).clean + " \(UnitsTexts.g)"
        protienLabel.text = foodRecord.totalProteins.roundDigits(afterDecimal: 1).clean + " \(UnitsTexts.g)"
        fatLabel.text = foodRecord.totalFat.roundDigits(afterDecimal: 1).clean + " \(UnitsTexts.g)"

        let total = [c,p,f].reduce(0, { $0 + $1.percent })
        if total > 0 {
            fatPercentLabel.text = "(\(f.percent.roundDigits(afterDecimal: 1).clean)%)"
            protienPercentLabel.text = "(\(p.percent.roundDigits(afterDecimal: 1).clean)%)"
            carbsPercentLabel.text = "(\(c.percent.roundDigits(afterDecimal: 1).clean)%)"
        } else {
            fatPercentLabel.text = "(0%)"
            protienPercentLabel.text = "(0%)"
            carbsPercentLabel.text = "(0%)"
        }
    }

    func setup(foodIngrident: FoodRecordIngredient) {

        favouriteButton.isHidden = true
        labelName.text = foodIngrident.name.capitalized
        labelShortName.text = foodIngrident.details

        let pidForImage = foodIngrident.iconId
        passioIDForCell = pidForImage
        imageFood.setFoodImage(id: foodIngrident.iconId,
                               passioID: pidForImage,
                               entityType: foodIngrident.entityType,
                               connector: PassioInternalConnector.shared) { [weak self] foodImage in
            DispatchQueue.main.async {
                self?.imageFood.image = foodImage
            }
        }

        imageFood.isUserInteractionEnabled = false
        imageFood.roundMyCorner()
        selectionStyle = .none

        openFoodFactsButton.isHidden = !foodIngrident.isOpenFood

        let percents = macronutrientPercentages(carbsG: foodIngrident.totalCarbs,
                                                fatG: foodIngrident.totalFat,
                                                proteinG: foodIngrident.totalProteins,
                                                totalCalories: foodIngrident.totalCalories)
        let c = DonutProgressView.Datasource.init(color: .lightBlue,
                                                  percent: percents.carbPercentage)
        let p = DonutProgressView.Datasource.init(color: .green500,
                                                  percent: percents.proteinPercentage)
        let f = DonutProgressView.Datasource.init(color: .purple500,
                                                  percent: percents.fatPercentage)

        nutritionView.updateData(data: [c,p,f])
        caloriesLabel.text = foodIngrident.totalCalories.roundDigits(afterDecimal: 0).clean
        carbsLabel.text = foodIngrident.totalCarbs.roundDigits(afterDecimal: 1).clean + " \(UnitsTexts.g)"
        protienLabel.text = foodIngrident.totalProteins.roundDigits(afterDecimal: 1).clean + " \(UnitsTexts.g)"
        fatLabel.text = foodIngrident.totalFat.roundDigits(afterDecimal: 1).clean + " \(UnitsTexts.g)"

        let total = [c,p,f].reduce(0, {$0 + $1.percent})
        if total > 0 {
            fatPercentLabel.text = "(\(f.percent.roundDigits(afterDecimal: 1).clean)%)"
            protienPercentLabel.text = "(\(p.percent.roundDigits(afterDecimal: 1).clean)%)"
            carbsPercentLabel.text = "(\(c.percent.roundDigits(afterDecimal: 1).clean)%)"
        } else{
            fatPercentLabel.text = "(0%)"
            protienPercentLabel.text = "(0%)"
            carbsPercentLabel.text = "(0%)"
        }
    }

    func macronutrientPercentages(carbsG: Double,
                                  fatG: Double,
                                  proteinG: Double,
                                  totalCalories: Double) -> (carbPercentage: Double,
                                                             fatPercentage: Double,
                                                             proteinPercentage: Double) {
        // Calculate calories contributed by each macronutrient
        let carbCalories = carbsG * 4
        let fatCalories = fatG * 9
        let proteinCalories = proteinG * 4

        // Calculate total calories from macronutrients
        let totalMacronutrientCalories = carbCalories + fatCalories + proteinCalories

        // Calculate percentages
        let carbPercentage = (carbCalories / totalMacronutrientCalories) * 100
        let fatPercentage = (fatCalories / totalMacronutrientCalories) * 100
        let proteinPercentage = (proteinCalories / totalMacronutrientCalories) * 100

        return (carbPercentage: carbPercentage,
                fatPercentage: fatPercentage,
                proteinPercentage: proteinPercentage)
    }
}
