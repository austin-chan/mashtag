//
//  ViewController.swift
//  Mashtag
//
//  Created by Austin Chan on 7/8/15.
//  Copyright (c) 2015 Awoes. All rights reserved.
//

import UIKit;

class HomeViewController: GradientViewController  {

    @IBAction func createPhotoTap(sender: UIButton) {
        var camera = CameraViewController(nibName: "CameraViewController", bundle: nil)
        navigationController?.pushViewController(camera, animated: true)
    }

}
