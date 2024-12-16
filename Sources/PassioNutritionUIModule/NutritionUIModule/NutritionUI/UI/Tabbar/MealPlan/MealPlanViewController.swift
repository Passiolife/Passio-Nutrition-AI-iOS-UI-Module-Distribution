//
//  MealPlanViewController.swift
//  BaseApp
//
//  Created by Mind on 26/03/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit
import SwipeCellKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

class MealPlanViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var disclaimerView: UIView!
    @IBOutlet weak var disclaimerLabel: UILabel!

    var selectedMealPlan: PassioMealPlan?
    var selectedDay: Int?

    private enum CellMealPlan: String, CaseIterable {
        case MealPlanFoodCell,
             MealPlanSectionHeaderCell,
             MealPlanDietTypeCell
    }

    enum Section {

        case dietType, bf, l, d, s

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

    var sections: [Section] = []
    var breakfastMealPlanItem: [PassioMealPlanItem] = []
    var lunchMealPlanItem: [PassioMealPlanItem] = []
    var dinnerMealPlanItem: [PassioMealPlanItem] = []
    var snacksMealPlanItem: [PassioMealPlanItem] = []

    var mealPlansFetched: Bool {
        MealPlanManager.shared.mealPlans.count > 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCellsAndTableDelegates()
        basicSetup()
        if !mealPlansFetched {
            MealPlanManager.shared.getMealPlans() { [weak self] in
                guard let self = self else { return }
                self.getData()
            }
        }
    }
    
    func basicSetup() {
        
        let isDisclaimerClosed = PassioUserDefaults.bool(for: .isMealPlanDisclaimerClosed)
        
        if isDisclaimerClosed {
            disclaimerView.isHidden = true
        } else {
            disclaimerView.isHidden = false
            disclaimerLabel.text = "These meal plans are general guidelines and not based on personal dietary needs. Always consult with a healthcare provider or nutritionist."
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if mealPlansFetched {
            getData()
        }
    }
    
    func getData() {
        if let mealPlan = UserManager.shared.user?.mealPlan {
            if selectedMealPlan != mealPlan {
                selectedMealPlan = mealPlan
                getMealPlanData()
            }
        } else {
            selectedMealPlan = MealPlanManager.shared.mealPlans.first
            selectedDay = 1
            getMealPlanData()
        }
    }

    @IBAction func onClose(_ sender: UIButton) {
        disclaimerView.isHidden = true
        PassioUserDefaults.store(for: .isMealPlanDisclaimerClosed, value: true)
    }
    
    private func getMealPlanData() {

        ProgressHUD.show(presentingVC: self, color: .gray500, alpha: 0.7)
        PassioNutritionAI.shared.fetchMealPlanForDay(mealPlanLabel: selectedMealPlan?.mealPlanLabel ?? "",
                                                     day: selectedDay ?? 1) { [weak self] mealPlanItems in

            guard let self else { return }

            breakfastMealPlanItem = mealPlanItems.filter { $0.mealTime == .breakfast }
            lunchMealPlanItem = mealPlanItems.filter { $0.mealTime == .lunch }
            dinnerMealPlanItem = mealPlanItems.filter { $0.mealTime == .dinner }
            snacksMealPlanItem = mealPlanItems.filter { $0.mealTime == .snack }
            
            sections = [.dietType]
            if breakfastMealPlanItem.count > 0 {
                sections.append(.bf)
            }
            if lunchMealPlanItem.count > 0 {
                sections.append(.l)
            }
            if dinnerMealPlanItem.count > 0 {
                sections.append(.d)
            }
            if snacksMealPlanItem.count > 0 {
                sections.append(.s)
            }
            
            DispatchQueue.main.async {
                ProgressHUD.hide(presentedVC: self)
                self.collectionView.reloadData()
                self.collectionView.reloadWithAnimations()
            }
        }
    }

    private func registerCellsAndTableDelegates() {

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 40, right: 0)

        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionNumber, env) in
            if sectionNumber == 0 {
                return self?.collectionLayout(height: 114)
            }
            return self?.collectionLayout(height: 60)
        }

        layout.register(MealPlanSectionDecorationView.self,
                        forDecorationViewOfKind: MealPlanSectionDecorationView.className)
        collectionView.setCollectionViewLayout(layout, animated: true)

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

        let decorationItem = NSCollectionLayoutDecorationItem.background(
            elementKind: MealPlanSectionDecorationView.className
        )
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
            let cell = collectionView.dequeueCell(cellClass: MealPlanDietTypeCell.self, forIndexPath: indexPath)
            cell.selectedMealPlan = selectedMealPlan
            cell.selectedDay = selectedDay ?? 1
            cell.delegate = self
            return cell
        }

        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueCell(cellClass: MealPlanSectionHeaderCell.self, forIndexPath: indexPath)
            guard let mealForSection =  sections[indexPath.section].mealForSection else {return UICollectionViewCell()}
            cell.mealLabel = mealForSection
            cell.labelMealTime.text = mealForSection.rawValue
            cell.delegate = self
            return cell

        default:
            let cell = collectionView.dequeueCell(cellClass: MealPlanFoodCell.self, forIndexPath: indexPath)
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
            self?.showMessage(msg: ToastMessages.addedToLog)
        }
    }
}

extension MealPlanViewController {

    func logSingleFood(isEdit: Bool, mealPlanItem: PassioMealPlanItem) {

        ProgressHUD.show(presentingVC: self)

        getFoodRecord(from: mealPlanItem) { [weak self] record in
            guard let self, let record else { return }
            if !isEdit {
                NutritionUIModule.shared.updateRecord(foodRecord: record)
            }
            DispatchQueue.main.async {
                ProgressHUD.hide(presentedVC: self)
                if isEdit {
                    let editVC = FoodDetailsViewController()
                    editVC.foodRecord = record
                    self.parent?.navigationController?.pushViewController(editVC, animated: true)
                } else {
                    self.showMessage(msg: ToastMessages.addedToLog)
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
                    NutritionUIModule.shared.updateRecord(foodRecord: record)
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            completion()
            ProgressHUD.hide(presentedVC: self)
        }
    }

    func getFoodRecord(from mealPlanItem: PassioMealPlanItem,
                       completion: @escaping (_ record: FoodRecordV3?) -> Void) {

        guard let passioFoodDataInfo = mealPlanItem.meal else {
            completion(nil)
            return
        }

        PassioNutritionAI.shared.fetchFoodItemFor(
            foodDataInfo: passioFoodDataInfo,
            servingQuantity: passioFoodDataInfo.nutritionPreview?.servingQuantity,
            servingUnit: passioFoodDataInfo.nutritionPreview?.servingUnit
        ) { (foodItem) in

            DispatchQueue.main.async {
                guard let foodItem else {
                    completion(nil)
                    return
                }
                var foodRecord = FoodRecordV3(foodItem: foodItem)
                foodRecord.mealLabel = MealLabel.init(mealTime: mealPlanItem.mealTime ?? .snack)
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUpViews() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 1
        self.layer.masksToBounds = false
    }
}
