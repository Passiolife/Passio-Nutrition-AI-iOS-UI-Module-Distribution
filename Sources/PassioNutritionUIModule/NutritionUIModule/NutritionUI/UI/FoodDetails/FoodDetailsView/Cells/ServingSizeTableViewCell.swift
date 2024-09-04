//
//  AmountSliderFullTableViewself.swift
//  PassioPassport
//
//  Created by zvika on 2/1/19.
//  Copyright © 2023 PassioLife Inc. All rights reserved.
//

import UIKit

class ServingSizeTableViewCell: UITableViewCell {

    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var quantitySlider: UISlider!
    @IBOutlet weak var unitButton: UIButton!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var insetBackground: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        quantitySlider.isContinuous = false
        quantityTextField.addOkButtonToToolbar(target: self,
                                        action: #selector(endViewEditing),
                                        forEvent: .touchUpInside)
        unitButton.roundMyCornerWith(radius: Custom.buttonCornerRadius)
        insetBackground.roundMyCornerWith(radius: 8)
        insetBackground.dropShadow(radius: 8,
                                   offset: CGSize(width: 0, height: 1),
                                   color: .black.withAlphaComponent(0.06),
                                   shadowRadius: 2,
                                   shadowOpacity: 1)
        quantitySlider.tintColor = .primaryColor
        quantitySlider.thumbTintColor = .primaryColor
        weightLabel.textColor = .gray900
        quantityTextField.backgroundColor = .white
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        insetBackground.layer.shadowPath = UIBezierPath(roundedRect: insetBackground.bounds,
                                                        cornerRadius: 8).cgPath
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }

    func setup(quantity: Double, unitName: String, weight: String) {

        let textAmount = quantity == Double(Int(quantity)) ? String(Int(quantity)) :
        String(quantity.roundDigits(afterDecimal: 2))
        quantityTextField.text = textAmount
        quantityTextField.backgroundColor = .white
        weightLabel.text = unitName ==  UnitsTexts.g ? "" : "(" + weight + " " + UnitsTexts.g + ") "
        let newTitle = " " + unitName.capitalized
        unitButton.setTitle(newTitle, for: .normal)
    }

    @objc private func endViewEditing() {
        endEditing(true)
    }
}
