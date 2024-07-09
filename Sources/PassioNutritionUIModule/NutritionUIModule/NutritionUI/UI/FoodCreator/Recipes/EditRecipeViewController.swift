//
//  EditRecipeViewController.swift
//  
//
//  Created by Nikunj Prajapati on 01/07/24.
//

import UIKit

class EditRecipeViewController: InstantiableViewController {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var editRecipeTableView: UITableView!

    private enum EditRecipeCell {
        case recipeDetails, servingSize, addIngredient, ingredients
    }
    private let editRecipeSections: [EditRecipeCell] = [.recipeDetails,
                                                        .servingSize,
                                                        .addIngredient,
                                                        .ingredients]

    var recipe: FoodRecordV3? {
        didSet {
            print("recipe:- \(recipe as Any)")
            editRecipeTableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupBackButton()
    }

    @IBAction func onCancel(_ sender: UIButton) {

        let message = "Are you sure you want to cancel recipe creation? All your progress will be lost."
        showCustomAlert(with: CustomAlert(headingLabel: false,
                                          titleLabel: true,
                                          alertTextField: true,
                                          rightButton: false,
                                          leftButton: false),
                        title: CustomAlert.AlertTitle(headingText: message,
                                                      rightButtonTitle: "Yes",
                                                      leftButtonTitle: "No"),
                        font: CustomAlert.AlertFont(headingFont: .inter(type: .medium, size: 16)),
                        color: CustomAlert.AlertColor(headingColor: .gray900,
                                                      rightButtonColor: .systemRed,
                                                      borderColor: .systemRed,
                                                      isRightBorder: true),
                        delegate: self)
    }

    @IBAction func onSave(_ sender: UIButton) {

    }
}

// MARK: - Configure
extension EditRecipeViewController {

    private func configureUI() {

        title = "Edit Recipe"
        editRecipeTableView.dataSource = self
        editRecipeTableView.register(nibName: RecipeDetailsCell.className)
        cancelButton.applyBorder(width: 2, color: .primaryColor)
        cancelButton.setTitleColor(.primaryColor, for: .normal)
        saveButton.backgroundColor = .primaryColor
    }
}

// MARK: - UITableViewDataSource
extension EditRecipeViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        editRecipeSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch editRecipeSections[section] {
        case .recipeDetails, .servingSize, .addIngredient: 1
        case .ingredients: (recipe?.ingredients.count ?? 1) == 1 ? 0 : (recipe?.ingredients.count ?? 1)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch editRecipeSections[indexPath.section] {
        case .recipeDetails:
            let cell = tableView.dequeueCell(cellClass: RecipeDetailsCell.self, forIndexPath: indexPath)
            return cell
        case .servingSize: return UITableViewCell()
        case .addIngredient: return UITableViewCell()
        case .ingredients: return UITableViewCell()
        }
    }
}

// MARK: - CustomAlert Delegate
extension EditRecipeViewController: CustomAlertDelegate {

    func onRightButtonTapped(textValue: String?) {
        navigationController?.popViewController(animated: true)
    }

    func onleftButtonTapped() { }
}
