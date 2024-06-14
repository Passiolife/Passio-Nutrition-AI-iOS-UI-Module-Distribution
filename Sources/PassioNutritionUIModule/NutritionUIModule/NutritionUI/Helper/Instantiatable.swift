//
//  Instantiatable.swift
//
//
//  Created by Nikunj Prajapati on 28/05/24.
//

import UIKit

class InstantiableViewController: UIViewController {

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: String(describing: Self.self), bundle: Bundle.module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
