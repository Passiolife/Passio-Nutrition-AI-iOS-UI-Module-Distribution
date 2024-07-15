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

    var dismmissToMyLog = false
    var isCreateRecipe = false
    private var isFirstTime = true

    weak var advancedSearchDelegate: AdvancedTextSearchViewDelegate?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let nib = UINib.nibFromBundle(nibName: "AdvancedTextSearchView")
        advancedTextSearchView = nib.instantiate(withOwner: self,
                                                 options: nil).first as? AdvancedTextSearchView
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
}

// MARK: - AdvancedTextSearchView Delegate
extension TextSearchViewController: AdvancedTextSearchViewDelegate {

    func userSelectedFood(record: FoodRecordV3?, isPlusAction: Bool) {
        DispatchQueue.main.async {
            if self.dismmissToMyLog || self.navigationController == nil {
                self.dismiss(animated: true) {
                    self.advancedSearchDelegate?.userSelectedFood(record: record,
                                                                   isPlusAction: isPlusAction)
                }
            } else {
                self.advancedSearchDelegate?.userSelectedFood(record: record,
                                                         isPlusAction: isPlusAction)
            }
        }
    }

    func userSelectedFoodItem(item: PassioFoodItem?, isPlusAction: Bool) {
        DispatchQueue.main.async {
            if self.dismmissToMyLog || self.navigationController == nil {
                self.dismiss(animated: true) { [weak self] in
                    self?.advancedSearchDelegate?.userSelectedFoodItem(item: item,
                                                                       isPlusAction: isPlusAction)
                }
            } else {
                self.advancedSearchDelegate?.userSelectedFoodItem(item: item, isPlusAction: isPlusAction)
            }
        }
    }
}
