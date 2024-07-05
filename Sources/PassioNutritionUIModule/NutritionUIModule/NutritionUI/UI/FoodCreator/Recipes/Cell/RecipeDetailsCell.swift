//
//  RecipeDetailsCell.swift
//  
//
//  Created by Nikunj Prajapati on 02/07/24.
//

import UIKit

class RecipeDetailsCell: UITableViewCell {

    @IBOutlet weak var backgroundShadowView: UIView!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeNameTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        recipeNameTextField.configureTextField(leftPadding: 13,
                                               radius: 6,
                                               borderColor: .gray300)
        backgroundShadowView.dropShadow(radius: 8,
                                        offset: CGSize(width: 0, height: 1),
                                        color: .black.withAlphaComponent(0.06),
                                        shadowRadius: 2,
                                        shadowOpacity: 1)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundShadowView.layer.shadowPath = UIBezierPath(roundedRect: backgroundShadowView.bounds,
                                                             cornerRadius: 8).cgPath
    }

    func configureCell(with image: UIImage) {

    }

    @IBAction func onRecipeImage(_ sender: UIButton) {

    }
}
