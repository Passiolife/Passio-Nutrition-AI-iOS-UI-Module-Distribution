//
//  UITextView+Extension.swift
//  BaseApp
//
//  Created by Nikunj Prajapati on 27/02/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit

public extension UITextView {

    func addHyperLinksToText(originalText: String,
                             hyperLinks: [String: String],
                             align: NSTextAlignment = .center,
                             textColor: UIColor = .white,
                             linkColor: UIColor = .white) {
        let style = NSMutableParagraphStyle()
        style.alignment = align
        let attributedOriginalText = NSMutableAttributedString(string: originalText)
        let fullRange = NSRange(location: 0, length: attributedOriginalText.length)
        attributedOriginalText.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: fullRange)
        attributedOriginalText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14), range: fullRange)
        attributedOriginalText.addAttribute(.foregroundColor, value: textColor, range: fullRange)
        for (hyperLink, urlString) in hyperLinks {
            let linkRange = attributedOriginalText.mutableString.range(of: hyperLink)
            attributedOriginalText.addAttribute(NSAttributedString.Key.link, value: urlString, range: linkRange)
            attributedOriginalText.addAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .regular), range: linkRange)
        }
        linkTextAttributes = [
            NSAttributedString.Key.foregroundColor: linkColor,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        attributedText = attributedOriginalText
    }
}
