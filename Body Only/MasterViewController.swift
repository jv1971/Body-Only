//
//  MasterViewController.swift
//  Body Only
//
//  Created by Jack on 6/17/15.
//  Copyright (c) 2015 Kim Property Real Estate Co. LTD. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, UISearchResultsUpdating {
    
    let TABLE_VIEW_FONT_SIZE: CGFloat = 22
    let FONT_NAME: String = "Hangyaboly"
    let IMAGE_FN_PREFIX = "w"

    var detailViewController: DetailViewController? = nil

    var exercisesData : NSArray = []
    //search data
    var filteredData : [String] = []
    var resultSearchController = UISearchController()
    
    var oldIndexPath: NSIndexPath? = nil
    
    var exerciseName = ""
    
    // MARK: - loadExData
    
    func loadExData(){
        exercisesData = NSArray(contentsOfFile: NSBundle.mainBundle().pathForResource("Exercises", ofType: "plist")!)!
    }
    
    // MARK: - getIndexFromName
    
    func getIndexFromName(name: String)-> Int {
        return exercisesData.indexOfObject(name)
    }
    
    // MARK: - updateSearchResultsForSearchController

    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filteredData.removeAll(keepCapacity: false)
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text)
        let array = (exercisesData as NSArray).filteredArrayUsingPredicate(searchPredicate)
        filteredData = array as! [String]
        self.tableView.reloadData()
    }

    // MARK: - shareDialog
    
    func shareDialog(sender: UIBarButtonItem) {
        let activityViewController = UIActivityViewController(activityItems: [NSLocalizedString("share", comment: "")], applicationActivities: nil)
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            activityViewController.popoverPresentationController!.barButtonItem = sender
        }
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - showAboutDialog
    
    func showAboutDialog(sender: UIBarButtonItem) {
        let alert = SCLAlertView()
        alert.labelTitle.font = UIFont(name: FONT_NAME, size: TABLE_VIEW_FONT_SIZE)
        alert.labelTitle.textColor = UIColor.redColor()
        alert.showError(NSLocalizedString("about", comment: ""), subTitle: NSLocalizedString("subtitles", comment: ""), closeButtonTitle: NSLocalizedString("close", comment: ""))
    }
    
    // MARK: - animateTable
    
    func animateTable() {
        //store selected row
        let indexPath = self.tableView.indexPathForSelectedRow();
        //animation
        self.tableView.reloadData()
        let cells = self.tableView.visibleCells()
        let tableHeight: CGFloat = self.tableView.bounds.size.height
        for i in cells {
            let cell: UITableViewCell = i as! UITableViewCell
            cell.transform = CGAffineTransformMakeTranslation(0, tableHeight)
        }
        var index = 0
        for a in cells {
            let cell: UITableViewCell = a as! UITableViewCell
            UIView.animateWithDuration(1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: nil, animations: {
                cell.transform = CGAffineTransformMakeTranslation(0, 0);
                }, completion: nil)
            index += 1
        }
        //set selected row
        self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None);
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }
    
    func disableScrollsToTopPropertyOnAllSubviewsOf(view: UIView) {
        for subview in view.subviews {
            if let scrollView = subview as? UIScrollView {
                (scrollView as UIScrollView).scrollsToTop = false
            }
            self.disableScrollsToTopPropertyOnAllSubviewsOf(subview as! UIView)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //loading data from plist to table
        loadExData()
        
        //left button routine
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "shareDialog:")
        
        //right button routine
        let aboutButton = UIButton.buttonWithType(UIButtonType.InfoLight) as! UIButton
        aboutButton.addTarget(self, action: "showAboutDialog:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: aboutButton)
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
        
        //search routine
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            self.tableView.tableHeaderView = controller.searchBar
            
            controller.searchBar.placeholder = NSLocalizedString("search_prompt", comment: "")
            controller.searchBar.barTintColor = UIColor.redColor()
            
            return controller
        })()
        
        tableView.reloadData()
        disableScrollsToTopPropertyOnAllSubviewsOf(self.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        if let indexPath = oldIndexPath as NSIndexPath! {
            self.tableView.reloadData()
            let inPath = NSIndexPath(forRow: getIndexFromName(exerciseName), inSection: 0)
            self.tableView.selectRowAtIndexPath(inPath, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
        }
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            super.viewWillAppear(animated)
        } else {
            animateTable()
        }
        //////////////////////////////////////////
        self.navigationController?.hidesBarsOnSwipe = true
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let currentCell = self.tableView.cellForRowAtIndexPath(indexPath)
                let realIndex = exercisesData.indexOfObject(currentCell!.textLabel!.text!)
                let object: [AnyObject] = [(IMAGE_FN_PREFIX + String(realIndex)), exercisesData[realIndex] as! String]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
                
                oldIndexPath = indexPath
                exerciseName = exercisesData[realIndex] as! String
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.resultSearchController.active {
            return filteredData.count
        }
        else {
            return exercisesData.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        var name: String = ""
        if resultSearchController.active {
            cell.textLabel!.text = filteredData[indexPath.row]
            name = filteredData[indexPath.row]
        } else {
            cell.textLabel!.text = exercisesData[indexPath.row] as? String
            name = (exercisesData[indexPath.row] as? String)!
        }
        //advanced cell styling
        cell.textLabel!.font = UIFont(name: FONT_NAME, size: TABLE_VIEW_FONT_SIZE)
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        //cell styling from workout progress
        let defaults = NSUserDefaults.standardUserDefaults()
        if let level = defaults.integerForKey(name) as Int? {
            switch level {
            case 1:
                cell.textLabel!.textColor = UIColor(red:0.78, green:0.16, blue:0.16, alpha:1.0)
            case 2:
                cell.textLabel!.textColor = UIColor(red:1.00, green:0.67, blue:0.00, alpha:1.0)
            case 3:
                cell.textLabel!.textColor = UIColor(red:0.11, green:0.37, blue:0.13, alpha:1.0)
            default:
                cell.textLabel!.textColor = UIColor.blackColor()
            }
        }
        
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
            }, completion: nil)
    }
}

