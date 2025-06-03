//
//  TipPopupVC.swift
//  PassioNutritionUIModule
//
//  Created by Pratik on 30/05/25.
//

import UIKit

class TipPopupVC: UIViewController {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var okButton: UIButton!
    
    var tip: Tip = .captureNutritionFacts

    override func viewDidLoad() {
        super.viewDidLoad()
        basicSetup()
        setData()
    }
    
    func basicSetup() {
        self.view.backgroundColor = .black.alpha(0.8)
        titleLabel.font = .inter(type: .semiBold, size: 20)
        descLabel.font = .inter(type: .regular, size: 16)
        okButton.titleLabel?.font = .inter(type: .semiBold, size: 18)
    }
    
    func setData() {
        titleLabel.text = tip.title
        descLabel.text = tip.desc
        imageView.image = tip.image
    }
    
    @IBAction func okButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
