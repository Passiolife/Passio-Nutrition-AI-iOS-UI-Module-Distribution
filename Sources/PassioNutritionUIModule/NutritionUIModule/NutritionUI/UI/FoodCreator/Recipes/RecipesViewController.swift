//
//  RecipesViewController.swift
//  
//
//  Created by Nikunj Prajapati on 21/06/24.
//

import UIKit

class RecipesViewController: InstantiableViewController {

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var recipesTableView: UITableView!

    private let connector = PassioInternalConnector.shared
    private var recipeName = ""
    private var recipe: FoodRecordV3?
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

        showCustomAlert(with: CustomAlert(headingLabel: false,
                                          titleLabel: false,
                                          alertTextField: false,
                                          rightButton: false,
                                          leftButton: false),
                        title: CustomAlert.AlertTitle(headingText: "Name Your Recipe",
                                                      titleText: "Give your recipe a name, then search for ingredients to include in your recipe.",
                                                      textFieldPlaceholder: "Enter a name",
                                                      rightButtonTitle: "Add Ingredients",
                                                      leftButtonTitle: "Cancel"),
                        font: CustomAlert.AlertFont(headingFont: .inter(type: .bold, size: 20),
                                                    titleFont: .inter(type: .regular, size: 14),
                                                    textFieldPlaceholderFont: .inter(type: .regular, size: 16),
                                                    textFieldFont: .inter(type: .regular, size: 16),
                                                    rightButtonFont: .inter(type: .medium, size: 16),
                                                    leftButtonFont: .inter(type: .medium, size: 16)),
                        delegate: self)
    }
}

// MARK: - Helper
extension RecipesViewController {

    private func configureUI() {

        recipesTableView.register(nibName: AdvancedTextSearchCell.className)
        recipesTableView.dataSource = self
        recipesTableView.delegate = self
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
        connector.updateRecord(foodRecord: record, isNew: true)
        showMessage(msg: "Added to Log")
    }

    private func createRecipe(item: PassioFoodItem) {
        recipe = FoodRecordV3(foodItem: item,
                              barcode: "",
                              scannedWeight: nil,
                              entityType: .recipe,
                              confidence: nil)
    }

    private func navigateToEditRecipe() {
        let editRecipeVC = EditRecipeViewController(nibName: EditRecipeViewController.className, bundle: .module)
        editRecipeVC.loadViewIfNeeded()
        editRecipeVC.recipe = recipe
        navigationController?.pushViewController(editRecipeVC, animated: true)
    }
}

// MARK: - CustomAlert Delegate
extension RecipesViewController: CustomAlertDelegate {

    func onRightButtonTapped(textValue: String?) {

        recipeName = textValue ?? ""

        let plusMenuVC = PlusMenuViewController()
        plusMenuVC.menuData = [.scan, .search, .voiceLogging]
        plusMenuVC.delegate = self
        plusMenuVC.modalTransitionStyle = .crossDissolve
        plusMenuVC.modalPresentationStyle = .overFullScreen
        navigationController?.present(plusMenuVC, animated: true)
    }

    func onleftButtonTapped() {}
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
        print("Recipes:- \(recipes[indexPath.row])")
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) ->
    UISwipeActionsConfiguration? {

        let editItem = UIContextualAction(style: .normal, title: "Edit".localized) {  (_, _, _) in
            print("Recipes:- \(self.recipes[indexPath.row])")
        }
        editItem.backgroundColor = .indigo600

        let deleteItem = UIContextualAction(style: .destructive, title: "Delete".localized) { (_, _, _) in
            self.connector.deleteRecipe(record: self.recipes[indexPath.row])
            DispatchQueue.main.async { [self] in
                if recipes.indices.contains(indexPath.row) {
                    recipes.remove(at: indexPath.row)
                }
            }
        }

        let swipeActions = UISwipeActionsConfiguration(actions: [deleteItem, editItem])
        return swipeActions
    }
}


// MARK: - PlusMenu Delegate
extension RecipesViewController: PlusMenuDelegate {

    func onSearchSelected() {
        let vc = TextSearchViewController()
        vc.dismmissToMyLog = true
        vc.isCreateRecipe = true
        vc.modalPresentationStyle = .fullScreen
        vc.advancedSearchDelegate = self
        present(vc, animated: true)
    }

    func onScanSelected() {

    }

    func onFavouritesSelected() {}

    func onRecipesSelected() {}

    func onMyFoodsSelected() {}

    func onVoiceLoggingSelected() {}

    func takePhotosSelected() {}

    func selectPhotosSelected() {}
}

// MARK: - AdvancedTextSearch ViewDelegate
extension RecipesViewController: AdvancedTextSearchViewDelegate {

    func userSelectedFoodItem(item: PassioFoodItem?) {
        if let item {
            if recipe == nil {
                createRecipe(item: item)
            } else if var recipe {
                recipe.addIngredient(record: FoodRecordV3(foodItem: item))
            }
            navigateToEditRecipe()
        }
    }

    func userSelectedFood(record: FoodRecordV3?) { }
}
