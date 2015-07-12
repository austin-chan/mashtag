//
//  FinalizeViewController.swift
//  mashtag
//
//  Created by Austin Chan on 7/11/15.
//  Copyright (c) 2015 Fiftyawoe. All rights reserved.
//

import UIKit
import AssetsLibrary

class FinalizeViewController: GradientViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveIconView: UIImageView!
    @IBOutlet weak var saveSuccessIconView: UIImageView!

    var image: UIImage!
    var savedImageUrl: NSURL?
    let library = ALAssetsLibrary()
    let application = UIApplication.sharedApplication()

    override func viewDidLoad() {
        super.viewDidLoad()

        render()
    }

    // MARK: UI Methods

    func render() {
        imageView.image = image
        imageView.contentMode = UIViewContentMode.ScaleAspectFill

        saveSuccessIconView.hidden = true
    }

    func animateSavedButton() {
        saveIconView.hidden = true
        saveSuccessIconView.hidden = false
        saveSuccessIconView.transform = CGAffineTransformMakeScale(0.8, 0.8)
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 10, options: nil, animations: {
            self.saveSuccessIconView.transform = CGAffineTransformIdentity
            }, completion: nil)
    }

    @IBAction func backTap(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func saveButtonTap(sender: UIButton) {
        if sender.tag == 1 {
            return
        }

        sender.tag = Int(1)
        animateSavedButton()
        saveImage()
    }

    @IBAction func instagramTap(sender: UIButton) {
        var instagramURL = NSURL(string: "instagram://app")!
        if application.canOpenURL(instagramURL) {
            let openURL = "instagram://library?AssetPath=\(savedImageUrl)"
            application.openURL(NSURL(string: openURL)!)
        }
    }

    @IBAction func facebookTap(sender: UIButton) {

    }

    @IBAction func twitterTap(sender: UIButton) {

    }


    @IBAction func moreTap(sender: UIButton) {

    }

    // MARK: Image Methods

    func saveImage() {
        library.writeImageToSavedPhotosAlbum(image.CGImage, orientation: ALAssetOrientation(rawValue: image.imageOrientation.rawValue)!, completionBlock: {
            (url, err) -> Void in
            self.savedImageUrl = url
        })
    }

}
