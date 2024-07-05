//
//  EditNutritionGoalCell.swift
//  BaseApp
//
//  Created by Nikunj Prajapati on 14/03/22.
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import UIKit

final class DailyNutritionGoalsCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nutritionView: DonutProgressView!
    @IBOutlet weak var caloriesValueLabel: UILabel!
    @IBOutlet weak var carbsPercentLabel: UILabel!
    @IBOutlet weak var carbsValueLabel: UILabel!
    @IBOutlet weak var proteinPercentLabel: UILabel!
    @IBOutlet weak var proteinValueLabel: UILabel!
    @IBOutlet weak var fatPercentLabel: UILabel!
    @IBOutlet weak var fatValueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.dropShadow(radius: 8,
                                 offset: CGSize(width: 0, height: 1),
                                 color: .black.withAlphaComponent(0.06),
                                 shadowRadius: 2,
                                 shadowOpacity: 1)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds,
                                                      cornerRadius: 8).cgPath
    }

    func updateProfile(userProfile: UserProfileModel) {

        caloriesValueLabel.text = "\(userProfile.caloriesTarget)"
        carbsPercentLabel.text = "\(userProfile.carbsPercent)%"
        carbsValueLabel.text = "\(userProfile.carbsGrams) \(Localized.gramUnit)"
        proteinPercentLabel.text = "\(userProfile.proteinPercent)%"
        proteinValueLabel.text = "\(userProfile.proteinGrams) \(Localized.gramUnit)"
        fatPercentLabel.text = "\(userProfile.fatPercent)%"
        fatValueLabel.text = "\(userProfile.fatGrams) \(Localized.gramUnit)"

        let carbs = DonutProgressView.Datasource.init(label: "carbs",
                                                  color: .lightBlue,
                                                  percent: Double(userProfile.carbsPercent))
        let protein = DonutProgressView.Datasource.init(label: "protein",
                                                  color: .green500,
                                                  percent: Double(userProfile.proteinPercent))
        let fat = DonutProgressView.Datasource.init(label: "Fat",
                                                  color: .purple500,
                                                  percent: Double(userProfile.fatPercent))

        nutritionView.updateData(data: [carbs, protein, fat])
    }
}
