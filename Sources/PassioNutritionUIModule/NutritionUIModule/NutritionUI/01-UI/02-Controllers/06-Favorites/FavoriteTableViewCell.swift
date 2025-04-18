//
//  FavoriteTableViewCell.swift
//  Passio App Module
//
//  Created by zvika on 2/12/19.
//  Copyright © 2023 PassioLife Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

class FavoriteTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var unitQtyLabel: UILabel!
    @IBOutlet weak var calorieLabel: UILabel!
    @IBOutlet weak var imageFood: UIImageView!
    @IBOutlet weak var insetBackground: UIView!
    @IBOutlet weak var buttonAddToLog: UIButton!

    var passioIDForCell: PassioID?

    override func awakeFromNib() {
        super.awakeFromNib()
        insetBackground.roundMyCornerWith(radius: Custom.insetBackgroundRadius)
    }
}
