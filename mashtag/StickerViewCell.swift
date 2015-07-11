//
//  StickerCellViewCollectionViewCell.swift
//  mashtag
//
//  Created by Austin Chan on 7/10/15.
//  Copyright (c) 2015 Fiftyawoe. All rights reserved.
//

import UIKit

class StickerViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        imageView.contentMode = UIViewContentMode.ScaleAspectFill
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        scaleIn()
    }

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
