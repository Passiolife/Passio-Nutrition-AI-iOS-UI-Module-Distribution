//
//  WeightWaterCardCell.swift
//  Passio-Nutrition-AI-iOS-UI-Module
//
//  Created by Tushar S on 06/11/24.
//

import UIKit

final class WeightWaterCardCell: UITableViewCell {

    @IBOutlet private weak var waterDetailsContainerView: UIView!
    
    @IBOutlet private weak var waterTitleLabel: UILabel!
    @IBOutlet private weak var addWaterButton: UIButton!
    @IBOutlet private weak var waterGoalValueLabel: UILabel!
    @IBOutlet private weak var waterUnitLabel: UILabel!
    @IBOutlet weak var waterRemainToDailyGoalLabel: UILabel!
    
    @IBOutlet private weak var weightDetailsContainerView: UIView!
    @IBOutlet private weak var weightTitleLabel: UILabel!
    @IBOutlet private weak var addWeightButton: UIButton!
    @IBOutlet private weak var weightGoalValueLabel: UILabel!
    @IBOutlet private weak var weightUnitLabel: UILabel!
    @IBOutlet private weak var weightRemainToDailyGoalLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension WeightWaterCardCell {
    private func setupUI() {
        waterDetailsContainerView.roundMyCornerWith(radius: 8)
        weightDetailsContainerView.roundMyCornerWith(radius: 8)
        
        waterTitleLabel.text = "Water"
        weightTitleLabel.text = "Weight"
    }
    
    func configureUI() {
        let userProfile = UserManager.shared.user ?? UserProfileModel()
        
        waterGoalValueLabel.text = "\((userProfile.goalWater ?? 0).clean)"
        waterUnitLabel.text = "\(userProfile.waterUnit ?? .oz)"
        
        var remainWaterGoal = ""
        var remainWaterGoalFullText = ""
        if let goalWater = userProfile.goalWater {
            remainWaterGoal = "\((userProfile.goalWater ?? 0).clean) \(userProfile.waterUnit ?? .oz)"
            remainWaterGoalFullText = "\(remainWaterGoal) remain to daily goal"
        }
        
        var remainWeightGoal = ""
        var remainWeightGoalFullText = ""
        weightGoalValueLabel.text = "0"
        weightUnitLabel.text = "lbs"
        
        if let weightDespription = userProfile.goalWeightDespription {
            let weightDespriptionArr = weightDespription.split(separator: " ")
            if weightDespriptionArr.count > 2 {
                weightGoalValueLabel.text = "\(weightDespriptionArr[0])"
                weightUnitLabel.text = "\(weightDespriptionArr[1])"
            }
        }
        
        
        if let goalWeightRemain = userProfile.goalWeightRemainDespription {
            remainWeightGoal = "\(goalWeightRemain)"
            remainWeightGoalFullText = "\(remainWeightGoal) remain to daily goal"
        }
        
        
        waterRemainToDailyGoalLabel.setBoldAttributedText(boldText: remainWaterGoal, fullText: remainWaterGoalFullText, fontSize: 12)
        weightRemainToDailyGoalLabel.setBoldAttributedText(boldText: remainWeightGoal, fullText: remainWeightGoalFullText, fontSize: 12)
        
        if userProfile.goalWater == nil {
            self.waterDetailsContainerView.isHidden = true
        }
        
        if userProfile.goalWeight == nil {
            self.weightDetailsContainerView.isHidden = true
        }
        
    }
}
