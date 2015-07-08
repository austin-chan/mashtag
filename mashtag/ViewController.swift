//
//  ViewController.swift
//  mashtag
//
//  Created by Austin Chan on 7/8/15.
//  Copyright (c) 2015 Fiftyawoe. All rights reserved.
//

import UIKit;

class ViewController: UIViewController {
    
    func initializeBackgroundGradient() {
        var gradient = CAGradientLayer()
        gradient.frame = self.view.bounds
        gradient.colors = [UIColor(hexString: "2A354C")!.CGColor, UIColor(hexString: "142139")!.CGColor]
        view.layer.insertSublayer(gradient, atIndex: 0)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeBackgroundGradient()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
