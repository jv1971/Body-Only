//
//  DetailViewController.swift
//  Body Only
//
//  Created by Jack on 6/17/15.
//  Copyright (c) 2015 Kim Property Real Estate Co. LTD. All rights reserved.
//

import UIKit
import QuartzCore // for timer

class DetailViewController: UIViewController, PathMenuDelegate {
    
    let TABLE_VIEW_FONT_SIZE: CGFloat = 42
    let FONT_NAME: String = "Hangyaboly"
    
    var i = 0
    
    var displayLink: CADisplayLink!
    var lastDisplayLinkTimeStamp: CFTimeInterval!
    
    let alertGlobal = SCLAlertView()
    
    var exerciseName = ""
    
    var menu: PathMenu!

    @IBOutlet weak var imageExersice: UIImageView!
    
    var detailItem: AnyObject? {
        didSet {
            self.configureView()
        }
    }

    func configureView() {
        if let detail: AnyObject = self.detailItem {
            self.title = detail[1] as? String
        }
    }
    
    func setupPathMenu() {
        //setup Path button
        let storyMenuItemImage: UIImage = UIImage(named: "bg-menuitem")!
        let storyMenuItemImagePressed: UIImage = UIImage(named: "bg-menuitem-highlighted")!
        let starMenuItem1: PathMenuItem = PathMenuItem(image: storyMenuItemImage, highlightedImage: storyMenuItemImagePressed, ContentImage: UIImage(named: "mark")!, highlightedContentImage:nil)
        let starMenuItem2: PathMenuItem = PathMenuItem(image: storyMenuItemImage, highlightedImage: storyMenuItemImagePressed, ContentImage: UIImage(named: "timer")!, highlightedContentImage:nil)
        let starMenuItem3: PathMenuItem = PathMenuItem(image: storyMenuItemImage, highlightedImage: storyMenuItemImagePressed, ContentImage: UIImage(named: "counter")!, highlightedContentImage:nil)
        let starMenuItem4: PathMenuItem = PathMenuItem(image: storyMenuItemImage, highlightedImage: storyMenuItemImagePressed, ContentImage: UIImage(named: "save")!, highlightedContentImage:nil)
        
        var menus: [PathMenuItem] = [starMenuItem1, starMenuItem2, starMenuItem3, starMenuItem4]
        
        let startItem: PathMenuItem = PathMenuItem(
            image: UIImage(named: "bg-addbutton"),
            highlightedImage: UIImage(named: "bg-addbutton-highlighted"),
            ContentImage: UIImage(named: "icon-plus"),
            highlightedContentImage: UIImage(named: "icon-plus-highlighted")
        )
        menu = PathMenu(frame: self.view.bounds, startItem: startItem, optionMenus: menus)
        menu.delegate = self
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            menu.startPoint = CGPointMake(self.view.frame.size.width - 150, 150)//self.view.frame.size.height/2)
        } else {
            menu.startPoint = CGPointMake(self.view.frame.size.width - self.view.frame.size.width/12, self.view.frame.size.height/4)
        }
        
        menu.menuWholeAngle = CGFloat(M_PI) - CGFloat(3*M_PI/2)
        
        menu.rotateAngle = -CGFloat(M_PI_2) + CGFloat(M_PI/5) * 1/2
        menu.timeOffset = 0.0
        menu.farRadius = 110.0
        menu.nearRadius = 90.0
        menu.endRadius = 100.0
        menu.animationDuration = 0.5
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupPathMenu()
        self.view.addSubview(menu)
        //new ios8 future
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set title for iPad on first load
        self.title = ((NSArray(contentsOfFile: NSBundle.mainBundle().pathForResource("Exercises", ofType: "plist")!)!)[0] as? String)!
        self.configureView()
        if let detail: AnyObject = self.detailItem {
            imageExersice.image = UIImage(named: (detail[0] as? String)!)
            exerciseName = (detail[1] as? String!)!
        }
        //add sweet animation
        imageExersice.transform = CGAffineTransformMakeScale(0.1, 0.1)
        UIView.animateWithDuration(1.5,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 6.0,
            options: UIViewAnimationOptions.AllowUserInteraction,
            animations: {
                self.imageExersice.transform = CGAffineTransformIdentity
            },
            completion: nil
        )
        //prepare timer
        self.displayLink = CADisplayLink(target: self, selector: "displayLinkUpdate:")
        self.displayLink.paused = true;
        self.displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        self.lastDisplayLinkTimeStamp = self.displayLink.timestamp
        
        //and global timer alert
        alertGlobal.labelTitle.font = UIFont(name: FONT_NAME, size: TABLE_VIEW_FONT_SIZE)
        alertGlobal.labelTitle.textColor = UIColor.redColor()
        
        //prevent screen from sleeping
        UIApplication.sharedApplication().idleTimerDisabled = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        UIApplication.sharedApplication().idleTimerDisabled = false
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func pathMenu(menu: PathMenu, didSelectIndex idx: Int) {
        switch idx {
        case 0:
            //show marker
            let alert = SCLAlertView()
            alert.labelTitle.font = UIFont(name: FONT_NAME, size: 32)
            alert.labelTitle.textColor = UIColor.redColor()
            
            let defaults = NSUserDefaults.standardUserDefaults()
            
            alert.addButton(NSLocalizedString("not_start", comment: "")) {
                defaults.setInteger(0, forKey: self.exerciseName)
                defaults.synchronize()
                alert.hideView()
                //NSLog("%@", defaults.dictionaryRepresentation())
            }
            alert.addButton(NSLocalizedString("lv1", comment: "")) {
                defaults.setInteger(1, forKey: self.exerciseName)
                defaults.synchronize()
                alert.hideView()
                //NSLog("%@", defaults.dictionaryRepresentation())
            }
            alert.addButton(NSLocalizedString("lv2", comment: "")) {
                defaults.setInteger(2, forKey: self.exerciseName)
                defaults.synchronize()
                alert.hideView()
                //NSLog("%@", defaults.dictionaryRepresentation())
            }
            alert.addButton(NSLocalizedString("lv3", comment: "")) {
                defaults.setInteger(3, forKey: self.exerciseName)
                defaults.synchronize()
                alert.hideView()
                //NSLog("%@", defaults.dictionaryRepresentation())
            }
            alert.addButton(NSLocalizedString("zero", comment: "")) {
                let appDomain = NSBundle.mainBundle().bundleIdentifier!
                NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain)
                alert.hideView()
                //NSLog("%@", defaults.dictionaryRepresentation())
            }
            alert.showError(NSLocalizedString("wl", comment: ""), subTitle: NSLocalizedString("sb2", comment: ""), closeButtonTitle: NSLocalizedString("close", comment: ""))
        case 1:
            //show timer. Note we do preserve timer data between alert show...
            alertGlobal.addButton(NSLocalizedString("start", comment: "")) {
                self.displayLink.paused = false
            }
            alertGlobal.addButton(NSLocalizedString("stop", comment: "")) {
                self.displayLink.paused = true
            }
            alertGlobal.addButton(NSLocalizedString("reset", comment: "")) {
                self.displayLink.paused = true;
                self.lastDisplayLinkTimeStamp = 0.0
                self.alertGlobal.labelTitle.text = "0.00"
            }
            alertGlobal.showError("0.00", subTitle: NSLocalizedString("timer", comment: ""), closeButtonTitle: NSLocalizedString("close", comment: ""))
        case 2:
            //show counter. Note we do preserve counter data between alert show...
            let alert = SCLAlertView()
            alert.labelTitle.font = UIFont(name: FONT_NAME, size: TABLE_VIEW_FONT_SIZE)
            alert.labelTitle.textColor = UIColor.redColor()
            alert.addButton(NSLocalizedString("plus", comment: "")) {
                if self.i > 100 {
                    self.i = 0
                }
                alert.labelTitle.text = String (++self.i)
            }
            alert.addButton(NSLocalizedString("minus", comment: "")) {
                if self.i == 0 {
                    self.i = 1
                }
                alert.labelTitle.text = String (--self.i)
            }
            alert.showError(String(self.i), subTitle: NSLocalizedString("sb3", comment: ""), closeButtonTitle: NSLocalizedString("close", comment: ""))
        default:
            //saving image to photolibrary
            UIImageWriteToSavedPhotosAlbum(imageExersice.image, self, "image:didFinishSavingWithError:contextInfo:", nil)
        }
    }
    
    func displayLinkUpdate(sender: CADisplayLink) {
        self.lastDisplayLinkTimeStamp = self.lastDisplayLinkTimeStamp + self.displayLink.duration
        if self.lastDisplayLinkTimeStamp >= 9999 {
            self.lastDisplayLinkTimeStamp = 0
        }
        // Format the running tally to display on the last two significant digits //
        let formattedString:String = String(format: "%0.2f", self.lastDisplayLinkTimeStamp)
        self.alertGlobal.labelTitle.text = formattedString
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        let alert = SCLAlertView()
        alert.labelTitle.font = UIFont(name: FONT_NAME, size: 22)
        alert.labelTitle.textColor = UIColor.redColor()
        if error == nil {
            alert.showSuccess(NSLocalizedString("saved", comment: ""), subTitle: NSLocalizedString("info", comment: ""), closeButtonTitle: NSLocalizedString("close", comment: ""))
        } else {
            alert.showError(NSLocalizedString("error", comment: ""), subTitle: (error?.localizedDescription)!)
        }
    }
}

