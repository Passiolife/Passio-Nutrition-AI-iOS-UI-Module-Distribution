//
//  CustomTappableButton.swift
//  BaseApp
//
//  Created by Dharam on 09/09/22.
//  Copyright © 2022 Passio Inc. All rights reserved.
//
import UIKit

@IBDesignable
final class CustomTappableButton: UIButton {

    var margin: CGFloat = 30.0

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let area = self.bounds.insetBy(dx: -margin, dy: -margin)
        return area.contains(point)
    }
}
