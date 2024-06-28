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

final class CreateFoodViewController: InstantiableViewController {

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var createFoodTableView: UITableView!

    private let createFoodSections: [CreateFoodSection] = [.foodDetail,
                                                           .requiredNutritions,
                                                           .otherNutritions]
    private let connector = PassioInternalConnector.shared
    private enum CreateFoodSection {
        case foodDetail
        case requiredNutritions
        case otherNutritions
    }
    var foodDataSet: NutritionFactsDataSet?
    var foodRecord: FoodRecordV3? {
        didSet {
            DispatchQueue.main.async {
                self.createFoodTableView.reloadData()
            }
        }
    }
    var isCreateNewFood = true
    var isFromFoodEdit = false
    var isFromNutritionFacts = false

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Food Creator"
        setupBackButton()
        configureTableView()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    private func configureTableView() {

        createFoodTableView.dataSource = self
        createFoodTableView.register(nibName: "FoodDetailsTableViewCell")
        createFoodTableView.register(nibName: "RequiredNutritionsTableViewCell")
        createFoodTableView.register(nibName: "OtherNutritionsTableViewCell")
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

    // MARK: @IBAction
    @IBAction func onCancel(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func onSave(_ sender: UIButton) {

        view.endEditing(true)
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()

        guard let getFoodDetailCell,
              let getRequiredNutritionsCell else {
            activityIndicatorView.isHidden = true
            return
        }

        let foodDetails = getFoodDetailCell.getFoodDetails
        let isFoodDetailsValid = getFoodDetailCell.isFoodDetailsValid
        let isRequiredNutritionsValid = getRequiredNutritionsCell.isRequiredNutritionsValid

        if isFoodDetailsValid.0 && isRequiredNutritionsValid.0 {

            if isCreateNewFood || isFromFoodEdit {
                createNewFoodRecord(foodDetails: foodDetails)
                activityIndicatorView.isHidden = true
                if isCreateNewFood {
                    navigationController?.popViewController(animated: true)
                } else if isFromFoodEdit {
                    NutritionUICoordinator.navigateToDairyAfterAction(
                        navigationController: self.navigationController
                    )
                    let vc = MyFoodsSelectionViewController()
                    navigationController?.pushViewController(vc, animated: true)
                }

            } else {
                editFoodRecord(foodDetails: foodDetails)
            }

        } else {
            activityIndicatorView.isHidden = true
            let errorMsg = (isFoodDetailsValid.1 ?? "") + "\n" + (isRequiredNutritionsValid.1 ?? "")
            showAlertWith(titleKey: errorMsg, view: parent ?? self)
        }
    }
}

// MARK: - Helper methods
extension CreateFoodViewController {

    private func createNewFoodRecord(foodDetails: FoodDetailsTableViewCell.FoodDetails) {
        if let foodItem = getFoodDataSet.updatedNutritionFacts?.fromNutritionFacts(foodName: foodDetails.name,
                                                                                   brand: foodDetails.brand ?? "") {

            var record = FoodRecordV3(foodItem: foodItem,
                                      barcode: foodDetails.barcode ?? "",
                                      entityType: .item)
            record.iconId = "userFood.\(record.iconId)"
            connector.updateUserFood(record: record, isNew: true)
            connector.updateUserFoodImage(with: record.iconId, image: foodDetails.image.get180pImage)
        }
    }

    private func editFoodRecord(foodDetails: FoodDetailsTableViewCell.FoodDetails) {

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
        
        connector.updateUserFood(record: record, isNew: true)
        connector.updateUserFoodImage(with: record.iconId, image: foodDetails.image.get180pImage)
        activityIndicatorView.isHidden = true
        navigationController?.popViewController(animated: true)
    }

    private func navigateToEditViewContorller(_ record: FoodRecordV3) {
        let editVC = EditRecordViewController()
        editVC.foodRecord = record
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] () in
            guard let self else { return }
            navigationController?.pushViewController(editVC, animated: true)
        })
    }

    private func navigateToBarcodeViewController() {

        let foodRecognisationStoryboard = UIStoryboard(name: "FoodRecognisation", bundle: .module)
        let barcodeRecogniserVC = foodRecognisationStoryboard.instantiateViewController(
            withIdentifier: "BarcodeRecogniserViewController"
        ) as! BarcodeRecogniserViewController
        barcodeRecogniserVC.delegate = self
        navigationController?.pushViewController(barcodeRecogniserVC, animated: true)
    }

    private func getImagePickerAndSetupUI(withSourceType: UIImagePickerController.SourceType) {
        view.endEditing(true)
        let picker = UIImagePickerController()
        picker.sourceType = withSourceType
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    private var getFoodDataSet: NutritionFactsDataSet {
        if isCreateNewFood {
            foodDataSet ?? NutritionFactsDataSet(nutritionFacts: PassioNutritionFacts())
        } else {
            NutritionFactsDataSet(nutritionFacts: foodRecord?.getNutritionFacts ?? PassioNutritionFacts())
        }
    }

    private var getFoodDetailCell: FoodDetailsTableViewCell? {
        createFoodTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? FoodDetailsTableViewCell
    }

    private var getRequiredNutritionsCell: RequiredNutritionsTableViewCell? {
        createFoodTableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? RequiredNutritionsTableViewCell
    }

    private var getOtherNutritionsTableViewCell: OtherNutritionsTableViewCell? {
        createFoodTableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? OtherNutritionsTableViewCell
    }

    private func refreshTableView() {
        UIView.performWithoutAnimation {
            createFoodTableView.beginUpdates()
            createFoodTableView.endUpdates()
        }
    }
}

// MARK: - UITableViewDataSource
extension CreateFoodViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        createFoodSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch createFoodSections[section] {
        case .foodDetail, .requiredNutritions, .otherNutritions: 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch createFoodSections[indexPath.section] {

        case .foodDetail:
            let cell = tableView.dequeueCell(cellClass: FoodDetailsTableViewCell.self, forIndexPath: indexPath)
            if !isCreateNewFood, let foodRecord = self.foodRecord {
                cell.configureCell(with: foodRecord)
            }
            cell.onBarcode = { [weak self] in
                self?.navigateToBarcodeViewController()
            }
            cell.onCreateFoodImage = { [weak self] (imageSource) in
                self?.getImagePickerAndSetupUI(withSourceType: imageSource)
            }
            return cell

        case .requiredNutritions:
            let cell = tableView.dequeueCell(cellClass: RequiredNutritionsTableViewCell.self,
                                             forIndexPath: indexPath)
            cell.configureCell(with: getFoodDataSet,
                               isCreateNewFood: isCreateNewFood,
                               isFromNutritionFacts: isFromNutritionFacts)
            cell.foodDataSetDelegate = self
            return cell

        case .otherNutritions:
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
        if let getRequiredNutritionsCell {
            getRequiredNutritionsCell.foodDataSet = updatedData
        }
        if let getOtherNutritionsTableViewCell {
            getOtherNutritionsTableViewCell.foodDataSet = updatedData
        }
    }
}

// MARK: - BarcodeRecogniser Delegate
extension CreateFoodViewController: BarcodeRecogniserDelegate {

    func onBarcodeDetected(barcode: String?, record: FoodRecordV3?, isUserFoodBarcode: Bool) {

        isCreateNewFood = isUserFoodBarcode

        if let getFoodDetailCell, let barcode {
            getFoodDetailCell.barcodeTextField.text = barcode
        }
        if var record {
            record.barcode = barcode ?? ""
            var passioID = UUID().uuidString.replacingOccurrences(of: "-", with: "")
            passioID = PassioIDEntityType.barcode.rawValue + passioID
            record.iconId = "userFood.\(passioID)"
            foodRecord = record
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
                guard let self, let getFoodDetailCell else { return }
                getFoodDetailCell.createFoodImageView.image = pickedImage
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
