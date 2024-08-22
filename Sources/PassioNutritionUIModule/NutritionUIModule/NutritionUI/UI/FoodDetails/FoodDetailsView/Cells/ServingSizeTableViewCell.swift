//
//  AmountSliderFullTableViewself.swift
//  PassioPassport
//
//  Created by zvika on 2/1/19.
//  Copyright © 2023 PassioLife Inc. All rights reserved.
//

import UIKit

class ServingSizeTableViewCell: UITableViewCell {

    @IBOutlet weak var labelAmount: UILabel!
    @IBOutlet weak var sliderAmount: UISlider!
    @IBOutlet weak var buttonUnits: UIButton!
    @IBOutlet weak var textAmount: UITextField!
    @IBOutlet weak var insetBackground: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        sliderAmount.isContinuous = false
        textAmount.addOkButtonToToolbar(target: self,
                                        action: #selector(endViewEditing),
                                        forEvent: .touchUpInside)
        buttonUnits.roundMyCornerWith(radius: Custom.buttonCornerRadius)
        insetBackground.roundMyCornerWith(radius: 8)
        insetBackground.dropShadow(radius: 8,
                                   offset: CGSize(width: 0, height: 1),
                                   color: .black.withAlphaComponent(0.06),
                                   shadowRadius: 2,
                                   shadowOpacity: 1)
        sliderAmount.tintColor = .primaryColor
        sliderAmount.thumbTintColor = .primaryColor
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
        self.textAmount.text = textAmount
        self.textAmount.backgroundColor = .white
        labelAmount.text = unitName == "g" ? "" : "(" + weight + " " + "g".localized + ") "
        let newTitle = " " + unitName
        labelAmount.textColor = .gray900
        buttonUnits.setTitle(newTitle, for: .normal)
    }

    @objc private func endViewEditing() {
        endEditing(true)
    }
}
