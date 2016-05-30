//
//  StudentsTableViewController.swift
//  OnTheMap
//
//  Created by SVYAT on 27.05.16.
//  Copyright © 2016 HiT2B. All rights reserved.
//

import UIKit
import MBProgressHUD
import FBSDKCoreKit
import FBSDKLoginKit

class StudentsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var studentsTable: UITableView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var setPinButton: UIBarButtonItem!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    @IBAction func logout(sender: AnyObject) {
        
        // Show progress bar
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.mode = MBProgressHUDMode.Indeterminate
        hud.labelText = "Loading..."
        hud.dimBackground = true
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            FBSDKLoginManager().logOut()
            
            // Remove current screen with animation
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewControllerWithIdentifier("loginVC") as! LoginViewController
            
            let snapshot: UIView = self.view.snapshotViewAfterScreenUpdates(true)
            loginVC.view.addSubview(snapshot)
            UIApplication.sharedApplication().keyWindow?.rootViewController = loginVC
            
            Animations().scaleAndHide(snapshot)
        }
            
        else {
            lockInterface()
            
            // Send request
            OnTheMapClient.instance.udacityLogout() { success, errorString in
                performUIUpdatesOnMain {
                    
                    self.unlockInterFace()
                    
                    // Hide progress bar
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    
                    if success {
                        // Remove current screen with animation
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let loginVC = storyboard.instantiateViewControllerWithIdentifier("loginVC") as! LoginViewController
                        
                        let snapshot: UIView = self.view.snapshotViewAfterScreenUpdates(true)
                        loginVC.view.addSubview(snapshot)
                        UIApplication.sharedApplication().keyWindow?.rootViewController = loginVC
                        
                        Animations().scaleAndHide(snapshot)
                    } else {
                        if let errorString = errorString {
                            self.showAlert(errorString)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func getStudents(sender: AnyObject) {
        
        lockInterface()
        
        // Show progress bar
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.mode = MBProgressHUDMode.Indeterminate
        hud.labelText = "Loading..."
        hud.dimBackground = true
        
        OnTheMapClient.instance.getStudents(100, completionHandler: { success, errorString in
            
            performUIUpdatesOnMain {
                
                self.unlockInterFace()
                
                // Hide progress bar
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                
                if success {
                    self.studentsTable.reloadData()
                } else {
                    if let errorString = errorString {
                        self.showAlert(errorString)
                    }
                }
            }
        })
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
        
        cell?.imageView?.image = UIImage(named: "pinIcon")
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
    
    func lockInterface() {
        tabBarController?.tabBar.userInteractionEnabled = false
        refreshButton.enabled = false
        setPinButton.enabled = false
        logoutButton.enabled = false
    }
    
    func unlockInterFace() {
        tabBarController?.tabBar.userInteractionEnabled = true
        refreshButton.enabled = true
        setPinButton.enabled = true
        logoutButton.enabled = true
    }
}