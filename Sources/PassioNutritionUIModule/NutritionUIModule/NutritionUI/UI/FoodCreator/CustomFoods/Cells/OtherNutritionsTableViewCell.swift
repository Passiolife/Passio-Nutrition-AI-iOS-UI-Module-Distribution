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
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        DispatchQueue.main.async {
            self.backgroundShadowView.dropShadow(radius: 8,
                                                 offset: CGSize(width: 0, height: 1),
                                                 color: .black.withAlphaComponent(0.10),
                                                 shadowRadius: 3,
                                                 shadowOpacity: 1,
                                                 useShadowPath: true)
        }
    }

    @IBAction func onDeleteNutrition(_ sender: UIButton) {
        guard optioanlNutrients.indices.contains(sender.tag) else { return }
        guard let indexToRemove = addedNutrients.firstIndex(where: { $0 == optioanlNutrients[sender.tag] }) else { return }
        addedNutrients.remove(at: indexToRemove)
        manageNutrientViews(selectedIndex: sender.tag, isHidden: true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }

    // MARK: - Cell Helper
    func configureCell(with nutritionData: NutritionFactsDataSet) {

        foodDataSet = nutritionData

        setTextField(satFatTextField,
                     text: foodDataSet?.saturatedFat?.stringValue,
                     title: optioanlNutrients[0],
                     index: 0)
        setTextField(transFatTextField,
                     text: foodDataSet?.transFat?.stringValue,
                     title: optioanlNutrients[1],
                     index: 1)
        setTextField(cholesterolTextField,
                     text: foodDataSet?.cholesterol?.stringValue,
                     title: optioanlNutrients[2],
                     index: 2)
        setTextField(sodiumTextField,
                     text: foodDataSet?.sodium?.stringValue,
                     title: optioanlNutrients[3],
                     index: 3)
        setTextField(dietaryFiberTextField,
                     text: foodDataSet?.dietaryFiber?.stringValue,
                     title: optioanlNutrients[4],
                     index: 4)
        setTextField(totalSugarsTextField,
                     text: foodDataSet?.totalSugars?.stringValue,
                     title: optioanlNutrients[5],
                     index: 5)
        setTextField(addedSugarTextField,
                     text: foodDataSet?.addedSugar?.stringValue,
                     title: optioanlNutrients[6],
                     index: 6)
        setTextField(vitaminDTextField,
                     text: foodDataSet?.vitaminD?.stringValue,
                     title: optioanlNutrients[7],
                     index: 7)
        setTextField(calciumTextField,
                     text: foodDataSet?.calcium?.stringValue,
                     title: optioanlNutrients[8],
                     index: 8)
        setTextField(ironTextField,
                     text: foodDataSet?.iron?.stringValue,
                     title: optioanlNutrients[9],
                     index: 9)
        setTextField(potassiumTextField,
                     text: foodDataSet?.potassium?.stringValue,
                     title: optioanlNutrients[10],
                     index: 10)
    }

    private func setTextField(_ textField: UITextField, text: String?, title: String, index: Int) {
        if let text, !text.contains("-") {
            textField.text = text
            addedNutrients.append(title)
            manageNutrientViews(selectedIndex: index, isHidden: false)
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
            manageNutrientViews(selectedIndex: selectedIndex, isHidden: false)
        }
        // Menu Items
        let menuChildren = optioanlNutrients.filter { !addedNutrients.contains($0) }.map { nutrients in
            UIAction(title: nutrients, handler: actionClosure)
        }
        // Add Menu into Button
        selectNutrientButton.menu = UIMenu(title: "", children: menuChildren)
        selectNutrientButton.showsMenuAsPrimaryAction = true
    }

    private func manageNutrientViews(selectedIndex: Int, isHidden: Bool) {
        switch selectedIndex {
        case 0: satFatStackView.isHidden = isHidden
        case 1: transFatStackView.isHidden = isHidden
        case 2: cholesterolStackView.isHidden = isHidden
        case 3: sodiumStackView.isHidden = isHidden
        case 4: dietaryFiberStackView.isHidden = isHidden
        case 5: totalSugarsStackView.isHidden = isHidden
        case 6: addedSugarStackView.isHidden = isHidden
        case 7: vitaminDStackView.isHidden = isHidden
        case 8: calciumStackView.isHidden = isHidden
        case 9: ironStackView.isHidden = isHidden
        case 10: potassiumStackView.isHidden = isHidden
        default:
            break
        }
        configureNutrientPickerMenu()
        reloadCell?()
    }

    @objc private func onOkTapped() {
        endEditing(true)
    }

    private func updateDataset() {

        if let satFatString = satFatTextField.text?.replacingOccurrences(of: " g", with: ""),
           let satFat = Double(satFatString) {
            foodDataSet?.updatedNutritionFacts?.saturatedFat = satFat
        }
        if let transFatString = transFatTextField.text?.replacingOccurrences(of: " g", with: ""),
           let transFat = Double(transFatString) {
            foodDataSet?.updatedNutritionFacts?.transFat = transFat
        }
        if let cholesterolString = cholesterolTextField.text?.replacingOccurrences(of: " mg", with: ""),
           let cholesterol = Double(cholesterolString) {
            foodDataSet?.updatedNutritionFacts?.cholesterol = cholesterol
        }
        if let sodiumString = sodiumTextField.text?.replacingOccurrences(of: " mg", with: ""),
           let sodium = Double(sodiumString) {
            foodDataSet?.updatedNutritionFacts?.sodium = sodium
        }
        if let dietaryFiberString = dietaryFiberTextField.text?.replacingOccurrences(of: " g", with: ""),
           let dietaryFiber = Double(dietaryFiberString) {
            foodDataSet?.updatedNutritionFacts?.dietaryFiber = dietaryFiber
        }
        if let totalSugarsString = totalSugarsTextField.text?.replacingOccurrences(of: " g", with: ""),
           let totalSugars = Double(totalSugarsString) {
            foodDataSet?.updatedNutritionFacts?.totalSugars = totalSugars
        }
        if let addedSugarString = addedSugarTextField.text?.replacingOccurrences(of: " g", with: ""),
           let addedSugar = Double(addedSugarString) {
            foodDataSet?.updatedNutritionFacts?.addedSugar = addedSugar
        }
        if let vitaminDString = vitaminDTextField.text?.replacingOccurrences(of: " mcg", with: ""),
           let vitaminD = Double(vitaminDString) {
            foodDataSet?.updatedNutritionFacts?.vitaminD = vitaminD
        }
        if let calciumString = calciumTextField.text?.replacingOccurrences(of: " mg", with: ""),
           let calcium = Double(calciumString) {
            foodDataSet?.updatedNutritionFacts?.calcium = calcium
        }
        if let ironString = ironTextField.text?.replacingOccurrences(of: " mg", with: ""),
           let iron = Double(ironString) {
            foodDataSet?.updatedNutritionFacts?.iron = iron
        }
        if let potassiumString = potassiumTextField.text?.replacingOccurrences(of: " mg", with: ""),
           let potassium = Double(potassiumString) {
            foodDataSet?.updatedNutritionFacts?.potassium = potassium
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
            let satFatText = satFatTextField.text ?? ""
            satFatTextField.text = satFatText == "" ? foodDataSet?.saturatedFat?.stringValue : "\(satFatText) g"

        case transFatTextField:
            let transFatText = transFatTextField.text ?? ""
            transFatTextField.text = transFatText == "" ? foodDataSet?.transFat?.stringValue : "\(transFatText) g"

        case cholesterolTextField:
            let cholesterolText = cholesterolTextField.text ?? ""
            cholesterolTextField.text = cholesterolText == "" ? foodDataSet?.cholesterol?.stringValue : "\(cholesterolText) mg"

        case sodiumTextField:
            let sodiumText = sodiumTextField.text ?? ""
            sodiumTextField.text = sodiumText == "" ? foodDataSet?.sodium?.stringValue : "\(sodiumText) mg"

        case dietaryFiberTextField:
            let dietaryFiberText = dietaryFiberTextField.text ?? ""
            dietaryFiberTextField.text = dietaryFiberText == "" ? foodDataSet?.dietaryFiber?.stringValue : "\(dietaryFiberText) g"

        case totalSugarsTextField:
            let totalSugarsText = totalSugarsTextField.text ?? ""
            totalSugarsTextField.text = totalSugarsText == "" ? foodDataSet?.totalSugars?.stringValue : "\(totalSugarsText) g"

        case addedSugarTextField:
            let addedSugarText = addedSugarTextField.text ?? ""
            addedSugarTextField.text = addedSugarText == "" ? foodDataSet?.addedSugar?.stringValue : "\(addedSugarText) g"

        case vitaminDTextField:
            let vitaminDText = vitaminDTextField.text ?? ""
            vitaminDTextField.text = vitaminDText == "" ? foodDataSet?.vitaminD?.stringValue : "\(vitaminDText) mcg"

        case calciumTextField:
            let calciumText = calciumTextField.text ?? ""
            calciumTextField.text = calciumText == "" ? foodDataSet?.calcium?.stringValue : "\(calciumText) mg"

        case ironTextField:
            let ironText = ironTextField.text ?? ""
            ironTextField.text = ironText == "" ? foodDataSet?.iron?.stringValue : "\(ironText) mg"

        case potassiumTextField:
            let potassiumText = potassiumTextField.text ?? ""
            potassiumTextField.text = potassiumText == "" ? foodDataSet?.potassium?.stringValue : "\(potassiumText) mg"

        default:
            break
        }

        updateDataset()
    }
}
