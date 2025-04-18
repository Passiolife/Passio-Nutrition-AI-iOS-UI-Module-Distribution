//
//  FoodDetailsViewController.swift
//
//  Created by zvika on 3/28/19.
//  Copyright © 2023 PassioLife Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

protocol FoodDetailsControllerDelegate: AnyObject {
    func deleteFromEdit(foodRecord: FoodRecordV3)
    func navigateToMyFoods(index: Int)
    func onFoodDetailsAddIngredient(foodRecord: FoodRecordV3?)
}

extension FoodDetailsControllerDelegate {
    func deleteFromEdit(foodRecord: FoodRecordV3) { }
    func navigateToMyFoods(index: Int) { }
    func onAddIngredient(foodRecord: FoodRecordV3?) { }
}

// MARK: - FoodDetailsViewController
final class FoodDetailsViewController: UIViewController {

    private var activityIndicator: UIActivityIndicatorView?
    private let connector = NutritionUIModule.shared
    private var foodDetailsView: FoodDetailsView?
    private var replaceFood = false
    private var isUpdateLogUponCreating = true
    private var isRecipe = false
    private var isMakeRecipe = false

    var userFood: FoodRecordV3?
    var recipe: FoodRecordV3?
    var foodRecord: FoodRecordV3?
    var isEditingFavorite = false
    var isEditingRecord = false
    var isFromSearch = false
    var isFromCustomFoodList = false
    var isFromBarcode = false
    var isFromRecipeList = false
    var isFromMyFavorites = false
    
    weak var delegate: FoodDetailsDelegate?
    weak var foodDetailsControllerDelegate: FoodDetailsControllerDelegate?
    
    /* As we don't need to make any logs from Favorite Food -> Food Details we ignore default set value,
     * we need only addIngredient enum to check if user redirect form Create/Edit Recipe screen or not.
     */
    var resultViewFor: DetectedFoodResultType = .addLog

    override func viewDidLoad() {
        super.viewDidLoad()

        title = FoodDetailsTexts.foodDetails

        let nib = UINib.nibFromBundle(nibName: FoodDetailsView.className)
        foodDetailsView = nib.instantiate(withOwner: self, options: nil).first as? FoodDetailsView
        foodDetailsView?.foodDetailsDelegate = self
        foodDetailsView?.isFromMyFavorites = isFromMyFavorites
        foodDetailsView?.isEditingFavorite = isEditingFavorite
        foodDetailsView?.isEditingRecord = isEditingRecord
        foodDetailsView?.configureTableView()
        foodDetailsView?.foodRecord = foodRecord
        foodDetailsView?.saveToConnector = !isEditingFavorite
        foodDetailsView?.isFromCustomFoodList = isFromCustomFoodList
        foodDetailsView?.isFromRecipeList = isFromRecipeList
        foodDetailsView?.resultViewFor = resultViewFor
        if resultViewFor == .addIngredient {
            foodDetailsView?.adjustBottomButton()
        }
        if let foodEditorView = foodDetailsView {
            view.addSubview(foodEditorView)
        }

        setupBackButton()
        activityIndicator = createActivityIndicator(themeColor: .primaryColor)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let foodRecord = foodRecord else { return }

        foodDetailsView?.frame = view.bounds

        fetchUserFoods(completion: { _ in })
        fetchRecipes(completion: { _ in })

        isRecipe = foodRecord.entityType == .recipe && foodRecord.ingredients.count > 1
        if resultViewFor != .addIngredient {
            if !isRecipe {
                setupRightNavigationButton()
            }
        }
    }
}

// MARK: - FoodDetails Helper
private extension FoodDetailsViewController {

    func setupRightNavigationButton() {
        let editFoodAction = UIAction(title: "") { [weak self] (action) in
            self?.onEditFood(isEditFood: true)
        }
        let rightButton = UIBarButtonItem(title: "",
                                          image: UIImage.imageFromBundle(named: "edit_icon"),
                                          primaryAction: editFoodAction,
                                          menu: nil)
        rightButton.tintColor = .gray400
        navigationItem.rightBarButtonItem = rightButton
    }

    func onEditFood(isEditFood: Bool) {

        if let foodRecord {

            if isFromCustomFoodList || isFromRecipeList {
                if isRecipe {
                    navigateToEditRecipe(with: foodRecord,
                                         vcTitle: RecipeTexts.editRecipe,
                                         isEditingExistingRecipe: true)
                } else {
                    navigateToCreateFood(with: foodRecord,
                                         isFromCustomFoodsList: true,
                                         isEditingExistingFood: true)
                }

            } else {

                isMakeRecipe = !isEditFood && !isRecipe

                activityIndicator?.startAnimating()
                let createFoodAlertVC = CreateFoodAlertViewController()
                createFoodAlertVC.delegate = self
                createFoodAlertVC.isHideLogSwitch = !isEditingRecord

                if isRecipe || isMakeRecipe {

                    createFoodAlertVC.isRecipe = true

                    if let _ = recipe {
                        createFoodAlertVC.isUserRecipe = true
                    } else if isMakeRecipe, let _ = userFood {
                        createFoodAlertVC.isUserRecipe = false
                    }
                    showCreateFoodAlert(createFoodAlertVC: createFoodAlertVC)

                } else {
                    if let _ = userFood {
                        createFoodAlertVC.isUserFood = true
                    }
                    showCreateFoodAlert(createFoodAlertVC: createFoodAlertVC)
                }
            }
        }
    }

    func showCreateFoodAlert(createFoodAlertVC: CreateFoodAlertViewController) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            activityIndicator?.stopAnimating()
            createFoodAlertVC.modalTransitionStyle = .crossDissolve
            createFoodAlertVC.modalPresentationStyle = .overFullScreen
            present(createFoodAlertVC, animated: true)
        }
    }

    func fetchUserFoods(completion: @escaping (FoodRecordV3?) -> Void) {

        DispatchQueue.global(qos: .userInteractive).async { [weak self] in

            guard let self else { return }

            if let foodRecord {
                if foodRecord.refCode != "" {
                    connector.fetchUserFoods(refCode: foodRecord.refCode) { [weak self] userFoods in
                        guard let self,
                              let matchedUserFood = userFoods.first else {
                            completion(nil)
                            return
                        }
                        self.userFood = matchedUserFood
                        completion(matchedUserFood)
                    }
                } else {
                    connector.fetchAllUserFoodsMatching(name: foodRecord.name) { [weak self] userFoods in
                        guard let self,
                              let matchedUserFood = userFoods.first else {
                            completion(nil)
                            return
                        }
                        self.userFood = matchedUserFood
                        completion(matchedUserFood)
                    }
                }
            } else {
                completion(nil)
            }
        }
    }

    func fetchRecipes(completion: @escaping (FoodRecordV3?) -> Void) {

        DispatchQueue.global(qos: .userInteractive).async { [weak self] in

            guard let self else { return }

            if let foodRecord {
                connector.fetchRecipes { [weak self] recipes in
                    guard let self,
                          let matchedRecipe = recipes.filter({ $0.refCode == foodRecord.refCode }).first else {
                        completion(nil)
                        return
                    }
                    if foodRecord.entityType == .recipe {
                        self.recipe = matchedRecipe
                    }
                    completion(matchedRecipe)
                }
            } else {
                completion(nil)
            }
        }
    }

    func navigateToCreateFood(with record: FoodRecordV3?,
                              loggedFoodRecord: FoodRecordV3? = nil,
                              isFromCustomFoodsList: Bool,
                              isEditingExistingFood: Bool) {

        let createFoodVC = CreateFoodViewController()
        createFoodVC.isCreateNewFood = false
        createFoodVC.isEditingExistingFood = isEditingExistingFood
        createFoodVC.isFromCustomFoodList = isFromCustomFoodsList
        createFoodVC.isFromBarcode = isFromBarcode
        createFoodVC.isUpdateLog = isUpdateLogUponCreating
        createFoodVC.isFromSearch = isFromSearch
        createFoodVC.foodRecord = record
        createFoodVC.loggedFoodRecord = loggedFoodRecord
        createFoodVC.loadViewIfNeeded()
        createFoodVC.delegate = self
        navigationController?.pushViewController(createFoodVC, animated: true)
    }

    func navigateToEditRecipe(with record: FoodRecordV3?,
                              loggedFoodRecord: FoodRecordV3? = nil,
                              vcTitle: String,
                              isFromCustomFood: Bool = false,
                              isEditingExistingRecipe: Bool,
                              isShowFoodIcon: Bool = true) {

        let editRecipeVC = EditRecipeViewController()
        editRecipeVC.vcTitle = vcTitle
        editRecipeVC.isEditingExistingRecipe = isEditingExistingRecipe
        editRecipeVC.isUpdateLog = isUpdateLogUponCreating
        editRecipeVC.isFromRecipeList = isFromRecipeList
        editRecipeVC.isFromUserFoodsList = isFromCustomFood
        editRecipeVC.isFromFoodDetails = true
        editRecipeVC.isFromMyFavorites = isFromMyFavorites
        editRecipeVC.isFromSearch = isFromSearch
        editRecipeVC.isShowFoodIcon = isShowFoodIcon
        editRecipeVC.loadViewIfNeeded()
        editRecipeVC.recipe = record
        editRecipeVC.loggedFoodRecord = loggedFoodRecord
        editRecipeVC.delegate = self
        navigationController?.pushViewController(editRecipeVC, animated: true)
    }
}

// MARK: - FoodEditor Delegate
extension FoodDetailsViewController: FoodDetailsDelegate {

    func onAddFoodToLog(foodRecord: FoodRecordV3) {

        if isEditingFavorite {
            connector.updateFavorite(foodRecord: foodRecord)
            navigationController?.popViewController(animated: true)
        } else {
            if !isEditingRecord {
                showMessage(msg: ToastMessages.addedToLog)
            }
            NutritionUICoordinator.navigateToDairyAfterAction(
                navigationController: navigationController,
                selectedDate: foodRecord.createdAt
            )
        }
    }

    func onDelete(foodRecord: FoodRecordV3) {
        if let navVC = parent?.navigationController {
            navVC.popViewController(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
        foodDetailsControllerDelegate?.deleteFromEdit(foodRecord: foodRecord)
    }

    func onCancelFood() {
        navigationController?.popViewController(animated: true)
    }

    func onUserSelected(ingredient: FoodRecordIngredient, indexOfIngredient: Int) {

        let editVC = EditIngredientViewController()
        editVC.foodItemData = ingredient
        editVC.indexOfIngredient = indexOfIngredient
        editVC.delegate = self
        navigationController?.pushViewController(editVC, animated: true)
    }

    func onMakeRecipe() {
        print("onMakeRecipe")
        if isFromCustomFoodList {
            var recipeFoodRecord = foodRecord
            let iconId = foodRecord?.iconId ?? ""
            recipeFoodRecord?.name = ""
            recipeFoodRecord?.ingredients[0].iconId = iconId
            navigateToEditRecipe(with: recipeFoodRecord,
                                 vcTitle: RecipeTexts.createRecipe,
                                 isFromCustomFood: true,
                                 isEditingExistingRecipe: false,
                                 isShowFoodIcon: false)
        } else {
            onEditFood(isEditFood: false)
        }
    }
    
    func onAddIngredient(foodRecord: FoodRecordV3?) {
        foodDetailsControllerDelegate?.onFoodDetailsAddIngredient(foodRecord: foodRecord)
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - CreateFoodAlert Delegate
extension FoodDetailsViewController: CreateFoodAlertDelegate {

    func onCreate() {
        var recipeFoodRecord = foodRecord
        if isRecipe || isMakeRecipe {
            if isMakeRecipe {
                let iconId = foodRecord?.iconId ?? ""
                recipeFoodRecord?.name = ""
                recipeFoodRecord?.ingredients[0].iconId = iconId
                recipeFoodRecord?.updateServingSizeAndUnitsForRecipe()
            } else if isFromSearch {
                isUpdateLogUponCreating = false
                recipeFoodRecord?.updateServingSizeAndUnitsForRecipe()
            }
            navigateToEditRecipe(with: recipeFoodRecord,
                                 vcTitle: RecipeTexts.createRecipe,
                                 isEditingExistingRecipe: false,
                                 isShowFoodIcon: !isMakeRecipe)
        } else {
            if isFromSearch && !isEditingRecord {
                isUpdateLogUponCreating = false
            }
            navigateToCreateFood(with: foodRecord,
                                 isFromCustomFoodsList: false,
                                 isEditingExistingFood: false)
        }
    }

    func onEdit() {

        if isFromSearch && !isEditingRecord {
            isUpdateLogUponCreating = false
        }

        if isRecipe, let recipe {
            navigateToEditRecipe(with: recipe,
                                 loggedFoodRecord: foodRecord,
                                 vcTitle: RecipeTexts.editRecipe,
                                 isEditingExistingRecipe: true)

        } else if let userFood {
            navigateToCreateFood(with: userFood,
                                 loggedFoodRecord: foodRecord,
                                 isFromCustomFoodsList: false,
                                 isEditingExistingFood: true)
        }
    }

    func onUpdateLoguponCreating(isUpdate: Bool) {
        isUpdateLogUponCreating = isUpdate
    }
}

// MARK: - IngredientEditorView Delegate
extension FoodDetailsViewController: IngredientEditorViewDelegate {

    func ingredientEditedFoodItemData(ingredient: FoodRecordIngredient, atIndex: Int) {
        foodDetailsView?.foodRecord?.replaceIngredient(updatedIngredient: ingredient,
                                                       atIndex: atIndex)
    }
}

// MARK: - AdvancedTextSearchView Delegate
extension FoodDetailsViewController: AdvancedTextSearchViewDelegate {

    func userSelectedFood(record: FoodRecordV3?, isPlusAction: Bool) {

        if let foodRecord = record {
            if replaceFood { // Replace Food
                var foodRecord = foodRecord
                if let uuid = foodDetailsView?.foodRecord?.uuid {
                    foodRecord.createdAt = foodDetailsView?.foodRecord?.createdAt ?? Date()
                    foodRecord.uuid = uuid
                }
                foodDetailsView?.foodRecord = foodRecord
            } else { // Add Ingredients
                foodDetailsView?.foodRecord?.addIngredient(record: foodRecord)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] () in
            guard let self else { return }
            foodDetailsView?.foodDetailsTableView.scrollToBottom()
        }
        navigationController?.popViewController(animated: true)
    }

    func userSelectedFoodItem(item: PassioFoodItem?, isPlusAction: Bool) {

        if let foodItem = item {
            if replaceFood { // Replace Food
                var foodRecord = FoodRecordV3(foodItem: foodItem)
                if let uuid = foodDetailsView?.foodRecord?.uuid {
                    foodRecord.createdAt = foodDetailsView?.foodRecord?.createdAt ?? Date()
                    foodRecord.uuid = uuid
                }
                foodDetailsView?.foodRecord = foodRecord
            } else { // Add Ingredients
                foodDetailsView?.foodRecord?.addIngredient(record: FoodRecordV3(foodItem: foodItem))
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] () in
            guard let self else { return }
            foodDetailsView?.foodDetailsTableView.scrollToBottom()
        }

        navigationController?.popViewController(animated: true)
    }
}

// MARK: - CreateFood Delegate
extension FoodDetailsViewController: NavigateToDiaryDelegate {

    func onSaveNavigateToDiary(isUpdateLog: Bool) {
        if !isUpdateLog {
            foodDetailsControllerDelegate?.navigateToMyFoods(index: isRecipe || isMakeRecipe ? 1 : 0)
        }
    }
}
