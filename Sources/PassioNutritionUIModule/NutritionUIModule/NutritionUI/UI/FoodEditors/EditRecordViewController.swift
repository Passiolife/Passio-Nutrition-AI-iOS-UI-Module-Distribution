//
//  EditRecordViewController.swift
//  Passio App Module
//
//  Created by zvika on 3/28/19.
//  Copyright © 2023 PassioLife Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

protocol EditRecordViewControllerDelegate: AnyObject {
    func deleteFromEdit(foodRecord: FoodRecordV3)
}

final class EditRecordViewController: UIViewController {

    private let connector = PassioInternalConnector.shared
    private var foodEditorView: FoodEditorView?
    private var replaceFood = false

    var foodRecord: FoodRecordV3?
    var isEditingFavorite = false
    var isEditingRecord = false

    weak var delegate: FoodEditorDelegate?
    weak var delegateDelete: EditRecordViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Edit"

        let nib = UINib.nibFromBundle(nibName: "FoodEditorView")
        foodEditorView = nib.instantiate(withOwner: self, options: nil).first as? FoodEditorView
        foodEditorView?.delegate = self
        foodEditorView?.isEditingFavorite = isEditingFavorite
        foodEditorView?.isEditingRecord = isEditingRecord
        foodEditorView?.foodRecord = foodRecord
        foodEditorView?.saveToConnector = !isEditingFavorite

        if let foodEditorView = foodEditorView {
            view.addSubview(foodEditorView)
        }

        setupBackButton()
        setupRightNavigationButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        foodEditorView?.frame = view.bounds
    }

    func setupRightNavigationButton() {
        let image = isEditingRecord || isEditingFavorite ? "edit_icon" : "swap_arrow"
        let action: Selector = isEditingRecord || isEditingFavorite ? #selector(onNavigateToCreateFood) : #selector(swapFood)
        let rightButton = UIBarButtonItem(image: UIImage.imageFromBundle(named: image),
                                          style: .plain,
                                          target: self,
                                          action: action)
        rightButton.tintColor = .gray400
        navigationItem.rightBarButtonItem = rightButton
    }

    @objc func onNavigateToCreateFood() {
        guard let foodRecord = foodRecord else { return }
        if foodRecord.entityType == .recipe {
            // Navigate to Recipe editor
        } else {
            let createFoodVC = CreateFoodViewController(nibName: "CreateFoodViewController", bundle: .module)
            createFoodVC.loadViewIfNeeded()
            createFoodVC.isCreateNewFood = false
            createFoodVC.isFromFoodEdit = true
            createFoodVC.foodRecord = foodRecord
            navigationController?.pushViewController(createFoodVC, animated: true)
        }
    }

    @objc func swapFood() {
        replaceFoodUsingSearch()
    }
}

// MARK: - FoodEditor Delegate
extension EditRecordViewController: FoodEditorDelegate {

    func addFoodToLog(foodRecord: FoodRecordV3, removeViews: Bool) {

        displayAdded()
        if isEditingFavorite {
            connector.updateFavorite(foodRecord: foodRecord)
            navigationController?.popViewController(animated: true)
        } else {
            if !isEditingRecord {
                self.showMessage(msg: "Added to log")
            }
            NutritionUICoordinator.navigateToDairyAfterAction(
                navigationController: self.navigationController,
                selectedDate: foodRecord.createdAt
            )
        }
    }

    func displayAdded() {

        let width: CGFloat = 200
        let height: CGFloat = 40
        let fromButton: CGFloat = 100
        let frame = CGRect(x: (view.bounds.width - width)/2,
                           y: view.bounds.height - fromButton,
                           width: width,
                           height: height)
        let addedToLog = AddedToLogView(frame: frame, withText: "Item added to the log")
        view.addSubview(addedToLog)
        addedToLog.removeAfter(withDuration: 1, delay: 1)
    }

    func foodEditorCancel() {
        navigationController?.popViewController(animated: true)
    }

    func userSelected(ingredient: FoodRecordIngredient, indexOfIngredient: Int) {

        let editVC = EditIngredientViewController()
        editVC.foodItemData = ingredient
        editVC.indexOfIngredient = indexOfIngredient
        editVC.delegate = self
        navigationController?.pushViewController(editVC, animated: true)
    }

    func foodEditorSearchText() {
        goToAdvancedSearch()
    }

    func replaceFoodUsingSearch() {
        goToAdvancedSearch(isFoodReplace: true)
    }

    func delete(foodRecord: FoodRecordV3) {
        delegateDelete?.deleteFromEdit(foodRecord: foodRecord)
        navigationController?.popViewController(animated: true)
    }

    private func goToAdvancedSearch(isFoodReplace: Bool = false) {
        replaceFood = isFoodReplace
        let textSearchVC = TextSearchViewController()
        textSearchVC.advancedSearchDelegate = self
        textSearchVC.shouldPopVC = false
        navigationController?.pushViewController(textSearchVC, animated: true)
    }

    func showVolumeEstimationViews(foodRecord: FoodRecordV3?) { }
    func rescanVolume() { }
    func animateMicroTotheLeft() { }
}

// MARK: - IngredientEditorView Delegate
extension EditRecordViewController: IngredientEditorViewDelegate {

    func ingredientEditedFoodItemData(ingredient: FoodRecordIngredient, atIndex: Int) {
        foodEditorView?.foodRecord?.replaceIngredient(updatedIngredient: ingredient,
                                                      atIndex: atIndex)
    }

    func goToSearchManully() { }
    func ingredientEditedCancel() { }
    func startNutritionBrowser(foodItemData: FoodRecordIngredient) { }
}

// MARK: - AdvancedTextSearchView Delegate
extension EditRecordViewController: AdvancedTextSearchViewDelegate {

    func userSelectedFood(record: FoodRecordV3?, isPlusAction: Bool) {

        if let foodRecord = record {
            if replaceFood { // Replace Food
                var foodRecord = foodRecord
                if let uuid = foodEditorView?.foodRecord?.uuid {
                    foodRecord.createdAt = foodEditorView?.foodRecord?.createdAt ?? Date()
                    foodRecord.uuid = uuid
                }
                foodEditorView?.foodRecord = foodRecord
            } else { // Add Ingredients
                foodEditorView?.foodRecord?.addIngredient(record: foodRecord)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] () in
            guard let `self` = self else { return }
            self.foodEditorView?.tableView.scrollToBottom()
        }
        navigationController?.popViewController(animated: true)
    }

    func userSelectedFoodItem(item: PassioFoodItem?, isPlusAction: Bool) {

        if let foodItem = item {
            if replaceFood { // Replace Food
                var foodRecord = FoodRecordV3(foodItem: foodItem)
                if let uuid = foodEditorView?.foodRecord?.uuid {
                    foodRecord.createdAt = foodEditorView?.foodRecord?.createdAt ?? Date()
                    foodRecord.uuid = uuid
                }
                foodEditorView?.foodRecord = foodRecord
            } else { // Add Ingredients
                foodEditorView?.foodRecord?.addIngredient(record: FoodRecordV3(foodItem: foodItem))
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] () in
            guard let `self` = self else { return }
            self.foodEditorView?.tableView.scrollToBottom()
        }

        navigationController?.popViewController(animated: true)
    }
}
