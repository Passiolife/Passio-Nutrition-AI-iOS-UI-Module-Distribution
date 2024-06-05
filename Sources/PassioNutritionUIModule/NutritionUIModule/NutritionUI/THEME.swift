//
//  THEME.swift
//  BaseApp
//
//  Created by Mind on 14/02/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit

public struct Custom {
    public static let insetBackgroundRadius: CGFloat = 16.0
    public static let buttonCornerRadius: CGFloat = 8.0
    public static let engineeringViews = false
    public static let useFirebase = false
    public static let useNutritionBrowser = false
    public static let oneLineAlternative = false
    public static let oneSizeAlternative = true
}

// MARK: - UIColor
public extension UIColor { // customized colors

    static var gray50: UIColor {
        colorFromBundle(named: "gray-50") ?? .blue
    }

    static var gray200: UIColor {
        colorFromBundle(named: "gray-200") ?? .blue
    }

    static var gray300: UIColor {
        colorFromBundle(named: "gray-300") ?? .gray
    }

    static var gray400: UIColor {
        colorFromBundle(named: "gray-400") ?? .blue
    }

    static var gray500: UIColor {
        colorFromBundle(named: "gray-500-bg") ?? .blue
    }

    static var gray700: UIColor {
        colorFromBundle(named: "gray-700") ?? .blue
    }

    static var gray900: UIColor {
        colorFromBundle(named: "gray-900") ?? .blue
    }

    static var green100: UIColor {
        colorFromBundle(named: "green-100") ?? .blue
    }

    static var green500: UIColor {
        colorFromBundle(named: "green-500") ?? .blue
    }

    static var green800: UIColor {
        colorFromBundle(named: "green-800") ?? .blue
    }

    static var indigo50: UIColor {
        colorFromBundle(named: "indigo-50") ?? .blue
    }

    static var indigo100: UIColor {
        colorFromBundle(named: "indigo-100") ?? .blue
    }

    static var indigo600: UIColor {
        colorFromBundle(named: "indigo-600") ?? .blue
    }

    static var indigo700: UIColor {
        colorFromBundle(named: "indigo-700") ?? .blue
    }

    static var lightBlue: UIColor {
        colorFromBundle(named: "lightBlue") ?? .blue
    }

    static var purple500: UIColor {
        colorFromBundle(named: "purple-500") ?? .blue
    }

    static var yellow500: UIColor {
        colorFromBundle(named: "yellow-500") ?? .blue
    }

    static var red100: UIColor {
        colorFromBundle(named: "red-100") ?? .blue
    }

    static var red500: UIColor {
        colorFromBundle(named: "red-500") ?? .blue
    }

    static var red800: UIColor {
        colorFromBundle(named: "red-800") ?? .blue
    }
}

// MARK: - UIFont
public extension UIFont {

    static func inter(type: NutritionFont, size: CGFloat = 17) -> UIFont {
        UIFont(name: type.name, size: size) ?? .systemFont(ofSize: size)
    }
}
