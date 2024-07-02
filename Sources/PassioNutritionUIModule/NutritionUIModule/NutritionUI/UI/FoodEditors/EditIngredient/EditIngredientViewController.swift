//
//  EditIngredientViewController.swift
//  Passio App Module
//
//  Created by zvika on 3/28/19.
//  Copyright © 2023 PassioLife Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

final class EditIngredientViewController: UIViewController {

    private let passioSDK = PassioNutritionAI.shared

    private var ingredientEditorView: IngredientEditorView?
    private var isFavoriteTemplate = false
    private var saveOnDismiss = true

    var foodItemData: FoodRecordIngredient?
    var indexOfIngredient = 0

    weak var delegate: IngredientEditorViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib.nibFromBundle(nibName: "IngredientEditorView")
        ingredientEditorView = nib.instantiate(withOwner: self,
                                               options: nil).first as? IngredientEditorView
        ingredientEditorView?.foodRecordIngredient = foodItemData
        ingredientEditorView?.indexOfIngredient = indexOfIngredient
        ingredientEditorView?.delegate = self
        title = "Edit Ingredient"
        
        self.setupBackButton()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let image = UIImage.imageFromBundle(named: "App_Background")
        let imageView = UIImageView(image: image)
        imageView.frame = view.bounds
        imageView.contentMode = .scaleToFill
        view.addSubview(imageView)
        ingredientEditorView?.frame = view.bounds
        if let ingredientEditorView = ingredientEditorView {
            view.addSubview(ingredientEditorView)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if saveOnDismiss, let foodItem = ingredientEditorView?.foodRecordIngredient {
            delegate?.ingredientEditedFoodItemData(ingredient: foodItem,
                                                   atIndex: indexOfIngredient)
        }
    }
}

extension EditIngredientViewController: IngredientEditorViewDelegate {

    func replaceFoodUsingSearch() {

        let tsVC = TextSearchViewController()
        tsVC.modalPresentationStyle = .fullScreen
        tsVC.advancedSearchDelegate = self
        self.present(tsVC, animated: true)
    }

    func startNutritionBrowser(foodItemData: FoodRecordIngredient) {
        // TODO: Fix lookupPassioIDAttributesFor + FoodItem
//        guard let pAtt = passioSDK.lookupPassioIDAttributesFor(passioID: foodItemData.passioID) else {
//            return
//        }
//        let nbVC = BrowseNutritionViewController()
//        nbVC.foodRecord = FoodRecordV3(passioIDAttributes: pAtt,
//                                     replaceVisualPassioID: nil,
//                                     replaceVisualName: nil)
//        nbVC.delegate = self
//        self.navigationController?.pushViewController(nbVC, animated: true)
    }

    func ingredientEditedFoodItemData(ingredient foodItemData: FoodRecordIngredient, atIndex: Int) {
        navigationController?.popViewController(animated: true)
    }

    func ingredientEditedCancel() {
        saveOnDismiss = false
        navigationController?.popViewController(animated: true)
    }
}

extension EditIngredientViewController: AdvancedTextSearchViewDelegate {

    func userSelectedFood(record: FoodRecordV3?) {
        guard let foodRecord = record else {
            navigationController?.popViewController(animated: true)
            return
        }
        let ingredients = FoodRecordIngredient(foodRecord: foodRecord)
        ingredientEditorView?.foodRecordIngredient = ingredients
        navigationController?.popViewController(animated: true)
    }

    func userSelectedFoodItem(item: PassioFoodItem?) {

        guard let foodItem = item else {
            navigationController?.popViewController(animated: true)
            return
        }
        let ingredients = FoodRecordIngredient(foodRecord: FoodRecordV3(foodItem: foodItem))
        ingredientEditorView?.foodRecordIngredient = ingredients
        navigationController?.popViewController(animated: true)
    }
}
