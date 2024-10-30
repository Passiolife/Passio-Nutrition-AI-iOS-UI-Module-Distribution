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
    func userSelectedFoodItem(item: PassioFoodItem?, isPlusAction: Bool)
    func userSelectedFood(record: FoodRecordV3?, isPlusAction: Bool)
}

final class AdvancedTextSearchView: UIView {

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var tblViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var searchViewContainer: UIStackView!
    @IBOutlet private weak var labelSemanticSearchTitle: UILabel!
    @IBOutlet private weak var switchSemantic: UISwitch!
    
    private let connecter = PassioInternalConnector.shared
    private var alternateSearches: SearchResponse?
    private var state: SearchState = .startTyping
    private var searchViewsSections: [SearchViewSections] = []
    private var customFoods: [FoodRecordV3] = []
    private var searchTimer: Timer?
    private var previousSearch = ""
    private var isFirstTime = true
    private var isSemanticSearchEnable: Bool = false

    var searchController: UISearchController?
    var isCreateRecipe = false

    weak var delegate: AdvancedTextSearchViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        activityIndicatorView.color = .primaryColor
        labelSemanticSearchTitle.text = "Enable Semantic Search Feature".capitalized
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if isFirstTime {
            isFirstTime = false
            setupSearchBar()
        }
    }
}

// MARK: - Helper
private extension AdvancedTextSearchView {

    func configureTableView() {
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.rowHeight = UITableView.automaticDimension
        searchTableView.register(nibName: AdvancedTextSearchCell.className)
        searchTableView.register(nibName: AlternateNamesCollCell.className)
        searchTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
    }

    private func setupSearchBar() {

        searchController = UISearchController(searchResultsController: nil)

        if let vc = findViewController(), let searchController {
            searchController.searchResultsUpdater = self
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.searchBar.placeholder = "Search Your Food".localized
            searchController.searchBar.delegate = self
            let titleAttribures = [NSAttributedString.Key.foregroundColor: UIColor.black]
            UIBarButtonItem.appearance(whenContainedInInstancesOf:
                                        [UISearchBar.self]).setTitleTextAttributes(titleAttribures,
                                                                                   for: .normal)
            searchController.searchBar.searchTextField.font = UIFont.inter(type: .regular, size: 14)
            searchController.searchBar.searchTextField.textColor = .black
            searchController.searchBar.searchTextField.leftView?.tintColor = .primaryColor
            searchController.searchBar.searchTextField.rightView?.tintColor = .gray400
            searchController.searchBar.searchTextField.backgroundColor = .white
            searchController.searchBar.keyboardAppearance = .dark
            searchController.searchBar.backgroundImage = UIImage()
            searchController.searchBar.tintColor = .primaryColor
            searchController.searchBar.showsCancelButton = true
            configureSearchBarTextField()
            vc.navigationItem.searchController = searchController
            vc.navigationItem.hidesSearchBarWhenScrolling = false
            vc.definesPresentationContext = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { [weak self] in
                self?.searchController?.searchBar.becomeFirstResponder()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in
                    self?.configureTableView()
                }
            }
        }
    }

    func isSearchBarEmpty() -> Bool {
        searchController?.searchBar.text?.isEmpty ?? true
    }

    func performSearch(term: String) {
        if previousSearch != term {
            previousSearch = term
            getSearchResults(term)
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
        customFoods.removeAll()
        searchController?.resignFirstResponder()
        searchController?.isActive = false
        findViewController()?.navigationController?.popViewController(animated: true)
    }

    private func navigateToEditFood(foodRecord: FoodRecordV3) {

        searchTimer?.invalidate()
        searchTimer = nil

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            var foodRecord = foodRecord
            foodRecord.createdAt = Date()
            foodRecord.mealLabel = MealLabel(mealTime: .currentMealTime())
            delegate?.userSelectedFood(record: foodRecord, isPlusAction: false)
        }
    }

    private func fetchFoodItemFromSearch(result: PassioFoodDataInfo) {

        searchTimer?.invalidate()
        searchTimer = nil

        PassioNutritionAI.shared.fetchFoodItemFor(foodDataInfo: result) { [weak self] (foodItem) in
            guard let self else { return }
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicatorView.isHidden = true
                self?.delegate?.userSelectedFoodItem(item: foodItem, isPlusAction: false)
            }
        }
    }

    private func getFoodRecord(foodData: PassioFoodDataInfo?,
                               record: FoodRecordV3?,
                               completion: @escaping ((FoodRecordV3?) -> Void)) {

        DispatchQueue.main.async { [weak self] in
            self?.activityIndicatorView.isHidden = false
            self?.activityIndicatorView.startAnimating()
        }
        if let foodData {
            PassioNutritionAI.shared.fetchFoodItemFor(foodDataInfo: foodData) { (foodItem) in
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

        DispatchQueue.main.async { [weak self] in
            self?.activityIndicatorView.isHidden = true
        }
        if var record {
            if isCreateRecipe {
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.userSelectedFood(record: record, isPlusAction: true)
                }
            } else {
                record.createdAt = Date()
                record.mealLabel = MealLabel.mealLabelBy()
                connecter.updateRecord(foodRecord: record)
                DispatchQueue.main.async { [weak self] in
                    self?.findViewController()?.showMessage(msg: ToastMessages.addedToLog, alignment: .center)
                }
            }
        }
    }

    private var isFoodRecordAvailable: Bool {
        if searchController?.searchBar.text!.count ?? 0 >= 3
            && (
                (alternateSearches?.alternateNames.count ?? 0 > 0)
                || (alternateSearches?.results.count ?? 0) > 0
                || customFoods.count > 0
            ) {
            return true
        } else {
            return false
        }
    }

    private func reloadTableView() {
        DispatchQueue.main.async { [weak self] in
            self?.searchTableView.reloadWithAnimations(withDuration: 0.1)
        }
    }

    // MARK: Search API
    private func getSearchResults(_ searchText: String) {

        searchTimer?.invalidate()
        searchTimer = nil
        customFoods.removeAll()

        guard searchText.count > 0 else {
            alternateSearches = nil
            state = .startTyping
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
            let searchQueue = DispatchQueue.global(qos: .userInitiated)

            // SDK Search
            dispatchGroup.enter()
            searchQueue.async {
                
                if self.isSemanticSearchEnable {
                    PassioNutritionAI.shared.semanticSearchForFood(searchTerm: searchText) { (searchResponse) in
                        self.alternateSearches = searchResponse
                        dispatchGroup.leave()
                    }
                }
                else {
                    PassioNutritionAI.shared.searchForFood(byText: searchText) { (searchResponse) in
                        self.alternateSearches = searchResponse
                        dispatchGroup.leave()
                    }
                }
            }

            let lowerSearchedText = searchText
            let searchedArray = lowerSearchedText.components(separatedBy: " ").map { $0.lowercased() }

            // User Foods
            dispatchGroup.enter()
            searchQueue.async {
                self.connecter.fetchAllUserFoods { userFoods in
                    if userFoods.count > 0 {
                        self.customFoods.append(contentsOf: self.getMatchedFoodRecords(for: userFoods,
                                                                                       text: searchedArray))
                    }
                    dispatchGroup.leave()
                }
            }

            // Recipes
            dispatchGroup.enter()
            searchQueue.async {
                self.connecter.fetchRecipes { recipes in
                    if recipes.count > 0 {
                        self.customFoods.append(contentsOf: self.getMatchedFoodRecords(for: recipes,
                                                                                       text: searchedArray))
                    }
                    dispatchGroup.leave()
                }
            }

            // Favorites
            dispatchGroup.enter()
            searchQueue.async {
                self.connecter.fetchFavorites { favorites in
                    self.customFoods.append(contentsOf: self.getMatchedFoodRecords(for: favorites,
                                                                                   text: searchedArray))
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .global(qos: .userInitiated)) {
                self.customFoods.flatMap { $0 }
                DispatchQueue.main.async {
                    self.state = self.isFoodRecordAvailable ? .searched : .noResult(text: searchText)
                    self.reloadTableView()
                }
            }
        }
    }

    private func getMatchedFoodRecords(for records: [FoodRecordV3],
                                       text: [String]) -> [FoodRecordV3] {
        records.filter { record in
            text.filter { record.name.lowercased().contains($0) }.isEmpty == false
        }
    }
}

// MARK: - UITableView DataSource & Delegate
extension AdvancedTextSearchView: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {

        switch state {

        case .noResult, .searching, .startTyping, .typing:
            searchViewsSections = [.searchStatus]

        case .searched:
            var sections: [SearchViewSections] = []
            if (alternateSearches?.alternateNames ?? []).count > 0 {
                sections.append(.alternateSearchNames)
            }
            if customFoods.count > 0 {
                sections.append(.customFoods)
            }
            if (alternateSearches?.results.count ?? 0) > 0 {
                sections.append(.searchResults)
            }
            searchViewsSections = sections
        }
        return searchViewsSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch searchViewsSections[section] {
        case .searchStatus, .alternateSearchNames: 1
        case .customFoods: customFoods.count ?? 0
        case .searchResults: alternateSearches?.results.count ?? 0
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let headerView = UIView()
        headerView.backgroundColor = .clear

        let headerLabel = UILabel()
        headerLabel.frame = CGRect(x: 16, y: 0, width: tableView.frame.size.width - 16, height: 28)
        headerLabel.font = .inter(type: .semiBold, size: 16)
        headerLabel.textColor = .gray900
        headerLabel.backgroundColor = .clear

        headerLabel.text = switch state {
        case .noResult, .searching, .startTyping, .typing:
            ""
        case .searched:
            switch searchViewsSections[section] {
            case .searchStatus, .alternateSearchNames: ""
            case .searchResults: "Search Results"
            case .customFoods: "My Foods"
            }
        }

        headerView.addSubview(headerLabel)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch state {
        case .noResult, .searching, .startTyping, .typing:
                16
        case .searched:
            switch searchViewsSections[section] {
            case .searchStatus, .alternateSearchNames: 2
            case .searchResults: (alternateSearches?.results.count ?? 0) > 0 ? 36 : .leastNonzeroMagnitude
            case .customFoods: customFoods.count > 0 ? 36 : .leastNonzeroMagnitude
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        2
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? AlternateNamesCollCell {
            cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self,
                                                     forRow: indexPath.row)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch searchViewsSections[indexPath.section] {

        case .alternateSearchNames:
            let cell = tableView.dequeueCell(cellClass: AlternateNamesCollCell.self, forIndexPath: indexPath)
            return cell

        case .searchStatus:
            let cell = tableView.dequeueCell(cellClass: AdvancedTextSearchCell.self, forIndexPath: indexPath)
            cell.setup(state: state)
            return cell

        case .searchResults:
            let cell = tableView.dequeueCell(cellClass: AdvancedTextSearchCell.self, forIndexPath: indexPath)
            if let passioFoodDataInfo = alternateSearches?.results[safe: indexPath.row] {
                cell.setup(passioFoodDataInfo: passioFoodDataInfo,
                           isFromSearch: true,
                           isRecipe: passioFoodDataInfo.type == "recipe")
                cell.onQuickAddFood = { [weak self] in
                    guard let self else { return }
                    getFoodRecord(foodData: passioFoodDataInfo, record: nil) { foodRecord in
                        self.quickLogFood(record: foodRecord)
                    }
                }
            }
            return cell

        case .customFoods:

            let cell = tableView.dequeueCell(cellClass: AdvancedTextSearchCell.self, forIndexPath: indexPath)

            if let customFoods = customFoods[safe: indexPath.row] {

                cell.setup(foodRecord: customFoods,
                           isFromSearch: true,
                           isRecipe: customFoods.ingredients.count > 1)

                cell.onQuickAddFood = { [weak self] in
                    guard let self else { return }
                    getFoodRecord(foodData: nil, record: customFoods) { foodRecord in
                        self.quickLogFood(record: foodRecord)
                    }
                }
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch searchViewsSections[indexPath.section] {

        case .searchResults:
            DispatchQueue.main.async {
                self.activityIndicatorView.isHidden = false
                self.activityIndicatorView.startAnimating()
            }
            if let searchResult = alternateSearches?.results, searchResult.count > 0 {
                fetchFoodItemFromSearch(result: searchResult[indexPath.row])
            }

        case .customFoods:
            if customFoods.count > 0 {
                navigateToEditFood(foodRecord: customFoods[indexPath.row])
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
        searchController?.searchBar.text = alternateSearch?.capitalized
        getSearchResults(alternateSearch ?? "")
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let foodName = alternateSearches?.alternateNames[safe: indexPath.item] ?? ""
        let sizeForText = foodName.getFixedTwoLineStringWidth()
        return CGSize(width: 80.0 + sizeForText, height: 48)
    }
}

// MARK: - UISearchBar Delegate
extension AdvancedTextSearchView: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        performSearch(term: searchController?.searchBar.text!.lowercased() ?? "")
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dissmissThisView()
    }
}

// MARK: - UISearchResultsUpdating
extension AdvancedTextSearchView: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        DispatchQueue.main.async { [weak self] in
            self?.performSearch(term: searchController.searchBar.text!.lowercased())
        }
    }
}

//MARK: - @IBAction
extension AdvancedTextSearchView {
    @IBAction func toggleSemanticSwitch(_ sender: UISwitch) {
        if sender.isOn {
            isSemanticSearchEnable = true
        } else {
            isSemanticSearchEnable = false
        }
        self.previousSearch = ""
        self.performSearch(term: searchController?.searchBar.text!.lowercased() ?? "")
    }
}
