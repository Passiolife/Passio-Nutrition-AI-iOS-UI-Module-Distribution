//
//  TextSearchCellTableViewCell.swift
//  Passio App Module
//
//  Created by zvika on 2/12/19.
//  Copyright © 2023 PassioLife Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

class TextSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageFood: UIImageView!
    @IBOutlet weak var insetBackground: UIView!
    @IBOutlet weak var imagePlus: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var passioIDForCell: PassioID?

    override func awakeFromNib() {
        super.awakeFromNib()
        insetBackground.roundMyCornerWith(radius: Custom.insetBackgroundRadius)
        imageFood.roundMyCorner()
    }
}
