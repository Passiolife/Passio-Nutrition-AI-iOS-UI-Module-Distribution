//
//  CustomFoodsViewController.swift
//
//
//  Created by Nikunj Prajapati on 24/06/24.
//

import UIKit

class CustomFoodsViewController: InstantiableViewController {

    @IBOutlet weak var createNewFoodButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var customFoodsTableView: UITableView!

    private let connector = PassioInternalConnector.shared
    var customFoods: [FoodRecordV3] = [] {
        didSet {
            customFoodsTableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupBackButton()
        fetchCustomFoods()
    }

    @IBAction func onCreateNewFood(_ sender: UIButton) {
        let createFoodVC = CreateFoodViewController(nibName: CreateFoodViewController.className, bundle: .module)
        navigationController?.pushViewController(createFoodVC, animated: true)
    }
}

// MARK: - Helper
extension CustomFoodsViewController {

    private func configureUI() {

        customFoodsTableView.register(nibName: AdvancedTextSearchCell.className)
        customFoodsTableView.dataSource = self
        customFoodsTableView.delegate = self
        createNewFoodButton.backgroundColor = .primaryColor
    }

    @objc private func fetchCustomFoods() {
        connector.fetchAllUserFoods(completion: { [weak self] customFoods in
            guard let self else { return }
            DispatchQueue.main.async {
                self.activityIndicatorView.isHidden = true
                self.customFoods = customFoods
            }
        })
    }

    private func addFoodQuickly(record: FoodRecordV3) {
        connector.updateRecord(foodRecord: record, isNew: true)
        showMessage(msg: "Added to Log")
    }

    private func navigateToEdit(with record: FoodRecordV3) {
        let createFoodVC = CreateFoodViewController(nibName: CreateFoodViewController.className,
                                                    bundle: .module)
        createFoodVC.loadViewIfNeeded()
        createFoodVC.isCreateNewFood = false
        createFoodVC.foodRecord = record
        navigationController?.pushViewController(createFoodVC, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension CustomFoodsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        customFoods.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueCell(cellClass: AdvancedTextSearchCell.self, forIndexPath: indexPath)
        let foodRecord = customFoods[indexPath.row]
        cell.setup(foodRecord: foodRecord)
        cell.onQuickAddFood = { [weak self] in
            self?.addFoodQuickly(record: foodRecord)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigateToEdit(with: customFoods[indexPath.row])
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) ->
    UISwipeActionsConfiguration? {

        let editItem = UIContextualAction(style: .normal, title: "Edit".localized) {  (_, _, _) in
            self.navigateToEdit(with: self.customFoods[indexPath.row])
        }
        editItem.backgroundColor = .primaryColor

        let deleteItem = UIContextualAction(style: .destructive, title: "Delete".localized) { (_, _, _) in
            self.connector.deleteUserFood(record: self.customFoods[indexPath.row])
            DispatchQueue.main.async { [self] in
                if customFoods.indices.contains(indexPath.row) {
                    customFoods.remove(at: indexPath.row)
                }
            }
        }
        return UISwipeActionsConfiguration(actions: [deleteItem, editItem])
    }
}
