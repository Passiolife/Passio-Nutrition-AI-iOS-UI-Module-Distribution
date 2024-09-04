//
//  RequiredNutritionsTableViewCell.swift
//  BaseApp
//
//  Created by Nikunj Prajapati on 01/05/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit

final class RequiredNutritionsTableViewCell: UITableViewCell {

    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var weightButton: UIButton!
    @IBOutlet weak var unitButton: UIButton!
    @IBOutlet weak var weightStackView: UIStackView!
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

    private let units = [UnitsTexts.serving,
                         UnitsTexts.piece,
                         UnitsTexts.cup,
                         UnitsTexts.oz,
                         UnitsTexts.gram,
                         UnitsTexts.ml,
                         UnitsTexts.small,
                         UnitsTexts.medium,
                         UnitsTexts.large,
                         UnitsTexts.handful,
                         UnitsTexts.scoop,
                         UnitsTexts.tbsp,
                         UnitsTexts.tsp,
                         UnitsTexts.slice,
                         UnitsTexts.can,
                         UnitsTexts.bottle,
                         UnitsTexts.bar,
                         UnitsTexts.packet]
    private let weights = [UnitsTexts.ml, UnitsTexts.g]
    private let g = UnitsTexts.g
    private let ml = UnitsTexts.ml

    override func awakeFromNib() {
        super.awakeFromNib()

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
        weightButton.semanticContentAttribute = .forceRightToLeft
        configureUnitPickerMenu()
        configureWeightPickerMenu()

        backgroundShadowView.dropShadow(radius: 8,
                                        offset: CGSize(width: 0, height: 1),
                                        color: .black.withAlphaComponent(0.06),
                                        shadowRadius: 2,
                                        shadowOpacity: 1)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundShadowView.layer.shadowPath = UIBezierPath(roundedRect: backgroundShadowView.bounds,
                                                             cornerRadius: 8).cgPath
    }
}

// MARK: - Cell Helper
extension RequiredNutritionsTableViewCell {

    func configureCell(with nutritionData: NutritionFactsDataSet,
                       isCreateNewFood: Bool,
                       isFromNutritionFacts: Bool) {

        foodDataSet = nutritionData

        if isCreateNewFood && !isFromNutritionFacts { return }

        servingSizeTextField.text = (nutritionData.nutritionFacts?.servingSizeQuantity.roundDigits(afterDecimal: 2).clean ?? "")
        unitsTextField.text = (nutritionData.nutritionFacts?.servingSizeUnitName?.capitalized ?? "")
        setWeightStackView(unit: unitsTextField.text)
        weightTextField.text = (nutritionData.nutritionFacts?.servingSizeGram?.roundDigits(afterDecimal: 2).clean ?? "?") + " \(UnitsTexts.g)"
        caloriesTextField.text = nutritionData.calories?.stringValue
        carbsTextField.text = nutritionData.carbs?.stringValue
        proteinTextField.text = nutritionData.protein?.stringValue
        fatTextField.text = nutritionData.fat?.stringValue
    }

    private func setWeightStackView(unit: String? = "") {
        let isGramsOrMl = unit == "\(UnitsTexts.gram)" || unit == ml
        weightStackView.isHidden = isGramsOrMl
        weightButton.isHidden = isGramsOrMl
        weightLabel.isHidden = isGramsOrMl
        weightTextField.text = isGramsOrMl ? "" : weightTextField.text
    }

    private func configureUnitPickerMenu() {
        let actionClosure = { [weak self] (action: UIAction) in
            guard let self else { return }
            guard units.firstIndex(where: { $0 == action.title }) != nil else {
                return
            }
            unitsTextField.text = action.title
            setWeightStackView(unit: action.title)
            foodDataSet?.updatedNutritionFacts?.servingSizeGram = nil
            updateDataset()
        }
        let menuChildren = units.map { unit in
            UIAction(title: unit, handler: actionClosure)
        }
        unitButton.menu = UIMenu(title: "", children: menuChildren)
        unitButton.showsMenuAsPrimaryAction = true
    }

    private func configureWeightPickerMenu() {
        let actionClosure = { [weak self] (action: UIAction) in
            guard let self else { return }
            guard weights.firstIndex(where: { $0 == action.title }) != nil else {
                return
            }
            weightLabel.text = action.title
            setWeight()
            updateDataset()
        }
        let menuChildren = weights.map { unit in
            UIAction(title: unit, handler: actionClosure)
        }
        weightButton.menu = UIMenu(title: "", children: menuChildren)
        weightButton.showsMenuAsPrimaryAction = true
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
            errors.append("Serving Unit")
        }
        if let weightString = weightTextField.getText(replacing: "\(weightLabel.text ?? g)"),
           let weight = Double(weightString), weight == 0 {
            if unitsTextField.text != g && unitsTextField.text != ml {
                errors.append("Weight")
            }
        }
        if let calorieString = caloriesTextField.getText(replacing: "\(UnitsTexts.cal)"),
           let _ = Double(calorieString) {

        } else if let calorieString = caloriesTextField.getText(replacing: "kcal"),
                   let _ = Double(calorieString) {

        } else {
            errors.append("Calories")
        }
        if let carbString = carbsTextField.getText(replacing: g),
           let _ = Double(carbString) { } else {
               errors.append("Carbs")
           }
        if let proteinString = proteinTextField.getText(replacing: g),
           let _ = Double(proteinString) { } else {
               errors.append("Protein")
           }
        if let fatString = fatTextField.getText(replacing: g),
           let _ = Double(fatString) { } else {
               errors.append("Fat")
           }

        if errors.count > 0 {
            return (false, "Please enter valid \(errors.joined(separator: ", ")).")
        } else {
            return (true, nil)
        }
    }

    private func updateDataset(currentTextField: UITextField? = nil) {

        if let servings = Double(servingSizeTextField.text ?? "") {
            foodDataSet?.updatedNutritionFacts?.servingSizeQuantity = servings
        }
        if let unit = unitsTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), unit != "" {
            foodDataSet?.updatedNutritionFacts?.servingSizeUnitName = unit
        }
        if let calories = Double((caloriesTextField.text ?? "").replacingOccurrences(of: " \(UnitsTexts.cal)", with: "")) {
            foodDataSet?.updatedNutritionFacts?.calories = calories
        }
        if let carbString = carbsTextField.getText(replacing: g),
           let carbs = Double(carbString) {
            foodDataSet?.updatedNutritionFacts?.carbs = carbs
        }
        if let weightString = weightTextField.getText(replacing: "\(weightLabel.text ?? g)"),
           let weight = Double(weightString) {
            foodDataSet?.updatedNutritionFacts?.servingSizeGram = weight
        } else if let currentTextField = currentTextField, currentTextField == weightTextField {
            foodDataSet?.updatedNutritionFacts?.servingSizeGram = Double(servingSizeTextField.text ?? "")
        }
        if let proteinString = proteinTextField.getText(replacing: g),
           let protein = Double(proteinString) {
            foodDataSet?.updatedNutritionFacts?.protein = protein
        }
        if let fatString = fatTextField.getText(replacing: g),
           let fats = Double(fatString) {
                foodDataSet?.updatedNutritionFacts?.fat = fats
        }
        foodDataSetDelegate?.updateFoodDataSet(with: foodDataSet)
    }

    private func setWeight() {
        let weightValue = weightTextField.text?.separateStringUsingSpace.0 ?? ""
        weightTextField.text = weightValue
        let weightType = weightLabel.text ?? g == ml ? ml : g
        let weight = foodDataSet?.nutritionFacts?.servingSizeGram.roundDigits(afterDecimal: 2)?.clean ?? ""
        let servingSizeGram = if weight == "" {
            ""
        } else {
            weight + " \(weightType)"
        }
        weightTextField.text = (weightTextField.text ?? "") == "" ? servingSizeGram : "\(weightTextField.text ?? "") \(weightType)"
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

        case servingSizeTextField:
            servingSizeTextField.text = servingSizeTextField.replaceCommaWithDot

        case unitsTextField:
            break

        case weightTextField:
            let weightText = weightTextField.replaceCommaWithDot
            let weightType = weightLabel.text ?? g == ml ? ml : g
            let weight = foodDataSet?.nutritionFacts?.servingSizeGram.roundDigits(afterDecimal: 2)?.clean ?? ""
            let servingSizeGram = if weight == "" {
                ""
            } else {
                weight + " \(weightType)"
            }
            weightLabel.text = weightType
            weightTextField.text = weightText == "" ? servingSizeGram : "\(weightTextField.text ?? "") \(weightType)"

        case caloriesTextField:
            let caloriesText = caloriesTextField.replaceCommaWithDot
            caloriesTextField.text = caloriesText == "" ? foodDataSet?.calories?.stringValue : "\(caloriesText) \(UnitsTexts.cal)"

        case carbsTextField:
            let carbsText = carbsTextField.replaceCommaWithDot
            carbsTextField.text = carbsText == "" ? foodDataSet?.carbs?.stringValue : "\(carbsText) \(g)"

        case proteinTextField:
            let proteinText = proteinTextField.replaceCommaWithDot
            proteinTextField.text = proteinText == "" ? foodDataSet?.protein?.stringValue : "\(proteinText) \(g)"

        case fatTextField:
            let fatText = fatTextField.replaceCommaWithDot
            fatTextField.text = fatText == "" ? foodDataSet?.fat?.stringValue : "\(fatText) \(g)"

        default:
            break
        }

        updateDataset(currentTextField: textField)
    }
}
