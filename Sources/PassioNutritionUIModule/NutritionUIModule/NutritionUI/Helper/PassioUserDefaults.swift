//
//  PassioUserModule.swift
//  BaseApp
//
//  Created by Mind on 26/02/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import Foundation

final class PassioUserDefaults {

    enum Key: String {
        case scanningOnboardingCompleted
        case dragTrayForFirstTime
    }

    class func store(for key: PassioUserDefaults.Key, value: Any?){
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key.rawValue)
    }

    class func bool(for key: PassioUserDefaults.Key) -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: key.rawValue)
    }
}
