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
        case trackingEnabled
        case savedLanguage
    }

    class func store(for key: PassioUserDefaults.Key, value: Any?) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key.rawValue)
    }

    class func bool(for key: PassioUserDefaults.Key) -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: key.rawValue)
    }
    
    class func setLanguage(_ language: Language?) {
        let defaults = UserDefaults.standard
        defaults.set(language?.rawValue, forKey: Key.savedLanguage.rawValue)
        defaults.synchronize()
    }
    
    class func getLanguage() -> Language? {
        let defaults = UserDefaults.standard
        guard let language = defaults.value(forKey: Key.savedLanguage.rawValue) as? String else {
            return nil
        }
        return Language(rawValue: language)
    }
}
