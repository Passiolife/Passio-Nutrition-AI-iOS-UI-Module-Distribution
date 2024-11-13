//
//  WeightWaterCardCell.swift
//  Passio-Nutrition-AI-iOS-UI-Module
//
//  Created by Tushar S on 06/11/24.
//

import UIKit

final class WaterWeightCardCell: UITableViewCell {

    @IBOutlet private weak var waterDetailsContainerView: UIView!
    
    @IBOutlet private weak var waterTitleLabel: UILabel!
    @IBOutlet private weak var addWaterButton: UIButton!
    @IBOutlet private weak var waterGoalValueLabel: UILabel!
    @IBOutlet private weak var waterRemainToDailyGoalLabel: UILabel!
    
    @IBOutlet private weak var weightDetailsContainerView: UIView!
    @IBOutlet private weak var weightTitleLabel: UILabel!
    @IBOutlet private weak var addWeightButton: UIButton!
    @IBOutlet private weak var weightGoalValueLabel: UILabel!
    @IBOutlet private weak var weightRemainToDailyGoalLabel: UILabel!
    
    var addWaterButtonAction: (() -> Void)? = nil
    var addWeightButtonAction: (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension WaterWeightCardCell {
    private func setupUI() {
        waterDetailsContainerView.roundMyCornerWith(radius: 8)
        weightDetailsContainerView.roundMyCornerWith(radius: 8)
        
        waterDetailsContainerView.dropShadow(radius: 8,
                              offset: CGSize(width: 0, height: 1),
                              color: .black.withAlphaComponent(0.06),
                              shadowRadius: 2,
                              shadowOpacity: 1)
        
        weightDetailsContainerView.dropShadow(radius: 8,
                              offset: CGSize(width: 0, height: 1),
                              color: .black.withAlphaComponent(0.06),
                              shadowRadius: 2,
                              shadowOpacity: 1)
        
        waterTitleLabel.text = "Water"
        weightTitleLabel.text = "Weight"
        
        addWaterButton.setTitle("", for: .normal)
        addWeightButton.setTitle("", for: .normal)
        
        addWaterButton.addTarget(self, action: #selector(addWaterButtonTap), for: .touchUpInside)
        addWeightButton.addTarget(self, action: #selector(addWeightButtonTap), for: .touchUpInside)
    }
    
    @objc private func addWaterButtonTap() {
        addWaterButtonAction?()
    }
    
    @objc private func addWeightButtonTap() {
        addWeightButtonAction?()
    }
    
    func configureUI(lastWeightRecord weightTrackingRecord: WeightTracking?) {
        let userProfile = UserManager.shared.user ?? UserProfileModel()
        
        // ****************************
        // *** Water Calculations ***
        // ****************************
        
        var remainWaterGoal = ""
        var remainWaterGoalFullText = ""
        let waterUnit = "\(userProfile.waterUnit ?? .oz)"
        var waterText = "0"
        var fullWaterText = "\(waterText) \(waterUnit)"
        
        if let goalWater = userProfile.goalWater {
            remainWaterGoal = "\((userProfile.goalWater ?? 0).clean) \(userProfile.waterUnit ?? .oz)"
            remainWaterGoalFullText = "\(remainWaterGoal) remain to daily goal"
        }
        
        waterGoalValueLabel.setAttributedTextWithColor(fullText: fullWaterText, highlights: [
            (text: waterText,textColor: .indigo600, font: UIFont.boldSystemFont(ofSize: 36)),
            (text: waterUnit,textColor: .gray500, font: UIFont.systemFont(ofSize: 17, weight: .semibold))
        ])
        
        waterRemainToDailyGoalLabel.setBoldAttributedText(boldText: remainWaterGoal, fullText: remainWaterGoalFullText, fontSize: 12)
        
        // ****************************
        // *** Weight Calculations ***
        // ****************************
        var remainWeightGoal = ""
        var remainWeightGoalFullText = ""
        let weightUnit = userProfile.selectedWeightUnit
        
        var weightText = "0"
        var fullWeightText = "\(weightText) \(weightUnit)"
        
        var subsctractValue = 0.0
        
        if let weightTrackingRecord = weightTrackingRecord,
           let dWeight = userProfile.goalWeight {
            let trackingWeight = userProfile.units == .imperial ? Double(weightTrackingRecord.weight * Conversion.lbsToKg.rawValue) : weightTrackingRecord.weight
            
            weightText = "\(trackingWeight.roundDigits(afterDecimal: 1).clean)"
            fullWeightText = "\(weightText) \(weightUnit)"
            
            let goalWeight = userProfile.units == .imperial ? Double(dWeight * Conversion.lbsToKg.rawValue) : dWeight

            subsctractValue = goalWeight - trackingWeight
            
            if subsctractValue < 0 {
                subsctractValue = 0
            }
            
            remainWeightGoal = "\(subsctractValue.roundDigits(afterDecimal: 1).clean) \(weightUnit)"
            remainWeightGoalFullText = "\(remainWeightGoal) remain to daily goal"
        }
        else {
            if let dWeight = userProfile.goalWeight {
                let goalWeight = userProfile.units == .imperial ? Double(dWeight * Conversion.lbsToKg.rawValue) : dWeight
                remainWeightGoal = "\(goalWeight.roundDigits(afterDecimal: 1).clean) \(weightUnit)"
                remainWeightGoalFullText = "\(remainWeightGoal) remain to daily goal"
            }
        }
        
        weightGoalValueLabel.setAttributedTextWithColor(fullText: fullWeightText, highlights: [
            (text: weightText,textColor: .indigo600, font: UIFont.boldSystemFont(ofSize: 36)),
            (text: weightUnit,textColor: .gray500, font: UIFont.systemFont(ofSize: 17, weight: .semibold))
        ])
        
        weightRemainToDailyGoalLabel.setBoldAttributedText(boldText: remainWeightGoal, fullText: remainWeightGoalFullText, fontSize: 12)
        
        
        if userProfile.goalWater == nil || (userProfile.goalWater ?? 0) < 0 {
            self.waterDetailsContainerView.isHidden = true
        }
        else {
            self.waterDetailsContainerView.isHidden = false
        }
        
        if userProfile.goalWeight == nil || (userProfile.goalWeight ?? 0) < 0 {
            self.weightDetailsContainerView.isHidden = true
        }
        else {
            self.weightDetailsContainerView.isHidden = false
        }
        
    }
}
