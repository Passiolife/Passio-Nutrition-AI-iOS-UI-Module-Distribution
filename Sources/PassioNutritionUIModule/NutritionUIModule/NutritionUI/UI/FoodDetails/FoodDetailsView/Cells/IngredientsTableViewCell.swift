//
//  IngredientAddTableViewCell.swift
//  BaseApp
//
//  Created by zvika on 4/30/20.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit

class IngredientsTableViewCell: UITableViewCell {

    @IBOutlet weak var insetBackground: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var makeRecipeButton: UIButton!
    @IBOutlet weak var makeRecipeWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        insetBackground.roundMyCornerWith(radius: 8, upper: true, down: false)
        insetBackground.dropShadow(radius: 8,
                                   offset: CGSize(width: 0, height: -1),
                                   color: .black.withAlphaComponent(0.06),
                                   shadowRadius: 2,
                                   shadowOpacity: 1)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        DispatchQueue.main.async { [self] in
            insetBackground.layer.shadowPath = UIBezierPath(roundedRect: insetBackground.bounds,
                                                            cornerRadius: 8).cgPath
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }
}
