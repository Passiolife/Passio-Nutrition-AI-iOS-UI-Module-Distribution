//
//  EditRecipeViewController.swift
//  
//
//  Created by Nikunj Prajapati on 01/07/24.
//

import UIKit

class EditRecipeViewController: InstantiableViewController {

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var editRecipeTableView: UITableView!

    private let connector = PassioInternalConnector.shared
    private var isAddIngredient = true
    private var cachedMaxForSlider: [String: Float] = [:]

    private enum EditRecipeCell: String, CaseIterable {
        case recipeDetailsCell,
             servingSizeTableViewCell,
             ingredientsTableViewCell,
             ingredientInfoTableViewCell
    }
    private let editRecipeSections: [EditRecipeCell] = [.recipeDetailsCell,
                                                        .servingSizeTableViewCell,
                                                        .ingredientsTableViewCell,
                                                        .ingredientInfoTableViewCell]
    var isCreate = true
    var vcTitle = RecipeTexts.editRecipe
    var isUpdateLog = true
    var isFromRecipeList = false
    var isFromUserFoodsList = false
    var isEditingExistingRecipe = false
    var isFromFoodDetails = false
    var loggedFoodRecord: FoodRecordV3?

    weak var delegate: NavigateToDiaryDelegate?

    var recipe: FoodRecordV3? {
        didSet {
            DispatchQueue.main.async { [self] in
                saveButton.enableDisableButton(duration: 0.21, isEnabled: isSaveRecipe)
                editRecipeTableView.reloadData()
            }
        }
    }

    private var recipeName = "" {
        didSet {
            saveButton.enableDisableButton(duration: 0.21, isEnabled: isSaveRecipe)
        }
    }
    private var isSaveRecipe: Bool {
        (recipe?.ingredients.count ?? 1 >= 2) &&
        (recipeName != "") &&
        !(recipeName.trimmingCharacters(in: .whitespaces).isEmpty)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        recipeName = recipe?.name ?? ""
        setupBackButton()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        recipe?.name = recipeName
    }
}

// MARK: - @IBAction & objc
extension EditRecipeViewController {

    @IBAction func onSave(_ sender: UIButton) {

        if var recipe, let getRecipeDetailsCell {

            recipe.name = recipeName
            recipe.iconId = recipe.iconId.contains("Recipe") ? recipe.iconId : "Recipe.\(recipe.iconId)"
            connector.updateRecipe(record: recipe)
            connector.updateUserFoodImage(
                with: recipe.iconId,
                image: getRecipeDetailsCell.recipeImageView.image?.get180pImage ?? UIImage()
            )

            if isFromUserFoodsList || isFromRecipeList {
                navigationController?.popToSpecificViewController(MyFoodsSelectionViewController.self)

            } else if isFromFoodDetails {

                if isUpdateLog {

                    if let loggedFoodRecord {
                        recipe.uuid = loggedFoodRecord.uuid
                        recipe.createdAt = loggedFoodRecord.createdAt
                        recipe.mealLabel = loggedFoodRecord.mealLabel
                        connector.deleteRecord(foodRecord: loggedFoodRecord)
                    } else {
                        connector.deleteRecord(foodRecord: recipe)
                    }

                    DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 0.2) {
                        self.connector.updateRecord(foodRecord: recipe)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.navigationController?.popToSpecificViewController(HomeTabBarController.self)
                    }

                } else {
                    delegate?.onSaveNavigateToDiary(isUpdateLog: false)
                    navigationController?.popToSpecificViewController(HomeTabBarController.self)
                }

            } else {
                navigationController?.popViewController(animated: true)
            }
        }
    }

    @IBAction func onCancel(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func onDelete(_ sender: UIButton) {
        if let recipe {
            connector.deleteRecipe(record: recipe)
            navigationController?.popToSpecificViewController(MyFoodsSelectionViewController.self)
        }
    }

    @objc private func onChangeUnit(sender: UIButton) {

        guard let servingUnits = recipe?.servingUnits else { return }
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
        present(customPickerViewController, animated: true, completion: nil)
    }

    @objc func onChangeQuantity(sender: UISlider) {

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
        plusMenuVC.menuData = [.search]
        plusMenuVC.delegate = self
        plusMenuVC.modalTransitionStyle = .crossDissolve
        plusMenuVC.modalPresentationStyle = .overFullScreen
        navigationController?.present(plusMenuVC, animated: true)
    }
}

// MARK: - Edit Recipe Helper
extension EditRecipeViewController {

    private func configureUI() {

        title = vcTitle

        deleteButton.isHidden = !isFromRecipeList
        cancelButton.applyBorder(width: 2, color: .primaryColor)
        cancelButton.setTitleColor(.primaryColor, for: .normal)
        saveButton.backgroundColor = .primaryColor

        editRecipeTableView.dataSource = self
        editRecipeTableView.delegate = self
        EditRecipeCell.allCases.forEach {
            editRecipeTableView.register(nibName: $0.rawValue.capitalizingFirst())
        }
    }

    private var getRecipeDetailsCell: RecipeDetailsCell? {
        editRecipeTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? RecipeDetailsCell
    }

    // MARK: Cell Helper
    private func getAmountsforCell(slider: UISlider) -> (quantity: Double,
                                                         unitName: String,
                                                         weight: String) {
        slider.minimumValue = 0.0
        guard let foodRecord = recipe,
              foodRecord.ingredients.count > 0,
              foodRecord.selectedQuantity > 0 else { return(100, UnitsTexts.gram, "100") }
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

    private func goToEditIngredient(foodRecordIngredient: FoodRecordIngredient, indexOfIngredient: Int) {
        let editVC = EditIngredientViewController()
        editVC.foodItemData = foodRecordIngredient
        editVC.indexOfIngredient = indexOfIngredient
        editVC.saveOnDismiss = false
        editVC.indexToPop = isAddIngredient ? 2 : nil
        editVC.isAddIngredient = isAddIngredient
        editVC.delegate = self
        navigationController?.pushViewController(editVC, animated: true)
    }

    private func updateRecipe(for record: FoodRecordV3,
                              isPlusAction: Bool,
                              indexOfIngredient: Int) {
        if var recipe {
            if isPlusAction {
                recipe.addIngredient(record: record)
                recipe.ingredients[indexOfIngredient].iconId = record.iconId
                self.recipe = recipe
                editRecipeTableView.scrollToBottom()
            } else {
                goToEditIngredient(foodRecordIngredient: FoodRecordIngredient(foodRecord: record),
                                   indexOfIngredient: indexOfIngredient)
            }
        }
    }

    private func createRecipe(from item: PassioFoodItem?, record: FoodRecordV3?) {
        if let item {
            var record = FoodRecordV3(foodItem: item,
                                      barcode: "",
                                      scannedWeight: nil,
                                      entityType: .recipe,
                                      confidence: nil)
            record.name = recipeName
            record.iconId = item.iconId
            recipe = record
        } else if var record {
            record.name = recipeName
            record.ingredients[0].iconId = record.iconId
            recipe = record
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
        case .recipeDetailsCell, .servingSizeTableViewCell, .ingredientsTableViewCell: 1
        case .ingredientInfoTableViewCell: recipe?.ingredients.count ?? 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch editRecipeSections[indexPath.section] {

        case .recipeDetailsCell:
            let cell = tableView.dequeueCell(cellClass: RecipeDetailsCell.self,
                                             forIndexPath: indexPath)
            if let recipe {
                cell.configureCell(with: recipe, isCreate: isCreate)
            }
            cell.recipeName = { [weak self] (recipeName) in
                guard let self else { return }
                self.recipeName = recipeName
                self.recipe?.name = recipeName
            }
            cell.onCreateFoodImage = { [weak self] (sourceType) in
                guard let self else { return }
                self.presentImagePicker(withSourceType: sourceType, delegate: self)
            }
            return cell

        case .servingSizeTableViewCell:
            let cell = tableView.dequeueCell(cellClass: ServingSizeTableViewCell.self,
                                             forIndexPath: indexPath)
            let (qty, unitName, weight) = getAmountsforCell(slider: cell.sliderAmount)
            cell.setup(quantity: qty, unitName: unitName, weight: weight)
            cell.textAmount.delegate = self
            cell.buttonUnits.addTarget(self,
                                       action: #selector(onChangeUnit(sender:)),
                                       for: .touchUpInside)
            cell.sliderAmount.addTarget(self,
                                        action: #selector(onChangeQuantity(sender:)),
                                        for: .valueChanged)
            return cell

        case .ingredientsTableViewCell:
            let cell = tableView.dequeueCell(cellClass: IngredientsTableViewCell.self,
                                             forIndexPath: indexPath)
            cell.makeRecipeButton.backgroundColor = .white
            cell.makeRecipeButton.setTitle("", for: .normal)
            cell.makeRecipeWidthConstraint.constant = 30
            cell.makeRecipeButton.setImage(UIImage(systemName: "plus"), for: .normal)
            cell.makeRecipeButton.addTarget(self,
                                                action: #selector(addIngredients),
                                                for: .touchUpInside)
            return cell

        case .ingredientInfoTableViewCell:
            let cell = tableView.dequeueCell(cellClass: IngredientInfoTableViewCell.self,
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
        case .recipeDetailsCell, .servingSizeTableViewCell, .ingredientsTableViewCell:
            break
        case .ingredientInfoTableViewCell:
            if let recipe, recipe.ingredients.count >= 1 {
                isAddIngredient = false
                goToEditIngredient(foodRecordIngredient: recipe.ingredients[indexPath.row],
                                   indexOfIngredient: indexPath.row)
            }
        }
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        switch editRecipeSections[indexPath.section] {

        case .recipeDetailsCell, .servingSizeTableViewCell, .ingredientsTableViewCell:
            return UISwipeActionsConfiguration(actions: [])

        case .ingredientInfoTableViewCell:
            let deleteItem = UIContextualAction(style: .destructive,
                                                title: ButtonTexts.delete) { [weak self] (_, _, _) in
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
        case .recipeDetailsCell, .servingSizeTableViewCell, .ingredientsTableViewCell: .none
        case .ingredientInfoTableViewCell: .delete
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

    func onVoiceLoggingSelected() {}

    func takePhotosSelected() {}

    func selectPhotosSelected() {}
}

// MARK: - AdvancedTextSearch ViewDelegate
extension EditRecipeViewController: AdvancedTextSearchViewDelegate {

    func userSelectedFoodItem(item: PassioFoodItem?, isPlusAction: Bool) {

        if let item, let recipe {
            updateRecipe(for: FoodRecordV3(foodItem: item),
                         isPlusAction: isPlusAction,
                         indexOfIngredient: recipe.ingredients.count)
        } else if let item {
            createRecipe(from: item, record: nil)
        }
    }

    func userSelectedFood(record: FoodRecordV3?, isPlusAction: Bool) {
        if let record, let recipe {
            updateRecipe(for: record,
                         isPlusAction: isPlusAction,
                         indexOfIngredient: recipe.ingredients.count)
        } else if let record {
            createRecipe(from: nil, record: record)
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
}
