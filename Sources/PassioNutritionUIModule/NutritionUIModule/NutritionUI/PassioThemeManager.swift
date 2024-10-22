//
//  PassioThemeManager.swift
//
//
//  Created by Nikunj Prajapati on 02/07/24.
//

import UIKit

/// PassioTheme struct to modify PassioNutrition UI's theme
/// - Parameters:
///   - primaryColor: Main tint color
///   - secondaryTabColor: secondary tab color for unselected Tab
///   - navigationColor: Navigation bar color
public struct PassioTheme {

    public var primaryColor: String
    public var secondaryTabColor: String
    public var navigationColor: String
    public var statusBarColor: String

    public init(primaryColor: String, 
                secondaryTabColor: String,
                navigationColor: String,
                statusBarColor: String) {
        self.primaryColor = primaryColor
        self.secondaryTabColor = secondaryTabColor
        self.navigationColor = navigationColor
        self.statusBarColor = statusBarColor
    }
}

public protocol PassioThemeable: AnyObject {
     func setAppTheme(theme: PassioTheme)
}

public class PassioThemeManager: PassioThemeable {

    private struct Static {
        fileprivate static var instance: PassioThemeManager?
    }

    // MARK: Shared Object
    public class var shared: PassioThemeManager {
        if Static.instance == nil {
            Static.instance = PassioThemeManager()
        }
        return Static.instance!
    }
    private init() {}

    public var passioAppTheme: PassioTheme = PassioTheme(primaryColor: "#4F46E5",
                                                         secondaryTabColor: "#D1D5DB",
                                                         navigationColor: "#FFFFFF",
                                                         statusBarColor: "#FFFFFF")

    public func setAppTheme(theme: PassioTheme) {
        passioAppTheme = theme
    }
}
