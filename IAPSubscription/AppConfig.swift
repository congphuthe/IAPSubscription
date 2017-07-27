//
//  AppConfig.swift
//  AppLock
//
//  Created by Cong Phu on 7/6/17.
//  Copyright © 2017 Cong Phu. All rights reserved.
//

import Foundation

class AppConfig {
//    static let verifyReceiptLink = "https://sandbox.itunes.apple.com/verifyReceipt"
    static let verifyReceiptLink = "https://buy.itunes.apple.com/verifyReceipt"
    static let tutorialLink = "https://www.google.com.vn/"
    
    static let numberOfDaysTrial = 10
    
    struct Purchase {
        static let itcAccountSecret = "9dbde12738bb4502a9cb1c9bbd5f2d13"
        static let trialProductId = "com.purchased.test1"
        static let upgradeProductId = "com.purchased.test2"
    }
    struct Key {
        static let purchased = "Purchased"
        static let purchasedExpired = "PurchasedExpired"
        static let appLaunchedDate = "AppLaunchedDate"
    }
}
