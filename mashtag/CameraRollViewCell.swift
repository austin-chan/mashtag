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

    override func awakeFromNib() {
        super.awakeFromNib()

        imageView.contentMode = UIViewContentMode.ScaleAspectFill
    }

}
