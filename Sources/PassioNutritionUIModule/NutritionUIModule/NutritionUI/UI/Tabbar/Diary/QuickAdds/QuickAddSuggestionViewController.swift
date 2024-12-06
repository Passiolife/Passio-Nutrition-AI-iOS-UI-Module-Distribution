//
//  QuickAddSuggestionViewController.swift
//  BaseApp
//
//  Created by Mind on 13/03/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

protocol QuickAddSuggestionViewDelegate: NSObjectProtocol {
    func suggestionDidFetched(isHavingSuggestion: Bool)
    func didSelected(suggestion: SuggestedFoods)
    func refreshFoodRecord()
}

final class QuickAddSuggestionViewController: CustomModalViewController {

    @IBOutlet weak var quickSuggestionsLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    var suggestions: [SuggestedFoods] = []
    private lazy var quickAddService = QuickAddService()

    weak var delegate: QuickAddSuggestionViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        containerView.dropShadow(radius: 16,
                                 offset: CGSize(width: 0, height: -4),
                                 color: .black.withAlphaComponent(0.1),
                                 shadowRadius: 8,
                                 shadowOpacity: 1)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        getQuickSuggestion()
    }

    private func configureUI() {

        quickSuggestionsLabel.font = UIFont.inter(type: .bold, size: 20)
        registerCellsAndTableDelegates()
        shouldShowMiniOnly = false
        containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds,
                                                      cornerRadius: 16).cgPath
    }

    func compressPopup() {
        containerViewHeightConstraint?.constant = 0
        view.layoutIfNeeded()
    }
}

// MARK: - Helper
extension QuickAddSuggestionViewController {

    private func registerCellsAndTableDelegates() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionNumber, env) in
            return self?.collectionLayout(height: 60)
        }
        collectionView.setCollectionViewLayout(layout, animated: true )
        collectionView.register(nibName: QuickAddCollectionViewCell.className)
    }

    func getQuickSuggestion() {
        DispatchQueue.global(qos: .userInteractive).async {
            self.quickAddService.getQuickAdds(mealTime: PassioMealTime.currentMealTime()) { [weak self] suggestions  in
                guard let self else { return }
                self.suggestions = suggestions
                DispatchQueue.main.async {
                    self.delegate?.suggestionDidFetched(isHavingSuggestion: suggestions.count > 0)
                    self.collectionView.reloadData()
                }
            }
        }
    }

    private func quickLogSuggestion(food: SuggestedFoods) {
        food.getFoodRecords(completion: { [weak self] foodRecord in
            if var record = foodRecord {
                record.createdAt = Date()
                record.mealLabel = MealLabel.mealLabelBy()
                NutritionUIModule.shared.updateRecord(foodRecord: record)
                DispatchQueue.main.async {
                    self?.getQuickSuggestion()
                    self?.showMessage(msg: ToastMessages.addedToLog, alignment: .center)
                    self?.delegate?.refreshFoodRecord()
                }
            }
        })
    }

    func collectionLayout(height: CGFloat) -> NSCollectionLayoutSection {

        let itemsPerRow = 2
        let inset: CGFloat = 4

        let fraction: CGFloat = 1/CGFloat(itemsPerRow)

        // Item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fraction),
                                              heightDimension: .fractionalHeight(1))

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)

        // Group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .absolute(height + inset))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        return section
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension QuickAddSuggestionViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return suggestions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuickAddCollectionViewCell", for: indexPath) as! QuickAddCollectionViewCell
        cell.setup(foodResult: suggestions[indexPath.row])
        cell.onQuickAddSuggestion = { [weak self] in
            guard let self else { return }
            quickLogSuggestion(food: suggestions[indexPath.row])
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        compressPopup()
        delegate?.didSelected(suggestion: suggestions[indexPath.row])
    }
}
