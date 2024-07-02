//
//  MealPlanSectionHeaderCell.swift
//  BaseApp
//
//  Created by Mind on 16/02/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit

protocol MealPlanSectionHeaderCellDelegate: NSObjectProtocol{
    func onClickLog(mealLabel: MealLabel)
}

class MealPlanSectionHeaderCell: UICollectionViewCell {

    @IBOutlet weak var labelMealTime: UILabel!
    @IBOutlet weak var sepratorView: UIView!
    @IBOutlet weak var logEntireMealButton: UIButton!

    weak var delegate: MealPlanSectionHeaderCellDelegate?
    var mealLabel: MealLabel = .snack

    func setup(hasChild: Bool) {
        sepratorView.isHidden = true
        if hasChild {
            sepratorView.isHidden = false
        }
    }

    @IBAction func onClickLogEntireMeal() {
        self.delegate?.onClickLog(mealLabel: self.mealLabel)
    }
}
