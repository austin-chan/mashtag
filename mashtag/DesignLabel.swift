//
//  DesignLabel.swift
//  mashtag
//
//  Created by Austin Chan on 7/11/15.
//  Copyright (c) 2015 Fiftyawoe. All rights reserved.
//

import UIKit

class DesignLabel: UILabel {

    var characterSpacing: NSNumber!

    override func awakeFromNib() {
        setup()
    }

    func setup() {
        if characterSpacing != nil && characterSpacing != 0 {
            var string = text
            var attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string!)
            attributedString.addAttribute(NSKernAttributeName, value: CGFloat(characterSpacing), range: NSRange(location: 0, length: count(string!)))
            UIView.performWithoutAnimation({
                self.attributedText = attributedString
                self.layoutIfNeeded()
            })
        }
    }

}
