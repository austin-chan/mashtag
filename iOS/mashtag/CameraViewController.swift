//
//  CameraViewController.swift
//  Mashtag
//
//  Created by Austin Chan on 7/8/15.
//  Copyright (c) 2015 Awoes. All rights reserved.
//
//  Lovingly from 🇺🇸
//  ❤️🍻☺️, 💣🔫😭
//

import UIKit
import AVFoundation
import Photos

/// A view controller for either taking picture or selecting an already saved photo.
class CameraViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // IBOutlets
    @IBOutlet weak var innerCameraButton: UIView!
    @IBOutlet weak var outerCameraButton: UIButton!
    @IBOutlet weak var mostRecentImageView: UIImageView!
    @IBOutlet weak var cameraRollCollectionView: UICollectionView!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var imagePickerButton: UIButton!
    @IBOutlet weak var bottomArea: UIView!
    @IBOutlet weak var bottomHalf: UIView!
    @IBOutlet weak var bottomHalfConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var topHalf: UIView!

    // Camera Properties
    let captureSession = AVCaptureSession()
    var stillImageOutput = AVCaptureStillImageOutput()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var backDevice: AVCaptureDevice?
    var frontDevice: AVCaptureDevice?
    var backInputActive = true
    var backInput: AVCaptureDeviceInput?
    var frontInput: AVCaptureDeviceInput?
    var flashActive = false

    // Camera Roll Properties
    var fetchedAssets: PHFetchResult?

    // UI Properties
    let cameraRollReuseIdentifier = "CameraRollViewCell"
    var heightOfCameraRoll: CGFloat = 0
    var finishedImage: UIImage?
    var activeFocusMarker: UIImageView?
    
    override func viewDidLoad() {
        prepareCamera()
        prepareCameraRoll()
        render()
    }

    /// Enables Google Analytics tracking.
    override func viewWillAppear(animated: Bool) {
        var tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Camera Screen")
        var builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }

    // MARK: UI Methods (#uimethods)

    /**
        Prepares the UI.
    */
    func render() {
        let innerCameraButtonHeight: CGFloat = 64
        let outerCameraButtonHeight: CGFloat = 86

        innerCameraButton.layer.cornerRadius = innerCameraButtonHeight/2

        outerCameraButton.layer.cornerRadius = outerCameraButtonHeight/2
        outerCameraButton.layer.borderWidth = 4
        outerCameraButton.layer.borderColor = UIColor(hexString: "#4A6491")?.CGColor

        let shadowPath = UIBezierPath(rect: imagePickerButton.bounds)
        imagePickerButton.layer.masksToBounds = false
        imagePickerButton.layer.shadowColor = UIColor(hexString: "#000000", alpha: 0.3)?.CGColor
        imagePickerButton.layer.shadowOpacity = 0.8
        imagePickerButton.layer.shadowRadius = 2
        imagePickerButton.layer.shadowOffset = CGSizeMake(0, 0)
        imagePickerButton.layer.shadowPath = shadowPath.CGPath

        mostRecentImageView.clipsToBounds = true
        if let image = fetchMostRecentPhoto() {
            mostRecentImageView.image = image
            mostRecentImageView.contentMode = UIViewContentMode.ScaleAspectFill
        }

        cameraRollCollectionView.registerNib(UINib(nibName: "CameraRollViewCell", bundle: nil), forCellWithReuseIdentifier: cameraRollReuseIdentifier)

        heightOfCameraRoll = cameraRollCollectionView.frame.size.height

        handlePrimitiveDevice()
    }

    /**
        Makes adjustments to the UI to handle older devices.
    */
    func handlePrimitiveDevice() {
        if Util.isPrimitiveDevice {
            bottomHalf.removeConstraint(bottomHalfConstraintTop)
            bottomArea.addConstraint(NSLayoutConstraint(item: bottomHalf, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: bottomArea, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
            topHalf.removeFromSuperview()
        }
    }

    /**
        Sets the flash setting and updates the flash UI components accordingly.

        :param: active True for flash or false for no flash.
    */
    func setFlash(active: Bool) {
        flashActive = active
        let filled = UIImage(named: "icon-flash-fill")
        let outline = UIImage(named: "icon-flash-outline")

        if flashActive {
            flashButton.setImage(filled, forState: .Normal)
        } else {
            flashButton.setImage(outline, forState: .Normal)
        }
        setCameraFlash(flashActive)
    }

    /**
        Animates a temporary focus marker UI component on top of the camera to indicate that the focus point has changed.

        :param: point Coordinate to apply the marker on.
    */
    func drawFocusMarker(point: CGPoint) {
        if let oldMarker = activeFocusMarker {
            oldMarker.removeFromSuperview()
        }
        var markerView = UIImageView(image: UIImage(named: "icon-focus-marker"))
        let markerHeight: CGFloat = 52
        markerView.frame = CGRectMake(point.x - markerHeight / 2, point.y - markerHeight / 2, markerHeight, markerHeight)
        markerView.alpha = 0.3
        view.addSubview(markerView)

        UIView.animateWithDuration(0.38, delay: 0, usingSpringWithDamping: 0.25, initialSpringVelocity: 10, options: nil, animations: {
            markerView.transform = CGAffineTransformMakeScale(0.75, 0.75)
            markerView.alpha = 0.65
            }, completion: nil)

        Util.delay(0.5, closure: {
            if markerView.superview != nil {
                markerView.removeFromSuperview()
                self.activeFocusMarker = nil
            }
        })
        activeFocusMarker = markerView
    }

    /**
        Darkens and lightens the camera button.

        :param: tap True darkens the button and false lightens the button back to normal.
    */
    func innerCameraButtonChangeColor(tap: Bool) {
        let innerCameraButtonColor = UIColor(hexString: "#91C9E9")
        let innerCameraButtonTapColor = UIColor(hexString: "#7293A6")

        UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: nil, animations: {
            if tap {
                self.innerCameraButton.backgroundColor = innerCameraButtonTapColor
            } else {
                self.innerCameraButton.backgroundColor = innerCameraButtonColor
            }
            }, completion: nil)
    }

    /**
        Darkens and lightens the image picker button.

        :param: tap True darkens the button and false lightens the button back to normal.
    */
    func imagePickerButtonChangeColor(tap: Bool) {
        let imagePickerButtonColor = UIColor(hexString: "#000000", alpha: 0)
        let imagePickerButtonTapColor = UIColor(hexString: "#000000", alpha: 0.55)

        UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: nil, animations: {
            if tap {
                self.imagePickerButton.backgroundColor = imagePickerButtonTapColor
            } else {
                self.imagePickerButton.backgroundColor = imagePickerButtonColor
            }
            }, completion: nil)
    }

    /**
        Animates the status bar back into view.
    */
    func setStatusBarVisible() {
        Util.delay(0, closure: {
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        })
    }

    /**
        Animates the status bar above and out of view.
    */
    func setStatusBarHidden() {
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
    }

    /**
        Activates the iOS image picker.
    */
    func startImagePicker() {
        var imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.delegate = self
        Util.delay(0.2, closure: {
            self.setStatusBarHidden()
        })
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    /**
        Activates the next sticker view controller step with a selected image.

        :param: image The selected image.
    */
    func startStickerStep(image: UIImage) {
        let stickerViewController = StickerViewController(nibName: "StickerViewController", bundle:nil)
        stickerViewController.overlayImage = image
        navigationController?.pushViewController(stickerViewController, animated: false)
    }
    // MARK: IBActions (#ibaction)

    /// Capture the camera image and activate the sticker stage.
    @IBAction func cameraTap(sender: UIButton) {
        innerCameraButtonChangeColor(false)
        captureCamera()
    }

    @IBAction func cameraTapUp(sender: UIButton) {
        innerCameraButtonChangeColor(false)
    }

    @IBAction func cameraTapDown(sender: UIButton) {
        innerCameraButtonChangeColor(true)
    }

    /// Pops the view controller.
    @IBAction func cancelTap(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }

    /// Flips the camera being used.
    @IBAction func cameraFlipTap(sender: UIButton) {
        if backInputActive {
            captureSession.removeInput(backInput)
            captureSession.addInput(frontInput)
            captureSession.startRunning()
            flashButton.hidden = true
            setFlash(false)
        } else {
            captureSession.removeInput(frontInput)
            captureSession.addInput(backInput)
            captureSession.startRunning()
            flashButton.hidden = false
        }
        backInputActive = !backInputActive
    }

    /// Toggles the flash setting.
    @IBAction func cameraFlashTap(sender: UIButton) {
        setFlash(!flashActive)
    }

    /// Activates the iOS image picker.
    @IBAction func imagePickerTap(sender: UIButton) {
        imagePickerButtonChangeColor(false)
        startImagePicker()
    }

    @IBAction func imagePickerTapDown(sender: UIButton) {
        imagePickerButtonChangeColor(true)
    }
    
    @IBAction func imagePickerTapUp(sender: UIButton) {
        imagePickerButtonChangeColor(false)
    }

    // MARK: Camera Methods (#camera)

    /**
        Initializes the camera components and activates the camera stream.
    */
    func prepareCamera() {
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }

        let devices = AVCaptureDevice.devices()
        for device in devices {
            if (device.hasMediaType(AVMediaTypeVideo)) {
                if(device.position == AVCaptureDevicePosition.Back) {
                    backDevice = device as? AVCaptureDevice
                } else if (device.position == AVCaptureDevicePosition.Front) {
                    frontDevice = device as? AVCaptureDevice
                }
            }
        }

        if backDevice != nil && frontDevice != nil {
            beginSession()
        }
    }

    /**
        Focuses the camera to a coordinate according to the iOS camera's wacko coordinate system.
    
        :param: point The coordinate point represented in the iOS camera's coordinate system.
    */
    func focusTo(point: CGPoint) {
        let device: AVCaptureDevice! = backInputActive ? backDevice : frontDevice
        if(device.lockForConfiguration(nil)) {
            if device.isFocusModeSupported(.ContinuousAutoFocus) {
                device.focusPointOfInterest = point
                device.focusMode = .ContinuousAutoFocus
            }

            if device.isExposureModeSupported(.ContinuousAutoExposure) {
                device.exposurePointOfInterest = point
                device.exposureMode = .ContinuousAutoExposure
            }
            device.unlockForConfiguration()
        }
    }

    /**
        Determines the coordinate of a touch according to the iOS camera's coordinate system.
    
        :param: touch The touch object to extract the coordinate from.
    
        :returns: The extracted coordinate value.
    */

    func touchRatioPoint(touch: UITouch) -> CGPoint {
        let cameraHeight: CGFloat = (Util.screenSize.width * 4 / 3)
        let cameraViewportHeight: CGFloat = Util.screenSize.width + 64
        let cameraOffset: CGFloat = (cameraHeight - cameraViewportHeight) / 2 + touch.locationInView(view).y
        return CGPointMake(
            (cameraOffset / cameraHeight),
            1 - (touch.locationInView(view).x / Util.screenSize.width)
        )
    }

    /// Focuses the camera.
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        focusTap(touch)
    }

    /// Focuses the camera.
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        focusTap(touch)
    }

    /**
        Performs the focus operation if the touch occurred in the frame of the camera.
    
        :param: touch The touch object to run the condition against.
    */
    func focusTap(touch: UITouch) {
        if touch.locationInView(view).y <= 64 + Util.screenSize.width && touch.locationInView(view).y > 64 {
            focusTo(touchRatioPoint(touch))
            drawFocusMarker(CGPointMake(touch.locationInView(view).x, touch.locationInView(view).y))
        }
    }

    /**
        Sets the camera flash setting.
    
        :param: active True to turn flash on, false to turn it off.
    */
    func setCameraFlash(active: Bool) {
        if backDevice!.hasFlash {
            backDevice!.lockForConfiguration(nil)
            backDevice!.flashMode = active ? .On : .Off
            backDevice!.unlockForConfiguration()
        }
    }

    /**
        Starts the camera stream and adds a preview layer to the view.
    */
    func beginSession() {
        // prepare focus mode for back camera
        backDevice!.lockForConfiguration(nil)
        if backDevice!.isFocusModeSupported(.ContinuousAutoFocus) {
            backDevice!.focusMode = .ContinuousAutoFocus
        }
        backDevice!.unlockForConfiguration()

        var err : NSError? = nil
        backInput = AVCaptureDeviceInput(device: backDevice, error: &err)
        frontInput = AVCaptureDeviceInput(device: frontDevice, error: &err)
        captureSession.addInput(backInput)

        if err != nil {
            println("error: \(err?.localizedDescription)")
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.zPosition = -1;
        previewLayer?.frame = CGRectMake(0, 0, Util.screenSize.width, 64 * 2 + Util.screenSize.width)
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill;
        view.layer.addSublayer(previewLayer)

        // this prevents delays for initializing the view controller.
        Util.delay(0.4, closure: {
            self.captureSession.startRunning()
        })
    }

    /**
        Begins async process to capture an image.
    */
    func captureCamera() {
        var videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)

        if videoConnection != nil {
            stillImageOutput.captureStillImageAsynchronouslyFromConnection(stillImageOutput.connectionWithMediaType(AVMediaTypeVideo))
                { (imageDataSampleBuffer, error) -> Void in
                    var capturedImage = UIImage(data: AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer))

                    self.startStickerStep(self.editCameraCapture(capturedImage!))
            }
        }
    }

    /**
        Crops image into a square and mirrors the image if taken by front camera.
    
        :param: image Image to edit and crop.
    
        :returns: The cropped and edited finished image.
    */
    func editCameraCapture(image: UIImage) -> UIImage {
        return generateMiddleCrop(image, orientation: backInputActive ? image.imageOrientation : .LeftMirrored)
    }

    /**
        Generates a square-cropped image and orients it according to a specified orientation mode.
        Adapted from http://carl-thomas.name/crop-image-to-square/.
    
        :param: originalImage The image to edit and crop.
        :param: orientation The orientation mode to edit the image according to.
    
        :returns: The finished edited image.
    */
    func generateMiddleCrop(originalImage: UIImage, orientation: UIImageOrientation) -> UIImage {
        let contextImage: UIImage = UIImage(CGImage: originalImage.CGImage)!
        let contextSize: CGSize = contextImage.size

        let posX: CGFloat
        let posY: CGFloat
        let width: CGFloat
        let height: CGFloat
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            width = contextSize.height
            height = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            width = contextSize.width
            height = contextSize.width
        }

        let rect: CGRect = CGRectMake(posX, posY, width, height)
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)
        let image: UIImage = UIImage(CGImage: imageRef, scale: originalImage.scale, orientation: orientation)!

        return image
    }


    // MARK: Camera Roll Methods (#cameraroll, #gallery)

    /**
        Prepares the data representing the camera roll images.
    */
    func prepareCameraRoll() {
        // Sort the images by creation date
        var fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]

        if let fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions) {
            fetchedAssets = fetchResult
        }
    }

    /**
        Retrieves the most recently taken image in the camera roll.

        :returns: The most recent photo or nil if the camera roll is empty.
    */
    func fetchMostRecentPhoto() -> UIImage? {
        return thumbnailForIndex(0)
    }

    /**
        Retrieves an image in the camera roll according to an index value ordered from most recent to oldest.
    
        :param: index The index value to retrieve an image based on.
    
        :returns: The image according to the request or nil if it does not exist.
    */
    func thumbnailForIndex(index: Int) -> UIImage? {
        var i: UIImage? = nil
        let imgManager = PHImageManager.defaultManager()

        var requestOptions = PHImageRequestOptions()
        requestOptions.synchronous = true

        if let assets = fetchedAssets {
            if assets.count > 0 {
                imgManager.requestImageForAsset(assets.objectAtIndex(assets.count - 1 - index) as! PHAsset, targetSize: CGSizeMake(150, 150), contentMode: PHImageContentMode.AspectFill, options: requestOptions, resultHandler: {
                    (image, _) in

                    i = image
                })
            }
        }
        return i
    }

    // MARK: UICollectionView Methods (#collectionview)

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let assets = fetchedAssets {
            return assets.count
        } else {
            return 0
        }
    }

    /// Uses CameraRollViewCells as cells.
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cameraRollReuseIdentifier, forIndexPath: indexPath) as! CameraRollViewCell

        cell.imageView.image = thumbnailForIndex(indexPath.row)

        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(heightOfCameraRoll, heightOfCameraRoll)
    }

    /// Activates the sticker stage with the selected image.
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var i: UIImage? = nil
        let imgManager = PHImageManager.defaultManager()

        var requestOptions = PHImageRequestOptions()

        if let assets = fetchedAssets {
            imgManager.requestImageDataForAsset(assets.objectAtIndex(assets.count - 1 - indexPath.row) as! PHAsset, options: requestOptions, resultHandler: { (data, str, orientation, info) -> Void in
                let image = UIImage(data: data)!
                self.startStickerStep(self.generateMiddleCrop(image, orientation: image.imageOrientation))
            })
        }
    }


    // MARK: UIImagePickerControllerDelegate Methods (#imagepicker)

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        setStatusBarVisible()
        dismissViewControllerAnimated(true, completion: nil)
    }

    /// Activates the sticker stage with the selected image.
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        setStatusBarVisible()
        dismissViewControllerAnimated(true, completion: nil)
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        Util.delay(0, closure: {
            self.startStickerStep(image)
        })
    }

}
