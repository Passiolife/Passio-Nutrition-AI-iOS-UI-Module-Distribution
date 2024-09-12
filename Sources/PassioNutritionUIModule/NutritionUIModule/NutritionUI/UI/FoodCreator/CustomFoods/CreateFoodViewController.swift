//
//  CreateFoodViewController.swift
//  BaseApp
//
//  Created by Nikunj Prajapati on 30/04/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

protocol FoodDataSetCellDelegate: AnyObject {
    func updateFoodDataSet(with newData: NutritionFactsDataSet?)
}
protocol NavigateToDiaryDelegate: AnyObject {
    func onSaveNavigateToDiary(isUpdateLog: Bool)
}
protocol NavigateToMyFoodsDelegate: AnyObject {
    func onNavigateToMyFoods()
}

final class CreateFoodViewController: InstantiableViewController {

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var createFoodTableView: UITableView!

    private let createFoodSections: [CreateFoodSection] = [.foodDetailsTableViewCell,
                                                           .requiredNutritionsTableViewCell,
                                                           .otherNutritionsTableViewCell]
    private let connector = PassioInternalConnector.shared

    private enum CreateFoodSection: String, CaseIterable {
        case foodDetailsTableViewCell
        case requiredNutritionsTableViewCell
        case otherNutritionsTableViewCell
    }

    var vcTitle = "Food Creator"
    var foodDataSet: NutritionFactsDataSet?
    var loggedFoodRecord: FoodRecordV3?

    var isCreateNewFood = true
    var isFromCustomFoodList = false
    var isFromBarcode = false
    var isEditingExistingFood = false
    var isUpdateLog = true
    var isFromNutritionFacts = false
    var isBarcodeExistInFoodList = false
    var isFromSearch = false

    var foodRecord: FoodRecordV3? {
        didSet {
            configureUserFood()
        }
    }

    weak var delegate: NavigateToDiaryDelegate?
    weak var navigateToMyFoodsDelegate: NavigateToMyFoodsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackButton()

        cancelButton.setTitleColor(.primaryColor, for: .normal)
        cancelButton.applyBorder(width: 2, color: .primaryColor)
        saveButton.backgroundColor = .primaryColor
        deleteButton.isHidden = !isFromCustomFoodList

        configureTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        title = vcTitle
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    // MARK: @IBAction
    @IBAction func onCancel(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func onDelete(_ sender: UIButton) {
        if let foodRecord {
            connector.deleteUserFood(record: foodRecord)
            navigationController?.popToSpecificViewController(MyFoodsSelectionViewController.self)
        }
    }

    @IBAction func onSave(_ sender: UIButton) {

        view.endEditing(true)

        guard let getFoodDetailCell = getCell(section: 0) as? FoodDetailsTableViewCell,
              let getRequiredNutritionsCell = getCell(section: 1) as? RequiredNutritionsTableViewCell else {
            return
        }

        let foodDetails = getFoodDetailCell.getFoodDetails
        let isFoodDetailsValid = getFoodDetailCell.isFoodDetailsValid
        let isRequiredNutritionsValid = getRequiredNutritionsCell.isRequiredNutritionsValid

        if isFoodDetailsValid.0 && isRequiredNutritionsValid.0 {

            if isCreateNewFood {
                createNewFoodRecord(foodDetails: foodDetails)
                if isFromNutritionFacts {
                    navigateToMyFoodsDelegate?.onNavigateToMyFoods()
                    navigationController?.popViewController(animated: true)
                } else {
                    navigationController?.popViewController(animated: true)
                }

            } else {
                editSaveFoodRecord(foodDetails: foodDetails)
            }

        } else {
            let errorMsg = (isFoodDetailsValid.1 ?? "") + "\n" + (isRequiredNutritionsValid.1 ?? "")
            showAlertWith(titleKey: errorMsg, view: parent ?? self)
        }
    }
}

// MARK: - Helper methods
extension CreateFoodViewController {

    private func configureTableView() {

        createFoodTableView.dataSource = self
        CreateFoodSection.allCases.forEach {
            createFoodTableView.register(nibName: $0.rawValue.capitalizingFirst())
        }
        createFoodTableView.estimatedRowHeight = 300
        createFoodTableView.rowHeight = UITableView.automaticDimension

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    private func createNewFoodRecord(foodDetails: FoodDetailsTableViewCell.FoodDetails) {
        if let foodItem = getFoodDataSet.updatedNutritionFacts?.fromNutritionFacts(foodName: foodDetails.name,
                                                                                   brand: foodDetails.brand ?? "") {

            var record = FoodRecordV3(foodItem: foodItem,
                                      barcode: foodDetails.barcode ?? "",
                                      entityType: .item)
            record.iconId = record.iconId.contains("userFood") ? record.iconId : "userFood.\(record.iconId).\(record.createdAt)"
            connector.updateUserFood(record: record)
            connector.updateUserFoodImage(with: record.iconId, image: foodDetails.image.get180pImage)
        }
    }

    private func editSaveFoodRecord(foodDetails: FoodDetailsTableViewCell.FoodDetails) {

        guard var record = foodRecord else { return }

        record.name = foodDetails.name
        record.details = foodDetails.brand ?? ""
        record.barcode = foodDetails.barcode ?? ""

        if let foodItem = foodDataSet?.updatedNutritionFacts?.fromNutritionFacts(foodName: foodDetails.name,
                                                                                 brand: foodDetails.brand ?? "") {
            record.servingSizes = foodItem.amount.servingSizes
            record.servingUnits = foodItem.amount.servingUnits
            _ = record.setSelectedUnit(unit: foodItem.amount.selectedUnit)
            record.setSelectedQuantity(quantity: foodItem.amount.selectedQuantity)
            record.ingredients = foodItem.ingredients.map { FoodRecordIngredient(ingredient: $0) }
            record.calculateQuantityForIngredients()
            _ = record.setFoodRecordServing(unit: record.selectedUnit,
                                            quantity: record.selectedQuantity)
        }

        record.iconId = record.iconId.contains("userFood") ? record.iconId : "userFood.\(record.iconId)"
        record.refCode = record.refCode.contains("userFood") ? record.refCode : "userFood.\(record.refCode)"

        if isEditingExistingFood {
            connector.deleteUserFood(record: record)
        }
        connector.updateUserFood(record: record)
        connector.updateUserFoodImage(with: record.iconId, image: foodDetails.image.get180pImage)

        if isFromCustomFoodList {
            navigationController?.popToSpecificViewController(MyFoodsSelectionViewController.self)

        } else if isFromBarcode {
            navigationController?.popToSpecificViewController(MyFoodsSelectionViewController.self)

        } else {

            if isUpdateLog {

                if let loggedFoodRecord {
                    record.uuid = loggedFoodRecord.uuid
                    record.createdAt = loggedFoodRecord.createdAt
                    record.mealLabel = loggedFoodRecord.mealLabel
                    connector.deleteRecord(foodRecord: loggedFoodRecord)
                } else {
                    connector.deleteRecord(foodRecord: record)
                }

                DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 0.2) {
                    self.connector.updateRecord(foodRecord: record)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.navigationController?.popToSpecificViewController(HomeTabBarController.self)
                }

            } else {
                delegate?.onSaveNavigateToDiary(isUpdateLog: false)
                navigationController?.popToSpecificViewController(HomeTabBarController.self)
            }
        }
    }

    private func navigateToBarcodeViewController() {

        let foodRecognisationStoryboard = UIStoryboard(name: "FoodRecognisation", bundle: .module)
        let barcodeRecogniserVC = foodRecognisationStoryboard.instantiateViewController(
            withIdentifier: BarcodeRecogniserViewController.className
        ) as! BarcodeRecogniserViewController
        barcodeRecogniserVC.delegate = self
        navigationController?.pushViewController(barcodeRecogniserVC, animated: true)
    }

    private func configureUserFood() {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self else { return }
            checkIsBarcodeAlreadyExistsForAFood { isBarcodeExist in
                self.isBarcodeExistInFoodList = isBarcodeExist
                DispatchQueue.main.async {
                    self.createFoodTableView.reloadData()
                }
            }
        }
    }

    private func checkIsBarcodeAlreadyExistsForAFood(completion: @escaping (Bool) -> Void) {

        if let barcode = foodRecord?.barcode, barcode != "" {
            connector.fetchUserFoods(barcode: barcode) { userFoods in
                if let _ = userFoods.first {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        } else {
            completion(false)
        }
    }

    private var getFoodDataSet: NutritionFactsDataSet {
        if isCreateNewFood {
            foodDataSet ?? NutritionFactsDataSet(nutritionFacts: PassioNutritionFacts())
        } else {
            NutritionFactsDataSet(nutritionFacts: foodRecord?.getNutritionFacts ?? PassioNutritionFacts())
        }
    }

    private func getCell<T: UITableViewCell>(section: Int) -> T? {
        createFoodTableView.cellForRow(at: IndexPath(row: 0, section: section)) as? T
    }

    private func refreshTableView() {
        UIView.performWithoutAnimation {
            createFoodTableView.beginUpdates()
            createFoodTableView.endUpdates()
        }
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardRectValue = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as?
                                    NSValue)?.cgRectValue {
            createFoodTableView.contentInset = UIEdgeInsets(top: 0,
                                                            left: 0,
                                                            bottom: keyboardRectValue.height - 75,
                                                            right: 0)
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        createFoodTableView.contentInset = .zero
    }
}

// MARK: - UITableViewDataSource
extension CreateFoodViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        createFoodSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch createFoodSections[indexPath.section] {

        case .foodDetailsTableViewCell:
            let cell = tableView.dequeueCell(cellClass: FoodDetailsTableViewCell.self, forIndexPath: indexPath)
            if !isCreateNewFood, let foodRecord {
                
                cell.configureCell(with: foodRecord,
                                   barcode: isBarcodeExistInFoodList && !isEditingExistingFood ? "" : foodRecord.barcode)
            }
            cell.onBarcode = { [weak self] in
                self?.navigateToBarcodeViewController()
            }
            cell.onCreateFoodImage = { [weak self] (sourceType) in
                guard let self else { return }
                self.presentImagePicker(withSourceType: sourceType, delegate: self)
            }
            return cell

        case .requiredNutritionsTableViewCell:
            let cell = tableView.dequeueCell(cellClass: RequiredNutritionsTableViewCell.self,
                                             forIndexPath: indexPath)
            cell.configureCell(with: getFoodDataSet,
                               isCreateNewFood: isCreateNewFood,
                               isFromNutritionFacts: isFromNutritionFacts)
            cell.foodDataSetDelegate = self
            return cell

        case .otherNutritionsTableViewCell:
            let cell = tableView.dequeueCell(cellClass: OtherNutritionsTableViewCell.self,
                                             forIndexPath: indexPath)
            cell.configureCell(with: getFoodDataSet)
            cell.foodDataSetDelegate = self
            cell.reloadCell = { [weak self] in
                self?.refreshTableView()
            }
            return cell
        }
    }
}

// MARK: - FoodDataSetCell Delegate
extension CreateFoodViewController: FoodDataSetCellDelegate {

    func updateFoodDataSet(with newData: NutritionFactsDataSet?) {
        foodDataSet = newData
        updateFoodDataForCell(with: foodDataSet)
    }

    private func updateFoodDataForCell(with updatedData: NutritionFactsDataSet?) {
        if let getRequiredNutritionsCell = getCell(section: 1) as? RequiredNutritionsTableViewCell {
            getRequiredNutritionsCell.foodDataSet = updatedData
        }
        if let getOtherNutritionsTableViewCell = getCell(section: 2) as? OtherNutritionsTableViewCell {
            getOtherNutritionsTableViewCell.foodDataSet = updatedData
        }
    }
}

// MARK: - BarcodeRecogniser Delegate
extension CreateFoodViewController: BarcodeRecogniserDelegate {

    func onBarcodeDetected(barcode: String?) {
        if let getFoodDetailCell = getCell(section: 0) as? FoodDetailsTableViewCell,
           let barcode {
            getFoodDetailCell.barcodeTextField.text = barcode
        }
    }
}

// MARK: - UIImagePickerController Delegate
extension CreateFoodViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        picker.dismiss(animated: true)

        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            DispatchQueue.main.async { [weak self] in
                guard let self,
                      let getFoodDetailCell = getCell(section: 0) as? FoodDetailsTableViewCell else { return }
                getFoodDetailCell.createFoodImageView.image = pickedImage
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
