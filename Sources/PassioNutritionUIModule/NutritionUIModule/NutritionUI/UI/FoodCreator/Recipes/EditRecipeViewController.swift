//
//  EditRecipeViewController.swift
//  
//
//  Created by Nikunj Prajapati on 01/07/24.
//

import UIKit

class EditRecipeViewController: InstantiableViewController {

    @IBOutlet weak var editRecipeTableView: UITableView!

    var recipe: FoodRecordV3? {
        didSet {
            print("recipe:- \(recipe)")
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

    }

    @IBAction func onSave(_ sender: UIButton) {

    }
}

// MARK: - Configure
extension EditRecipeViewController {

    private func configureUI() {

        title = "Edit Recipe"
        editRecipeTableView.dataSource = self
    }
}

// MARK: - UITableViewDataSource
extension EditRecipeViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
}
