//
//  CalculatedBMICell.swift
//  BaseApp
//
//  Created by Nikunj Prajapati on 14/03/22.
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import UIKit

final class CalculatedBMICell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var calculatedBMILabel: UILabel!
    @IBOutlet weak var bmiValueLabel: UILabel!
    @IBOutlet weak var bmiView: UIView!
    @IBOutlet weak var underWeightLabel: UILabel!
    @IBOutlet weak var normalLabel: UILabel!
    @IBOutlet weak var overWeightLabel: UILabel!
    @IBOutlet weak var obeseLabel: UILabel!
    @IBOutlet weak var bmiPointStackVwLeadingConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.containerView.dropShadow()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureBMIView()
    }
}

// MARK: - Configure UI
extension CalculatedBMICell {

    private func configureBMIView() {
        calculatedBMILabel.text = Localized.calculatedBMI
        obeseLabel.text = Localized.obese
        overWeightLabel.text = Localized.overweight
        normalLabel.text = Localized.normal
        underWeightLabel.text = Localized.underWeight
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: bmiView.frame.width, height: bmiView.frame.height)
        view.backgroundColor = .clear
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red:39/256,green:  177/256,blue: 255/256,alpha: 1).cgColor,
            UIColor(red:162/256,green:  228/256,blue: 12/256,alpha: 1).cgColor,
            UIColor(red:172/256,green:  217/256,blue: 11/256,alpha: 1).cgColor,
            UIColor(red:241/256,green:  131/256,blue: 0/256,alpha: 1).cgColor,
            UIColor(red:241/256,green:  131/256,blue: 0/256,alpha: 1).cgColor,
            UIColor(red:231/256,green:  34/256,blue: 26/256,alpha: 1).cgColor
        ]
        layer.locations = [0.17, 0.28, 0.43, 0.55, 0.68, 0.75]
        layer.startPoint = CGPoint(x: 0.25, y: 0.5)
        layer.endPoint = CGPoint(x: 0.80, y: 0.5)
        layer.bounds = view.bounds.insetBy(dx: -0.5*view.bounds.size.width, dy: -0.5*view.bounds.size.height)
        layer.position = view.center
        view.layer.addSublayer(layer)
        bmiView.addSubview(view)
    }

    func setBMIValue(bmiValue: Double, bmiDescription: String) {
        bmiValueLabel.text = "\(bmiValue)"
        let width = ScreenSize.width - 64
        let fraction = width / 4
        var centerConstant: CGFloat = 0.0
        
        switch bmiDescription {
        case Localized.underWeight:
            let normaliseProgress = bmiValue.normalize(_min: 0, _max: 18.5)
            let _fraction = (fraction * CGFloat(normaliseProgress))
            centerConstant = _fraction
        case Localized.normal:
            let normaliseProgress = bmiValue.normalize(_min: 18.5, _max: 24.9)
            let _fraction = (fraction * CGFloat(normaliseProgress))
            centerConstant = _fraction + (1.0 * fraction)
        case Localized.overweight:
            let normaliseProgress = bmiValue.normalize(_min: 24.9, _max: 29.9)
            let _fraction = (fraction * CGFloat(normaliseProgress))
            centerConstant = _fraction + (2.0 * fraction)
        default:
            let normaliseProgress = bmiValue.normalize(_min: 29.9, _max: 35.0)
            let _fraction = (fraction * CGFloat(normaliseProgress))
            centerConstant = _fraction + (3.0 * fraction)
        }
        bmiPointStackVwLeadingConstraint.constant = centerConstant >= width ? (width - 4.0) : centerConstant
    }
}
