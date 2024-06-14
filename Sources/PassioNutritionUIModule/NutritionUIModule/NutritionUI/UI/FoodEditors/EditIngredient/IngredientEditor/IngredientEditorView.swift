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
    func startNutritionBrowser(foodItemData: FoodRecordIngredient)
    func replaceFoodUsingSearch()
}

class IngredientEditorView: UIView {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonSave: UIButton!

    let passioSDK = PassioNutritionAI.shared
    let connector = PassioInternalConnector.shared

    var indexOfIngredient = 0

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
        // TODO: Fix PassioAlternative
//        guard let foodItemData = foodItemData else {
//            return nil
//        }
//        let tempAlternatives = (foodItemData.parents ?? []) +
//        (foodItemData.children ?? []) +
//        (foodItemData.siblings ?? [])
//
//        return tempAlternatives.isEmpty ? nil : tempAlternatives
        return nil
    }

    weak var delegate: IngredientEditorViewDelegate?

    var cachedMaxForSlider = [Int: [String: Float]]()

//    var userProfile = UserProfileModel()

    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.dataSource = self
        tableView.allowsSelection = true
        CellNameFoodEditor.allCases.forEach {
            tableView.register(nibName: $0.rawValue.capitalizingFirst())
        }
        buttonCancel.setTitle( "Cancel", for: .normal)
        buttonSave.setTitle( "Save", for: .normal)
        buttonCancel.roundMyCornerWith(radius: Custom.buttonCornerRadius)
        buttonSave.roundMyCornerWith(radius: Custom.buttonCornerRadius)
    }

    // MARK: Button Actions.
    @objc func changeLabel(sender: UIButton ) {
        guard let servingUnits = foodRecordIngredient?.servingUnits else { return }
        let items = servingUnits.map { return $0.unitName }
        let customPickerViewController = CustomPickerViewController()
        customPickerViewController.loadViewIfNeeded()
        customPickerViewController.pickerItems = items.map({PickerElement.init(title: $0)})
        if let frame = sender.superview?.convert(sender.frame, to: nil) {
            customPickerViewController.pickerFrame = CGRect(x: frame.origin.x - 5,
                                                            y: frame.origin.y + 50,
                                                            width: frame.width + 10,
                                                            height: 42.5 * Double(items.count))
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

extension IngredientEditorView: UITableViewDataSource {

    func tableView(_ tableView: UITableView, 
                   numberOfRowsInSection section: Int) -> Int {
//        guard // let alternatives = alternatives,
//            let _ =  foodRecordIngredient else {
//            return 0
//        }
        return 2
    }

    func tableView(_ tableView: UITableView, 
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let _ = foodRecordIngredient else {
            return UITableViewCell()
        }
        switch indexPath.row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FoodHeaderSimpleTableViewCell",
                                                           for: indexPath) as? FoodHeaderSimpleTableViewCell,
                  let foodIngrident = foodRecordIngredient else {
                return UITableViewCell()
            }
            cell.setup(foodIngrident: foodIngrident)
            cell.nutritionInfoButton.addTarget(self, action: #selector(showNutritionInformation), for: .touchUpInside)
            return cell

        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AmountSliderFullTableViewCell",
                                                           for: indexPath) as? AmountSliderFullTableViewCell else {
                return UITableViewCell()
            }
            let (quantity, unitName, weight) = getAmountsforCell(tableRowOrCollectionTag: indexPath.row,
                                                                 slider: cell.sliderAmount)
            cell.setup(quantity: quantity, unitName: unitName, weight: weight)
            cell.textAmount.delegate = self
            cell.buttonUnits.addTarget(self, action: #selector(changeLabel(sender:)), for: .touchUpInside)
            cell.sliderAmount.addTarget(self, action: #selector(sliderAmountValueDidChange(sender:)), for: .valueChanged)
            return cell
        default:
           return UITableViewCell()
        }
    }
    
    @objc private func showNutritionInformation() {
        let popUpVC = PopUpViewController()
        popUpVC.modalTransitionStyle = .crossDissolve
        popUpVC.modalPresentationStyle = .overFullScreen
        findViewController()?.present(popUpVC, animated: true)
    }

    @objc func dissmissPhoto(recognizer: UITapGestureRecognizer) {
        recognizer.view?.removeFromSuperview()
    }

    func getAmountsforCell(tableRowOrCollectionTag: Int, slider: UISlider) ->
    (quantity: Double, unitName: String, weight: String) {
        slider.minimumValue = 0.0
        slider.tag = tableRowOrCollectionTag
        guard let foodItemData = foodRecordIngredient else { return(0, "error", "0") }
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

    @objc func startNutritionBrowser() {
        if let foodItemData = foodRecordIngredient {
            delegate?.startNutritionBrowser(foodItemData: foodItemData)
        }
    }

    @objc func userPressedReplaceSearch() {
        delegate?.replaceFoodUsingSearch()
    }
}

extension IngredientEditorView: CustomPickerSelectionDelegate {

    func onPickerSelection(value: String, selectedIndex: Int, viewTag: Int) {
        _ = foodRecordIngredient?.setServingUnitKeepWeight(unitName: value)
    }
}

extension IngredientEditorView: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let nFrame = CGRect(x: 0, y: 0, width: frame.size.width, height: 44)
        let kbToolBarView = UIToolbar.init(frame: nFrame)
        let kbSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                       target: nil, action: nil)
        let bottonOk = UIBarButtonItem(title: "OK".localized, style: .plain, target: self,
                                       action: #selector(closeKeyBoard(barButtonItem:)))
        bottonOk.tag = textField.tag
        kbToolBarView.items = [kbSpacer, bottonOk, kbSpacer]
        kbToolBarView.tintColor = .white
        kbToolBarView.barTintColor = .customBase
        textField.inputAccessoryView = kbToolBarView
        frame.origin.y -= 180
        return true
    }

    @objc func closeKeyBoard(barButtonItem: UIBarButtonItem) {
        if let fvc = self.findViewController() {
            fvc.view.endEditing(true)
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if let text = textField.text, text.contains("."), string == "." {
            return false
        } else {// if let text = textField.text, text.count =< 5 {
            return true
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        frame.origin.y += 180
        if let textGerman = textField.text {
            let text = textGerman.replacingOccurrences(of: ",", with: ".")
            if let quantity = Double(text),
               var tempfoodItemData = foodRecordIngredient {
                _ = tempfoodItemData.setFoodIngredientServing(unit: tempfoodItemData.selectedUnit,
                                                                quantity: quantity)
                foodRecordIngredient = tempfoodItemData
            }
        }
        tableView.reloadData()
    }
}
