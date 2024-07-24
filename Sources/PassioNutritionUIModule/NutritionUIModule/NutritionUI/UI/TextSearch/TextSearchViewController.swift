//
//  TextSearchViewController.swift
//  SDKApp
//
//  Created by zvika on 1/16/19.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

final class TextSearchViewController: InstantiableViewController {

    private var advancedTextSearchView: AdvancedTextSearchView!
    private var isFirstTime = true

    var isCreateRecipe = false
    var indexToPop: Int? = nil
    var shouldPopVC: Bool = true

    weak var advancedSearchDelegate: AdvancedTextSearchViewDelegate?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        title = "Text Search"
        extendedLayoutIncludesOpaqueBars = true

        setupBackButton()
        if advancedTextSearchView == nil {
            let nib = UINib.nibFromBundle(nibName: AdvancedTextSearchView.className)
            advancedTextSearchView = nib.instantiate(withOwner: self,
                                                     options: nil).first as? AdvancedTextSearchView
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if isFirstTime {
            isFirstTime = false
            advancedTextSearchView.delegate = self
            advancedTextSearchView.frame = view.bounds
            advancedTextSearchView.isCreateRecipe = isCreateRecipe
            view.addSubview(advancedTextSearchView)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        advancedTextSearchView.searchController?.removeFromParent()
        advancedTextSearchView.searchController = nil
        advancedTextSearchView.removeFromSuperview()
        advancedTextSearchView = nil
    }
}

// MARK: - AdvancedTextSearchView Delegate
extension TextSearchViewController: AdvancedTextSearchViewDelegate {

    func userSelectedFood(record: FoodRecordV3?, isPlusAction: Bool) {
        if shouldPopVC {
            if let indexToPop {
                navigationController?.popUpToIndexControllers(popUptoIndex: indexToPop)
            } else {
                navigationController?.popViewController(animated: false)
            }
            advancedSearchDelegate?.userSelectedFood(record: record, isPlusAction: isPlusAction)
        } else {
            advancedSearchDelegate?.userSelectedFood(record: record, isPlusAction: isPlusAction)
        }
    }

    func userSelectedFoodItem(item: PassioFoodItem?, isPlusAction: Bool) {
        if shouldPopVC {
            if let indexToPop {
                navigationController?.popUpToIndexControllers(popUptoIndex: indexToPop)
            } else {
                navigationController?.popViewController(animated: false)
            }
            advancedSearchDelegate?.userSelectedFoodItem(item: item, isPlusAction: isPlusAction)
        } else {
            advancedSearchDelegate?.userSelectedFoodItem(item: item, isPlusAction: isPlusAction)
        }
    }
}
