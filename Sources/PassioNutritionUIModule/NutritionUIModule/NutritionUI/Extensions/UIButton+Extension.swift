//
//  UIButton+Extension.swift
//  BaseApp
//
//  Created by Nikunj Prajapati on 27/02/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit

extension UIButton {

    func underline() {
        guard let text = titleLabel?.text else { return }
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedString.Key.underlineColor,
                                      value: titleColor(for: .normal)!,
                                      range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                      value: titleColor(for: .normal)!,
                                      range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle,
                                      value: NSUnderlineStyle.single.rawValue,
                                      range: NSRange(location: 0, length: text.count))
        setAttributedTitle(attributedString, for: .normal)
    }
}
