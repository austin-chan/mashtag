//
//  Util.swift
//  Mashtag
//
//  Created by Austin Chan on 7/8/15.
//  Copyright (c) 2015 Awoes. All rights reserved.
//

import UIKit

struct Util {

    // Universal access to device screen size.
    static let screenSize: CGRect = UIScreen.mainScreen().bounds

    // Delay timeout method.
    static func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }

    // Is iPhone 4S or older.
    static var isPrimitiveDevice: Bool {
        return screenSize.height <= 480
    }

}