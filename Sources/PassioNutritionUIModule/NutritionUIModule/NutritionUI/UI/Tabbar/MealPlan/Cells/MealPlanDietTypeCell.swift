//
//  MealPlanDietTypeCell.swift
//  BaseApp
//
//  Created by Mind on 26/03/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

protocol MealPlanDietSelectionDelegate: AnyObject {
    func selectedDay(day: Int)
    func mealPlanSelectionTapped(_ sender: UIButton)
}

class MealPlanDietTypeCell: UICollectionViewCell {

    @IBOutlet weak var mealPlanNameLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!

    private var buttons: [UIButton] = []
    var selectedDay: Int = 1 {
        didSet {
            buttons.forEach { $0.isSelected = selectedDay == $0.tag }
        }
    }
    var selectedMealPlan: PassioMealPlan? {
        didSet {
            mealPlanNameLabel.text = selectedMealPlan?.mealPlanTitle ?? "Please select meal plan"
        }
    }
    weak var delegate: MealPlanDietSelectionDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        setupStackView()
    }

    func setupStackView() {
        let buttonCount = 14
        var buttons: [ColoredButton] = []
        let buttonWidth = 64
        let buttonGap = 8
        for i in 1 ..< buttonCount + 1 {
            let button = ColoredButton.init(frame: CGRect.init(x: 0, y: 0, width: 64, height: 34))
            button.setTitle("Day \(i)", for: .normal)
            button.setTitle("Day \(i)", for: .selected)

            button.setBackgroundColor(.gray50, for: .normal)
            button.setBackgroundColor(.primaryColor, for: .selected)
            button.setTitleColor(.gray900, for: .normal)
            button.setTitleColor(.white, for: .selected)
            button.tag = i
            button.roundMyCorner()
            button.titleLabel?.font = .inter(type: .semiBold, size: 12)
            button.addTarget(self, action: #selector(selectDay), for: .touchUpInside)
            button.isSelected = selectedDay == i
            stackView.addArrangedSubview(button)
            buttons.append(button)
        }
        self.buttons = buttons
        stackView.constraints.first(where: {
            $0.firstAttribute == .width
        })?.constant = CGFloat(((buttonWidth + buttonGap) * buttonCount) - buttonGap)
    }

    @IBAction func mealPlanSelectionTapped(_ sender: UIButton){
        delegate?.mealPlanSelectionTapped(sender)
    }

    @objc func selectDay(_ sender: UIButton) {
        selectedDay = sender.tag
        delegate?.selectedDay(day: sender.tag)
    }
}
