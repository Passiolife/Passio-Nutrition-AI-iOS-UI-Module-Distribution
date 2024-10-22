//
//  RecipesViewController.swift
//  
//
//  Created by Nikunj Prajapati on 21/06/24.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

class RecipesViewController: InstantiableViewController {

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var recipesTableView: UITableView!
    @IBOutlet weak var createNewRecipeButton: UIButton!
    
    private let connector = PassioInternalConnector.shared
    private var recipes: [FoodRecordV3] = [] {
        didSet {
            recipesTableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupBackButton()
        fetchRecipes()
    }

    @IBAction func onCreateNewRecipe(_ sender: UIButton) {

        let editRecipeVC = EditRecipeViewController()
        editRecipeVC.isCreate = true
        editRecipeVC.vcTitle = RecipeTexts.createRecipe
        editRecipeVC.loadViewIfNeeded()
        navigationController?.pushViewController(editRecipeVC, animated: true)
    }
}

// MARK: - Helper
extension RecipesViewController {

    private func configureUI() {

        recipesTableView.register(nibName: AdvancedTextSearchCell.className)
        recipesTableView.dataSource = self
        recipesTableView.delegate = self
        createNewRecipeButton.backgroundColor = .primaryColor
        activityIndicatorView.color = .primaryColor
    }

    @objc private func fetchRecipes() {
        connector.fetchRecipes { [weak self] recipes in
            guard let self else { return }
            DispatchQueue.main.async {
                self.activityIndicatorView.isHidden = true
                self.recipes = recipes
            }
        }
    }

    private func addFoodQuickly(record: FoodRecordV3) {
        var foodRecord = record
        foodRecord.uuid = UUID().uuidString
        foodRecord.createdAt = Date()
        foodRecord.mealLabel = .mealLabelBy()
        connector.updateRecord(foodRecord: foodRecord)
        showMessage(msg: ToastMessages.addedToLog)
    }

    private func navigateToFoodEdit(with record: FoodRecordV3) {
        let editVC = FoodDetailsViewController()
        editVC.isFromRecipeList = true
        editVC.foodRecord = record
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            navigationController?.pushViewController(editVC, animated: true)
        }
    }

    private func navigateToEditRecipe(with record: FoodRecordV3?) {

        let editRecipeVC = EditRecipeViewController()
        editRecipeVC.vcTitle = RecipeTexts.editRecipe
        editRecipeVC.isCreate = false
        editRecipeVC.isFromRecipeList = true

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            editRecipeVC.loadViewIfNeeded()
            editRecipeVC.recipe = record
            navigationController?.pushViewController(editRecipeVC, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension RecipesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        recipes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueCell(cellClass: AdvancedTextSearchCell.self, forIndexPath: indexPath)
        let foodRecord = recipes[indexPath.row]
        cell.setup(foodRecord: foodRecord)
        cell.onQuickAddFood = { [weak self] in
            self?.addFoodQuickly(record: foodRecord)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigateToFoodEdit(with: recipes[indexPath.row])
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) ->
    UISwipeActionsConfiguration? {

        let editItem = UIContextualAction(style: .normal, title: ButtonTexts.edit) { [weak self] (_, _, _) in
            self?.navigateToEditRecipe(with: self?.recipes[indexPath.row])
        }
        editItem.backgroundColor = .primaryColor

        let deleteItem = UIContextualAction(style: .destructive, title: ButtonTexts.delete) { [weak self] (_, _, _) in
            if let self {
                self.connector.deleteRecipe(record: self.recipes[indexPath.row])
                DispatchQueue.main.async { [self] in
                    if self.recipes.indices.contains(indexPath.row) {
                        self.recipes.remove(at: indexPath.row)
                    }
                }
            }
        }

        let swipeActions = UISwipeActionsConfiguration(actions: [deleteItem, editItem])
        return swipeActions
    }
}
