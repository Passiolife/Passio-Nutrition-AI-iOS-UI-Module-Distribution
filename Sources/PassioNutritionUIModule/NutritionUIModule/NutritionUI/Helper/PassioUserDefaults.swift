//
//  PassioUserModule.swift
//  BaseApp
//
//  Created by Mind on 26/02/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import Foundation

final public class PassioUserDefaults {

    enum Key: String {
        case scanningOnboardingCompleted
        case dragTrayForFirstTime
        case trackingEnabled
        case savedLanguage
        case savedAdvisorHistory
        case isMealPlanDisclaimerClosed
    }

    class func store(for key: PassioUserDefaults.Key, value: Any?) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key.rawValue)
    }

    class func bool(for key: PassioUserDefaults.Key) -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: key.rawValue)
    }
    
    public class func setLanguage(_ language: Language?) {
        let defaults = UserDefaults.standard
        defaults.set(language?.rawValue, forKey: Key.savedLanguage.rawValue)
        defaults.synchronize()
    }
    
    public class func getLanguage() -> Language? {
        let defaults = UserDefaults.standard
        guard let language = defaults.value(forKey: Key.savedLanguage.rawValue) as? String else {
            return nil
        }
        return Language(rawValue: language)
    }
    
    class func saveAdvisorHistory(_ datasource: [NAMessageModel]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(datasource) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: Key.savedAdvisorHistory.rawValue)
            defaults.synchronize()
        }
    }
    
    class func fetchAdvisorHistory() -> [NAMessageModel]? {
        let defaults = UserDefaults.standard
        guard let history = defaults.object(forKey: Key.savedAdvisorHistory.rawValue) as? Data else { return nil }
        let decoder = JSONDecoder()
        guard let datasource = try? decoder.decode([NAMessageModel].self, from: history) else { return nil }
        return datasource
    }
    
    class func clearAdvisorHistory() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Key.savedAdvisorHistory.rawValue)
    }
}
