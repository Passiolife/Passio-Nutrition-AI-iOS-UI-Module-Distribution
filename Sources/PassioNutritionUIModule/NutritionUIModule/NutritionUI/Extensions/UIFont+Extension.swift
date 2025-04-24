//
//  File.swift
//  PassioNutritionUIModule
//
//  Created by Pratik on 21/04/25.
//

import Foundation
import UIKit

enum CustomFonts: String {
    case inter = "Inter"
}

enum CustomFontWight: String {
    case thin = "-Thin"
    case light = "-Light"
    case extraLight = "-ExtraLight"
    case regular = "-Regular"
    case medium = "-Medium"
    case semiBold = "-SemiBold"
    case bold = "-Bold"
    case extraBold = "-ExtraBold"
    case black = "-Black"
}

extension UIFont {
    static func inter(size: CGFloat,
                       weight: CustomFontWight,
                       isScaled: Bool = true) -> UIFont {
        let fontName: String = CustomFonts.inter.rawValue + weight.rawValue
        guard let font = UIFont(name: fontName, size: size) else {
            debugPrint("Font can't be loaded")
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }
    static func system(_ size: CGFloat, weight: UIFont.Weight) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: weight)
    }
}
