//
//  Util.swift
//  Mashtag
//
//  Created by Austin Chan on 7/8/15.
//  Copyright (c) 2015 Awoes. All rights reserved.
//
//  Lovingly from 🇺🇸
//  ❤️🍻☺️, 💣🔫😭
//

import UIKit

/// A utility struct containing common actions and data for Mashtag
struct Util {

    // The device screen size.
    static let screenSize: CGRect = UIScreen.mainScreen().bounds

    // Closure delay timeout.
    static func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }

    // Whether or not the device is an iPhone 4S or older.
    static var isPrimitiveDevice: Bool {
        return screenSize.height <= 480
    }

}