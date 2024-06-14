//
//  MealPlanDietTypeCell.swift
//  BaseApp
//
//  Created by Mind on 26/03/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit
import PassioNutritionAISDK

protocol MealPlanDietSelectionDelegate: NSObjectProtocol{
    func selectedDay(day: Int)
    func mealPlanSelectionTapped(_ sender: UIButton)
}

class MealPlanDietTypeCell: UICollectionViewCell {

    @IBOutlet weak var mealPlanNameLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    private var buttons: [UIButton] = []
    weak var delegate: MealPlanDietSelectionDelegate?
    
    var selectedDay: Int = 1 {
        didSet {
            buttons.forEach({
                $0.isSelected = selectedDay == $0.tag
            })
        }
    }
    
    var selectedMealPlan: PassioMealPlan? {
        didSet {
            self.mealPlanNameLabel.text = selectedMealPlan?.mealPlanTitle ?? "Please select meal plan"
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupStackView()
        // Initialization code
    }
    
    func setupStackView(){
        let buttonCount = 14
        var buttons: [ColoredButton] = []
        let buttonWidth = 64
        let buttonGap = 8
        for i in 1 ..< buttonCount + 1{
            let button = ColoredButton.init(frame: CGRect.init(x: 0, y: 0, width: 64, height: 34))
            button.setTitle("Day \(i)", for: .normal)
            button.setTitle("Day \(i)", for: .selected)
            
            button.setBackgroundColor(.gray50, for: .normal)
            button.setBackgroundColor(.indigo600, for: .selected)
            button.setTitleColor(.gray900, for: .normal)
            button.setTitleColor(.white, for: .selected)
            button.tag = i
            button.roundMyCorner()
            button.titleLabel?.font = .inter(type: .semiBold, size: 12)
            button.addTarget(self, action: #selector(selectDay), for: .touchUpInside)
            button.isSelected = selectedDay == i
            self.stackView.addArrangedSubview(button)
            buttons.append(button)
        }
        self.buttons = buttons
        self.stackView.constraints.first(where: {$0.firstAttribute == .width})?.constant = CGFloat(((buttonWidth + buttonGap) * buttonCount) - buttonGap)
    }
    
    @IBAction func mealPlanSelectionTapped(_ sender: UIButton){
        delegate?.mealPlanSelectionTapped(sender)
    }
    
    
    @objc func selectDay(_ sender: UIButton) {
        self.selectedDay = sender.tag
        delegate?.selectedDay(day: sender.tag)
        
    }
    

}
