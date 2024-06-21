//
//  RecipesViewController.swift
//  
//
//  Created by Nikunj Prajapati on 21/06/24.
//

import UIKit

class RecipesViewController: InstantiableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Recipes"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupBackButton()
    }
}
