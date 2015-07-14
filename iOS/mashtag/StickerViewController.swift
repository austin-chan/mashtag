//
//  StickerViewController.swift
//  Mashtag
//
//  Created by Austin Chan on 7/9/15.
//  Copyright (c) 2015 Awoes. All rights reserved.
//
//  Lovingly from 🇺🇸
//  ❤️🍻☺️, 💣🔫😭
//

import UIKit

/// A view controller for adding stickers to the selected image.
class StickerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {

    /// IBOutlets
    @IBOutlet weak var overlayImageView: UIImageView!
    @IBOutlet weak var stickerCollectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var canvas: UIView!

    /// UI Properties
    var stickerCollectionHeight: CGFloat = Util.screenSize.height - (Util.screenSize.width + 64) - (20 + 30)
    let stickerCollectionReuseIdentifier = "StickerViewCell"
    var activeSticker: UIImageView!

    /// The selected image to apply stickers to. Must be set before the view controller is presented.
    var overlayImage: UIImage?

    /// An array of (String, Int) tuples that describe the file name prefix of sticker families and how many stickers are in each family (not including the cover).
    var stickers = [("jaden-smith", 1)]

    /// An array of sizes that describe the size of the covers for each sticker family.
    lazy var stickerCoverSizes: Array<CGSize> = {
        var arr: Array<CGSize> = []
        for sticker in self.stickers {
            var (str, _) = sticker
            let image = UIImage(named: str + "-cover")!
            arr.append(image.size)
        }
        return arr
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        render()
    }

    /// Enables Google Analytics tracking.
    override func viewWillAppear(animated: Bool) {
        var tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Sticker Screen")
        var builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }

    // MARK: UI Methods (#uimethods)

    /**
        Prepares the UI.
    */
    func render() {
        overlayImageView.image = overlayImage
        stickerCollectionView.registerNib(UINib(nibName: "StickerViewCell", bundle: nil), forCellWithReuseIdentifier: stickerCollectionReuseIdentifier)
    }

    /**
        Moves the sticker to the default position.
    */
    func positionSticker() {
        let image = activeSticker.image!
        activeSticker.center = CGPointMake(canvas.frame.width / 2, canvas.frame.height - (image.size.height / 2) + 20)
        activeSticker.transform = CGAffineTransformIdentity
    }

    /**
        Triggers the last view controller and pushes the finalize view controller.
    */
    func startFinalStep() {
        var finalStep: FinalizeViewController = FinalizeViewController(nibName: "FinalizeViewController", bundle: nil)
        finalStep.image = generateScreenshot()
        navigationController?.pushViewController(finalStep, animated: true)
    }

    // MARK: IBActions (#ibaction)

    /// Pops view controller.
    @IBAction func backTap(sender: UIButton) {
        navigationController?.popViewControllerAnimated(false)
    }

    /// Animates the sticker back to default position.
    @IBAction func resetPositionTap(sender: UIButton) {
        if activeSticker == nil {
            return
        }

        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 8, options: nil, animations: {
            self.positionSticker()
            }, completion: nil)
    }

    /// Activates next view controller stage.
    @IBAction func nextTap(sender: UIButton) {
        startFinalStep()
    }

    // MARK: Image Data Methods (#image)

    /**
        Creates an image of the final edited image by screenshotting it.

        :returns: The screenshot of the final image after sticker editing it.
    */
    func generateScreenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(Util.screenSize.width, Util.screenSize.width), false, 0);
        self.view.drawViewHierarchyInRect(CGRectMake(0, -64, Util.screenSize.width, Util.screenSize.height), afterScreenUpdates: true)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext();

        UIGraphicsEndImageContext();

        return image
    }

    // MARK: UICollectionView Methods (#collectionview)

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickers.count
    }

    /// Uses StickerViewCell for cells and assigns the sticker family's cover image as the cell image.
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(stickerCollectionReuseIdentifier, forIndexPath: indexPath) as! StickerViewCell

        var (str, _) = stickers[indexPath.row]
        cell.imageView.image = UIImage(named: str + "-cover")

        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let yPadding: CGFloat = 10
        let rowHeight = (stickerCollectionHeight / (Util.isPrimitiveDevice ? 1 : 2)) - yPadding
        let imageSize = stickerCoverSizes[indexPath.row]
        let imageRatio = imageSize.width / imageSize.height
        return CGSizeMake(
            rowHeight * imageRatio,
            rowHeight
        )
    }

    /// Applies a new sticker to the main image and prepares it for moving and pinching.
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let (name, count) = stickers[indexPath.row]
        let randomIndex = Int(arc4random_uniform(UInt32(count))) + 1
        var imageView = UIImageView(image: UIImage(named: name + "-" + String(randomIndex))!)
        imageView.userInteractionEnabled = true

        let pan = UIPanGestureRecognizer(target: self, action: "handlePan:")
        pan.delegate = self
        imageView.addGestureRecognizer(pan)
        let pinch = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
        pinch.delegate = self
        imageView.addGestureRecognizer(pinch)
        let rotation = UIRotationGestureRecognizer(target: self, action: "handleRotation:")
        rotation.delegate = self
        imageView.addGestureRecognizer(rotation)

        if activeSticker != nil {
            activeSticker.removeFromSuperview()
        }

        canvas.addSubview(imageView)
        activeSticker = imageView

        positionSticker()
        activeSticker.transform = CGAffineTransformMakeScale(0.8, 0.8)
        activeSticker.alpha = 0.7
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: nil, animations: {
            self.positionSticker()
            self.activeSticker.alpha = 1
        }, completion: nil)
    }


    // MARK: Gesture Recognizers (#gesture)

    /// Translates the sticker laterally and vertically.
    func handlePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        if let view = recognizer.view {
            view.center = CGPoint(x:view.center.x + translation.x,
                y:view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPointZero, inView: self.view)

        if recognizer.state == UIGestureRecognizerState.Ended {

        }
    }

    /// Zooms the sticker in and out.
    func handlePinch(recognizer: UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = CGAffineTransformScale(view.transform,
                recognizer.scale, recognizer.scale)
            recognizer.scale = 1
        }
    }

    /// Rotates the sticker.
    func handleRotation(recognizer: UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = CGAffineTransformRotate(view.transform, recognizer.rotation)
            recognizer.rotation = 0
        }
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}
