//
//  UIColor+Extension.swift
//  PassioDemoApp
//
//  Created by Jonmar on 3/11/21.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit

public extension UIColor {

    convenience init?(hex: String) {
        func toHexString() -> String {
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            getRed(&r, green: &g, blue: &b, alpha: &a)
            let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
            return String(format: "#%06x", rgb)
        }
        let hexString: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if hexString.hasPrefix("#") {
            scanner.currentIndex = hexString.index(hexString.startIndex, offsetBy: 1)
            // scanLocation = 1
        }
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }

    static func colorFromBundle(named: String) -> UIColor? {
        UIColor(named: named,
                in: NutritionUIModule.shared.bundleForModule,
                compatibleWith: nil)
    }
}

public extension UIColor { // customized colors

    static var customBase: UIColor {
        colorFromBundle(named: "CustomBase") ?? .blue
    }

    static var blue0D1: UIColor {
        colorFromBundle(named: "Blue0D1") ?? .blue
    }

    static var passioBackgroundWhite: UIColor {
        colorFromBundle(named: "PassioBackgroundWhite") ?? .white
    }

    static var passioInsetColor: UIColor {
        colorFromBundle(named: "PassioInsetColor") ?? .white
    }

    static var passioLowContrast: UIColor {
        colorFromBundle(named: "PassioLowContrast") ?? .lightGray
    }

    static var passioMedContrast: UIColor {
        colorFromBundle(named: "PassioMedContrast") ?? .gray
    }
}

public extension UIColor { // Marcro Graphs

    static var gCaloriesN: UIColor {
        colorFromBundle(named: "GCalories") ?? .yellow
    }
    static var gCaloriesOverN: UIColor {
        colorFromBundle(named: "GCaloriesOver") ?? .yellow
    }

    static var gCarbsN: UIColor {
        colorFromBundle(named: "GCarbs") ?? .blue
    }
    static var gCarbsOverN: UIColor {
        colorFromBundle(named: "GCarbsOver") ?? .blue
    }

    static var gProteinN: UIColor {
        colorFromBundle(named: "GProtein") ?? .green
    }
    static var gProteinOverN: UIColor {
        colorFromBundle(named: "GProteinOver") ?? .green
    }

    static var gFatN: UIColor {
        colorFromBundle(named: "GFat") ?? .red
    }
    static var gFatOverN: UIColor {
        colorFromBundle(named: "GFatOver") ?? .red
    }
}
