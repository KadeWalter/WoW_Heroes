//
//  UserDefaultsHelper.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 9/26/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import Foundation

final class UserDefaultsHelper {
    
    class func set<T>(value: T, forKey key: String) {
        UserDefaults.standard.setValue(value, forKey: key)
    }
    
    class func getValue(forKey key: String) -> Any? {
        return UserDefaults.standard.value(forKey: key)
    }
    
    class func getStringValue(forKey key: String) -> String? {
        return UserDefaults.standard.value(forKey: key) as? String
    }
    
    class func getDateValue(forKey key: String) -> Date? {
        return UserDefaults.standard.value(forKey: key) as? Date
    }
}
