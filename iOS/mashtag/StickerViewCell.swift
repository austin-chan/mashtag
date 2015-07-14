//
//  StickerCellViewCollectionViewCell.swift
//  Mashtag
//
//  Created by Austin Chan on 7/10/15.
//  Copyright (c) 2015 Awoes. All rights reserved.
//
//  Lovingly from 🇺🇸
//  ❤️🍻☺️, 💣🔫😭
//

import UIKit

/// A cell to represent each sticker family in StickerViewController
class StickerViewCell: UICollectionViewCell {

    /// IBOutlets
    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
    }

    /// Runs the 'pop' animation on tap down of the cell.
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        scaleIn()
    }

    /**
        Runs 'pop' animation for the sticker to expand and then bounce back to regular size quickly.
    */
    func scaleIn() {
        UIView.animateWithDuration(0.1, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 10, options: nil, animations: {
            self.imageView.transform = CGAffineTransformMakeScale(0.93, 0.93)
        }, completion: {
            (_) in
            UIView.animateWithDuration(0.42, delay: 0, usingSpringWithDamping: 0.45, initialSpringVelocity: 25, options: nil, animations: {
            self.imageView.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: nil)
        })
    }

}
