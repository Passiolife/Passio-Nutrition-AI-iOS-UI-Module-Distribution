//
//  AlternateNamesSearchCell.swift
//  NutritionAISDK
//
//  Created by Nikunj Prajapati on 05/01/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit

class AlternateNamesSearchCell: UICollectionViewCell {
    
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var labelFoodName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        viewBackground.roundMyCornerWith(radius: 8)
        viewBackground.dropShadow()
    }
}
