//
//  AmountSliderFullTableViewself.swift
//  PassioPassport
//
//  Created by zvika on 2/1/19.
//  Copyright © 2023 PassioLife Inc. All rights reserved.
//

import UIKit

class AmountSliderFullTableViewCell: UITableViewCell {

    @IBOutlet weak var labelAmount: UILabel!
    @IBOutlet weak var sliderAmount: UISlider!
    @IBOutlet weak var buttonUnits: UIButton!
    @IBOutlet weak var textAmount: UITextField!

    @IBOutlet weak var insetBackground: UIView!

    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        buttonUnits.roundMyCornerWith(radius: Custom.buttonCornerRadius)
        insetBackground.roundMyCornerWith(radius: 8)
        insetBackground.dropShadow()
        self.selectionStyle = .none 
        
    }

    func setup(quantity: Double,
               unitName: String,
               weight: String){
        
        
        let textAmount = quantity == Double(Int(quantity)) ? String(Int(quantity)) :
        String(quantity.roundDigits(afterDecimal: 2))
        self.textAmount.text = textAmount
        self.textAmount.backgroundColor = .white
        self.labelAmount.text = unitName == "g" ? "" : "(" + weight + " " + "g".localized + ") "
        let newTitle = " " + unitName
        self.labelAmount.textColor = .black

        self.buttonUnits.setTitle(newTitle, for: .normal)
        
    }
    
    
}
