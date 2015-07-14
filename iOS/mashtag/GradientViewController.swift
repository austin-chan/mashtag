//
//  GradientViewController.swift
//  Mashtag
//
//  Created by Austin Chan on 7/8/15.
//  Copyright (c) 2015 Awoes. All rights reserved.
//
//  Lovingly from 🇺🇸
//  ❤️🍻☺️, 💣🔫😭
//

import UIKit;

/// A view controller that adds a dark blue gradient to the background on initialization.
class GradientViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeBackgroundGradient()
    }

    /**
        Draws a dark blue gradient layer on the background.
    */
    func initializeBackgroundGradient() {
        var gradient = CAGradientLayer()
        gradient.frame = Util.screenSize
        gradient.colors = [UIColor(hexString: "2A354C")!.CGColor, UIColor(hexString: "142139")!.CGColor]
        view.layer.insertSublayer(gradient, atIndex: 0)
    }

}
