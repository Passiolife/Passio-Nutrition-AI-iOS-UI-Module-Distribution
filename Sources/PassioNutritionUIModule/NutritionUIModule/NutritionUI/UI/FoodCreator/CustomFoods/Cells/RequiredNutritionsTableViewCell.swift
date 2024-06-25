//
//  RequiredNutritionsTableViewCell.swift
//  BaseApp
//
//  Created by Nikunj Prajapati on 01/05/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit

final class RequiredNutritionsTableViewCell: UITableViewCell {

    @IBOutlet weak var backgroundShadowView: UIView!
    @IBOutlet weak var servingSizeTextField : UITextField!
    @IBOutlet weak var unitsTextField : UITextField!
    @IBOutlet weak var weightTextField : UITextField!
    @IBOutlet weak var caloriesTextField : UITextField!
    @IBOutlet weak var fatTextField : UITextField!
    @IBOutlet weak var carbsTextField : UITextField!
    @IBOutlet weak var proteinTextField : UITextField!

    var foodDataSet: NutritionFactsDataSet?
    weak var foodDataSetDelegate: FoodDataSetCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        // Shadow
        DispatchQueue.main.async {
            self.backgroundShadowView.dropShadow(radius: 8,
                                                 offset: CGSize(width: 0, height: 1),
                                                 color: .black.withAlphaComponent(0.10),
                                                 shadowRadius: 3,
                                                 shadowOpacity: 1,
                                                 useShadowPath: true)
        }
        // Configure TextField
        [servingSizeTextField,
         unitsTextField,
         weightTextField,
         caloriesTextField,
         fatTextField,
         carbsTextField,
         proteinTextField].forEach {
            $0.delegate = self
            $0.configureTextField(leftPadding: 13, radius: 6, borderColor: .gray300)
            $0.addOkButtonToToolbar(target: self, action: #selector(onOkTapped), forEvent: .touchUpInside)
        }
    }
}

// MARK: - Cell Helper
extension RequiredNutritionsTableViewCell {

    func configureCell(with nutritionData: NutritionFactsDataSet, isCreateNewFood: Bool) {

        foodDataSet = nutritionData

        if isCreateNewFood { return }

        servingSizeTextField.text = (nutritionData.nutritionFacts?.servingSizeQuantity.roundDigits(afterDecimal: 2).clean ?? "")
        unitsTextField.text = (nutritionData.nutritionFacts?.servingSizeUnitName ?? "")
        weightTextField.text = (nutritionData.nutritionFacts?.servingSizeGram?.roundDigits(afterDecimal: 2).clean ?? "?") + " g"
        caloriesTextField.text = nutritionData.calories?.stringValue
        carbsTextField.text = nutritionData.carbs?.stringValue
        proteinTextField.text = nutritionData.protein?.stringValue
        fatTextField.text = nutritionData.fat?.stringValue
    }

    @objc private func onOkTapped() {
        endEditing(true)
    }

    var isRequiredNutritionsValid: (Bool, String?) {

        var errors = [String]()

        if let servings = Double(servingSizeTextField.text ?? ""),
           servings == 0 {
            errors.append("Serving Size")
        }
        if let unit = unitsTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), unit == "" {
            errors.append("serving unit")
        }
        if let weightString = weightTextField.text?.replacingOccurrences(of: " g", with: ""),
           let weight = Double(weightString), weight == 0 {
            errors.append("weight")
        }

        if let calorieString = caloriesTextField.text?.replacingOccurrences(of: " kcal", with: ""),
           let _ = Double(calorieString) { } else {
               errors.append("calories")
           }
        if let carbString = carbsTextField.text?.replacingOccurrences(of: " g", with: ""),
           let _ = Double(carbString) { } else {
               errors.append("carbs")
           }
        if let proteinString = proteinTextField.text?.replacingOccurrences(of: " g", with: ""),
           let _ = Double(proteinString) { } else {
               errors.append("protein")
           }
        if let fatString = fatTextField.text?.replacingOccurrences(of: " g", with: ""),
           let _ = Double(fatString) { } else {
               errors.append("fat")
           }

        if errors.count > 0 {
            return (false, "Please enter valid \(errors.joined(separator: ", ")).")
        } else {
            return (true, nil)
        }
    }

    private func updateDataset() {

        if let servings = Double(servingSizeTextField.text ?? "") {
            foodDataSet?.updatedNutritionFacts?.servingSizeQuantity = servings
        }
        if let unit = unitsTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            foodDataSet?.updatedNutritionFacts?.servingSizeUnitName = unit
        }
        if let calories = Double((caloriesTextField.text ?? "").replacingOccurrences(of: " kcal", with: "")) {
            foodDataSet?.updatedNutritionFacts?.calories = calories
        }
        if let carbString = carbsTextField.text?.replacingOccurrences(of: " g", with: ""),
           let carbs = Double(carbString) {
            foodDataSet?.updatedNutritionFacts?.carbs = carbs
        }
        if let weightString = weightTextField.text?.replacingOccurrences(of: " g", with: ""),
           let weight = Double(weightString) {
            foodDataSet?.updatedNutritionFacts?.servingSizeGram = weight
        }
        if let proteinString = proteinTextField.text?.replacingOccurrences(of: " g", with: ""),
           let protein = Double(proteinString) {
            foodDataSet?.updatedNutritionFacts?.protein = protein
        }
        if let fatString = fatTextField.text?.replacingOccurrences(of: " g", with: ""),
           let fats = Double(fatString) {
            foodDataSet?.updatedNutritionFacts?.fat = fats
        }
        foodDataSetDelegate?.updateFoodDataSet(with: foodDataSet)
    }
}

// MARK: - UITexField Delgate
extension RequiredNutritionsTableViewCell: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0:
            servingSizeTextField.resignFirstResponder()
            unitsTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField != servingSizeTextField, textField != unitsTextField {
            textField.text = ""
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {

        switch textField {
        case servingSizeTextField, unitsTextField:
            break

        case weightTextField:
            let weightText = weightTextField.text ?? ""
            let servingSizeGram = (foodDataSet?.nutritionFacts?.servingSizeGram.roundDigits(afterDecimal: 2)?.clean ?? "") + " g"
            weightTextField.text = weightText == "" ? servingSizeGram : "\(self.weightTextField.text ?? "") g"

        case caloriesTextField:
            let caloriesText = caloriesTextField.text ?? ""
            caloriesTextField.text = caloriesText == "" ? foodDataSet?.calories?.stringValue : "\(caloriesText) kcal"

        case carbsTextField:
            let carbsText = carbsTextField.text ?? ""
            carbsTextField.text = carbsText == "" ? foodDataSet?.carbs?.stringValue : "\(carbsText) g"

        case proteinTextField:
            let proteinText = proteinTextField.text ?? ""
            proteinTextField.text = proteinText == "" ? foodDataSet?.protein?.stringValue : "\(proteinText) g"

        case fatTextField:
            let fatText = fatTextField.text ?? ""
            fatTextField.text = fatText == "" ? foodDataSet?.fat?.stringValue : "\(fatText) g"

        default:
            break
        }

        updateDataset()
    }
}
