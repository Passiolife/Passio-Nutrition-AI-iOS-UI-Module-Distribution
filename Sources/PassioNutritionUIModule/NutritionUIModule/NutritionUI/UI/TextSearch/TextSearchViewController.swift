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
    var isAdvancedSearch = false

    weak var advancedSearchDelegate: AdvancedTextSearchViewDelegate?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let nib = UINib.nibFromBundle(nibName: "AdvancedTextSearchView")
        advancedTextSearchView = nib.instantiate(withOwner: self, options: nil).first as? AdvancedTextSearchView
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        advancedTextSearchView.delegate = self
        advancedTextSearchView.frame = view.bounds
        view.addSubview(advancedTextSearchView)
    }
}

// MARK: - AdvancedTextSearchView Delegate
extension TextSearchViewController: AdvancedTextSearchViewDelegate {

    func userSelectedFood(record: FoodRecordV3?) {
        advancedSearchDelegate?.userSelectedFood(record: record)
        if dismmissToMyLog || navigationController == nil {
            dismiss(animated: true)
        }
    }

    func userSelectedFoodItem(item: PassioFoodItem?) {
        advancedSearchDelegate?.userSelectedFoodItem(item: item)
        if dismmissToMyLog || navigationController == nil {
            dismiss(animated: true)
        }
    }
}
