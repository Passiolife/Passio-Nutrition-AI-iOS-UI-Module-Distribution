//
//  DailyNutritionCell.swift
//  BaseApp
//
//  Created by Nikunj Prajapati on 16/02/22.
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import UIKit

struct NutritionDataModal {

    var calory: (consumed: Int, target: Int)
    var carb: (consumed: Int, target: Int)
    var protein: (consumed: Int, target: Int)
    var fat: (consumed: Int, target: Int)
}

final class DailyNutritionCell: UITableViewCell {

    @IBOutlet weak var nutritionView: DailyNutritionView!
    @IBOutlet weak var shadowView: UIView!

    var nutritionData: NutritionDataModal? {
        didSet {
            guard let data = nutritionData else { return }
            self.nutritionView.setup(data: data)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.shadowView.dropShadow()
    }
}
