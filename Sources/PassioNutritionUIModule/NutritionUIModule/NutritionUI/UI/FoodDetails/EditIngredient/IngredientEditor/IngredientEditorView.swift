//
//  FoodEditorLegacyView
//  PassioPassport
//
//  Created by zvika on 3/25/19.
//  Copyright © 2023 PassioLife Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

protocol IngredientEditorViewDelegate: AnyObject {
    func ingredientEditedFoodItemData(ingredient: FoodRecordIngredient, atIndex: Int)
    func ingredientEditedCancel()
    func replaceFoodUsingSearch()
}

extension IngredientEditorViewDelegate {
    func ingredientEditedCancel() { }
    func replaceFoodUsingSearch() { }
}

class IngredientEditorView: UIView {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonSave: UIButton!

    let passioSDK = PassioNutritionAI.shared
    let connector = PassioInternalConnector.shared
    var cachedMaxForSlider = [Int: [String: Float]]()
    var indexOfIngredient = 0
    var isAddIngredient = false {
        didSet {
            buttonSave.setTitle(isAddIngredient ? ButtonTexts.addIngredient : ButtonTexts.save, for: .normal)
        }
    }

    var foodRecordIngredient: FoodRecordIngredient? {
        didSet {
            UIView.transition(with: tableView, duration: 0.1,
                              options: [.transitionCrossDissolve, .allowUserInteraction],
                              animations: {
                self.tableView.reloadData()
            })
        }
    }
    var alternatives: [PassioAlternative]? {
        return nil
    }

    weak var delegate: IngredientEditorViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        tableView.dataSource = self
        tableView.allowsSelection = true
        FoodDetailsCell.allCases.forEach {
            tableView.register(nibName: $0.rawValue.capitalizingFirst())
        }
        buttonCancel.setTitle(ButtonTexts.cancel, for: .normal)
        buttonCancel.setTitleColor(.primaryColor, for: .normal)
        buttonCancel.applyBorder(width: 2, color: .primaryColor)
        buttonSave.backgroundColor = .primaryColor
        buttonCancel.roundMyCornerWith(radius: 4)
        buttonSave.roundMyCornerWith(radius: 4)
    }

    // MARK: Button's Actions
    @objc func changeLabel(sender: UIButton) {
        guard let servingUnits = foodRecordIngredient?.servingUnits else { return }
        let items = servingUnits.map { return $0.unitName }
        let customPickerViewController = CustomPickerViewController()
        customPickerViewController.loadViewIfNeeded()
        customPickerViewController.pickerItems = items.map { PickerElement(title: $0) }
        if let frame = sender.superview?.convert(sender.frame, to: nil) {
            customPickerViewController.pickerFrame = CGRect(x: frame.origin.x - 5,
                                                            y: frame.origin.y + 50,
                                                            width: frame.width + 10,
                                                            height: 36 * Double(items.count))
        }
        customPickerViewController.delegate = self
        customPickerViewController.modalTransitionStyle = .crossDissolve
        customPickerViewController.modalPresentationStyle = .overFullScreen
        findViewController()?.present(customPickerViewController, animated: true, completion: nil)
    }

    @IBAction func saveIngredient(_ sender: UIButton) {
        if let foodItemData = foodRecordIngredient {
            delegate?.ingredientEditedFoodItemData(ingredient: foodItemData,
                                                   atIndex: indexOfIngredient)
        } else {
            delegate?.ingredientEditedCancel()
        }
    }

    @IBAction func cancel(_ sender: UIButton) {
        delegate?.ingredientEditedCancel()
    }
}

// MARK: - UITableViewDataSource
extension IngredientEditorView: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }

    func tableView(_ tableView: UITableView, 
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let _ = foodRecordIngredient else {
            return UITableViewCell()
        }
        switch indexPath.row {
        case 0:
            guard let foodIngrident = foodRecordIngredient else {
                return UITableViewCell()
            }
            let cell = tableView.dequeueCell(cellClass: FoodInfoTableViewCell.self, forIndexPath: indexPath)
            cell.setup(foodIngrident: foodIngrident)
            cell.openFoodFactsButton.addTarget(self,
                                               action: #selector(onOpenFoodFacts),
                                               for: .touchUpInside)
            cell.moreDetailsButton.addTarget(self,
                                             action: #selector(onMoreDetails),
                                             for: .touchUpInside)
            return cell

        case 1:
            let cell = tableView.dequeueCell(cellClass: ServingSizeTableViewCell.self, forIndexPath: indexPath)
            let (quantity, unitName, weight) = getAmountsforCell(tableRowOrCollectionTag: indexPath.row,
                                                                 slider: cell.sliderAmount)
            cell.setup(quantity: quantity, unitName: unitName, weight: weight)
            cell.textAmount.delegate = self
            cell.textAmount.addOkButtonToToolbar(target: self, action: #selector(closeKeyBoard), forEvent: .touchUpInside)
            cell.buttonUnits.addTarget(self, action: #selector(changeLabel(sender:)), for: .touchUpInside)
            cell.sliderAmount.addTarget(self, action: #selector(sliderAmountValueDidChange(sender:)), for: .valueChanged)
            return cell
        default:
           return UITableViewCell()
        }
    }
    
    @objc private func onOpenFoodFacts() {
        let popUpVC = PopUpViewController()
        popUpVC.modalTransitionStyle = .crossDissolve
        popUpVC.modalPresentationStyle = .overFullScreen
        findViewController()?.present(popUpVC, animated: true)
    }

    @objc private func onMoreDetails() {
        let nutritionInfoVC = NutritionInformationViewController()
        nutritionInfoVC.loadViewIfNeeded()
        nutritionInfoVC.foodData = getFoodData
        findViewController()?.navigationController?.pushViewController(nutritionInfoVC, animated: true)
    }

    var getFoodData: FoodData? {
        if let foodRecordIngredient {
            return FoodData(name: foodRecordIngredient.name,
                            barcode: foodRecordIngredient.barcode ?? "",
                            icon: getFoodImage,
                            nutritionInfo: MicroNutirents.getMicroNutrientsFromFood(records: [FoodRecordV3(foodRecordIngredient: foodRecordIngredient)]))
        }
        return nil
    }

    var getFoodImage: UIImage {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? FoodInfoTableViewCell
        return cell?.imageFood.image ?? UIImage()
    }

    @objc func dissmissPhoto(recognizer: UITapGestureRecognizer) {
        recognizer.view?.removeFromSuperview()
    }

    func getAmountsforCell(tableRowOrCollectionTag: Int, slider: UISlider) ->
    (quantity: Double, unitName: String, weight: String) {
        slider.minimumValue = 0.0
        slider.tag = tableRowOrCollectionTag
        guard let foodItemData = foodRecordIngredient else { return(100, UnitsTexts.cGrams, "100") }
        let sliderMultiplier: Float = 5.0
        let maxSliderFromData = Float(1) * sliderMultiplier
        let currentValue = Float(foodItemData.selectedQuantity)

        if cachedMaxForSlider[tableRowOrCollectionTag]?[foodItemData.selectedUnit] == nil {
            cachedMaxForSlider[tableRowOrCollectionTag] = [foodItemData.selectedUnit: sliderMultiplier * currentValue]
            slider.maximumValue = sliderMultiplier * currentValue
        } else if let maxFromCache = cachedMaxForSlider[tableRowOrCollectionTag]?[foodItemData.selectedUnit],
                  maxFromCache > maxSliderFromData, maxFromCache > currentValue {
            slider.maximumValue = maxFromCache
        } else  if maxSliderFromData > currentValue {
            slider.maximumValue = maxSliderFromData
        } else {
            slider.maximumValue = currentValue
            cachedMaxForSlider[tableRowOrCollectionTag] = [foodItemData.selectedUnit: currentValue]
        }
        slider.value = currentValue
        return (Double(currentValue), foodItemData.selectedUnit.capitalized,
                String(Int(foodItemData.computedWeight.value)))
    }

    @objc func sliderAmountValueDidChange(sender: UISlider) {
        let maxSlider = Int(sender.maximumValue)
        var sizeOfAtTick: Double
        switch maxSlider {
        case 0..<10:
            sizeOfAtTick = 0.5
        case 10..<100:
            sizeOfAtTick = 1
        case 100..<500:
            sizeOfAtTick = 1
        default:
            sizeOfAtTick = 10
        }
        let previousValue = foodRecordIngredient?.selectedQuantity
        var newValue = round(Double(sender.value)/sizeOfAtTick) * sizeOfAtTick
        guard newValue != previousValue else {
            return
        }
        if let unit = foodRecordIngredient?.selectedUnit {
            newValue = newValue == 0 ? sizeOfAtTick/1000 : newValue
            _ = foodRecordIngredient?.setFoodIngredientServing(unit: unit, quantity: newValue)
        }
        tableView.reloadData()
    }

    @objc func userPressedReplaceSearch() {
        delegate?.replaceFoodUsingSearch()
    }

    @objc private func closeKeyBoard(barButtonItem: UIBarButtonItem) {
        endEditing(true)
    }
}

extension IngredientEditorView: CustomPickerSelectionDelegate {

    func onPickerSelection(value: String, selectedIndex: Int, viewTag: Int) {
        _ = foodRecordIngredient?.setSelectedUnit(unit: value)
    }
}

extension IngredientEditorView: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if let text = textField.text, text.contains("."), string == "." {
            return false
        } else {
            return true
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        frame.origin.y += 180
        if let quantity = Double(textField.replaceCommaWithDot),
           var tempfoodItemData = foodRecordIngredient {
            _ = tempfoodItemData.setFoodIngredientServing(unit: tempfoodItemData.selectedUnit,
                                                          quantity: quantity)
            foodRecordIngredient = tempfoodItemData
        }
        tableView.reloadData()
    }
}
