//
//  StickerViewController.swift
//  Mashtag
//
//  Created by Austin Chan on 7/9/15.
//  Copyright (c) 2015 Awoes. All rights reserved.
//

import UIKit

class StickerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {

    // IBOutlets
    @IBOutlet weak var overlayImageView: UIImageView!
    @IBOutlet weak var stickerCollectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var canvas: UIView!

    // UI Properties
    var overlayImage: UIImage?
    var stickerCollectionHeight: CGFloat = Util.screenSize.height - (Util.screenSize.width + 64) - (20 + 30)
    let stickerCollectionReuseIdentifier = "StickerViewCell"
    var activeSticker: UIImageView!

    // Sticker Properties
    var stickers = [("jaden-smith", 1)]
    var stickerCoverSizes: Array<CGSize> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        render()
    }

    // MARK: Image Data Methods

    func analyzeStickerData() {
        for sticker in stickers {
            var (str, _) = sticker
            let image = UIImage(named: str + "-cover")!
            stickerCoverSizes.append(image.size)
        }
    }

    func generateScreenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(Util.screenSize.width, Util.screenSize.width), false, 0);
        self.view.drawViewHierarchyInRect(CGRectMake(0, -64, Util.screenSize.width, Util.screenSize.height), afterScreenUpdates: true)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext();

        UIGraphicsEndImageContext();

        return image
    }

    // MARK: UICollectionView Methods

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickers.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(stickerCollectionReuseIdentifier, forIndexPath: indexPath) as! StickerViewCell

        var (str, _) = stickers[indexPath.row]
        cell.imageView.image = UIImage(named: str + "-cover")

        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let yPadding: CGFloat = 10
        let rowHeight = (stickerCollectionHeight / (Util.isPrimitiveDevice || true ? 1 : 2)) - yPadding
        let imageSize = stickerCoverSizes[indexPath.row]
        let imageRatio = imageSize.width / imageSize.height
        return CGSizeMake(
            rowHeight * imageRatio,
            rowHeight
        )
    }

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


    // MARK: Gesture Recognizers

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

    func handlePinch(recognizer: UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = CGAffineTransformScale(view.transform,
                recognizer.scale, recognizer.scale)
            recognizer.scale = 1
        }
    }

    func handleRotation(recognizer: UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = CGAffineTransformRotate(view.transform, recognizer.rotation)
            recognizer.rotation = 0
        }
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }



    // MARK: UI Methods

    func render() {
        overlayImageView.image = overlayImage
        stickerCollectionView.registerNib(UINib(nibName: "StickerViewCell", bundle: nil), forCellWithReuseIdentifier: stickerCollectionReuseIdentifier)

        analyzeStickerData()
    }

    func positionSticker() {
        let image = activeSticker.image!
        activeSticker.center = CGPointMake(canvas.frame.width / 2, canvas.frame.height - (image.size.height / 2) + 20)
        activeSticker.transform = CGAffineTransformIdentity
    }

    @IBAction func backTap(sender: UIButton) {
        navigationController?.popViewControllerAnimated(false)
    }

    @IBAction func resetPositionTap(sender: UIButton) {
        if activeSticker == nil {
            return
        }

        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 8, options: nil, animations: {
            self.positionSticker()
        }, completion: nil)
    }

    @IBAction func nextTap(sender: UIButton) {
        startFinalStep()
    }

    func startFinalStep() {
        var finalStep: FinalizeViewController = FinalizeViewController(nibName: "FinalizeViewController", bundle: nil)
        finalStep.image = generateScreenshot()
        navigationController?.pushViewController(finalStep, animated: true)
    }

}
