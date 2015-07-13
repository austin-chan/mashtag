//
//  DesignButton.swift
//  Mashtag
//
//  Created by Austin Chan on 7/10/15.
//  Copyright (c) 2015 Awoes. All rights reserved.
//
//  Lovingly from 🇺🇸
//  ❤️🍻☺️, 💣🔫😭
//

import UIKit

/// A button that supports setting the label text kerning from Interface Builder.
class DesignButton: UIButton {

    /// The letter spacing value for the label text.
    var characterSpacing: NSNumber?

    override func awakeFromNib() {
        setup()
    }

    /**
        Re-renders the button with the settings supplied
    */
    func setup() {
        if characterSpacing != nil && characterSpacing != 0 {
            var string = titleLabel?.text!
            var attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string!)
            attributedString.addAttribute(NSKernAttributeName, value: CGFloat(characterSpacing!), range: NSRange(location: 0, length: count(string!)))
            UIView.performWithoutAnimation({
                self.setAttributedTitle(attributedString, forState: .Normal)
                self.layoutIfNeeded()
            })
        }
    }

}
