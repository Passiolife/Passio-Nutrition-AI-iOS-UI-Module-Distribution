//
//  MealPlanViewController.swift
//  BaseApp
//
//  Created by Mind on 26/03/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import Foundation
import UIKit
import SwipeCellKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

class MealPlanViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var selectedMealPlan: PassioMealPlan?
    var selectedDay: Int?

    enum Section {
        case dietType,bf,l,d,s

        var mealForSection: MealLabel? {
            switch self {
            case .dietType:
                return nil
            case .bf:
                return .breakfast
            case .l:
                return .lunch
            case .d:
                return .dinner
            case .s:
                return .snack
            }
        }
    }

    var sections: [Section] = [.dietType,.bf,.l,.d,.s]
    var breakfastMealPlanItem: [PassioMealPlanItem] = []
    var lunchMealPlanItem: [PassioMealPlanItem] = []
    var dinnerMealPlanItem: [PassioMealPlanItem] = []
    var snacksMealPlanItem: [PassioMealPlanItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        registerCellsAndTableDelegates()
    }

    override func viewWillAppear(_ animated: Bool) {
        if let mealPlan = UserManager.shared.user?.mealPlan {
            if self.selectedMealPlan != mealPlan {
                self.selectedMealPlan = mealPlan
                self.getMealPlanData()
            }
        } else {
            self.selectedMealPlan = MealPlanManager.shared.mealPlans.first
            self.selectedDay = 1
            self.getMealPlanData()
        }
    }

    func getMealPlanData() {
        ProgressHUD.show(presentingVC: self)
        PassioNutritionAI.shared.fetchMealPlanForDay(mealPlanLabel: selectedMealPlan?.mealPlanLabel ?? "",
                                                     day: selectedDay ?? 1) { [weak self] mealPlanItems in
            guard let self else { return }
            DispatchQueue.main.async {
                ProgressHUD.hide(presentedVC: self)
                self.breakfastMealPlanItem = mealPlanItems.filter({$0.mealTime == .breakfast})
                self.lunchMealPlanItem = mealPlanItems.filter({$0.mealTime == .lunch})
                self.dinnerMealPlanItem = mealPlanItems.filter({$0.mealTime == .dinner})
                self.snacksMealPlanItem = mealPlanItems.filter({$0.mealTime == .snack})
                self.collectionView.reloadData()
            }
        }
    }

    func registerCellsAndTableDelegates() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 120, right: 0)

        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionNumber, env) in
            if sectionNumber == 0 {
                return self?.collectionLayout(height: 114)
            }
            return self?.collectionLayout(height: 60)
        }

        layout.register(MealPlanSectionDecorationView.self, forDecorationViewOfKind: "MealPlanSectionDecorationView")
        collectionView.setCollectionViewLayout(layout, animated: true )

        CellMealPlan.allCases.forEach {
            collectionView.register(nibName: $0.rawValue.capitalizingFirst())
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension MealPlanViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionLayout(height: CGFloat) -> NSCollectionLayoutSection {

        let itemsPerRow = 1
        let inset: CGFloat = 0

        let fraction: CGFloat = 1/CGFloat(itemsPerRow)

        // Item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fraction),
                                              heightDimension: .fractionalHeight(1))

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)

        // Group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .absolute(height))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

        let decorationItem = NSCollectionLayoutDecorationItem.background(elementKind: "MealPlanSectionDecorationView")
        decorationItem.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        section.decorationItems = [decorationItem]

        return section
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section] {
        case .dietType: return 1
        case .bf: return 1 + breakfastMealPlanItem.count
        case .l: return 1 + lunchMealPlanItem.count
        case .d: return 1 + dinnerMealPlanItem.count
        case .s: return 1 + snacksMealPlanItem.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if sections[indexPath.section] == .dietType {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MealPlanDietTypeCell",
                                                                for: indexPath) as? MealPlanDietTypeCell else {
                return UICollectionViewCell()
            }
            cell.selectedMealPlan = selectedMealPlan
            cell.selectedDay = selectedDay ?? 1
            cell.delegate = self
            return cell
        }

        switch indexPath.row {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MealPlanSectionHeaderCell",
                                                                for: indexPath) as? MealPlanSectionHeaderCell else {
                return UICollectionViewCell()
            }
            guard let mealForSection =  sections[indexPath.section].mealForSection else {return UICollectionViewCell()}
            cell.mealLabel = mealForSection
            cell.labelMealTime.text = mealForSection.rawValue
            cell.delegate = self
            return cell

        default:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MealPlanFoodCell",
                                                                for: indexPath) as? MealPlanFoodCell else {
                return UICollectionViewCell()
            }
            if let mealPlanItem = getMealPlanItem(indexPath: indexPath) {
                if let foodSearchResult = mealPlanItem.meal {
                    cell.setup(foodResult: foodSearchResult)
                }
                cell.onAddingMeal = { [weak self] in
                    self?.logSingleFood(isEdit: false, mealPlanItem: mealPlanItem)
                }
            }
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section != 0, indexPath.row != 0 else { return }
        if let mealPlanItem = getMealPlanItem(indexPath: indexPath) {
            logSingleFood(isEdit: true, mealPlanItem: mealPlanItem)
        }
    }

    private func getMealPlanItem(indexPath: IndexPath) -> PassioMealPlanItem? {
        let index = indexPath.row - 1
        let passioMealPlanItem: PassioMealPlanItem? = switch sections[indexPath.section] {
        case .bf: breakfastMealPlanItem[index]
        case .l: lunchMealPlanItem[index]
        case .d: dinnerMealPlanItem[index]
        case .s: snacksMealPlanItem[index]
        default: nil
        }
        return passioMealPlanItem
    }
}

// MARK: - MealPlanSectionHeaderCell Delegate
extension MealPlanViewController: MealPlanSectionHeaderCellDelegate {

    func onClickLog(mealLabel: MealLabel) {
        let mealPlanItem = switch mealLabel {
        case .breakfast: breakfastMealPlanItem
        case .lunch: lunchMealPlanItem
        case .dinner: dinnerMealPlanItem
        case .snack: snacksMealPlanItem
        }
        logMultipleFood(mealPlanItems: mealPlanItem) { [weak self] in
            self?.showMessage(msg: "Added to log")
        }
    }
}

extension MealPlanViewController {

    func logSingleFood(isEdit: Bool, mealPlanItem: PassioMealPlanItem) {

        ProgressHUD.show(presentingVC: self)

        getFoodRecord(from: mealPlanItem) { [weak self] record in
            guard let self, let record else { return }
            if !isEdit {
                PassioInternalConnector.shared.updateRecord(foodRecord: record, isNew: true)
            }
            DispatchQueue.main.async {
                ProgressHUD.hide(presentedVC: self)
                if isEdit {
                    let editVC = EditRecordViewController()
                    editVC.foodRecord = record
                    self.parent?.navigationController?.pushViewController(editVC, animated: true)
                } else {
                    self.showMessage(msg: "Added to log")
                }
            }
        }
    }

    func logMultipleFood(mealPlanItems: [PassioMealPlanItem], completion: @escaping () -> Void) {

        let group = DispatchGroup()
        ProgressHUD.show(presentingVC: self)

        for mealPlanItem in mealPlanItems {
            group.enter()
            getFoodRecord(from: mealPlanItem) { record in
                DispatchQueue.main.async {
                    guard let record = record else {
                        group.leave()
                        return
                    }
                    PassioInternalConnector.shared.updateRecord(foodRecord: record, isNew: true)
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            completion()
            ProgressHUD.hide(presentedVC: self)
        }
    }

    func getFoodRecord(from mealPlanItem: PassioMealPlanItem, completion: @escaping (_ record: FoodRecordV3?) -> Void) {

        guard let passioSearchResult = mealPlanItem.meal else {
            completion(nil)
            return
        }

        PassioNutritionAI.shared.fetchFoodItemFor(foodItem: passioSearchResult) { (foodItem) in
            DispatchQueue.main.async {
                guard let foodItem = foodItem else {
                    completion(nil)
                    return
                }
                let nutritionPreview = passioSearchResult.nutritionPreview
                var foodRecord = FoodRecordV3(foodItem: foodItem)
                foodRecord.mealLabel = MealLabel.init(mealTime: mealPlanItem.mealTime ?? .snack)
                if foodRecord.setSelectedUnit(unit: nutritionPreview?.servingUnit ?? ""),
                   let quantity = nutritionPreview?.servingQuantity {
                    foodRecord.setSelectedQuantity(quantity: quantity)
                } else {
                    let weight = nutritionPreview?.weightQuantity ?? 0
                    if foodRecord.setSelectedUnit(unit: "gram") {
                        foodRecord.setSelectedQuantity(quantity: weight)
                    }
                }
                completion(foodRecord)
            }
        }
    }
}

// MARK: - MealPlanDietSelection Delegate
extension MealPlanViewController: MealPlanDietSelectionDelegate, CustomPickerSelectionDelegate {

    func selectedDay(day: Int) {
        if selectedDay != day {
            selectedDay = day
            getMealPlanData()
        }
    }

    func mealPlanSelectionTapped(_ sender: UIButton) {
        let customPickerViewController = CustomPickerViewController()
        customPickerViewController.loadViewIfNeeded()
        customPickerViewController.disableCapatlized = true
        customPickerViewController.pickerItems = (MealPlanManager.shared.mealPlans).map({PickerElement(title: $0.mealPlanTitle)})
        if let frame = sender.superview?.convert(sender.frame, to: nil) {
            customPickerViewController.pickerFrame = CGRect(x: frame.origin.x - 200,
                                                            y: frame.origin.y + sender.frame.height + 10,
                                                            width: 200 + sender.frame.width,
                                                            height: 42.5 * CGFloat(MealPlanManager.shared.mealPlans.count))
        }
        customPickerViewController.delegate = self
        customPickerViewController.modalTransitionStyle = .crossDissolve
        customPickerViewController.modalPresentationStyle = .overFullScreen
        navigationController?.present(customPickerViewController, animated: true, completion: nil)
    }

    func onPickerSelection(value: String, selectedIndex: Int, viewTag: Int) {
        UserManager.shared.user?.setMealPlan(mealPlan: MealPlanManager.shared.mealPlans[selectedIndex])
        selectedMealPlan = MealPlanManager.shared.mealPlans[selectedIndex]
        selectedDay = 1
        getMealPlanData()
    }
}

class MealPlanSectionDecorationView: UICollectionReusableView {

    // MARK: MAIN
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: FUNCTIONS
    func setUpViews(){
        self.backgroundColor = .white//UIColor(red: 244/255, green: 243/255, blue: 245/255, alpha: 1)
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        self.layer.shadowOffset = CGSize(width: 0.5, height: 1)
        self.layer.shadowOpacity = 0.3
        self.layer.masksToBounds = false
    }
}
