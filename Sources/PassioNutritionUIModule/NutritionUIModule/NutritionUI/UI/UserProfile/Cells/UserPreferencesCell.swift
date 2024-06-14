//
//  MedicalInfoCell.swift
//  BaseApp
//
//  Created by Nikunj Prajapati on 27/07/22.
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import UIKit

final class UserPreferencesCell: UITableViewCell {

    @IBOutlet weak var containerView1: UIView!
    @IBOutlet weak var containerView2: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var weightGoalTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var heightButton: UIButton!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var genderButton   : UIButton!
    @IBOutlet weak var activityLvlTextField: UITextField!
    @IBOutlet weak var activityLevelButton: UIButton!
    @IBOutlet weak var calorieDeficitTextField: UITextField!
    @IBOutlet weak var calorieDeficitButton: UIButton!
    @IBOutlet weak var dietTextField: UITextField!
    @IBOutlet weak var dietButton: UIButton!
    @IBOutlet weak var waterLevelTextField: UITextField!
    @IBOutlet var userPreferencesTextFields: [UITextField]!

    override func awakeFromNib() {
        super.awakeFromNib()
        userPreferencesTextFields.forEach {
            $0.configureTextField()
            $0.autocorrectionType = .no
        }
        containerView1.dropShadow()
        containerView2.dropShadow()
    }
}

// MARK: - Configure Cell
extension UserPreferencesCell {

    func configureCell(userProfile: UserProfileModel?) {
      
        nameTextField.text = userProfile?.firstName ?? "-"
        
        let gender = userProfile?.gender ?? .male
        genderTextField.text = gender.rawValue.capitalizingFirst()
        
        if let weightDespription = userProfile?.weightDespription {
            weightTextField.text = weightDespription
        }
        if let goalWeightDespription = userProfile?.goalWeightDespription {
            weightGoalTextField.text = goalWeightDespription
        }
        if let heightDescription = userProfile?.heightDescription {
            heightTextField.text = heightDescription
        }
        if let ageDesription = userProfile?.ageDesription {
            ageTextField.text = ageDesription
        }
        if let activityLevel = userProfile?.activityLevel {
            activityLvlTextField.text = activityLevel.rawValue.localized
        }
        if let goalWeightTimeLine = userProfile?.goalWeightTimeLine {
            calorieDeficitTextField.text = goalWeightTimeLine.localized
        }
        if let mealPlan = userProfile?.mealPlan{
            dietTextField.text = mealPlan.mealPlanTitle ?? "" 
        } else {
            dietTextField.text = "-"
        }
        if let waterLevel = userProfile?.goalWaterDescription {
            waterLevelTextField.text = "\(waterLevel)"
        }
    }
}
