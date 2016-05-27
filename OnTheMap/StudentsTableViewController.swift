//
//  StudentsTableViewController.swift
//  OnTheMap
//
//  Created by SVYAT on 27.05.16.
//  Copyright © 2016 HiT2B. All rights reserved.
//

import UIKit

class StudentsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var studentsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OnTheMapClient.instance.students.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        }
        
        let firstName = OnTheMapClient.instance.students[indexPath.row].firstName
        let lastName = OnTheMapClient.instance.students[indexPath.row].lastName
        
        cell!.textLabel?.text = (firstName != nil ? firstName! + " " : "") + (lastName != nil ? lastName! : "")
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let mediaURL = OnTheMapClient.instance.students[indexPath.row].mediaURL
        
        if Functions().validateUrl(mediaURL) {
            let url = NSURL(string: mediaURL!)
            UIApplication.sharedApplication().openURL(url!)
        }  else {
            showAlert("Users' url is incorrect!")
        }
    }
    
}