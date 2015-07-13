//
//  FinalizeViewController.swift
//  Mashtag
//
//  Created by Austin Chan on 7/11/15.
//  Copyright (c) 2015 Awoes. All rights reserved.
//
//  Lovingly from 🇺🇸
//  ❤️🍻☺️, 💣🔫😭
//

import UIKit
import AssetsLibrary
import Social

class FinalizeViewController: GradientViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveIconView: UIImageView!
    @IBOutlet weak var saveSuccessIconView: UIImageView!

    var image: UIImage!
    var savedImageUrl: NSURL?
    var hasSavedImage = false
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
        if !hasSavedImage {
            return
        }

        saveImage(andOpenInstagram: false, orOpenTwitter: false)
    }

    @IBAction func instagramTap(sender: UIButton) {
        var instagramURL = NSURL(string: "instagram://app")!
        if application.canOpenURL(instagramURL) {
            if savedImageUrl != nil {
                openInstagramWithImage()
            } else {
                saveImage(andOpenInstagram: true, orOpenTwitter: false)
            }
        }
    }

    @IBAction func facebookTap(sender: UIButton) {
        var facebookURL = NSURL(string: "fb://feed")!
        if application.canOpenURL(facebookURL) {
            let sharePhoto = FBSDKSharePhoto(image: image, userGenerated: true)
            var shareContent = FBSDKSharePhotoContent()
            shareContent.photos = [sharePhoto]

            var shareDialog = FBSDKShareDialog.showFromViewController(self, withContent: shareContent, delegate: nil)
        }
    }

    @IBAction func twitterTap(sender: UIButton) {
        var twitterURL = NSURL(string: "twitter://timeline")!
        if application.canOpenURL(twitterURL) {
            if savedImageUrl != nil {
                openTwitter()
            } else {
                saveImage(andOpenInstagram: false, orOpenTwitter: true)
            }
        }
    }


    @IBAction func moreTap(sender: UIButton) {
        let moreController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        self.presentViewController(moreController, animated: true, completion: nil)
    }

    @IBAction func returnHomeTap(sender: UIButton) {
        navigationController?.popToRootViewControllerAnimated(true)
    }

    // MARK: Image Methods

    func saveImage(andOpenInstagram openInsta: Bool, orOpenTwitter openTwitter: Bool) {
        animateSavedButton()
        hasSavedImage = true

        library.writeImageToSavedPhotosAlbum(image.CGImage, orientation: ALAssetOrientation(rawValue: image.imageOrientation.rawValue)!, completionBlock: {
            (url, err) -> Void in
            self.savedImageUrl = url

            if openInsta {
                self.openInstagramWithImage()
            } else if openTwitter {
                self.openTwitter()
            }
        })
    }

    func openInstagramWithImage() {
        let openURL = "instagram://library?AssetPath=\(savedImageUrl)"
        application.openURL(NSURL(string: openURL)!)
    }

    func openTwitter() {
        let openURL = "twitter://post"
        application.openURL(NSURL(string: openURL)!)
    }

}
