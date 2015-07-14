//
//  DesignLabel.swift
//  Mashtag
//
//  Created by Austin Chan on 7/11/15.
//  Copyright © 2015 Awoes, Inc. All rights reserved.
//
//  Lovingly from 🇺🇸
//  ❤️🍻☺️, 💣🔫😭
//

import UIKit

/// A label that supports setting the label text kerning from Interface Builder.
class DesignLabel: UILabel {

    /// The letter spacing value for the label text.
    var characterSpacing: NSNumber!

    override func awakeFromNib() {
        setup()
    }

    /**
        Re-renders the label with the settings supplied.
    */
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
