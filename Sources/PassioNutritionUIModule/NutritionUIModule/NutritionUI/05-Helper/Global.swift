//
//  Global+Functions.swift
//  BaseApp
//
//  Created by Zvika on 8/28/23.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit

// MARK: - Screen Size
public struct ScreenSize {
    public static let height = UIScreen.main.bounds.height
    public static let width = UIScreen.main.bounds.width
}

struct Constant {
    static let defaultTargetCalories = 2100
}

var currentTime: String {
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss.SSS"
    return formatter.string(from: date)
}

func Delay(_ seconds: Double, _ execute: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: execute)
}

func isValidDecimalInput(currentText: String, range: NSRange, replacementString string: String) -> Bool {
    // Allow backspace
    if string.isEmpty {
        return true
    }
    
    // Only allow digits and dot
    let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
    if string.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
        return false
    }
    
    // Construct the new text after input
    let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
    
    // Allow only one dot
    let dotCount = newText.filter { $0 == "." }.count
    if dotCount > 1 {
        return false
    }
    
    // LIMIT TO 2 DECIMAL PLACES
    if let dotIndex = newText.firstIndex(of: ".") {
        let decimalPart = newText[newText.index(after: dotIndex)...]
        if decimalPart.count > 2 {
            return false
        }
    }
    return true
}

func isValidDecimal(_ text: String?) -> Bool {
    guard let text = text else {
        return false
    }
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return false } // Disallow empty or spaces only
    
    // Use regex to match decimal with max 2 decimal places
    let regex = #"^\d+(\.\d{1,2})?$"#
    return trimmed.range(of: regex, options: .regularExpression) != nil
}

func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage? {
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { _ in
        image.draw(in: CGRect(origin: .zero, size: size))
    }
}

internal let unitsArray = [UnitsTexts.serving,
                           UnitsTexts.piece,
                           UnitsTexts.cup,
                           UnitsTexts.oz,
                           UnitsTexts.gram,
                           UnitsTexts.ml,
                           UnitsTexts.small,
                           UnitsTexts.medium,
                           UnitsTexts.large,
                           UnitsTexts.handful,
                           UnitsTexts.scoop,
                           UnitsTexts.tbsp,
                           UnitsTexts.tsp,
                           UnitsTexts.slice,
                           UnitsTexts.can,
                           UnitsTexts.bottle,
                           UnitsTexts.bar,
                           UnitsTexts.packet]
