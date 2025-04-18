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

protocol FoodDetailsDelegate: AnyObject {
    func onAddFoodToLog(foodRecord: FoodRecordV3)
    func onDelete(foodRecord: FoodRecordV3)
    func onCancelFood()
    func onUserSelected(ingredient: FoodRecordIngredient, indexOfIngredient: Int)
    func onMakeRecipe()
    func onAddIngredient(foodRecord: FoodRecordV3?)
}

extension FoodDetailsDelegate {
    func onUserSelected(ingredient: FoodRecordIngredient, indexOfIngredient: Int) { }
    func onMakeRecipe() { }
}

// MARK: - FoodDetails UIView Class
class FoodDetailsView: UIView {

    @IBOutlet weak var foodDetailsTableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var addIngredientButton: UIButton!
    
    private let connector = NutritionUIModule.shared
    private var foodDetailsSection: [FoodDetailsCell] = []
    private var dateSelector: DateSelectorViewController?
    private var cachedMaxForSlider = [Int: [String: Float]]()

    var saveToConnector: Bool = true
    var isFromMyFavorites = false
    var isEditingFavorite = false
    var isFromCustomFoodList = false
    var isFromRecipeList = false
    
    /* As we don't need to make any logs from Favorite Food -> Food Details -> Food Details View we ignore default set value,
     * we need only addIngredient enum to check if user redirect form Create/Edit Recipe screen or not.
     */
    var resultViewFor: DetectedFoodResultType = .addLog
    weak var foodDetailsDelegate: FoodDetailsDelegate?

    var foodRecord: FoodRecordV3? {
        didSet {
            if foodRecord != nil {
                fetchFavorites()
            } else {
                favorites = []
            }
            foodDetailsTableView.reloadData()
        }
    }
    var ingredientsCount: Int {
        foodRecord?.ingredients.count ?? 1
    }
    var favorites = [FoodRecordV3]() {
        willSet(newValue) {
            if newValue != favorites {
                foodDetailsTableView.reloadData()
            }
        }
    }
    var isEditingRecord = false {
        didSet {
            saveButton?.setTitle((isEditingRecord || isEditingFavorite) ? ButtonTexts.save : ButtonTexts.log, for: .normal)
            deleteButton.isHidden = !isEditingRecord
        }
    }
    var editedTimestamp: Date = Date() {
        didSet {
            foodDetailsTableView.reloadData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        configureUI()
    }

    private func configureUI() {

        //configureTableView()
        cancelButton?.setTitle(ButtonTexts.cancel, for: .normal)
        saveButton.backgroundColor = .primaryColor
        cancelButton.setTitleColor(.primaryColor, for: .normal)
        cancelButton.applyBorder(width: 2, color: .primaryColor)
        deleteButton?.setTitle(ButtonTexts.delete, for: .normal)
    }

    func configureTableView() {

        if self.isEditingFavorite {
            foodDetailsSection = [.foodInfoTableViewCell,
                                  .servingSizeTableViewCell,
                                  .ingredientsTableViewCell,
                                  .ingredientInfoTableViewCell]
        } else {
            foodDetailsSection = [.foodInfoTableViewCell,
                                  .servingSizeTableViewCell,
                                  .mealTimeTableViewCell,
                                  .dateSelectionTableViewCell,
                                  .ingredientsTableViewCell,
                                  .ingredientInfoTableViewCell]
        }
        
        foodDetailsTableView.dataSource = self
        foodDetailsTableView.delegate = self
        foodDetailsTableView.estimatedRowHeight = 200
        foodDetailsTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        FoodDetailsCell.allCases.forEach {
            foodDetailsTableView.register(nibName: $0.rawValue.capitalizingFirst())
        }
    }
    
    func adjustBottomButton() {
        if resultViewFor == .addIngredient {
            saveButton.isHidden = true
            deleteButton.isHidden = true
            addIngredientButton.isHidden = false
        }
    }
}

// MARK: - @IBAction & @objc
extension FoodDetailsView {

    func enableInteration(_ isEnable: Bool) {
        self.isUserInteractionEnabled = isEnable
    }
    
    @IBAction func onFoodLog(_ sender: UIButton) {

        guard var record = foodRecord else { return }
        enableInteration(false)
        
        if saveToConnector {
            if editedTimestamp != nil {
                // https://app.zenhub.com/workspaces/nutrition-ai-6553a6e30a14f004a13d6dac/issues/gh/passiolife/ios-demo-app/581
                if isFromMyFavorites == true && isEditingFavorite == false {
                    record.uuid = UUID().uuidString
                    record.createdAt = editedTimestamp ?? record.createdAt
                }
                else {
                    connector.deleteRecord(foodRecord: record)
                    record.createdAt = editedTimestamp ?? record.createdAt
                }
                
            } else if isFromCustomFoodList || isFromRecipeList {
                record.uuid = UUID().uuidString
                record.createdAt = Date()
            }
            connector.updateRecord(foodRecord: record)
        }
        enableInteration(true)
        foodDetailsDelegate?.onAddFoodToLog(foodRecord: record)
    }

    @IBAction func onDelete(_ sender: UIButton) {
        if let foodRecord {
            foodDetailsDelegate?.onDelete(foodRecord: foodRecord)
        }
    }

    @IBAction func cancel(_ sender: UIButton) {
        foodDetailsDelegate?.onCancelFood()
    }

    @objc func addRemoveFavorites() {

        guard let foodRecord = foodRecord else { return }

        if favorites.count > 0 {
            connector.deleteFavorite(foodRecord: foodRecord)
            findViewController()?.showMessage(msg: ToastMessages.removedFavorite)
        } else {
            var favorite = foodRecord
            favorite.name = foodRecord.name.capitalized
            connector.updateFavorite(foodRecord: favorite)
            findViewController()?.showMessage(msg: ToastMessages.addedFavorite)
        }
        fetchFavorites()
    }

    @IBAction func onFoodAddINgredients(_ sender: UIButton) {
        foodDetailsDelegate?.onAddIngredient(foodRecord: foodRecord)
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

    @objc func onChangeUnit(sender: UIButton) {
        guard let servingUnits = foodRecord?.servingUnits else { return }
        let items = servingUnits.map { $0.unitName }
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
        guard newValue != foodRecord?.selectedQuantity,
              var tempFoodRecord = foodRecord else {
            return
        }
        newValue = newValue == 0 ? sizeOfAtTick/1000 : newValue
        _ = tempFoodRecord.setFoodRecordServing(unit: tempFoodRecord.selectedUnit, quantity: newValue)
        foodRecord = tempFoodRecord
    }

    @objc func makeRecipe() {
        foodDetailsDelegate?.onMakeRecipe()
    }

    @objc func goBack() {
        if let nav = findViewController()?.navigationController {
            nav.popViewController(animated: true)
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension FoodDetailsView: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        foodDetailsSection.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch foodDetailsSection[section] {

        case .foodInfoTableViewCell,
                .servingSizeTableViewCell,
                .mealTimeTableViewCell,
                .dateSelectionTableViewCell,
                .ingredientsTableViewCell:
            return 1

        case .ingredientInfoTableViewCell:
            if resultViewFor == .addIngredient {
                return foodRecord?.ingredients.count ?? 0
            }
            else {
                return ingredientsCount > 1 ? ingredientsCount : 0
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch foodDetailsSection[indexPath.section] {
        case .foodInfoTableViewCell: getFoodInfoCell(cellForRowAt: indexPath)
        case .servingSizeTableViewCell: getServingSizeCell(indexPath: indexPath)
        case .mealTimeTableViewCell: getMealTimeCell(indexPath: indexPath)
        case .dateSelectionTableViewCell: getDateSelectionCell(indexPath: indexPath)
        case .ingredientsTableViewCell: getIngredientsCell(indexPath: indexPath)
        case .ingredientInfoTableViewCell: getIngredientInfoCell(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch foodDetailsSection[indexPath.section]
        {
        case .ingredientInfoTableViewCell:
            if let foodRecord, foodRecord.ingredients.count >= 1 {
                foodDetailsDelegate?.onUserSelected(ingredient: foodRecord.ingredients[indexPath.row],
                                                    indexOfIngredient: indexPath.row)
            }
        default:
            break
        }
    }
}

// MARK: - FoodDetails TableViewCells
extension FoodDetailsView {

    func getFoodInfoCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let foodRecord = foodRecord else {
            return UITableViewCell()
        }
        let cell = foodDetailsTableView.dequeueCell(cellClass: FoodInfoTableViewCell.self,
                                         forIndexPath: indexPath)
        let isFavorite = favorites.count > 0 ? "heart.fill" : "heart"
        cell.favouriteButton.setImage(UIImage(systemName: isFavorite), for: .normal)
        cell.favouriteButton.tintColor = favorites.count > 0 ? .primaryColor : .gray400
        cell.favouriteButton.addTarget(self,
                                       action: #selector(addRemoveFavorites),
                                       for: .touchUpInside)
        cell.setup(foodRecord: foodRecord)
        cell.openFoodFactsButton.addTarget(self,
                                           action: #selector(onOpenFoodFacts),
                                           for: .touchUpInside)
        cell.moreDetailsButton.addTarget(self,
                                           action: #selector(onMoreDetails),
                                           for: .touchUpInside)
        return cell
    }

    func getServingSizeCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = foodDetailsTableView.dequeueCell(cellClass: ServingSizeTableViewCell.self,
                                         forIndexPath: indexPath)
        let (quantity, unitName, weight) = getAmountsforCell(tableRowOrCollectionTag: indexPath.row,
                                                             slider: cell.quantitySlider)
        cell.setup(quantity: quantity, unitName: unitName, weight: weight)
        cell.quantityTextField.delegate = self
        cell.unitButton.addTarget(self,
                                   action: #selector(onChangeUnit(sender:)),
                                   for: .touchUpInside)
        cell.quantitySlider.addTarget(self,
                                    action: #selector(onChangeQuantity(sender:)),
                                    for: .valueChanged)
        return cell
    }

    func getIngredientsCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = foodDetailsTableView.dequeueCell(cellClass: IngredientsTableViewCell.self,
                                         forIndexPath: indexPath)
        let title = ingredientsCount > 1 ? RecipeTexts.editRecipe : RecipeTexts.makeCustomRecipe
        cell.makeRecipeButton.setTitle(title, for: .normal)
        cell.makeRecipeButton.backgroundColor = .primaryColor
        cell.makeRecipeButton.addTarget(self, action: #selector(makeRecipe), for: .touchUpInside)
        if resultViewFor == .addIngredient {
            cell.makeRecipeButton.isHidden = true
        }
        return cell
    }

    func getIngredientInfoCell(indexPath: IndexPath) -> UITableViewCell {

        guard let foodRecord = foodRecord else {
            return UITableViewCell()
        }
        let cell = foodDetailsTableView.dequeueCell(cellClass: IngredientInfoTableViewCell.self,
                                         forIndexPath: indexPath)
        let ingredient = foodRecord.ingredients[indexPath.row]
        cell.setup(ingredient: ingredient,
                   isLastCell: foodRecord.ingredients.count == indexPath.row + 1)
        return cell
    }

    func getMealTimeCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = foodDetailsTableView.dequeueCell(cellClass: MealTimeTableViewCell.self,
                                         forIndexPath: indexPath)
        if let meal = foodRecord?.mealLabel {
            cell.setMealSelection(meal)
        }
        cell.delegate = self
        cell.insetBackgroundView.backgroundColor = .passioInsetColor
        return cell
    }

    func getDateSelectionCell(indexPath: IndexPath) -> UITableViewCell{
        let cell = foodDetailsTableView.dequeueCell(cellClass: DateSelectionTableViewCell.self, forIndexPath: indexPath)
//        if let editedDate = editedTimestamp {
//            cell.updateWithDate(editedDate)
//        } else if let record = foodRecord {
//            cell.updateWithDate(record.createdAt)
//        }
        cell.updateWithDate(editedTimestamp)
        cell.timestampButton.addTarget(self, action: #selector(showDateSelector), for: .touchUpInside)
        return cell
    }
}

// MARK: - FoodDetails Helper
private extension FoodDetailsView {

    func fetchFavorites() {
        connector.fetchFavorites { favorites in
            self.favorites = favorites.filter {
                $0.refCode == self.foodRecord?.refCode
            }
            DispatchQueue.main.async {
                self.foodDetailsTableView.reloadData()
            }
        }
    }

    func getAmountsforCell(tableRowOrCollectionTag: Int,
                           slider: UISlider) -> (quantity: Double,
                                                 unitName: String,
                                                 weight: String) {
        slider.minimumValue = 0.0
        slider.tag = tableRowOrCollectionTag
        guard let foodRecord = foodRecord else { return(100, UnitsTexts.cGrams, "100") }
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

    var getFoodData: FoodData? {
        if let foodRecord {
            return FoodData(name: foodRecord.name,
                            barcode: foodRecord.barcode,
                            icon: getFoodImage,
                            nutritionInfo: MicroNutirents.getMicroNutrientsFromFood(records: [foodRecord]))
        }
        return nil
    }

    var getFoodImage: UIImage {
        let cell = foodDetailsTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? FoodInfoTableViewCell
        return cell?.imageFood.image ?? UIImage()
    }
}

// MARK: - UITextField Delegate
extension FoodDetailsView: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if let text = textField.text, text.contains("."), string == "." {
            return false
        } else {
            return true
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let quantity = Double(textField.replaceCommaWithDot),
           var tempfoodRecord = foodRecord {
            _ = tempfoodRecord.setFoodRecordServing(unit: tempfoodRecord.selectedUnit,
                                                    quantity: quantity)
            foodRecord = tempfoodRecord
        }
        foodDetailsTableView.reloadData()
    }
}

// MARK: - DateSelectorUIView Delegate
extension FoodDetailsView: DateSelectorUIViewDelegate {

    @objc func showDateSelector() {
        dateSelector = DateSelectorViewController()
        dateSelector?.delegate = self
        dateSelector?.dateForPicker = self.editedTimestamp ?? self.foodRecord?.createdAt ?? Date()
        dateSelector?.modalPresentationStyle = .overFullScreen
        findViewController()?.navigationController?.presentVC(vc: dateSelector!)
    }

    func removeDateSelector(remove: Bool) {
        dateSelector?.dismiss(animated: false)
    }

    func dateFromPicker(date: Date) {
        editedTimestamp = date
    }
}

// MARK: - MealSelection Delegate
extension FoodDetailsView: MealSelectionDelegate {

    func didChangeMealSelection(selection: MealLabel) {
        foodRecord?.mealLabel = selection
    }
}

// MARK: - CustomPickerSelection Delegate
extension FoodDetailsView: CustomPickerSelectionDelegate {

    func onPickerSelection(value: String, selectedIndex: Int, viewTag: Int) {
        _ = foodRecord?.setSelectedUnit(unit: value)
    }
}
