//
//  DailyNutritionWithDateCollectionViewCell.swift
//  BaseApp
//
//  Created by Mind on 16/02/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit

class DailyNutritionWithDateCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var nutritionView: DailyNutritionView!
        
    var nutritionData: NutritionDataModal? {
        didSet {
            guard let data = nutritionData else { return }
            self.nutritionView.setup(data: data)
        }
    }
}
