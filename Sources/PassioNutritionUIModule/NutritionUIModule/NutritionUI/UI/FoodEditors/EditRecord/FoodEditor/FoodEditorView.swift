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

protocol FoodEditorDelegate: AnyObject {
    func addFoodToLog(foodRecord: FoodRecordV3, removeViews: Bool)
    func delete(foodRecord: FoodRecordV3)
    func addFoodFavorites(foodRecord: FoodRecordV3)
    func foodEditorCancel()
    func userSelected(foodRecord: FoodRecordV3)
    func userSelected(ingredient: FoodRecordIngredient, indexOfIngredient: Int)
    func foodEditorSearchText()
    func replaceFoodUsingSearch()
}

extension FoodEditorDelegate {
    func userSelected(foodRecord: FoodRecordV3) { }
    func userSelected(ingredient: FoodRecordIngredient, indexOfIngredient: Int) { }
    func foodEditorSearchText() { }
}

// MARK: - Food Editor
class FoodEditorView: UIView {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonSave: UIButton!

    let connector = PassioInternalConnector.shared
    let rowsBeforeIngrediants = 4

    weak var delegate: FoodEditorDelegate?

    var saveToConnector: Bool = true
    var isEditingFavorite = false
    var invisibleList = [PassioID]()
    var dateForCheckMark: Date?
    var nameForCheckMark: String?
    var userProfile = UserProfileModel()

    var isEditingRecord = false {
        didSet {
            let title = (isEditingRecord || isEditingFavorite) ? "Save" : "Log"
            buttonSave?.setTitle(title, for: .normal)
        }
    }

    var foodRecord: FoodRecordV3? {
        didSet {
            if foodRecord != nil {
                fetchFavorites()
                if foodRecord?.ingredients.count == 1 {
                    showAmount = true
                }
            } else {
                favorites = []
            }
            invisibleList = []
            tableView.reloadWithAnimations(withDuration: 0.2)
        }
    }

    var favorites = [FoodRecordV3]() {
        willSet(newValue) {
            if newValue != favorites {
                tableView.reloadWithAnimations()
            }
        }
    }

    var showAmount = false {
        didSet {
            tableView.reloadWithAnimations()
        }
    }

    var listOfFailedBarcodes = Set<String>() {
        didSet {
            pauseForFailedBarcode = true
        }
    }
    var pauseForFailedBarcode = false {
        didSet {
            tableView.reloadData()
        }
    }
    var showAlternativesRow: Bool {
        return false
    }
    var editedTimestamp: Date? {
        didSet {
            tableView.reloadData()
        }
    }
    var dateSelector: DateSelectorViewController?

    override func awakeFromNib() {
        super.awakeFromNib()

        userProfile = UserManager.shared.user ?? UserProfileModel()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = true
        tableView.estimatedRowHeight = 200
        buttonCancel?.setTitle( "Cancel", for: .normal)
        let title = isEditingRecord ? "Save" : "Log"
        buttonSave?.setTitle(title, for: .normal)
        buttonCancel?.roundMyCornerWith(radius: 8)
        buttonSave?.roundMyCornerWith(radius: 8)
        CellNameFoodEditor.allCases.forEach {
            tableView.register(nibName: $0.rawValue.capitalizingFirst())
        }
    }

    // MARK: Button Actions
    @objc func changeLabel(sender: UIButton) {
        guard let servingUnits = foodRecord?.servingUnits else { return }
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
                                                            height: 42.5 * Double(items.count))
        }
        customPickerViewController.delegate = self
        customPickerViewController.modalTransitionStyle = .crossDissolve
        customPickerViewController.modalPresentationStyle = .overFullScreen
        findViewController()?.present(customPickerViewController, animated: true, completion: nil)
    }

    @objc func goBack() {
        if let nav = self.findViewController()?.navigationController {
            nav.popViewController(animated: true)
        }
    }

    @IBAction func cancel(_ sender: UIButton) {
        delegate?.foodEditorCancel()
    }

    func fetchFavorites() {
        connector.fetchFavorites { favorites in
            self.favorites = favorites.filter {
                $0.passioID == self.foodRecord?.passioID
            }.sorted {
                $0.createdAt > $1.createdAt
            }
        }
    }

    @objc func addToFavorites() {
        guard let foodRecord = foodRecord else { return }
        var favorite = foodRecord
        let alertFavorite = UIAlertController(title: "Name your favorite".localized,
                                              message: nil, preferredStyle: .alert)
        alertFavorite.addTextField { (textField) in
            textField.placeholder = "My " + favorite.name.capitalizingFirst()
            textField.clearButtonMode = .always
        }
        let save = UIAlertAction(title: "Save".localized, style: .default) { (_) in
            let firstTextFied = alertFavorite.textFields![0] as UITextField

            // favorite.isFavorite = true
            if self.isEditingFavorite {
                favorite.uuid = UUID().uuidString
            }
            favorite.createdAt = Date()
            if let text = firstTextFied.text, !text.isEmpty {
                favorite.name = text
            } else {
                favorite.name = "My " + favorite.name
            }

            //if self.saveToConnector {
            self.connector.updateFavorite(foodRecord: favorite)
            //}
            self.delegate?.addFoodFavorites(foodRecord: favorite)
            self.tableView.reloadData()
        }
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel)
        alertFavorite.addAction(save)
        alertFavorite.addAction(cancel)
        self.findViewController()?.present(alertFavorite, animated: true)
    }

    @objc private func showNutritionInformation() {
        let popUpVC = PopUpViewController()
        popUpVC.modalTransitionStyle = .crossDissolve
        popUpVC.modalPresentationStyle = .overFullScreen
        findViewController()?.present(popUpVC, animated: true)
    }

    @IBAction func addToLog(_ sender: UIButton) {
        addFoodToLog()
    }

    @objc func addFoodToLog() {
        guard var record = foodRecord else { return }
        if saveToConnector {
            if editedTimestamp != nil {
                connector.deleteRecord(foodRecord: record)
                record.createdAt = editedTimestamp ?? record.createdAt
            }
            if record.entityType == .recipe {
                connector.updateUserFood(record: record, isNew: true)
            }
            connector.updateRecord(foodRecord: record, isNew: true)
        }
        delegate?.addFoodToLog(foodRecord: record, removeViews: true)
    }

    // MARK: Cell Name
    func getCellNameFor(indexPath: IndexPath) -> CellNameFoodEditor {
        switch indexPath.row {
        case 0:
            return .foodHeaderSimpleTableViewCell
        case 1:
            return .amountSliderFullTableViewCell
        case 2:
            return .mealSelectionTableViewCell
        case 3:
            return .timestampTableViewCell
        case 4:
            return .ingredientAddTableViewCell
        default:
            return .ingredientHeaderTableViewCell
        }
    }

    private var cachedMaxForSlider = [Int: [String: Float]]()
}

// MARK: - UITableView DataSource
extension FoodEditorView: UITableViewDataSource {

    var calculatedNumberOfRaws: Int {
        guard let foodRecord = foodRecord else { return 0 }
        let numOfIngredients = foodRecord.ingredients.count
        let withoutAlternatives = numOfIngredients == 1 ? rowsBeforeIngrediants : rowsBeforeIngrediants + numOfIngredients
        return withoutAlternatives + 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        calculatedNumberOfRaws
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {


        let cellName = getCellNameFor(indexPath: indexPath)
        switch cellName {
        case .foodHeaderSimpleTableViewCell:
            return getHeaderSimpleTableViewCell(cellForRowAt: indexPath)
        case .amountSliderFullTableViewCell:
            return getAmountSliderFullTableViewCell(indexPath: indexPath)
        case .mealSelectionTableViewCell:
            return getMealSelectionCell(indexPath: indexPath)
        case .timestampTableViewCell:
            return getTimestampCell(indexPath: indexPath)
        case .ingredientAddTableViewCell:
            return getIngredientAddTableViewCell(indexPath: indexPath)
        case .ingredientHeaderTableViewCell:
            return getIngredientHeaderTableViewCell(indexPath: indexPath)
        }
    }

    @objc func userPressedReplaceSearch() {
        delegate?.replaceFoodUsingSearch()
    }

    func getAmountsforCell(tableRowOrCollectionTag: Int, slider: UISlider) -> (quantity: Double,
                                                                               unitName: String,
                                                                               weight: String) {
        slider.minimumValue = 0.0
        slider.tag = tableRowOrCollectionTag
        guard let foodRecord = foodRecord else { return(0, "error", "0") }
        let sliderMultiplier: Float = 5.0
        let maxSliderFromData = Float(1) * sliderMultiplier
        let currentValue = Float(foodRecord.selectedQuantity)

        if cachedMaxForSlider[tableRowOrCollectionTag]?[foodRecord.selectedUnit] == nil {
            cachedMaxForSlider[tableRowOrCollectionTag] = [foodRecord.selectedUnit: sliderMultiplier * currentValue]
            slider.maximumValue = sliderMultiplier * currentValue
        } else if let maxFromCache = cachedMaxForSlider[tableRowOrCollectionTag]?[foodRecord.selectedUnit],
                  maxFromCache > maxSliderFromData, maxFromCache > currentValue {
            slider.maximumValue = maxFromCache
        } else if maxSliderFromData > currentValue {
            slider.maximumValue = maxSliderFromData
        } else {
            slider.maximumValue = currentValue
            cachedMaxForSlider[tableRowOrCollectionTag] = [foodRecord.selectedUnit: currentValue]
        }
        slider.value = currentValue
        return (Double(currentValue), foodRecord.selectedUnit.capitalizingFirst(),
                String(foodRecord.computedWeight.value.roundDigits(afterDecimal: 1).clean))
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
        guard newValue != foodRecord?.selectedQuantity,
              var tempFoodRecord = foodRecord else {
            return
        }
        newValue = newValue == 0 ? sizeOfAtTick/1000 : newValue
        _ = tempFoodRecord.setFoodRecordServing(unit: tempFoodRecord.selectedUnit, quantity: newValue)
        foodRecord = tempFoodRecord
    }

    @objc func renameFoodRecordAlert(createRecipe: Bool = false) {

        let title = createRecipe ? "Create Recipe?".localized : "Rename Food Record".localized
        let message = createRecipe ? "You are about to turn this food into  recipe. Name and create yoru recipe" : ""
        let actionName = createRecipe ? "Create" : "Save".localized
        let suggestedName = createRecipe ?  "Recipe of".localized + " " + (self.foodRecord?.name ?? "") :
        self.foodRecord?.name ?? "Error2"

        let alertName = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertName.addTextField { (textField) in
            textField.text = suggestedName
            textField.clearButtonMode = .always
        }
        let save = UIAlertAction(title: actionName, style: .default) { [weak self] (_) in
            guard let self else { return }
            let firstTextField = alertName.textFields![0] as UITextField
            guard self.foodRecord != nil, let newName = firstTextField.text else { return }

            if createRecipe && !(self.foodRecord?.iconId ?? "").contains("REC") {
                let newRecipeIcon = "Recipe.\(self.foodRecord?.iconId ?? "")"
                self.foodRecord?.iconId = newRecipeIcon
            }
            self.foodRecord?.name = newName
            self.tableView.reloadData()
            if createRecipe {
                self.delegate?.foodEditorSearchText()
            }
        }
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel) { _ in }
        alertName.addAction(save)
        alertName.addAction(cancel)
        self.findViewController()?.present(alertName, animated: true)
    }
}

// MARK: - UITableView Delegate
extension FoodEditorView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.row == rowsBeforeIngrediants {
            addIngredients()
        } else if indexPath.row > rowsBeforeIngrediants, let foodRecord = foodRecord {
            // let openFood = foodRecord.isOpenFood ? 1 : 0
            // let index = indexPath.row - rowsBeforeIngrediants - 1 - openFood
            // Fixed: Crash Due to -1 index (No need to check for open food, we're not showing open food msg now)
            let index = indexPath.row - rowsBeforeIngrediants - 1
            guard foodRecord.ingredients.count > index, index >= 0  else { return }
            let foodItem = foodRecord.ingredients[index]
            delegate?.userSelected(ingredient: foodItem, indexOfIngredient: index)
        }
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        guard indexPath.row > rowsBeforeIngrediants else { return nil }

        let deleteItem = UIContextualAction(style: .destructive, title: "Delete".localized) {  (_, _, _) in

            let index = indexPath.row - self.rowsBeforeIngrediants - 1
            _ = self.foodRecord?.removeIngredient(atIndex: index)
            tableView.reloadData()
        }

        let swipeActions = UISwipeActionsConfiguration(actions: [deleteItem])
        return swipeActions
    }

    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return indexPath.row > rowsBeforeIngrediants ? .delete : .none
    }
}

extension FoodEditorView: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let kbToolBarView = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 44))
        let kbSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                       target: nil, action: nil)
        let bottonOk = UIBarButtonItem(title: "OK".localized, style: .plain, target: self,
                                       action: #selector(closeKeyBoard(barButtonItem:)))
        bottonOk.tag = textField.tag
        kbToolBarView.items = [kbSpacer, bottonOk, kbSpacer]
        kbToolBarView.tintColor = .white
        kbToolBarView.barTintColor = .indigo600
        textField.inputAccessoryView = kbToolBarView
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
        } else {
            return true
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let textGerman = textField.text {
            let text = textGerman.replacingOccurrences(of: ",", with: ".")
            if let quantity = Double(text), var tempfoodRecord = foodRecord {
                _ = tempfoodRecord.setFoodRecordServing(unit: tempfoodRecord.selectedUnit, quantity: quantity)
                foodRecord = tempfoodRecord
            }
        }
        tableView.reloadData()
    }
}

// MARK: - Cells
extension FoodEditorView {

    func getHeaderSimpleTableViewCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FoodHeaderSimpleTableViewCell",
                                                       for: indexPath) as? FoodHeaderSimpleTableViewCell,
              let foodRecord = foodRecord else {
            return UITableViewCell()
        }
        cell.favouriteButton.addTarget(self, action: #selector(addToFavorites), for: .touchUpInside)
        let titleRecognizer = UITapGestureRecognizer(target: self, action: #selector(renameFoodRecordAlert))
        cell.labelName.addGestureRecognizer(titleRecognizer)
        cell.setup(foodRecord: foodRecord, isFavourite: isEditingFavorite)
        cell.nutritionInfoButton.addTarget(self, action: #selector(showNutritionInformation), for: .touchUpInside)
        return cell
    }

    func getAmountSliderFullTableViewCell(indexPath: IndexPath) -> UITableViewCell {
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
    }

    func getIngredientAddTableViewCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientAddTableViewCell",
                                                       for: indexPath) as? IngredientAddTableViewCell else {
            return UITableViewCell()
        }
        cell.titleLabel.text = "Add Ingredient  " // "Add ingredients to create a recipe".localized
        cell.buttonAddIngredients.addTarget(self, action: #selector(addIngredients), for: .touchUpInside)
        cell.insetBackground.roundMyCornerWith(radius: Custom.insetBackgroundRadius)
        cell.selectionStyle = .none
        return cell
    }

    @objc func addIngredients() {
        if foodRecord?.ingredients.count == 1 {
            renameFoodRecordAlert(createRecipe: true)
        } else {
            delegate?.foodEditorSearchText()
        }
    }

    func getIngredientHeaderTableViewCell(indexPath: IndexPath) -> UITableViewCell {

        let numbertoJump = 1
        let indexForIngredient = indexPath.row - rowsBeforeIngrediants - numbertoJump

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientHeaderTableViewCell",
                                                       for: indexPath) as? IngredientHeaderTableViewCell,
              let foodRecord = foodRecord,
              foodRecord.ingredients.count > indexForIngredient else {
            return UITableViewCell()
        }

        let ingredient = foodRecord.ingredients[indexForIngredient]
        cell.setup(ingredient: ingredient)
        self.tag = indexPath.row
        return cell
    }

    func getMealSelectionCell(indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MealSelectionTableViewCell",
                                                       for: indexPath) as? MealSelectionTableViewCell else {
            return UITableViewCell()
        }

        if let meal = foodRecord?.mealLabel {
            cell.setMealSelection(meal)
        }

        cell.delegate = self
        cell.insetBackgroundView.backgroundColor = .passioInsetColor
        return cell
    }

    func getTimestampCell(indexPath: IndexPath) -> UITableViewCell{
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TimestampTableViewCell", for: indexPath) as? TimestampTableViewCell  else {
            return UITableViewCell()
        }
        if let editedDate = editedTimestamp {
            cell.updateWithDate(editedDate)
        } else if let record = foodRecord {
            cell.updateWithDate(record.createdAt)
        }
        cell.timestampButton.addTarget(self, action: #selector(showDateSelector), for: .touchUpInside)
        return cell
    }
}

extension FoodEditorView: DateSelectorUIViewDelegate {

    @objc func showDateSelector() {
        dateSelector = DateSelectorViewController()
        dateSelector?.delegate = self
        dateSelector?.dateForPicker = self.editedTimestamp ?? self.foodRecord?.createdAt ?? Date()
        dateSelector?.modalPresentationStyle = .overFullScreen
        self.findViewController()?.navigationController?.presentVC(vc: dateSelector!)
    }

    func removeDateSelector(remove: Bool) {
        dateSelector?.dismiss(animated: false)
    }

    func dateFromPicker(date: Date) {
        self.editedTimestamp = date
    }
}

extension FoodEditorView: MealSelectionDelegate {

    func didChangeMealSelection(selection: MealLabel) {
        foodRecord?.mealLabel = selection
    }
}

extension FoodEditorView: CustomPickerSelectionDelegate {

    func onPickerSelection(value: String, selectedIndex: Int, viewTag: Int) {
        _ = foodRecord?.setSelectedUnit(unit: value)
    }
}
