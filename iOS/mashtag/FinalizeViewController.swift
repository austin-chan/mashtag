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

/// A view controller for saving the generated image and sharing it to external services.
class FinalizeViewController: GradientViewController {

    /// IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveIconView: UIImageView!
    @IBOutlet weak var saveSuccessIconView: UIImageView!

    /// The generated image to either save or share.
    var image: UIImage!

    /// The library asset path of the image or nil if the image has not been saved.
    var savedImageUrl: NSURL?

    /// Whether or not the image has been saved.
    var hasSavedImage = false

    /// An assets library instance.
    let library = ALAssetsLibrary()

    /// The application singleton.
    let application = UIApplication.sharedApplication()

    override func viewDidLoad() {
        super.viewDidLoad()
        render()
    }

    /// Enables Google Analytics tracking.
    override func viewWillAppear(animated: Bool) {
        var tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Finalize Screen")
        var builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }

    // MARK: UI Methods (#uimethods)

    /**
        Prepares the UI.
    */
    func render() {
        imageView.image = image
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        saveSuccessIconView.hidden = true
    }

    /**
        Run animation on the 'Save to Camera Roll' button. removing the save icon and expanding in the green checkmark icon.
    */
    func animateSavedButton() {
        saveIconView.hidden = true
        saveSuccessIconView.hidden = false
        saveSuccessIconView.transform = CGAffineTransformMakeScale(0.8, 0.8)
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 10, options: nil, animations: {
            self.saveSuccessIconView.transform = CGAffineTransformIdentity
        }, completion: nil)
    }

    // MARK: IBActions (#ibaction)

    /// Pops view controller.
    @IBAction func backTap(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }

    /// Saves the image to the camera roll.
    @IBAction func saveButtonTap(sender: UIButton) {
        if !hasSavedImage {
            return
        }

        saveImage(andOpenInstagram: false, orOpenTwitter: false)
    }


    /// Saves the image if it hasn't been yet and opens the Instagram app directly to the 'New Post' screen with the image ready to be shared.
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

    /// Opens the Facebook app to the 'New Post' screen with the image already attached.
    @IBAction func facebookTap(sender: UIButton) {
        var facebookURL = NSURL(string: "fb://feed")!
        if application.canOpenURL(facebookURL) {
            let sharePhoto = FBSDKSharePhoto(image: image, userGenerated: true)
            var shareContent = FBSDKSharePhotoContent()
            shareContent.photos = [sharePhoto]

            var shareDialog = FBSDKShareDialog.showFromViewController(self, withContent: shareContent, delegate: nil)
        }
    }

    /// Opens the Twitter app to the 'New Tweet' screen but the image isn't already attached like Insta and FB, there's nothing I can do about that.
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

    /// Opens the iOS share dialog with the context set as the image.
    @IBAction func moreTap(sender: UIButton) {
        let moreController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        self.presentViewController(moreController, animated: true, completion: nil)
    }

    /// Pops the navigation stack all the way back to the home view controller.
    @IBAction func returnHomeTap(sender: UIButton) {
        navigationController?.popToRootViewControllerAnimated(true)
    }

    // MARK: Image Methods

    /**
        Performs save operation and optionally opens the Instagram app or Twitter app. If both apps are specified, Instagram takes precedence and opens instead of Twitter.
        
        :param: openInsta True opens Instagram
        :param: openTwitter True opens Twitter
    */
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

    /// Opens the Instagram app with the image already prepared to share.
    func openInstagramWithImage() {
        let openURL = "instagram://library?AssetPath=\(savedImageUrl)"
        application.openURL(NSURL(string: openURL)!)
    }

    /// Opens the Twitter app to the stage to make a new tweet.
    func openTwitter() {
        let openURL = "twitter://post"
        application.openURL(NSURL(string: openURL)!)
    }

}
