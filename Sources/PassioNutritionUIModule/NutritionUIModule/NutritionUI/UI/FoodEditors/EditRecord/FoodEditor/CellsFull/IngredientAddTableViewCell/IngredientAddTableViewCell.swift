//
//  IngredientAddTableViewCell.swift
//  BaseApp
//
//  Created by zvika on 4/30/20.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit

class IngredientAddTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var buttonAddIngredients: UIButton!
    @IBOutlet weak var insetBackground: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        insetBackground.roundMyCornerWith(radius: 8)
        insetBackground.dropShadow(radius: 8,
                                   offset: CGSize(width: 0, height: 1),
                                   color: .black.withAlphaComponent(0.06),
                                   shadowRadius: 2,
                                   shadowOpacity: 1)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        insetBackground.layer.shadowPath = UIBezierPath(roundedRect: insetBackground.bounds,
                                                        cornerRadius: 8).cgPath
    }
}
