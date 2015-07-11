//
//  FinalizeViewController.swift
//  mashtag
//
//  Created by Austin Chan on 7/11/15.
//  Copyright (c) 2015 Fiftyawoe. All rights reserved.
//

import UIKit

class FinalizeViewController: GradientViewController {

    @IBOutlet weak var imageView: UIImageView!

    var image: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()

        render()
    }

    // MARK: UI Methods

    func render() {
        imageView.image = image
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        
    }

    @IBAction func backTap(sender: UIButton) {

    }

}
