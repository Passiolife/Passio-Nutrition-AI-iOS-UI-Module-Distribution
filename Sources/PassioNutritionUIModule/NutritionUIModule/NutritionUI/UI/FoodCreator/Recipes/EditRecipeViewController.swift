//
//  EditRecipeViewController.swift
//  
//
//  Created by Nikunj Prajapati on 01/07/24.
//

import UIKit

class EditRecipeViewController: InstantiableViewController {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var editRecipeTableView: UITableView!

    private var isAddIngredient = true
    private var cachedMaxForSlider: [String: Float] = [:]
    private enum EditRecipeCell: String, CaseIterable {
        case recipeDetailsCell,
             amountSliderFullTableViewCell,
             ingredientAddTableViewCell,
             ingredientHeaderTableViewCell
    }
    private let editRecipeSections: [EditRecipeCell] = [.recipeDetailsCell,
                                                        .amountSliderFullTableViewCell,
                                                        .ingredientAddTableViewCell,
                                                        .ingredientHeaderTableViewCell]
    var isCreate = true
    var recipe: FoodRecordV3? {
        didSet {
            DispatchQueue.main.async { [self] in
                saveButton.enableDisableButton(isEnabled: recipe?.ingredients.count ?? 1 > 1)
                editRecipeTableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupBackButton()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        recipe?.name = getRecipeDetailsCell?.recipeNameTextField.text ?? ""
    }

    @IBAction func onCancel(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func onSave(_ sender: UIButton) {
        if var recipe, let getRecipeDetailsCell {
            recipe.name = getRecipeDetailsCell.recipeNameTextField.text ?? ""
            recipe.iconId = "Recipe.\(recipe.iconId)"
            PassioInternalConnector.shared.updateRecipe(record: recipe)
            PassioInternalConnector.shared.updateUserFoodImage(
                with: recipe.iconId,
                image: getRecipeDetailsCell.recipeImageView.image?.get180pImage ?? UIImage()
            )
            navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - Configure
extension EditRecipeViewController {

    private func configureUI() {

        title = "Edit Recipe"
        editRecipeTableView.dataSource = self
        editRecipeTableView.delegate = self
        EditRecipeCell.allCases.forEach {
            editRecipeTableView.register(nibName: $0.rawValue.capitalizingFirst())
        }
        cancelButton.applyBorder(width: 2, color: .primaryColor)
        cancelButton.setTitleColor(.primaryColor, for: .normal)
        saveButton.backgroundColor = .primaryColor
    }

    private var getRecipeDetailsCell: RecipeDetailsCell? {
        editRecipeTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? RecipeDetailsCell
    }

    // MARK: Cell Helper
    private func getAmountsforCell(slider: UISlider) -> (quantity: Double,
                                                         unitName: String,
                                                         weight: String) {
        slider.minimumValue = 0.0
        guard let foodRecord = recipe else { return(0, "error", "0") }
        let sliderMultiplier: Float = 5.0
        let maxSliderFromData = Float(1) * sliderMultiplier
        let currentValue = Float(foodRecord.selectedQuantity)

        if cachedMaxForSlider[foodRecord.selectedUnit] == nil {
            cachedMaxForSlider = [foodRecord.selectedUnit: sliderMultiplier * currentValue]
            slider.maximumValue = sliderMultiplier * currentValue
        } else if let maxFromCache = cachedMaxForSlider[foodRecord.selectedUnit],
                  maxFromCache > maxSliderFromData, maxFromCache > currentValue {
            slider.maximumValue = maxFromCache
        } else if maxSliderFromData > currentValue {
            slider.maximumValue = maxSliderFromData
        } else {
            slider.maximumValue = currentValue
            cachedMaxForSlider = [foodRecord.selectedUnit: currentValue]
        }
        slider.value = currentValue
        return (Double(currentValue),
                foodRecord.selectedUnit.capitalizingFirst(),
                String(foodRecord.computedWeight.value.roundDigits(afterDecimal: 1).clean))
    }

    @objc private func changeLabel(sender: UIButton) {
        guard let servingUnits = recipe?.servingUnits else { return }
        let items = servingUnits.map { return $0.unitName }
        let customPickerViewController = CustomPickerViewController()
        customPickerViewController.loadViewIfNeeded()
        customPickerViewController.pickerItems = items.map({ item in
            return PickerElement.init(title: item)
        })
        if let frame = sender.superview?.convert(sender.frame, to: nil) {
            customPickerViewController.pickerFrame = CGRect(x: frame.origin.x - 5,
                                                            y: frame.origin.y + 50,
                                                            width: frame.width + 10,
                                                            height: 36 * Double(items.count))
        }
        customPickerViewController.delegate = self
        customPickerViewController.modalTransitionStyle = .crossDissolve
        customPickerViewController.modalPresentationStyle = .overFullScreen
        present(customPickerViewController, animated: true, completion: nil)
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
        var newValue = round(Double(sender.value)/sizeOfAtTick) * sizeOfAtTick
        guard newValue != recipe?.selectedQuantity,
              var tempFoodRecord = recipe else {
            return
        }
        newValue = newValue == 0 ? sizeOfAtTick/1000 : newValue
        _ = tempFoodRecord.setFoodRecordServing(unit: tempFoodRecord.selectedUnit,
                                                quantity: newValue)
        recipe = tempFoodRecord
    }

    @objc func addIngredients() {
        isAddIngredient = true
        let plusMenuVC = PlusMenuViewController()
        plusMenuVC.menuData = [.scan, .search, .voiceLogging]
        plusMenuVC.delegate = self
        plusMenuVC.modalTransitionStyle = .crossDissolve
        plusMenuVC.modalPresentationStyle = .overFullScreen
        navigationController?.present(plusMenuVC, animated: true)
    }

    private func goToEditIngredient(foodRecordIngredient: FoodRecordIngredient, indexOfIngredient: Int) {
        let editVC = EditIngredientViewController()
        editVC.foodItemData = foodRecordIngredient
        editVC.indexOfIngredient = indexOfIngredient
        editVC.saveOnDismiss = false
        editVC.indexToPop = isAddIngredient ? 2 : nil
        editVC.delegate = self
        navigationController?.pushViewController(editVC, animated: true)
    }

    private func updateRecipe(for record: FoodRecordV3,
                              isPlusAction: Bool,
                              indexOfIngredient: Int) {
        if var recipe {
            if isPlusAction {
                recipe.addIngredient(record: record)
                self.recipe = recipe
                editRecipeTableView.scrollToBottom()
            } else {
                goToEditIngredient(foodRecordIngredient: FoodRecordIngredient(foodRecord: record),
                                   indexOfIngredient: indexOfIngredient)
            }
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension EditRecipeViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        editRecipeSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch editRecipeSections[section] {
        case .recipeDetailsCell, .amountSliderFullTableViewCell, .ingredientAddTableViewCell: 1
        case .ingredientHeaderTableViewCell: (recipe?.ingredients.count ?? 1) == 1 ? 0 : (recipe?.ingredients.count ?? 1)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch editRecipeSections[indexPath.section] {

        case .recipeDetailsCell:
            let cell = tableView.dequeueCell(cellClass: RecipeDetailsCell.self,
                                             forIndexPath: indexPath)
            if let recipe {
                cell.configureCell(with: recipe, isCreate: isCreate)
                cell.onCreateFoodImage = { [weak self] (sourceType) in
                    guard let self else { return }
                    self.presentImagePicker(withSourceType: sourceType, delegate: self)
                }
            }
            return cell

        case .amountSliderFullTableViewCell:
            let cell = tableView.dequeueCell(cellClass: AmountSliderFullTableViewCell.self,
                                             forIndexPath: indexPath)
            let (qty, unitName, weight) = getAmountsforCell(slider: cell.sliderAmount)
            cell.setup(quantity: qty, unitName: unitName, weight: weight)
            cell.textAmount.delegate = self
            cell.buttonUnits.addTarget(self,
                                       action: #selector(changeLabel(sender:)),
                                       for: .touchUpInside)
            cell.sliderAmount.addTarget(self,
                                        action: #selector(sliderAmountValueDidChange(sender:)),
                                        for: .valueChanged)
            return cell

        case .ingredientAddTableViewCell:
            let cell = tableView.dequeueCell(cellClass: IngredientAddTableViewCell.self,
                                             forIndexPath: indexPath)
            cell.buttonAddIngredients.addTarget(self,
                                                action: #selector(addIngredients),
                                                for: .touchUpInside)
            return cell

        case .ingredientHeaderTableViewCell:
            let cell = tableView.dequeueCell(cellClass: IngredientHeaderTableViewCell.self,
                                             forIndexPath: indexPath)
            if let recipe {
                cell.setup(ingredient: recipe.ingredients[indexPath.row],
                           isLastCell: recipe.ingredients.count == indexPath.row + 1)
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch editRecipeSections[indexPath.section] {
        case .recipeDetailsCell, .amountSliderFullTableViewCell, .ingredientAddTableViewCell:
            break
        case .ingredientHeaderTableViewCell:
            if let recipe, recipe.ingredients.count > 1 {
                isAddIngredient = false
                goToEditIngredient(foodRecordIngredient: recipe.ingredients[indexPath.row],
                                   indexOfIngredient: indexPath.row)
            }
        }
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        switch editRecipeSections[indexPath.section] {

        case .recipeDetailsCell, .amountSliderFullTableViewCell, .ingredientAddTableViewCell:
            return UISwipeActionsConfiguration(actions: [])

        case .ingredientHeaderTableViewCell:
            let deleteItem = UIContextualAction(style: .destructive,
                                                title: "Delete") { [weak self] (_, _, _) in
                _ = self?.recipe?.removeIngredient(atIndex: indexPath.row)
                tableView.reloadData()
            }
            let swipeActions = UISwipeActionsConfiguration(actions: [deleteItem])
            return swipeActions
        }
    }

    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {

        switch editRecipeSections[indexPath.section] {
        case .recipeDetailsCell, .amountSliderFullTableViewCell, .ingredientAddTableViewCell: .none
        case .ingredientHeaderTableViewCell: .delete
        }
    }
}

// MARK: - CustomAlert Delegate
extension EditRecipeViewController: CustomAlertDelegate {

    func onRightButtonTapped(textValue: String?) {
        navigationController?.popViewController(animated: true)
    }

    func onleftButtonTapped() { }
}

// MARK: - UIImagePickerController Delegate
extension EditRecipeViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        picker.dismiss(animated: true)

        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            DispatchQueue.main.async { [weak self] in
                guard let self, let getRecipeDetailsCell else { return }
                getRecipeDetailsCell.recipeImageView.image = pickedImage
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - UITextField Delegate
extension EditRecipeViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if let text = textField.text, text.contains("."), string == "." {
            return false
        } else {
            return true
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let textGerman = textField.text {
            let text = textGerman.replacingOccurrences(of: ",", with: ".")
            if let quantity = Double(text),
               var tempfoodRecord = recipe {
                _ = tempfoodRecord.setFoodRecordServing(unit: tempfoodRecord.selectedUnit,
                                                        quantity: quantity)
                recipe = tempfoodRecord
            }
        }
        editRecipeTableView.reloadData()
    }
}

// MARK: - CustomPickerSelection Delegate
extension EditRecipeViewController: CustomPickerSelectionDelegate {

    func onPickerSelection(value: String, selectedIndex: Int, viewTag: Int) {
        _ = recipe?.setSelectedUnit(unit: value)
    }
}

// MARK: - PlusMenu Delegate
extension EditRecipeViewController: PlusMenuDelegate {

    func onSearchSelected() {
        let vc = TextSearchViewController()
        vc.advancedSearchDelegate = self
        vc.isCreateRecipe = true
        navigationController?.pushViewController(vc, animated: true)
    }

    func onScanSelected() {}

    func onFavouritesSelected() {}

    func onMyFoodsSelected() {}

    func onVoiceLoggingSelected() {}

    func takePhotosSelected() {}

    func selectPhotosSelected() {}
}

// MARK: - AdvancedTextSearch ViewDelegate
extension EditRecipeViewController: AdvancedTextSearchViewDelegate {

    func userSelectedFoodItem(item: PassioFoodItem?, isPlusAction: Bool) {

        if let item, var recipe {
            updateRecipe(for: FoodRecordV3(foodItem: item),
                         isPlusAction: isPlusAction,
                         indexOfIngredient: recipe.ingredients.count)
        }
    }

    func userSelectedFood(record: FoodRecordV3?, isPlusAction: Bool) {
        if let record, var recipe {
            updateRecipe(for: record,
                         isPlusAction: isPlusAction,
                         indexOfIngredient: recipe.ingredients.count)
        }
    }
}

// MARK: - IngredientEditorView Delegate
extension EditRecipeViewController: IngredientEditorViewDelegate {

    func ingredientEditedFoodItemData(ingredient: FoodRecordIngredient, atIndex: Int) {
        if isAddIngredient {
            recipe?.addIngredient(ingredient: ingredient)
        } else {
            recipe?.replaceIngredient(updatedIngredient: ingredient, atIndex: atIndex)
        }
    }

    func ingredientEditedCancel() { }
    func startNutritionBrowser(foodItemData: FoodRecordIngredient) { }
    func replaceFoodUsingSearch() { }
}
