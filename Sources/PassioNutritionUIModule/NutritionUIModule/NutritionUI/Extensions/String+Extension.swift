//
//  String+Extension.swift
//
//  Created by Former Developer on 02/06/18.
//  Copyright © 2023 PassioLife All rights reserved.
//

import UIKit

extension String {

    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }

    var localized: String {
        return NSLocalizedString(self,
                                 bundle: PassioInternalConnector.shared.bundleForModule,
                                 comment: "")
    }

    func capitalizingFirst() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirst() {
        self = self.capitalizingFirst()
    }

    func plural() -> String {
        if hasSuffix("s") {
            return self
        }
        if hasSuffix("y") {
            var copy = self
            copy.removeLast(1)
            return copy + "ies"
        }
        return self + "s"
    }

    func truncate(length: Int) -> String {
        if length > count { return self }
        let endPosition = self.index(self.startIndex, offsetBy: length)
        let trimmed = self[..<endPosition]
        return String(trimmed)
    }

    func getFixedTwoLineStringWidth() -> Double {
        let label = UILabel()
        label.numberOfLines = 2
        let words = self.components(separatedBy: .whitespacesAndNewlines)
        var sizeForText = Double()
        if words.count == 1 {
            label.text = self
            label.sizeToFit()
            sizeForText = Double(label.frame.width)
            if words.first!.count < 6 {
                sizeForText += 10
            }
        } else if words.count == 2 {
            let maxWord = words.max {$1.count > $0.count}
            label.text = maxWord
            label.sizeToFit()
            sizeForText = Double(label.frame.width)*1.2
            if maxWord!.count < 6 {
                sizeForText += 10
            }
        } else if words.count == 3 {
            let maxCount = max(words[0].count, words[2].count)
            if maxCount == (words[0].count) {
                let maxCount = max(words[0].count, (words[1].count + 1 + words[2].count))
                if maxCount == words[0].count {
                    label.text = words[0]
                } else {
                    label.text = words[1] + " " + words[2]
                }
            } else {
                let maxCount = max(words[0].count + 1 + words[1].count, words[2].count)
                if maxCount == words[2].count {
                    label.text = words[2]
                } else {
                    label.text = words[0] + " " + words[1]
                }
            }
            label.sizeToFit()
            sizeForText = Double(label.frame.width)
        } else {
            label.text = self
            label.sizeToFit()
            sizeForText = Double(label.frame.width)/2
        }
        return sizeForText
    }
    
        func attributedStringWithFont(for substring: String, font: UIFont) -> NSAttributedString {
            let attributedString = NSMutableAttributedString(string: self)
            let range = (self as NSString).range(of: substring)
            attributedString.addAttribute(.font, value: font, range: range)
            return attributedString
        }

}
extension UILabel {
    func setAttributedTextWithFont(for substring: String, font: UIFont) {
        guard let labelText = self.text else {
            return
        }
        
        let attributedString = NSMutableAttributedString(string: labelText)
        let range = (labelText as NSString).range(of: substring)
        attributedString.addAttribute(.font, value: font, range: range)
        
        self.attributedText = attributedString
    }
}
