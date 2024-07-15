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

    private var cachedMaxForSlider: [String: Float] = [:]
    private enum EditRecipeCell {
        case recipeDetails, servingSize, addIngredient, ingredients
    }
    private let editRecipeSections: [EditRecipeCell] = [.recipeDetails,
                                                        .servingSize,
                                                        .addIngredient,
                                                        .ingredients]
    var isCreate = true
    var recipe: FoodRecordV3? {
        didSet {
            editRecipeTableView.reloadData()
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

    @IBAction func onCancel(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
//        let message = "Are you sure you want to cancel recipe creation? All your progress will be lost."
//        showCustomAlert(with: CustomAlert(headingLabel: false,
//                                          titleLabel: true,
//                                          alertTextField: true,
//                                          rightButton: false,
//                                          leftButton: false),
//                        title: CustomAlert.AlertTitle(headingText: message,
//                                                      rightButtonTitle: "Yes",
//                                                      leftButtonTitle: "No"),
//                        font: CustomAlert.AlertFont(headingFont: .inter(type: .medium, size: 16)),
//                        color: CustomAlert.AlertColor(headingColor: .gray900,
//                                                      rightButtonColor: .systemRed,
//                                                      borderColor: .systemRed,
//                                                      isRightBorder: true),
//                        delegate: self)
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
        editRecipeTableView.register(nibName: RecipeDetailsCell.className)
        editRecipeTableView.register(nibName: AmountSliderFullTableViewCell.className)
        editRecipeTableView.register(nibName: IngredientAddTableViewCell.className)
        editRecipeTableView.register(nibName: IngredientHeaderTableViewCell.className)
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
        let plusMenuVC = PlusMenuViewController()
        plusMenuVC.menuData = [.scan, .search, .voiceLogging]
        plusMenuVC.delegate = self
        plusMenuVC.modalTransitionStyle = .crossDissolve
        plusMenuVC.modalPresentationStyle = .overFullScreen
        navigationController?.present(plusMenuVC, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension EditRecipeViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        editRecipeSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch editRecipeSections[section] {
        case .recipeDetails, .servingSize, .addIngredient: 1
        case .ingredients: (recipe?.ingredients.count ?? 1) == 1 ? 0 : (recipe?.ingredients.count ?? 1)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch editRecipeSections[indexPath.section] {

        case .recipeDetails:
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

        case .servingSize:
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

        case .addIngredient:
            let cell = tableView.dequeueCell(cellClass: IngredientAddTableViewCell.self,
                                             forIndexPath: indexPath)
            cell.buttonAddIngredients.addTarget(self,
                                                action: #selector(addIngredients),
                                                for: .touchUpInside)
            return cell

        case .ingredients:
            let cell = tableView.dequeueCell(cellClass: IngredientHeaderTableViewCell.self,
                                             forIndexPath: indexPath)
            if let recipe {
                cell.setup(ingredient: recipe.ingredients[indexPath.row],
                           isLastCell: recipe.ingredients.count == indexPath.row + 1)
            }
            return cell
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
        vc.dismmissToMyLog = true
        vc.isCreateRecipe = true
        vc.modalPresentationStyle = .fullScreen
        vc.advancedSearchDelegate = self
        present(vc, animated: true)
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

            if isPlusAction {
                recipe.addIngredient(record: FoodRecordV3(foodItem: item))
                self.recipe = recipe
                editRecipeTableView.scrollToBottom()
            } else {
                let editVC = EditIngredientViewController()
                editVC.foodItemData = FoodRecordIngredient(foodRecord: FoodRecordV3(foodItem: item))
                editVC.indexOfIngredient = 0
                editVC.delegate = self
                navigationController?.pushViewController(editVC, animated: true)
            }
        }
    }

    func userSelectedFood(record: FoodRecordV3?, isPlusAction: Bool) {
        if let record, var recipe {
            recipe.addIngredient(record: record)
            self.recipe = recipe
        }
    }
}

// MARK: - IngredientEditorView Delegate
extension EditRecipeViewController: IngredientEditorViewDelegate {

    func ingredientEditedFoodItemData(ingredient: FoodRecordIngredient, atIndex: Int) {

    }

    func ingredientEditedCancel() {

    }

    func startNutritionBrowser(foodItemData: FoodRecordIngredient) { }
    func replaceFoodUsingSearch() { }
}
