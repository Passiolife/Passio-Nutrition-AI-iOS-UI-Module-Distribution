//
//  OtherNutritionsTableViewCell.swift
//  BaseApp
//
//  Created by Nikunj Prajapati on 01/05/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit

final class OtherNutritionsTableViewCell: UITableViewCell {

    @IBOutlet weak var backgroundShadowView: UIView!
    @IBOutlet weak var selectNutrientTextField: UITextField!
    @IBOutlet weak var selectNutrientButton: UIButton!
    @IBOutlet weak var satFatStackView: UIStackView!
    @IBOutlet weak var satFatTextField: UITextField!
    @IBOutlet weak var transFatStackView: UIStackView!
    @IBOutlet weak var transFatTextField: UITextField!
    @IBOutlet weak var cholesterolStackView: UIStackView!
    @IBOutlet weak var cholesterolTextField: UITextField!
    @IBOutlet weak var sodiumStackView: UIStackView!
    @IBOutlet weak var sodiumTextField: UITextField!
    @IBOutlet weak var dietaryFiberStackView: UIStackView!
    @IBOutlet weak var dietaryFiberTextField: UITextField!
    @IBOutlet weak var totalSugarsStackView: UIStackView!
    @IBOutlet weak var totalSugarsTextField: UITextField!
    @IBOutlet weak var addedSugarStackView: UIStackView!
    @IBOutlet weak var addedSugarTextField: UITextField!
    @IBOutlet weak var vitaminDStackView: UIStackView!
    @IBOutlet weak var vitaminDTextField: UITextField!
    @IBOutlet weak var calciumStackView: UIStackView!
    @IBOutlet weak var calciumTextField: UITextField!
    @IBOutlet weak var ironStackView: UIStackView!
    @IBOutlet weak var ironTextField: UITextField!
    @IBOutlet weak var potassiumStackView: UIStackView!
    @IBOutlet weak var potassiumTextField: UITextField!

    private let optioanlNutrients = ["Saturated Fat",
                                     "Trans Fat",
                                     "Cholesterol",
                                     "Sodium",
                                     "Dietary Fiber",
                                     "Total Sugars",
                                     "Added Sugar",
                                     "Vitamin D",
                                     "Calcium",
                                     "Iron",
                                     "Potassium"]

    private var addedNutrients: [String] = []
    var foodDataSet: NutritionFactsDataSet?
    var reloadCell: (() -> Void)?
    weak var foodDataSetDelegate: FoodDataSetCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        configureSelectNutrientUI()

        [selectNutrientTextField,
         satFatTextField,
         transFatTextField,
         cholesterolTextField,
         sodiumTextField,
         dietaryFiberTextField,
         totalSugarsTextField,
         addedSugarTextField,
         vitaminDTextField,
         calciumTextField,
         ironTextField,
         potassiumTextField].forEach {
            $0.configureTextField(leftPadding: 13, radius: 6, borderColor: .gray300)
            $0.addOkButtonToToolbar(target: self, action: #selector(onOkTapped), forEvent: .touchUpInside)
            $0.delegate = self
        }
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

    @IBAction func onDeleteNutrition(_ sender: UIButton) {

        guard optioanlNutrients.indices.contains(sender.tag) else { return }
        guard let indexToRemove = addedNutrients.firstIndex(where: { $0 == optioanlNutrients[sender.tag] }) else { return }
        addedNutrients.remove(at: indexToRemove)
        manageNutrientViews(selectedIndex: sender.tag, text: "", isHidden: true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }

    // MARK: - Cell Helper
    func configureCell(with nutritionData: NutritionFactsDataSet) {

        foodDataSet = nutritionData

        setTextField(satFatTextField,
                     text: nutritionData.saturatedFat?.stringValue,
                     title: optioanlNutrients[0],
                     index: 0)
        setTextField(transFatTextField,
                     text: nutritionData.transFat?.stringValue,
                     title: optioanlNutrients[1],
                     index: 1)
        setTextField(cholesterolTextField,
                     text: nutritionData.cholesterol?.stringValue,
                     title: optioanlNutrients[2],
                     index: 2)
        setTextField(sodiumTextField,
                     text: nutritionData.sodium?.stringValue,
                     title: optioanlNutrients[3],
                     index: 3)
        setTextField(dietaryFiberTextField,
                     text: nutritionData.dietaryFiber?.stringValue,
                     title: optioanlNutrients[4],
                     index: 4)
        setTextField(totalSugarsTextField,
                     text: nutritionData.totalSugars?.stringValue,
                     title: optioanlNutrients[5],
                     index: 5)
        setTextField(addedSugarTextField,
                     text: nutritionData.addedSugar?.stringValue,
                     title: optioanlNutrients[6],
                     index: 6)
        setTextField(vitaminDTextField,
                     text: nutritionData.vitaminD?.stringValue,
                     title: optioanlNutrients[7],
                     index: 7)
        setTextField(calciumTextField,
                     text: nutritionData.calcium?.stringValue,
                     title: optioanlNutrients[8],
                     index: 8)
        setTextField(ironTextField,
                     text: nutritionData.iron?.stringValue,
                     title: optioanlNutrients[9],
                     index: 9)
        setTextField(potassiumTextField,
                     text: nutritionData.potassium?.stringValue,
                     title: optioanlNutrients[10],
                     index: 10)
    }

    private func setTextField(_ textField: UITextField, text: String?, title: String, index: Int) {
        if let text, !text.contains("-") {
            textField.text = text
            addedNutrients.append(title)
            manageNutrientViews(selectedIndex: index, text: text, isHidden: false)
        }
    }

    private func configureSelectNutrientUI() {

        let dropDownIcon = UIImage(systemName: "chevron.down")?.withTintColor(
            .gray400, renderingMode: .alwaysOriginal
        ).applyingSymbolConfiguration(.init(weight: .regular))

        selectNutrientTextField.addImageInTextField(isLeftImg: false,
                                                    image: dropDownIcon ?? UIImage(),
                                                    imageFrame: CGRect(x: 0,
                                                                       y: 0,
                                                                       width: 25,
                                                                       height: 13))
        configureNutrientPickerMenu()
    }

    private func configureNutrientPickerMenu() {

        // Menu Action
        let actionClosure = { [weak self] (action: UIAction) in
            guard let self else { return }
            guard let selectedIndex = optioanlNutrients.firstIndex(where: { $0 == action.title }) else {
                return
            }
            addedNutrients.append(action.title)
            manageNutrientViews(selectedIndex: selectedIndex, text: "", isHidden: false)
        }
        // Menu Items
        let menuChildren = optioanlNutrients.filter { !addedNutrients.contains($0) }.map { nutrients in
            UIAction(title: nutrients, handler: actionClosure)
        }
        // Add Menu into Button
        selectNutrientButton.menu = UIMenu(title: "", children: menuChildren)
        selectNutrientButton.showsMenuAsPrimaryAction = true
    }

    private func manageNutrientViews(selectedIndex: Int, text: String?, isHidden: Bool) {

        switch selectedIndex {
        case 0: 
            satFatStackView.isHidden = isHidden
            satFatTextField.text = text

        case 1:
            transFatStackView.isHidden = isHidden
            transFatTextField.text = text

        case 2:
            cholesterolStackView.isHidden = isHidden
            cholesterolTextField.text = text

        case 3: 
            sodiumStackView.isHidden = isHidden
            sodiumTextField.text = text

        case 4: 
            dietaryFiberStackView.isHidden = isHidden
            dietaryFiberTextField.text = text

        case 5: 
            totalSugarsStackView.isHidden = isHidden
            totalSugarsTextField.text = text

        case 6:
            addedSugarStackView.isHidden = isHidden
            addedSugarTextField.text = text

        case 7:
            vitaminDStackView.isHidden = isHidden
            vitaminDTextField.text = text

        case 8: 
            calciumStackView.isHidden = isHidden
            calciumTextField.text = text

        case 9:
            ironStackView.isHidden = isHidden
            ironTextField.text = text

        case 10:
            potassiumStackView.isHidden = isHidden
            potassiumTextField.text = text

        default:
            break
        }
        configureNutrientPickerMenu()
        reloadCell?()
        updateDataset(isHidden: isHidden)
    }

    @objc private func onOkTapped() {
        endEditing(true)
    }

    private func updateDataset(isHidden: Bool = false) {

        if let satFatString = satFatTextField.text?.replacingOccurrences(of: " \(UnitsTexts.g)", with: ""),
           let satFat = Double(satFatString) {
            foodDataSet?.updatedNutritionFacts?.saturatedFat = satFat
        } else if isHidden {
            foodDataSet?.updatedNutritionFacts?.saturatedFat = nil
        }
        if let transFatString = transFatTextField.text?.replacingOccurrences(of: " \(UnitsTexts.g)", with: ""),
           let transFat = Double(transFatString) {
            foodDataSet?.updatedNutritionFacts?.transFat = transFat
        } else if isHidden {
            foodDataSet?.updatedNutritionFacts?.transFat = nil
        }
        if let cholesterolString = cholesterolTextField.text?.replacingOccurrences(of: " \(UnitsTexts.mg)", with: ""),
           let cholesterol = Double(cholesterolString) {
            foodDataSet?.updatedNutritionFacts?.cholesterol = cholesterol
        } else if isHidden {
            foodDataSet?.updatedNutritionFacts?.cholesterol = nil
        }
        if let sodiumString = sodiumTextField.text?.replacingOccurrences(of: " \(UnitsTexts.mg)", with: ""),
           let sodium = Double(sodiumString) {
            foodDataSet?.updatedNutritionFacts?.sodium = sodium
        } else if isHidden {
            foodDataSet?.updatedNutritionFacts?.sodium = nil
        }
        if let dietaryFiberString = dietaryFiberTextField.text?.replacingOccurrences(of: " \(UnitsTexts.g)", with: ""),
           let dietaryFiber = Double(dietaryFiberString) {
            foodDataSet?.updatedNutritionFacts?.dietaryFiber = dietaryFiber
        } else if isHidden {
            foodDataSet?.updatedNutritionFacts?.dietaryFiber = nil
        }
        if let totalSugarsString = totalSugarsTextField.text?.replacingOccurrences(of: " \(UnitsTexts.g)", with: ""),
           let totalSugars = Double(totalSugarsString) {
            foodDataSet?.updatedNutritionFacts?.totalSugars = totalSugars
        } else if isHidden {
            foodDataSet?.updatedNutritionFacts?.totalSugars = nil
        }
        if let addedSugarString = addedSugarTextField.text?.replacingOccurrences(of: " \(UnitsTexts.g)", with: ""),
           let addedSugar = Double(addedSugarString) {
            foodDataSet?.updatedNutritionFacts?.addedSugar = addedSugar
        } else if isHidden {
            foodDataSet?.updatedNutritionFacts?.addedSugar = nil
        }
        if let vitaminDString = vitaminDTextField.text?.replacingOccurrences(of: " \(UnitsTexts.mcg)", with: ""),
           let vitaminD = Double(vitaminDString) {
            foodDataSet?.updatedNutritionFacts?.vitaminD = vitaminD
        } else if isHidden {
            foodDataSet?.updatedNutritionFacts?.vitaminD = nil
        }
        if let calciumString = calciumTextField.text?.replacingOccurrences(of: " \(UnitsTexts.mg)", with: ""),
           let calcium = Double(calciumString) {
            foodDataSet?.updatedNutritionFacts?.calcium = calcium
        } else if isHidden {
            foodDataSet?.updatedNutritionFacts?.calcium = nil
        }
        if let ironString = ironTextField.text?.replacingOccurrences(of: " \(UnitsTexts.mg)", with: ""),
           let iron = Double(ironString) {
            foodDataSet?.updatedNutritionFacts?.iron = iron
        } else if isHidden {
            foodDataSet?.updatedNutritionFacts?.iron = nil
        }
        if let potassiumString = potassiumTextField.text?.replacingOccurrences(of: " \(UnitsTexts.mg)", with: ""),
           let potassium = Double(potassiumString) {
            foodDataSet?.updatedNutritionFacts?.potassium = potassium
        } else if isHidden {
            foodDataSet?.updatedNutritionFacts?.potassium = nil
        }
        foodDataSetDelegate?.updateFoodDataSet(with: foodDataSet)
    }
}

// MARK: - UITexField Delgate
extension OtherNutritionsTableViewCell: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }

    func textFieldDidEndEditing(_ textField: UITextField) {

        switch textField {

        case satFatTextField:
            let satFatText = satFatTextField.replaceCommaWithDot
            satFatTextField.text = satFatText == "" ? foodDataSet?.saturatedFat?.stringValue : "\(satFatText) \(UnitsTexts.g)"

        case transFatTextField:
            let transFatText = transFatTextField.replaceCommaWithDot
            transFatTextField.text = transFatText == "" ? foodDataSet?.transFat?.stringValue : "\(transFatText) \(UnitsTexts.g)"

        case cholesterolTextField:
            let cholesterolText = cholesterolTextField.replaceCommaWithDot
            cholesterolTextField.text = cholesterolText == "" ? foodDataSet?.cholesterol?.stringValue : "\(cholesterolText) \(UnitsTexts.mg)"

        case sodiumTextField:
            let sodiumText = sodiumTextField.replaceCommaWithDot
            sodiumTextField.text = sodiumText == "" ? foodDataSet?.sodium?.stringValue : "\(sodiumText) \(UnitsTexts.mg)"

        case dietaryFiberTextField:
            let dietaryFiberText = dietaryFiberTextField.replaceCommaWithDot
            dietaryFiberTextField.text = dietaryFiberText == "" ? foodDataSet?.dietaryFiber?.stringValue : "\(dietaryFiberText) \(UnitsTexts.mg)"

        case totalSugarsTextField:
            let totalSugarsText = totalSugarsTextField.replaceCommaWithDot
            totalSugarsTextField.text = totalSugarsText == "" ? foodDataSet?.totalSugars?.stringValue : "\(totalSugarsText) \(UnitsTexts.g)"

        case addedSugarTextField:
            let addedSugarText = addedSugarTextField.replaceCommaWithDot
            addedSugarTextField.text = addedSugarText == "" ? foodDataSet?.addedSugar?.stringValue : "\(addedSugarText) \(UnitsTexts.g)"

        case vitaminDTextField:
            let vitaminDText = vitaminDTextField.replaceCommaWithDot
            vitaminDTextField.text = vitaminDText == "" ? foodDataSet?.vitaminD?.stringValue : "\(vitaminDText) \(UnitsTexts.mcg)"

        case calciumTextField:
            let calciumText = calciumTextField.replaceCommaWithDot
            calciumTextField.text = calciumText == "" ? foodDataSet?.calcium?.stringValue : "\(calciumText) \(UnitsTexts.mg)"

        case ironTextField:
            let ironText = ironTextField.replaceCommaWithDot
            ironTextField.text = ironText == "" ? foodDataSet?.iron?.stringValue : "\(ironText) \(UnitsTexts.mg)"

        case potassiumTextField:
            let potassiumText = potassiumTextField.replaceCommaWithDot
            potassiumTextField.text = potassiumText == "" ? foodDataSet?.potassium?.stringValue : "\(potassiumText) \(UnitsTexts.mg)"

        default:
            break
        }

        updateDataset()
    }
}
