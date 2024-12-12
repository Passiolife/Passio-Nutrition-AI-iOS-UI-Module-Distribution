//
//  MyFavoritesViewController.swift
//  Passio App Module
//
//  Created by zvika on 4/9/19.
//  Copyright © 2023 PassioLife Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

protocol FavoritesViewDelegate: AnyObject {
    func userAddedToLog(foodRecord: FoodRecordV3)
    func onAddIngredient(foodRecord: FoodRecordV3?)
}

extension FavoritesViewDelegate {
    func userAddedToLog(foodRecord: FoodRecordV3) {}
    func onAddIngredient(foodRecord: FoodRecordV3?) {}
}

final class MyFavoritesViewController: InstantiableViewController {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    weak var delegate: FavoritesViewDelegate?
    private let connector = NutritionUIModule.shared
    private let refreshControl = UIRefreshControl()
    private var favorites = [FoodRecordV3]()
    private var addedToFavorites = -1

    /* As we don't need to make any logs from Favorite Foods we ignore default set value,
     * we need only addIngredient enum to check if user redirect form Create/Edit Recipe screen or not.
     */
    var resultViewFor: DetectedFoodResultType = .addLog

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "TitleFavorites".localized

        tableView.register(nibName: "AdvancedTextSearchCell")
        tableView.delegate = self
        tableView.dataSource = self
        refreshControl.addTarget(self,
                                 action: #selector(getFavoritesFromConnector),
                                 for: .valueChanged)
        tableView.addSubview(refreshControl)
        setupBackButton()
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 50, right: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if navigationController == nil {
            closeButton.setTitle("", for: .normal)
            closeButton.isHidden = false
        } else {
            closeButton.isHidden = true
        }
        getFavoritesFromConnector()
    }

    @objc func getFavoritesFromConnector() {

        activityIndicator.startAnimating()
        connector.fetchFavorites { [weak self] (records) in
            guard let self else { return }
            favorites = records.sorted { $0.createdAt > $1.createdAt }
            activityIndicator.stopAnimating()
            tableView.reloadData()
            if favorites.count == 0 {
                alertUserNoFavorits()
            }
        }
        refreshControl.endRefreshing()
    }

    func alertUserNoFavorits() {
        let alert = UIAlertController(title: "Nofavorites".localized,
                                      message: "SaveFavorites".localized, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK".localized, style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(action)
        present(alert, animated: true)
    }

    @IBAction func dissmiss(_ sender: Any) {
        dismiss(animated: true)
    }
}

// MARK: - UITableView DataSource
extension MyFavoritesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AdvancedTextSearchCell",
                                                       for: indexPath) as? AdvancedTextSearchCell else {
            return UITableViewCell()
        }
        cell.setup(foodRecord: favorites[indexPath.row])
        cell.plusButton.tag = indexPath.row
        cell.plusButton.addTarget(self, action: #selector(addFoodToLog(button:)), for: .touchUpInside)
        cell.plusButton.isHidden = indexPath.row == addedToFavorites ? true : false
        return cell
    }

    @objc func addFoodToLog(button: UIButton) {

        var newFoodRecord = favorites[button.tag]
        newFoodRecord.uuid = UUID().uuidString
        newFoodRecord.createdAt = Date()
        newFoodRecord.mealLabel = MealLabel.mealLabelBy(time: Date())
        
        if resultViewFor == .addIngredient {
            self.delegate?.onAddIngredient(foodRecord: newFoodRecord)
            self.navigationController?.popViewController(animated: true)
        }
        else {
            connector.updateRecord(foodRecord: newFoodRecord)
            
            addedToFavorites = button.tag
            tableView.reloadData()
            
            delegate?.userAddedToLog(foodRecord: newFoodRecord)
            
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] (_) in
                self?.addedToFavorites = -1
                self?.tableView.reloadData()
            }
            
            showMessage(msg: ToastMessages.addedToLog)
            NutritionUICoordinator.navigateToDairyAfterAction(navigationController: self.navigationController!)
        }
    }
}

// MARK: - UITableView Delegate
extension MyFavoritesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favorite = favorites[indexPath.row]
        let editVC = FoodDetailsViewController()
        editVC.foodRecord = favorite
        
        editVC.resultViewFor = resultViewFor
        editVC.isFromMyFavorites = true
        editVC.isEditingFavorite = false
        editVC.foodDetailsControllerDelegate = self
        navigationController?.pushViewController(editVC, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) ->
    UISwipeActionsConfiguration? {
        let editItem = UIContextualAction(style: .normal, title: "Edit".localized) {  (_, _, _) in
            let favorite = self.favorites[indexPath.row]
            let editVC = FoodDetailsViewController()
            editVC.foodRecord = favorite
            editVC.isEditingFavorite = true
            editVC.isFromMyFavorites = true
            editVC.resultViewFor = self.resultViewFor
            editVC.foodDetailsControllerDelegate = self
            self.navigationController?.pushViewController(editVC, animated: true)
        }
        editItem.backgroundColor = .primaryColor

        let deleteItem = UIContextualAction(style: .destructive, title: "Delete".localized) {  (_, _, _) in
            let favorite = self.favorites.remove(at: indexPath.row)
            self.connector.deleteFavorite(foodRecord: favorite)
            self.getFavoritesFromConnector()
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }

        let swipeActions = UISwipeActionsConfiguration(actions: [deleteItem,editItem])
        return swipeActions
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) ->
    UITableViewCell.EditingStyle {
        return .delete
    }
}

extension MyFavoritesViewController: FoodDetailsControllerDelegate {

    func deleteFromEdit(foodRecord: FoodRecordV3) {
        connector.deleteFavorite(foodRecord: foodRecord)
        favorites = favorites.filter { $0.uuid != foodRecord.uuid }
        tableView.reloadData()
    }
    
    func onFoodDetailsAddIngredient(foodRecord: FoodRecordV3?) {
        self.delegate?.onAddIngredient(foodRecord: foodRecord)
        self.navigationController?.popViewController(animated: true)
    }
}

extension MyFavoritesViewController {

    func userAddedToLog(foodRecord: FoodRecordV3) {

        //        delegate?.userAddedToLog(foodRecord: foodRecord)
        //
        //        if dismmissToMyLog {
        //            dismiss(animated: true)
        //        } else {
        //            displayAdded(withText: "Item added to Log" )
        //        }
    }

    func displayAdded(withText: String) {
        //        let width: CGFloat = 200
        //        let height: CGFloat = 40
        //        let fromButton: CGFloat = 100
        //        let frame = CGRect(x: (view.bounds.width - width)/2,
        //                           y: view.bounds.height - fromButton,
        //                           width: width,
        //                           height: height)
        //        let addedToLog = AddedToLogView(frame: frame, withText: withText)
        //        view.addSubview(addedToLog)
        //        addedToLog.removeAfter(withDuration: 1, delay: 1)
    }

}
