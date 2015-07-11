//
//  StickerViewController.swift
//  mashtag
//
//  Created by Austin Chan on 7/9/15.
//  Copyright (c) 2015 Fiftyawoe. All rights reserved.
//

import UIKit

class StickerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // IBOutlets
    @IBOutlet weak var overlayImageView: UIImageView!
    @IBOutlet weak var stickerCollectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var canvas: UIView!

    // UI Properties
    var overlayImage: UIImage?
    var stickerCollectionHeight: CGFloat = Util.screenSize.height - (Util.screenSize.width + 64) - (20 + 30)
    let stickerCollectionReuseIdentifier = "StickerViewCell"

    // Sticker Properties
    var stickers = [("jaden-smith", 1), ("jaden-smith", 1), ("jaden-smith", 1)]
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
        let rowHeight = (stickerCollectionHeight / 2) - yPadding
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
        imageView.addGestureRecognizer(pan)
        let pinch = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
        imageView.addGestureRecognizer(pinch)

        canvas.addSubview(imageView)
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

    // MARK: UI Methods

    func render() {
        overlayImageView.image = overlayImage
        stickerCollectionView.registerNib(UINib(nibName: "StickerViewCell", bundle: nil), forCellWithReuseIdentifier: stickerCollectionReuseIdentifier)

        analyzeStickerData()
    }

    @IBAction func backTap(sender: UIButton) {
        navigationController?.popViewControllerAnimated(false)
    }

}
