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
            nutritionView.setup(data: data)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let path = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: 8)
        shadowView.dropShadow(radius: 8,
                              offset: CGSize(width: 0, height: 1),
                              color: .black.withAlphaComponent(0.06),
                              shadowRadius: 2,
                              shadowOpacity: 1,
                              useShadowPath: true,
                              shadowPath: path.cgPath)
    }
}
