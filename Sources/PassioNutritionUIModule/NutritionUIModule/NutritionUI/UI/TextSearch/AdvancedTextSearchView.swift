//
//  AdvancedTextSearchView.swift
//  NutritionAISDK
//
//  Created by Nikunj Prajapati on 22/12/23.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

protocol AdvancedTextSearchViewDelegate: AnyObject {
    func userSelectedFoodItem(item: PassioFoodItem?)
    func userSelectedFood(record: FoodRecordV3?)
}

final class AdvancedTextSearchView: UIView {

    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var tblViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchView: UIView!

    private let connecter = PassioInternalConnector.shared
    private let searchController = UISearchController(searchResultsController: nil)
    private var alternateSearches: SearchResponse?
    private var favorites: [FoodRecordV3]?
    private var userFoods: [FoodRecordV3]?

    private var searchTimer: Timer?
    private var previousSearch = ""

    var isCreateRecipe = false
    weak var delegate: AdvancedTextSearchViewDelegate?

    enum SearchState: Equatable {

        case noResult(text: String)
        case typing
        case searching
        case searched

        func getSFSymbolImage(name: String) -> UIImage? {
            UIImage(systemName: name)?.applyingSymbolConfiguration(.init(pointSize: 16,
                                                                         weight: .regular,
                                                                         scale: .medium))
        }

        var image: UIImage? {
            switch self {
            case .noResult:
                return getSFSymbolImage(name: "nosign")
            case .typing:
                return getSFSymbolImage(name: "pencil.line")
            case .searching:
                return getSFSymbolImage(name: "magnifyingglass")
            case .searched:
                return nil
            }
        }

        var message: String? {
            switch self {
            case .noResult(let text):
                return text + " is not in the database".localized
            case .typing:
                return "Keep typing"
            case .searching:
                return "Searching"
            case .searched:
                return nil
            }
        }
    }

    var state: SearchState = .typing

    enum Sections {
        case alternateSearch
        case results
        case status
        case favorites
        case userFoods
    }

    var sections: [Sections] = []

    override func awakeFromNib() {
        super.awakeFromNib()

        configureTableView()
        configureSearchBar()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillShowNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
    }
}

// MARK: - Helper
private extension AdvancedTextSearchView {

    func configureTableView() {
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.rowHeight = UITableView.automaticDimension
        searchTableView.register(nibName: "AdvancedTextSearchCell")
        searchTableView.register(nibName: "AlternateNamesCollCell")
        searchTableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 50, right: 0)
    }

    func configureSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Type in food name".localized
        searchController.searchBar.delegate = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.searchController.searchBar.becomeFirstResponder()
        }

        let titleAttribures = [NSAttributedString.Key.foregroundColor: UIColor.black]
        UIBarButtonItem.appearance(whenContainedInInstancesOf:
                                    [UISearchBar.self]).setTitleTextAttributes(titleAttribures,
                                                                               for: .normal)
        searchController.searchBar.searchTextField.font = UIFont.inter(type: .regular, size: 14)
        searchController.searchBar.searchTextField.textColor = .black
        searchController.searchBar.searchTextField.leftView?.tintColor = .indigo600
        searchController.searchBar.searchTextField.rightView?.tintColor = .gray400
        searchController.searchBar.searchTextField.backgroundColor = .white
        searchController.searchBar.keyboardAppearance = .dark
        searchController.searchBar.backgroundImage = UIImage()
        let searchbar = searchController.searchBar
        searchbar.frame = searchView.bounds
        searchView.addSubview(searchbar)
    }

    func isSearchBarEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    func performSearch(term: String) {
        if previousSearch != term {
            previousSearch = term
            filterContentForSearchText(term)
        }
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardRectValue = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as?
                                    NSValue)?.cgRectValue {
            let constant = (UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 00) +
            (UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 00)
            tblViewHeightConstraint.constant = frame.height - keyboardRectValue.height + constant - 40
            searchTableView.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        tblViewHeightConstraint.constant = frame.height
        searchTableView.layoutIfNeeded()
    }

    func dissmissThisView(passioIDAndName: PassioIDAndName? = nil) {
        searchTimer?.invalidate()
        searchTimer = nil
        alternateSearches = nil
        favorites = nil
        userFoods = nil
        searchController.resignFirstResponder()
        searchController.isActive = false
    }

    private func navigateToEditFood(foodRecord: FoodRecordV3) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            searchController.resignFirstResponder()
            searchController.isActive = false
            var foodRecord = foodRecord
            foodRecord.createdAt = Date()
            foodRecord.mealLabel = MealLabel(mealTime: .currentMealTime())
            delegate?.userSelectedFood(record: foodRecord)
        }
    }

    private func getFoodRecord(foodData: PassioFoodDataInfo?,
                               record: FoodRecordV3?,
                               completion: @escaping ((FoodRecordV3?) -> Void)) {
        if let foodData {
            PassioNutritionAI.shared.fetchFoodItemFor(foodItem: foodData) { (foodItem) in
                guard let foodItem else {
                    completion(nil)
                    return
                }
                completion(FoodRecordV3(foodItem: foodItem))
            }
        } else if let record {
            completion(record)
        }
    }

    private func quickLogFood(record: FoodRecordV3?) {
        if var record {
            record.createdAt = Date()
            record.mealLabel = MealLabel.mealLabelBy()
            connecter.updateRecord(foodRecord: record, isNew: true)
            DispatchQueue.main.async {
                self.findViewController()?.showMessage(msg: "Added to log", alignment: .center)
            }
        }
    }

    // MARK: Search API
    func filterContentForSearchText(_ searchText: String) {

        searchTimer?.invalidate()
        searchTimer = nil

        guard searchText.count > 0 else {
            alternateSearches = nil
            favorites = nil
            userFoods = nil
            reloadTableView()
            return
        }

        if searchText.count < 3 {
            state = .typing
            reloadTableView()
            return
        } else {
            state = .searching
            reloadTableView()
        }

        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] (timer) in

            guard let self else { return }
            let dispatchGroup = DispatchGroup()

            // SDK Search
            dispatchGroup.enter()
            DispatchQueue.global(qos: .userInteractive).async {
                PassioNutritionAI.shared.searchForFood(byText: searchText) { (searchResponse) in
                    self.alternateSearches = searchResponse
                    dispatchGroup.leave()
                }
            }

            // User Foods
            dispatchGroup.enter()
            DispatchQueue.global(qos: .userInitiated).async {
                self.connecter.fetchAllUserFoods { foodRecords in
                    self.userFoods = foodRecords.filter { $0.name.lowercased().contains(searchText) }
                    dispatchGroup.leave()
                }
            }

            // Favorites
            dispatchGroup.enter()
            DispatchQueue.global(qos: .userInitiated).async {
                self.connecter.fetchFavorites { favorites in
                    self.favorites = favorites.filter { $0.name.lowercased().contains(searchText) }
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                if !self.isFoodRecordAvailable {
                    self.state = .noResult(text: searchText)
                } else {
                    self.state = .searched
                }
                self.reloadTableView()
            }
        }
    }

    func fetchFoodItemFromSearch(result: PassioFoodDataInfo) {

        PassioNutritionAI.shared.fetchFoodItemFor(foodItem: result) { [weak self] (foodItem) in
            guard let self else { return }
            DispatchQueue.main.async {
                self.searchController.resignFirstResponder()
                self.searchController.isActive = false
                self.delegate?.userSelectedFoodItem(item: foodItem)
            }
        }
    }

    private var isFoodRecordAvailable: Bool {
        if searchController.searchBar.text!.count >= 3
            && (
                (alternateSearches?.alternateNames.count ?? 0 > 0)
                || (alternateSearches?.results.count ?? 0 > 0)
                || (userFoods?.count ?? 0 > 0)
                || (favorites?.count ?? 0 > 0)
            ) {
            return true
        } else {
            return false
        }
    }

    private func reloadTableView() {
        DispatchQueue.main.async {
            self.searchTableView.reloadWithAnimations(withDuration: 0.03)
        }
    }

    func getAlternateNamesCollectionViewCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = searchTableView.dequeueCell(cellClass: AlternateNamesCollCell.self, forIndexPath: indexPath)
        return cell
    }
}

// MARK: - UITableView DataSource & Delegate
extension AdvancedTextSearchView: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {

        switch state {

        case .noResult, .searching, .typing:
            sections = [.status]

        case .searched:
            var sections: [Sections] = []
            if (alternateSearches?.alternateNames ?? []).count > 0 {
                sections.append(.alternateSearch)
            }
            if (userFoods?.count ?? 0) > 0 {
                sections.append(.userFoods)
            }
            if (favorites?.count ?? 0) > 0 {
                sections.append(.favorites)
            }
            if (alternateSearches?.results ?? []).count > 0 {
                sections.append(.results)
            }
            self.sections = sections
        }
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .status, .alternateSearch: 1
        case .userFoods: userFoods?.count ?? 0
        case .favorites: favorites?.count ?? 0
        case .results: alternateSearches?.results.count ?? 0
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        .leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? AlternateNamesCollCell {
            cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self,
                                                     forRow: indexPath.row)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch sections[indexPath.section] {

        case .alternateSearch:
            let cell = tableView.dequeueCell(cellClass: AlternateNamesCollCell.self, forIndexPath: indexPath)
            return cell

        case .status:
            let cell = tableView.dequeueCell(cellClass: AdvancedTextSearchCell.self, forIndexPath: indexPath)
            cell.setup(state: state)
            return cell

        case .results:
            let cell = tableView.dequeueCell(cellClass: AdvancedTextSearchCell.self, forIndexPath: indexPath)
            if let foodResult = alternateSearches?.results[safe: indexPath.row] {
                cell.setup(foodResult: foodResult)
                cell.plusButton.isHidden = isCreateRecipe
                cell.onQuickAddFood = { [weak self] in
                    guard let self else { return }
                    getFoodRecord(foodData: foodResult, record: nil) { foodRecord in
                        self.quickLogFood(record: foodRecord)
                    }
                }
            }
            return cell

        case .favorites:
            let cell = tableView.dequeueCell(cellClass: AdvancedTextSearchCell.self, forIndexPath: indexPath)

            if let favorites = favorites?[safe: indexPath.row] {

                cell.setup(foodRecord: favorites, isFromSearch: true, isFavorite: true)
                cell.plusButton.isHidden = isCreateRecipe
                cell.onQuickAddFood = { [weak self] in
                    guard let self else { return }
                    getFoodRecord(foodData: nil, record: favorites) { foodRecord in
                        self.quickLogFood(record: foodRecord)
                    }
                }
            }
            return cell

        case .userFoods:
            let cell = tableView.dequeueCell(cellClass: AdvancedTextSearchCell.self, forIndexPath: indexPath)

            if let userFoods = userFoods?[safe: indexPath.row] {

                cell.setup(foodRecord: userFoods, isFromSearch: true)
                cell.plusButton.isHidden = isCreateRecipe
                cell.onQuickAddFood = { [weak self] in
                    guard let self else { return }
                    getFoodRecord(foodData: nil, record: userFoods) { foodRecord in
                        self.quickLogFood(record: foodRecord)
                    }
                }
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let searchResult = alternateSearches?.results else { return }

        switch sections[indexPath.section] {

        case .results:
            fetchFoodItemFromSearch(result: searchResult[indexPath.row])

        case .favorites:
            if let favorites {
                navigateToEditFood(foodRecord: favorites[indexPath.row])
            }

        case .userFoods:
            if let userFoods {
                navigateToEditFood(foodRecord: userFoods[indexPath.row])
            }

        default:
            break
        }
    }
}

//MARK: - UICollectionView DataSource & Delegate
extension AdvancedTextSearchView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return alternateSearches?.alternateNames.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueCell(cellClass: AlternateNamesSearchCell.self, forIndexPath: indexPath)
        let alternateFoodName = alternateSearches?.alternateNames[safe: indexPath.item]
        cell.labelFoodName.text = alternateFoodName?.capitalized
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let alternateSearch = alternateSearches?.alternateNames[safe: indexPath.item]
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
        searchController.searchBar.text = alternateSearch?.capitalized
        filterContentForSearchText(alternateSearch ?? "")
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let foodName = alternateSearches?.alternateNames[safe: indexPath.item] ?? ""
        let sizeForText = foodName.getFixedTwoLineStringWidth()
        return CGSize(width: 80.0 + sizeForText, height: 60)
    }
}

// MARK: - UISearchBar Delegate
extension AdvancedTextSearchView: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        performSearch(term: searchController.searchBar.text!.lowercased())
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dissmissThisView()
    }
}

// MARK: - UISearchResultsUpdating
extension AdvancedTextSearchView: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        performSearch(term: searchController.searchBar.text!.lowercased())
    }
}
