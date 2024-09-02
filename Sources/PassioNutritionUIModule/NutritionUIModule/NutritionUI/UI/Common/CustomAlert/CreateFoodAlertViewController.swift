//
//  CreateFoodAlertViewController.swift
//
//
//  Created by Nikunj Prajapati on 09/08/24.
//

import UIKit

protocol CreateFoodAlertDelegate: AnyObject {
    func onCancel()
    func onCreate()
    func onEdit()
    func onUpdateLoguponCreating(isUpdate: Bool)
}

extension CreateFoodAlertDelegate {
    func onCancel() { }
}

class CreateFoodAlertViewController: InstantiableViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var uponLogLabel: UILabel!
    @IBOutlet weak var logSwitch: UISwitch!
    @IBOutlet weak var updateLogStackView: UIStackView!
    
    var isUserFood = false
    var isUserRecipe = false
    var isRecipe = false
    var isHideLogSwitch = false

    weak var delegate: CreateFoodAlertDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
    
    private func configureUI() {

        view.backgroundColor = .gray500.withAlphaComponent(0.75)

        logSwitch.onTintColor = .primaryColor
        cancelButton.applyBorder(width: 2, color: .primaryColor)
        cancelButton.setTitleColor(.primaryColor, for: .normal)
        cancelButton.titleLabel?.textColor = .primaryColor
        createButton.backgroundColor = .primaryColor
        editButton.backgroundColor = .primaryColor

        setTitleAndButtons()
    }

    private func setTitleAndButtons() {

        updateLogStackView.isHidden = isHideLogSwitch

        if isRecipe {
            titleLabel.text = isUserRecipe ? RecipeTexts.createOrEditUserRecipeTitle : RecipeTexts.createUserRecipeTitle
            subTitleLabel.text = isUserRecipe ? RecipeTexts.createOrEditUserRecipeSubTitle : RecipeTexts.createUserRecipeSubTitle
            editButton.isHidden = isUserRecipe ? false : true
        } else {
            titleLabel.text = isUserFood ? UserFoodTexts.createOrEditUserFoodTitle : UserFoodTexts.createUserFoodTitle
            subTitleLabel.text = isUserFood ? UserFoodTexts.createOrEditUserFoodSubTitle : UserFoodTexts.createUserFoodSubTitle
            editButton.isHidden = isUserFood ? false : true
        }
    }

    @IBAction func onCreate(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            self?.delegate?.onCreate()
        }
    }

    @IBAction func onEdit(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            self?.delegate?.onEdit()
        }
    }

    @IBAction func onCancel(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            self?.delegate?.onCancel()
        }
    }

    @IBAction func onUpdateLogCreating(_ sender: UISwitch) {
        delegate?.onUpdateLoguponCreating(isUpdate: sender.isOn)
    }
}
