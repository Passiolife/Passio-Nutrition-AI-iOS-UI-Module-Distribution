//
//  FontRegistration.swift
//
//
//  Created by Nikunj Prajapati on 27/05/24.
//

import UIKit

public enum FontError: Swift.Error {
    case failedToRegisterFont
}

func registerFont(named name: String) throws {

    guard let asset = NSDataAsset(name: "Fonts/\(name)", bundle: Bundle.module),
          let provider = CGDataProvider(data: asset.data as NSData),
          let font = CGFont(provider),
          CTFontManagerRegisterGraphicsFont(font, nil) else {
        throw FontError.failedToRegisterFont
    }
}

public struct NutritionFont {

    public let name: String

    private init(named name: String) {
        self.name = name
        do {
            try registerFont(named: name)
        } catch {
            fatalError("Failed to register font: \(error.localizedDescription)")
        }
    }

    public static let medium = NutritionFont(named: "Inter-Medium")
    public static let light = NutritionFont(named: "Inter-Light")
    public static let thin = NutritionFont(named: "Inter-Thin")
    public static let bold = NutritionFont(named: "Inter-Bold")
    public static let regular = NutritionFont(named: "Inter-Regular")
    public static let extraBold = NutritionFont(named: "Inter-ExtraBold")
    public static let extraLight = NutritionFont(named: "Inter-ExtraLight")
    public static let black = NutritionFont(named: "Inter-Black")
    public static let semiBold = NutritionFont(named: "Inter-SemiBold")
}
