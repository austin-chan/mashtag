//
//  CameraRollViewCellCollectionViewCell.swift
//  Mashtag
//
//  Created by Austin Chan on 7/9/15.
//  Copyright (c) 2015 Awoes. All rights reserved.
//
//  Lovingly from 🇺🇸
//  ❤️🍻☺️, 💣🔫😭
//

import UIKit

/// A cell to represent each saved camera roll picture in CameraViewController.
class CameraRollViewCell: UICollectionViewCell {

    /// IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var screenView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
    }

    /// Darkens cell.
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        darken()
    }

    /// Lightens cell.
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        lighten()
    }

    /// Lightens cell.
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        super.touchesCancelled(touches, withEvent: event)
        lighten()
    }

    /**
        Runs an animation to darkens the cell.
    */
    func darken() {
        let dark = UIColor(hexString: "#000000", alpha: 0.45)
        UIView.animateWithDuration(0.18, animations: {
            self.screenView.backgroundColor = dark
        })
    }

    /**
        Runs an animation to lighten the cell to regular color.
    */
    func lighten() {
        let light = UIColor(hexString: "#000000", alpha: 0.05)
        UIView.animateWithDuration(0.18, animations: {
            self.screenView.backgroundColor = light
        })
    }

}
