//
//  ViewController.swift
//  Filterer
//
//  Created by Jack on 2015-09-22.
//  Copyright © 2015 UofT. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var filteredImage: UIImage?
    
    var originalImage: UIImage?
    
    let processor:ImageProcessor = ImageProcessor()
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var secondaryMenu: UIView!
    @IBOutlet var bottomMenu: UIView!
    
    @IBOutlet var filterButton: UIButton!
    @IBOutlet weak var compareButton: UIButton!
    @IBOutlet weak var originalLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var filterRedBtn: UIButton!
    @IBOutlet weak var filterGreenBtn: UIButton!
    @IBOutlet weak var filterBlueBtn: UIButton!
    @IBOutlet weak var filterYellowBtn: UIButton!
    @IBOutlet weak var filterPurpleBtn: UIButton!
    
    var selectedFilter:[Filter] = []
    var selectedIntensity:Int = 50

    @IBOutlet var slideView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        secondaryMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        originalImage = imageView.image!
        filteredImage = imageView.image!
        compareButton.enabled = false
        editButton.enabled = false
        
        // enable gestrue
        let gesture = UILongPressGestureRecognizer(target:self, action: #selector(ViewController.imageTouched))
        self.imageView.userInteractionEnabled = true
        self.imageView.addGestureRecognizer(gesture)
        
        slideView.translatesAutoresizingMaskIntoConstraints = false
        
        generateThumbnail()
    }
    
    func generateThumbnail() {
        let redThumbnail = processor.applyFilter(originalImage!, filters: [Filter.DOUBLERED])
        let greenThumbnail = processor.applyFilter(originalImage!, filters: [Filter.DOUBLEGREEN])
        let blueThumbnail = processor.applyFilter(originalImage!, filters: [Filter.DOUBLEBLUE])
        let yellowThumbnail = processor.applyFilter(originalImage!, filters: [Filter.DOUBLEGREEN, Filter.DOUBLERED])
        let purpleThumbnail = processor.applyFilter(originalImage!, filters: [Filter.DOUBLEBLUE, Filter.DOUBLERED])
        
        filterRedBtn.setImage(redThumbnail, forState: .Normal)
        filterGreenBtn.setImage(greenThumbnail, forState: .Normal)
        filterBlueBtn.setImage(blueThumbnail, forState: .Normal)
        filterYellowBtn.setImage(yellowThumbnail, forState: .Normal)
        filterPurpleBtn.setImage(purpleThumbnail, forState: .Normal)
    }
    
    func imageTouched(recognizer: UILongPressGestureRecognizer) {
        if (recognizer.state == .Began) {
            setNewImge(filteredImage, target: originalImage)
            originalLabel.hidden = false
            
        } else if (recognizer.state == .Ended) {
            setNewImge(originalImage, target: filteredImage)
            originalLabel.hidden = true
        }
    }

    // MARK: Share
    @IBAction func onShare(sender: AnyObject) {
        let activityController = UIActivityViewController(activityItems: ["Check out our really cool app", imageView.image!], applicationActivities: nil)
        presentViewController(activityController, animated: true, completion: nil)
    }
    
    // MARK: New Photo
    @IBAction func onNewPhoto(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .ActionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { action in
            self.showCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Album", style: .Default, handler: { action in
            self.showAlbum()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func showCamera() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .Camera
        
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    func showAlbum() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .PhotoLibrary
        
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            originalImage = image
            filteredImage = image
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onEdit(sender: UIButton) {
        if (sender.selected) {
            // hide slide view
            UIView.animateWithDuration(0.4, animations: {
                self.slideView.alpha = 0
            }) { completed in
                if completed == true {
                    self.slideView.removeFromSuperview()
                }
            }

            sender.selected = false
        } else {
            // hide filter menu
            hideSecondaryMenu()
            filterButton.selected = false
            // show slide view
            view.addSubview(slideView)
            
            let bottomConstraint = slideView.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
            let leftConstraint = slideView.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
            let rightConstraint = slideView.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
            
            let heightConstraint = slideView.heightAnchor.constraintEqualToConstant(30)
            
            NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
            
            view.layoutIfNeeded()
            
            self.slideView.alpha = 0
            UIView.animateWithDuration(0.4) {
                self.slideView.alpha = 1.0
            }
            sender.selected = true
        }
    }
    
    // MARK: Filter Menu
    @IBAction func onFilter(sender: UIButton) {
        if (sender.selected) {
            hideSecondaryMenu()
            sender.selected = false
        } else {
            showSecondaryMenu()
            sender.selected = true
        }
    }
    @IBAction func onClickRed(sender: AnyObject) {
        filteredImage = processor.applyFilter(originalImage!, filters: [Filter.DOUBLERED])
        selectedFilter = [Filter.DOUBLERED]
        compareButton.enabled = true
        originalLabel.hidden = true
        editButton.enabled = true
        setNewImge(originalImage, target: filteredImage)
    }
    
    func setNewImge(source:UIImage?, target:UIImage?) {
        let crossFade:CABasicAnimation = CABasicAnimation(keyPath: "contents");
        crossFade.duration = 1.5;
        crossFade.fromValue = source!.CGImage;
        crossFade.toValue = target!.CGImage;
        imageView.layer.addAnimation(crossFade, forKey: "animateContents");
        imageView.image = target
    }
    
    @IBAction func onClickBlue(sender: AnyObject) {
        filteredImage = processor.applyFilter(originalImage!, filters: [Filter.DOUBLEBLUE])
        selectedFilter = [Filter.DOUBLEBLUE]
        compareButton.enabled = true
        originalLabel.hidden = true
        editButton.enabled = true
        setNewImge(originalImage, target: filteredImage)
    }
    
    @IBAction func onClickGreen(sender: AnyObject) {
        filteredImage = processor.applyFilter(originalImage!, filters: [Filter.DOUBLEGREEN])
        selectedFilter = [Filter.DOUBLEGREEN]
        compareButton.enabled = true
        originalLabel.hidden = true
        editButton.enabled = true
        setNewImge(originalImage, target: filteredImage)
    }
    
    @IBAction func onClickYellow(sender: AnyObject) {
        filteredImage = processor.applyFilter(originalImage!, filters: [Filter.DOUBLEGREEN, Filter.DOUBLERED])
        selectedFilter = [Filter.DOUBLEGREEN, Filter.DOUBLERED]
        compareButton.enabled = true
        originalLabel.hidden = true
        editButton.enabled = true
        setNewImge(originalImage, target: filteredImage)
    }
    
    @IBAction func onClickPurple(sender: AnyObject) {
        filteredImage = processor.applyFilter(originalImage!, filters: [Filter.DOUBLEBLUE, Filter.DOUBLERED])
        selectedFilter = [Filter.DOUBLEBLUE, Filter.DOUBLERED]
        compareButton.enabled = true
        originalLabel.hidden = true
        editButton.enabled = true
        setNewImge(originalImage, target: filteredImage)
    }
    
    @IBAction func onClickCompare(sender: UIButton) {
        if (compareButton.selected) {
            setNewImge(originalImage, target: filteredImage)
            sender.selected = false
            originalLabel.hidden = true
        } else {
           setNewImge(filteredImage, target: originalImage)
            sender.selected = true
            originalLabel.hidden = false
        }
    }
    
    func showSecondaryMenu() {
        view.addSubview(secondaryMenu)
        
        let bottomConstraint = secondaryMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = secondaryMenu.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = secondaryMenu.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        
        let heightConstraint = secondaryMenu.heightAnchor.constraintEqualToConstant(44)
        
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        view.layoutIfNeeded()
        
        self.secondaryMenu.alpha = 0
        UIView.animateWithDuration(0.4) {
            self.secondaryMenu.alpha = 1.0
        }
    }

    func hideSecondaryMenu() {
        UIView.animateWithDuration(0.4, animations: {
            self.secondaryMenu.alpha = 0
            }) { completed in
                if completed == true {
                    self.secondaryMenu.removeFromSuperview()
                }
        }
    }

    @IBAction func slideValueChanged(sender: UISlider) {
        let intensity = Int(sender.value * 100) + 1
        
        selectedIntensity = intensity
        filteredImage = processor.applyFilter(originalImage!, filters: selectedFilter, intensity: selectedIntensity)
        imageView.image = filteredImage
    }

}

