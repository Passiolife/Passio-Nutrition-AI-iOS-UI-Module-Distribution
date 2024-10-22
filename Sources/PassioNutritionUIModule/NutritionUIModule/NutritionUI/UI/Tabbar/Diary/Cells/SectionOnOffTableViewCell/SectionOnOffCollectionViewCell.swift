//
//  SectionOnOffCollectionViewCell.swift
//  BaseApp
//
//  Created by Mind on 16/02/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit

class SectionOnOffCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var labelMealTime: UILabel!
    @IBOutlet weak var sepratorView: UIView!
    @IBOutlet weak var arrowImageView: UIImageView!

    var mealLabel: MealLabel = .snack
    
    func setup(isExpanded: Bool, hasChild: Bool){
        sepratorView.isHidden = true
        self.arrowImageView.transform = CGAffineTransform(rotationAngle: 0)
        self.arrowImageView.alpha = 0.2
        if hasChild {
            self.arrowImageView.alpha = 1
            if isExpanded {
                sepratorView.isHidden = false
                self.arrowImageView.transform = CGAffineTransform(rotationAngle: .pi)
            }
        }
    }
    
}
