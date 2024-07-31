//
//  Instantiatable.swift
//
//
//  Created by Nikunj Prajapati on 28/05/24.
//

import UIKit

class InstantiableViewController: UIViewController {

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let initBundle = nibBundleOrNil ?? Bundle.module
        super.init(nibName: String(describing: Self.self), bundle: initBundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
