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
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        insetBackground.roundMyCornerWith(radius: 8)
        insetBackground.dropShadow()
    }

}
