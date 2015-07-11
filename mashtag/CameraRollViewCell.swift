//
//  CameraRollViewCellCollectionViewCell.swift
//  mashtag
//
//  Created by Austin Chan on 7/9/15.
//  Copyright (c) 2015 Fiftyawoe. All rights reserved.
//

import UIKit

class CameraRollViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var screenView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        imageView.contentMode = UIViewContentMode.ScaleAspectFill
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        darken()
    }

    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        lighten()
    }

    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        super.touchesCancelled(touches, withEvent: event)
        lighten()
    }

    func darken() {
        let dark = UIColor(hexString: "#000000", alpha: 0.45)
        UIView.animateWithDuration(0.18, animations: {
            self.screenView.backgroundColor = dark
        })
    }

    func lighten() {
        let light = UIColor(hexString: "#000000", alpha: 0.05)
        UIView.animateWithDuration(0.18, animations: {
            self.screenView.backgroundColor = light
        })
    }

}
