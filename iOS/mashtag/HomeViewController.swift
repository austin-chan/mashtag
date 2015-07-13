//
//  HomeViewController.swift
//  Mashtag
//
//  Created by Austin Chan on 7/8/15.
//  Copyright (c) 2015 Awoes. All rights reserved.
//
//  Lovingly from 🇺🇸
//  ❤️🍻☺️, 💣🔫😭
//

import UIKit;
import AVFoundation
import Photos

class HomeViewController: GradientViewController  {

    // IBOutlets
    @IBOutlet weak var startButton: DesignButton!

    // Returns 0 if all access is granted, 1 if user has not been asked, and 2 if they have denied
    var permissionAccess: Int {
        var permission = 0

        switch AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) {
        case AVAuthorizationStatus.Denied, AVAuthorizationStatus.Restricted:
            permission = 2
        case AVAuthorizationStatus.NotDetermined:
            permission = 1
        default:
            ()
        }

        switch PHPhotoLibrary.authorizationStatus() {
        case PHAuthorizationStatus.Denied, PHAuthorizationStatus.Restricted:
            permission = 2
        case PHAuthorizationStatus.NotDetermined:
            permission = max(permission, 1)
        default:
            ()
        }

        return permission
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let authorized = NSUserDefaults.standardUserDefaults().boolForKey("authorized")

        if permissionAccess != 0 {
            startButton.titleLabel?.text = Util.isPrimitiveDevice ? "GRANT ACCESS" : "GRANT CAMERA / LIBRARY ACCESS"
            startButton.setup()
        }
    }

    // MARK: UI Methods

    @IBAction func createPhotoTap(sender: UIButton) {
        switch permissionAccess {
        case 0:
            // make sure button label is correct
            startButton.titleLabel?.text = "CREATE PHOTO"
            startButton.setup()

            var camera = CameraViewController(nibName: "CameraViewController", bundle: nil)
            navigationController?.pushViewController(camera, animated: true)
        case 1:
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: nil)
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                if self.permissionAccess == 0 {
                    // rerun method to proceed

                    Util.delay(0, closure: {
                        self.createPhotoTap(sender)
                    })
                }
            })
        default:
            let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString)!
            UIApplication.sharedApplication().openURL(settingsURL)
        }
    }

}
