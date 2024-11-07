//
//  UILabel+Extension.swift
//  Passio-Nutrition-AI-iOS-UI-Module
//
//  Created by Tushar S on 06/11/24.
//

import UIKit

extension UILabel {
    
    func setBoldAttributedText(boldText: String, fullText: String, fontSize: CGFloat = 14) {
        // Ensure the text exists and is not empty
        guard !boldText.isEmpty, !fullText.isEmpty else { return }
        
        // Initialize an NSMutableAttributedString with the full text
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // Set up the system font size for normal text
        let normalFont = UIFont.systemFont(ofSize: fontSize)
        
        // Set up the bold font with the same size as the current font
        let boldFont = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        
        
        // Apply the normal font to the rest of the text (it's implicit if not explicitly set)
        attributedString.addAttribute(.font, value: normalFont, range: NSRange(location: 0, length: fullText.count))
        
        // Check for the boldText occurrence within the fullText
        let range = (fullText as NSString).range(of: boldText)
        
        // If the boldText is found, apply the bold font style to it
        if range.location != NSNotFound {
            attributedString.addAttribute(.font, value: boldFont, range: range)
        }
        
        // Set the attributed text to the label
        self.attributedText = attributedString
    }
}

