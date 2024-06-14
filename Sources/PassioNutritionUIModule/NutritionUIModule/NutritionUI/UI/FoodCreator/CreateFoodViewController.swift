//
//  CreateFoodViewController.swift
//  BaseApp
//
//  Created by Nikunj Prajapati on 30/04/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit
import PassioNutritionAISDK

protocol FoodDataSetCellDelegate: AnyObject {
    func updateFoodDataSet(with newData: NutritionFactsDataSet?)
}

final class CreateFoodViewController: InstantiableViewController {

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
    var isFromFoodScanner = false

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Create Your Food"
        setupBackButton()
        configureTableView()
        connector.deleteAllUserFood()
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

        guard let getFoodDetailCell,
              let getRequiredNutritionsCell else {
            return
        }

        let foodDetails = getFoodDetailCell.getFoodDetails
        let isFoodDetailsValid = getFoodDetailCell.isFoodDetailsValid
        let isRequiredNutritionsValid = getRequiredNutritionsCell.isRequiredNutritionsValid

        if isFoodDetailsValid.0 && isRequiredNutritionsValid.0 {

            if let foodItem = getFoodDataSet.updatedNutritionFacts?.fromNutritionFacts(foodName: foodDetails.name,
                                                                                       brand: foodDetails.brand ?? "") {

                var record = FoodRecordV3(foodItem: foodItem,
                                          barcode: foodDetails.barcode,
                                          entityType: .item)
                let userFoodImgId = "userFood.\(record.iconId)"
                record.iconId = userFoodImgId
                connector.updateUserFood(record: record, isNew: true)
                connector.updateUserFoodImage(with: record.iconId, image: foodDetails.image)
                navigateToEditViewContorller(record)
            }

        } else {
            let errorMsg = (isFoodDetailsValid.1 ?? "") + "\n" + (isRequiredNutritionsValid.1 ?? "")
            showAlertWith(titleKey: errorMsg, view: parent ?? self)
        }
    }
}

// MARK: - Helper methods
extension CreateFoodViewController {

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

        barcodeRecogniserVC.barcodeValue = { [weak self] barcode in
            guard let self, let getFoodDetailCell else { return }
            getFoodDetailCell.barcodeTextField.text = barcode
        }

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
        foodDataSet ?? NutritionFactsDataSet(nutritionFacts: PassioNutritionFacts())
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

// MARK: - UITableView DataSource
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
            cell.onBarcode = { [weak self] in
                self?.navigateToBarcodeViewController()
            }
            cell.onCreateFoodImage = { [weak self] (imageSource) in
                self?.getImagePickerAndSetupUI(withSourceType: imageSource)
            }
            return cell

        case .requiredNutritions:
            let cell = tableView.dequeueCell(cellClass: RequiredNutritionsTableViewCell.self, forIndexPath: indexPath)
            cell.configureCell(with: getFoodDataSet, isFromFoodScanner: self.isFromFoodScanner)
            cell.foodDataSetDelegate = self
            return cell

        case .otherNutritions:
            let cell = tableView.dequeueCell(cellClass: OtherNutritionsTableViewCell.self, forIndexPath: indexPath)
            cell.configureCell(with: getFoodDataSet)
            cell.foodDataSetDelegate = self
            cell.reloadCell = { [weak self] in
                self?.refreshTableView()
            }
            return cell
        }
    }
}

// MARK: - UITableView DataSource
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
