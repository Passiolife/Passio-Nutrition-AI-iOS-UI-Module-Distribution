//
//  NFNoDataVC.swift
//  PassioNutritionUIModule
//
//  Created by Pratik on 23/05/25.
//

import UIKit

class NFNoDataVC: UIViewController {
    
    var onTryAgain: (() -> Void)?
    var onEnterManually: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        basicSetup()
    }
    
    func basicSetup() {
        self.view.backgroundColor = UIColor.black.alpha(0.8)
    }
    
    @IBAction func tryAgainTapped(_ sender: UIButton) {
        self.onTryAgain?()
        self.dismiss(animated: true)
    }
    
    @IBAction func enterManuallyTapped(_ sender: UIButton) {
        self.onEnterManually?()
        self.dismiss(animated: true)
    }
}
