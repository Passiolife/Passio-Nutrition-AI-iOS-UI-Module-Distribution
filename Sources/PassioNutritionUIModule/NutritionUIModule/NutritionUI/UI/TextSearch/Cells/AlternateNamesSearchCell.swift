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
        viewBackground.dropShadow(radius: 8,
                                  offset: CGSize(width: 0, height: 1),
                                  color: .black.withAlphaComponent(0.06),
                                  shadowRadius: 2,
                                  shadowOpacity: 1)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        viewBackground.layer.shadowPath = UIBezierPath(roundedRect: viewBackground.bounds,
                                                        cornerRadius: 8).cgPath
    }
}
