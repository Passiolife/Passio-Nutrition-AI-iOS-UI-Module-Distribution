//
//  NutritionInfoCollectionViewCell.swift
//
//
//  Created by Nikunj Prajapati on 21/08/24.
//

import UIKit

class NutritionInfoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var insetBackgroundView: UIView!
    @IBOutlet weak var nutritionNameLabel: UILabel!
    @IBOutlet weak var nutritionValueLabel: UILabel!
    @IBOutlet weak var nutritionUnitLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        insetBackgroundView.dropShadow(radius: 8,
                                       offset: CGSize(width: 0, height: 1),
                                       color: .black.withAlphaComponent(0.06),
                                       shadowRadius: 2,
                                       shadowOpacity: 1)
        nutritionValueLabel.textColor = .primaryColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        DispatchQueue.main.async { [self] in
            insetBackgroundView.layer.shadowPath = UIBezierPath(roundedRect: insetBackgroundView.bounds,
                                                                cornerRadius: 8).cgPath
        }
    }

    func configureNutritionInfoCell(with nutrition: MicroNutirents) {

        nutritionNameLabel.text = nutrition.name
        nutritionValueLabel.text = nutrition.value == 0 ? "0" : String(nutrition.value)
        nutritionUnitLabel.text = nutrition.unit
    }
}
