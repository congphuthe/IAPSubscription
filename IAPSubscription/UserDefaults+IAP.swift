//
//  UserDefaults+HelperMethod.swift
//  Health App
//
//  Created by Nguyen Tan Thanh on 12/22/16.
//  Copyright © 2016 Infini. All rights reserved.
//

import Foundation

extension UserDefaults {

    
    static var purchasedExpiresDate: Date? {
        get {
            guard let expiresDate = UserDefaults.standard.value(forKey: AppConfig.Key.purchasedExpired) as? Date else {
                return nil
            }
            return expiresDate
        }
        set {
            UserDefaults.standard.set(newValue, forKey: AppConfig.Key.purchasedExpired)
        }
    }

    static var appLaunched: TimeInterval? {
        get {
            guard let expiresDate = UserDefaults.standard.value(forKey: AppConfig.Key.appLaunchedDate) as? TimeInterval else {
                return nil
            }
            return expiresDate
        }
        set {
            UserDefaults.standard.set(newValue, forKey: AppConfig.Key.appLaunchedDate)
        }
    }

}
