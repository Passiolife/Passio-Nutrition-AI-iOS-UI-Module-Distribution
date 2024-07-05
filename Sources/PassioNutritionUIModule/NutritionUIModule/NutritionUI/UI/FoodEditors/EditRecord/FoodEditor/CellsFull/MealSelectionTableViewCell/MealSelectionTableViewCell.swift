//
//  MealSelectionTableViewCell.swift
//  PassioAppModule
//
//  Created by Patrick Goley on 4/19/21.
//

import UIKit

protocol MealSelectionDelegate: AnyObject {

    func didChangeMealSelection(selection: MealLabel)
}

class MealSelectionTableViewCell: UITableViewCell {

    weak var delegate: MealSelectionDelegate?

    private var selectedButton: ColoredButton?

    @IBOutlet weak var breakfastButton: ColoredButton!
    @IBOutlet weak var snackButton: ColoredButton!
    @IBOutlet weak var dinnerButton: ColoredButton!
    @IBOutlet weak var lunchButton: ColoredButton!

    @IBOutlet weak var insetBackgroundView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        styleButton(breakfastButton, title: "Breakfast")
        styleButton(lunchButton, title: "Lunch")
        styleButton(dinnerButton, title: "Dinner")
        styleButton(snackButton, title: "Snack")
        insetBackgroundView.roundMyCornerWith(radius: 8)
        insetBackgroundView.dropShadow(radius: 8,
                                       offset: CGSize(width: 0, height: 1),
                                       color: .black.withAlphaComponent(0.06),
                                       shadowRadius: 2,
                                       shadowOpacity: 1)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        insetBackgroundView.layer.shadowPath = UIBezierPath(roundedRect: insetBackgroundView.bounds,
                                                            cornerRadius: 8).cgPath
    }

    func setMealSelection(_ mealLabel: MealLabel) {

        let selectedButton: ColoredButton
        switch mealLabel {
        case .breakfast:
            selectedButton = breakfastButton
        case .lunch:
            selectedButton = lunchButton
        case .dinner:
            selectedButton = dinnerButton
        case .snack:
            selectedButton = snackButton
        }

        self.selectedButton?.isSelected = false
        selectedButton.isSelected = true
        self.selectedButton = selectedButton
    }

    func styleButton(_ button: ColoredButton, title: String, roundedCorners: CACornerMask = []) {

        button.layer.maskedCorners = roundedCorners
        if !roundedCorners.isEmpty {
            button.cornerRadius = 15
        }

        button.borderColor = UIColor.gray400
        button.borderWidth = 1

        // normal state
        button.setAttributedTitle(NSAttributedString(string: title, attributes: [
            .font: UIFont.inter(type: .medium, size: 14),
            .foregroundColor: UIColor.gray400
        ]), for: .normal)
        button.setBackgroundColor(.white, for: .normal)

        // selected state
        let selectedAttributes = NSAttributedString(string: title, attributes: [
            .font: UIFont.inter(type: .medium, size: 14),
            .foregroundColor: UIColor.white
        ])
        button.setAttributedTitle(selectedAttributes, for: .highlighted)
        button.setAttributedTitle(selectedAttributes, for: .selected)
        button.setBackgroundColor(.primaryColor, for: .selected)
        button.setBackgroundColor(.primaryColor, for: .highlighted)
    }

    @IBAction func mealButtonPressed(_ sender: ColoredButton) {

        selectedButton?.isSelected = false
        sender.isSelected = true
        selectedButton = sender

        let meal: MealLabel
        switch sender {
        case breakfastButton: meal = .breakfast
        case lunchButton: meal = .lunch
        case dinnerButton: meal = .dinner
        case snackButton: meal = .snack
        default:
            return
        }

        delegate?.didChangeMealSelection(selection: meal)
    }
}
