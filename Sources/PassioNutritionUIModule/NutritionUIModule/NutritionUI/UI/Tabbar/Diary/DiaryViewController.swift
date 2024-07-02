//
//  DiaryViewController.swift
//  Passio App Module
//
//  Created by zvika on 2/12/19.
//  Copyright © 2023 PassioLife Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif
import SwipeCellKit

protocol GoToManualSearchDelegate: AnyObject {
    func goToSearch(viewController: UIViewController)
}

class DiaryViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var nextDateButton: UIButton!
    @IBOutlet weak var quickAddContainerView: UIView!

    var dateSelector: DateSelectorViewController?
    var quickAddViewController: QuickAddSuggestionViewController?

    let passioSDK = PassioNutritionAI.shared
    let numberSectionCellsAbove = 1
    let connector = PassioInternalConnector.shared

    var selectedDate: Date = Date() {
        didSet {
            guard collectionView != nil,
                  activityIndicator != nil,
                  dateButton != nil,
                  nextDateButton != nil else {
                return
            }
            refreshData()
        }
    }

    enum Section {
        case dailyNutrition, bf, l, d, s

        var mealForSection: MealLabel {
            switch self {
            case .dailyNutrition:
                return .breakfast
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

    var sections: [(Section,Bool)] = [
        (.dailyNutrition,true),
        (.bf,true),
        (.l,true),
        (.d,true),
        (.s,true)
    ]

    var selectedMeal: MealLabel? {
        didSet {
            connector.mealLabel = selectedMeal
        }
    }

    var dayLog = DayLog(date: Date(), records: []) {
        didSet {
            collectionView.reloadData()
        }
    }

    var displayedRecords: [FoodRecordV3] { dayLog.displayedRecords }

    override func viewDidLoad() {
        super.viewDidLoad()

        registerCellsAndTableDelegates()

        if let quickAddChild = children.first(where: {
            $0 is QuickAddSuggestionViewController
        }) as? QuickAddSuggestionViewController {
            quickAddViewController = quickAddChild
            quickAddViewController?.delegate = self
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refreshData()
        quickAddViewController?.compressPopup()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setDayLogForSelectedDate()
    }

    func setTitle() {
        if selectedDate.isToday {
            dateButton.setTitle("Today".localized, for: .normal)
        } else {
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "MMMM dd, yyyy"
            let newTitle = dateFormatterPrint.string(for: selectedDate)
            dateButton.setTitle(newTitle, for: .normal)
        }
    }

    func registerCellsAndTableDelegates() {

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 120, right: 0)

        let layout = UICollectionViewCompositionalLayout { (sectionNumber, env) in
            if sectionNumber == 0 {
                let proHeight = CGFloat(103) / CGFloat(364) * CGFloat(375 - 64)
                let toBeHeight = 103 / 364 * (ScreenSize.width - 64)
                let diffrence = toBeHeight - CGFloat(proHeight)
                return self.collectionLayout(height: 167 + diffrence)
            }
            return self.collectionLayout(height: 55)
        }

        layout.register(SectionDecorationView.self, forDecorationViewOfKind: "SectionDecorationView")
        collectionView.setCollectionViewLayout(layout, animated: true)

        CellMyLogCollection.allCases.forEach {
            collectionView.register(nibName: $0.rawValue.capitalizingFirst())
        }
    }

    @objc func setDayLogForSelectedDate() {
        setDayLogFor(date: dayLog.date)
    }

    func setDayLogFor(date: Date) {
        connector.fetchDayRecords(date: date) { [weak self] (foodRecords) in
            guard let `self` = self else { return }
            self.dayLog = DayLog(date: date, records: foodRecords)
            self.collectionView.reloadData()
        }
    }

    @IBAction func onNextPrevButtonPressed(_ sender: UIButton) {
        let nextDate = Calendar.current.date(byAdding: .day, value: sender.tag == 1 ? 1 : -1, to: selectedDate)!
        self.selectedDate = nextDate
    }

    func refreshData() {
        setTitle()
        connector.dateForLogging = selectedDate
        setDayLogFor(date: selectedDate)
        nextDateButton.isEnabled = selectedDate.isToday ? false : true
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension DiaryViewController: UICollectionViewDataSource {

    func collectionLayout(height: CGFloat) -> NSCollectionLayoutSection {

        let itemsPerRow = 1
        let inset: CGFloat = 0

        let fraction: CGFloat = 1/CGFloat(itemsPerRow)

        // Item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fraction),
                                              heightDimension: .estimated(height))

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)

        // Group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(height))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

        let decorationItem = NSCollectionLayoutDecorationItem.background(elementKind: "SectionDecorationView")
        decorationItem.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        section.decorationItems = [decorationItem]

        return section
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section].0 {
        case .dailyNutrition: return 1
        default:
            let header = 1
            let expandCount = sections[section].1 ? dayLog.numberOfRecordsByMeal(mealLabel: sections[section].0.mealForSection) : 0
            return header + expandCount
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if sections[indexPath.section].0 == .dailyNutrition {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DailyNutritionWithDateCollectionViewCell",
                                                          for: indexPath) as! DailyNutritionWithDateCollectionViewCell
            let userProfile = UserManager.shared.user ?? UserProfileModel()
            let (calories, carbs, protein, fat) = getNutritionSummaryfor(foodRecords: displayedRecords)
            let nuData = NutritionDataModal(
                calory: (consumed: Int(calories), target: userProfile.caloriesTarget),
                carb: (consumed: Int(carbs), target: userProfile.carbsGrams),
                protein: (consumed: Int(protein), target: userProfile.proteinGrams),
                fat: (consumed: Int(fat), target: userProfile.fatGrams))
            cell.nutritionData = nuData
            return cell
        }

        switch indexPath.row {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SectionOnOffCollectionViewCell",
                                                                for: indexPath) as? SectionOnOffCollectionViewCell else {
                return UICollectionViewCell()
            }
            let mealForSection =  sections[indexPath.section].0.mealForSection
            cell.mealLabel = mealForSection
            cell.labelMealTime.text = mealForSection.rawValue
            cell.setup(isExpanded: sections[indexPath.section].1,
                       hasChild: dayLog.numberOfRecordsByMeal(mealLabel: sections[indexPath.section].0.mealForSection) > 0)
            return cell

        default:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FoodRecordCollectionViewCell",
                                                                for: indexPath) as? FoodRecordCollectionViewCell,
                  let foodRecord = getRecordFor(indexPath: indexPath) else {
                return UICollectionViewCell()
            }
            cell.setup(foodRecord.0)
            cell.delegate = self
            return cell
        }
    }
}

extension DiaryViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section != 0 else { return }

        selectedMeal = sections[indexPath.section].0.mealForSection
        if indexPath.row == 0 {
            self.sections[indexPath.section].1 = !self.sections[indexPath.section].1
            self.collectionView.reloadData()
            return
        }

        if let record = getRecordFor(indexPath: indexPath)?.0{
            navigateToEditor(foodRecord: record)
        }
    }

    func getRecordFor(indexPath: IndexPath) -> (FoodRecordV3,Bool)? {
        let indexdjusted = indexPath.row - numberSectionCellsAbove
        switch sections[indexPath.section].0{
        case .dailyNutrition: return nil
        case .bf:
            return (dayLog.breakfastArray[indexdjusted], indexdjusted == dayLog.breakfastArray.count - 1)
        case .l:
            return (dayLog.lunchArray[indexdjusted], indexdjusted == dayLog.lunchArray.count - 1)
        case .d:
            return (dayLog.dinnerArray[indexdjusted], indexdjusted == dayLog.dinnerArray.count - 1)
        case .s:
            return (dayLog.snackArray[indexdjusted], indexdjusted == dayLog.snackArray.count - 1)
        }
    }

    func navigateToEditor(foodRecord: FoodRecordV3) {
        let editVC = EditRecordViewController()
        editVC.foodRecord = foodRecord
        editVC.isEditingRecord = true
        editVC.delegateDelete = self
        self.parent?.navigationController?.pushViewController(editVC, animated: true)
    }
}

extension DiaryViewController: SwipeCollectionViewCellDelegate {

    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        guard indexPath.row >= numberSectionCellsAbove, let record = getRecordFor(indexPath: indexPath)?.0 else {
            return nil
        }

        let deleteAction = SwipeAction(style: .default, title: "Delete".localized) { [weak self] action, indexPath in
            guard let self else { return }
            connector.deleteRecord(foodRecord: record)
            dayLog = DayLog(date: self.dayLog.date,
                            records: self.dayLog.records.filter { $0.uuid != record.uuid })
            collectionView.reloadData()
            quickAddViewController?.getQuickSuggestion()
        }
        deleteAction.backgroundColor = .red500

        let editAction = SwipeAction(style: .default, title: "Edit".localized) { [weak self] action, indexPath in
            guard let `self` = self else { return }
            self.navigateToEditor(foodRecord: record)
        }
        editAction.backgroundColor = .indigo600

        return [deleteAction,editAction]
    }

    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .fill
        options.transitionStyle = .border
        return options
    }
}

// MARK: - DateSelectorUIView Delegate
extension DiaryViewController: DateSelectorUIViewDelegate {

    @IBAction func showDateSelector(_ sender: Any) {
        dateSelector = DateSelectorViewController()
        dateSelector?.delegate = self
        dateSelector?.dateForPicker = self.selectedDate
        dateSelector?.modalPresentationStyle = .overFullScreen
        self.parent?.present(dateSelector!, animated: false)
    }

    func removeDateSelector(remove: Bool) {
        dateSelector?.dismiss(animated: false)
    }

    func dateFromPicker(date: Date) {
        self.selectedDate = date
    }
}

// MARK: - Go To Manual Search Delegate
extension DiaryViewController: GoToManualSearchDelegate {

    func goToSearch(viewController: UIViewController) {

        DispatchQueue.main.async {
            if let nav = self.navigationController {
                nav.popViewController(animated: true)
            } else {
                viewController.dismiss(animated: true)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let vc = TextSearchViewController()
                vc.dismmissToMyLog = true
                vc.modalPresentationStyle = .fullScreen
                vc.advancedSearchDelegate = self
                self.present(vc, animated: true)
            }
        }
    }
}

// MARK: - EditRecordViewController Delegate
extension DiaryViewController: EditRecordViewControllerDelegate {

    func deleteFromEdit(foodRecord: FoodRecordV3) {
        connector.deleteRecord(foodRecord: foodRecord)
        dayLog.setNew(foodRecords: dayLog.records.filter { $0.uuid != foodRecord.uuid })
        collectionView.reloadData()
    }
}

// MARK: - FavoritesView Delegate
extension DiaryViewController: FavoritesViewDelegate {

    func userSelectedFavorite(favorite: FoodRecordV3) { }
    func numberOfFavotires(number: Int) { }

    func userAddedToLog(foodRecord: FoodRecordV3) {
        connector.updateRecord(foodRecord: foodRecord, isNew: true)
        setDayLogFor(date: dayLog.date)
    }
}

// MARK: - QuickSuggestion Delegate
extension DiaryViewController: QuickAddSuggestionViewDelegate {

    func refreshFoodRecord() {
        refreshData()
    }

    func suggestionDidFetched(isHavingSuggestion: Bool) {
        self.quickAddContainerView.isHidden = !isHavingSuggestion
    }

    func didSelected(suggestion: SuggestedFoods) {

        suggestion.getFoodRecords(completion: { [weak self] foodRecord in

            guard let self else { return }

            DispatchQueue.main.async {
                let editVC = EditRecordViewController()
                editVC.foodRecord = foodRecord
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.parent?.navigationController?.pushViewController(editVC, animated: true)
                }
            }
        })
    }
}

// MARK: - AdvancedTextSearchView Delegate
extension DiaryViewController: AdvancedTextSearchViewDelegate {

    func userSelectedFood(record: FoodRecordV3?) {
        guard let foodRecord = record else { return }
        connector.updateRecord(foodRecord: foodRecord, isNew: true)
        setDayLogFor(date: dayLog.date)
    }

    func userSelectedFoodItem(item: PassioFoodItem?) {
        guard let foodItem = item else { return }
        let foodRecord = FoodRecordV3(foodItem: foodItem)
        connector.updateRecord(foodRecord: foodRecord, isNew: true)
        setDayLogFor(date: dayLog.date)
    }
}

class SectionDecorationView: UICollectionReusableView {

    // MARK: MAIN
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
