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
