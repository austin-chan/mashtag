//
//  StickerViewController.swift
//  mashtag
//
//  Created by Austin Chan on 7/9/15.
//  Copyright (c) 2015 Fiftyawoe. All rights reserved.
//

import UIKit

class StickerViewController: UIViewController {

    // IBOutlets
    @IBOutlet weak var overlayImageView: UIImageView!

    var overlayImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        render()
    }

    func render() {
        overlayImageView.image = overlayImage
    }

    @IBAction func backTap(sender: UIButton) {
        navigationController?.popViewControllerAnimated(false)
    }

}
