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
}

extension FoodDetailsControllerDelegate {
    func navigateToMyFoods(index: Int) { }
}

// MARK: - FoodDetailsViewController
final class FoodDetailsViewController: UIViewController {

    private var activityIndicator: UIActivityIndicatorView?
    private let connector = PassioInternalConnector.shared
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
    var isFromCustomFoodList = false
    var isFromBarcode = false
    var isFromRecipeList = false

    weak var delegate: FoodDetailsDelegate?
    weak var foodDetailsControllerDelegate: FoodDetailsControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = FoodDetailsTexts.foodDetails

        let nib = UINib.nibFromBundle(nibName: FoodDetailsView.className)
        foodDetailsView = nib.instantiate(withOwner: self, options: nil).first as? FoodDetailsView
        foodDetailsView?.foodDetailsDelegate = self
        foodDetailsView?.isEditingFavorite = isEditingFavorite
        foodDetailsView?.isEditingRecord = isEditingRecord
        foodDetailsView?.foodRecord = foodRecord
        foodDetailsView?.saveToConnector = !isEditingFavorite
        foodDetailsView?.isFromCustomFoodList = isFromCustomFoodList
        foodDetailsView?.isFromRecipeList = isFromRecipeList

        if let foodEditorView = foodDetailsView {
            view.addSubview(foodEditorView)
        }

        setupBackButton()
        activityIndicator = createActivityIndicator(themeColor: .primaryColor)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetchUserFoods(isDone: { (_, _) in })
        fetchRecipes(isDone: { (_, _) in })

        foodDetailsView?.frame = view.bounds

        guard let foodRecord = foodRecord else { return }

        isRecipe = foodRecord.entityType == .recipe && foodRecord.ingredients.count > 1

        if !isRecipe {
            setupRightNavigationButton()
        }
    }
}

// MARK: - FoodDetails Helper
private extension FoodDetailsViewController {

    func setupRightNavigationButton() {
        let rightButton = UIBarButtonItem(image: UIImage.imageFromBundle(named: "edit_icon"),
                                          style: .plain,
                                          target: self,
                                          action: #selector(onEditFood))
        rightButton.tintColor = .gray400
        navigationItem.rightBarButtonItem = rightButton
    }

    @objc func onEditFood() {

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
                activityIndicator?.startAnimating()
                let createFoodAlertVC = CreateFoodAlertViewController()
                createFoodAlertVC.delegate = self

                if isRecipe || isMakeRecipe {
                    fetchRecipes { [weak self] (isRecipe, recipes) in
                        guard let self else { return }
                        if isRecipe,
                           let matchedRecipe = recipes?.filter({ $0.refCode == foodRecord.refCode }).first {
                               recipe = matchedRecipe
                               createFoodAlertVC.isUserRecipe = true
                        }
                        createFoodAlertVC.isRecipe = true
                        showCreateFoodAlert(createFoodAlertVC: createFoodAlertVC)
                    }

                } else {
                    fetchUserFoods { [weak self] (isUserFood, userFoods) in
                        guard let self else { return }
                        if isUserFood,
                           let matchUserFood = userFoods {
                               userFood = matchUserFood
                               createFoodAlertVC.isUserFood = true
                           }
                        showCreateFoodAlert(createFoodAlertVC: createFoodAlertVC)
                    }
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

    func fetchUserFoods(isDone: @escaping (Bool, FoodRecordV3?) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self else { return }
            connector.fetchUserFoods(refCode: foodRecord?.refCode ?? "") { userFoods in
                isDone(userFoods.count > 0, userFoods.first)
            }
        }
    }

    func fetchRecipes(isDone: @escaping (Bool, [FoodRecordV3]?) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self else { return }
            connector.fetchRecipes { recipes in
                isDone(recipes.count > 0, recipes)
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
                              isEditingExistingRecipe: Bool) {

        let editRecipeVC = EditRecipeViewController()
        editRecipeVC.vcTitle = vcTitle
        editRecipeVC.isEditingExistingRecipe = isEditingExistingRecipe
        editRecipeVC.isUpdateLog = isUpdateLogUponCreating
        editRecipeVC.isFromRecipeList = isFromRecipeList
        editRecipeVC.isFromUserFoodsList = isFromCustomFood
        editRecipeVC.isFromFoodDetails = true
        editRecipeVC.loadViewIfNeeded()
        editRecipeVC.recipe = record
        editRecipeVC.loggedFoodRecord = loggedFoodRecord
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
        if isFromCustomFoodList {
            navigateToEditRecipe(with: foodRecord,
                                 vcTitle: RecipeTexts.createRecipe,
                                 isFromCustomFood: true,
                                 isEditingExistingRecipe: false)
        } else {
            isMakeRecipe = true
            onEditFood()
        }
    }
}

// MARK: - CreateFoodAlert Delegate
extension FoodDetailsViewController: CreateFoodAlertDelegate {

    func onCreate() {
        if isRecipe || isMakeRecipe {
            navigateToEditRecipe(with: foodRecord,
                                 vcTitle: RecipeTexts.createRecipe,
                                 isEditingExistingRecipe: false)
        } else {
            navigateToCreateFood(with: foodRecord,
                                 isFromCustomFoodsList: false,
                                 isEditingExistingFood: false)
        }
    }

    func onEdit() {
        if isRecipe, let recipe {
            navigateToEditRecipe(with: recipe,
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
            foodDetailsControllerDelegate?.navigateToMyFoods(index: 0)
        }
    }
}
