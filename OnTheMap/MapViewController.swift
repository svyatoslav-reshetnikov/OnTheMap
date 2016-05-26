//
//  MapViewController.swift
//  OnTheMap
//
//  Created by SVYAT on 26.05.16.
//  Copyright © 2016 HiT2B. All rights reserved.
//

import UIKit
import MapKit
import MBProgressHUD

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logout(sender: AnyObject) {
        
        // Show progress bar
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.mode = MBProgressHUDMode.Indeterminate
        hud.labelText = "Loading..."
        hud.dimBackground = true
        
        // Send request
        UdacityClient.instance.udacityLogout() { success, errorString in
            performUIUpdatesOnMain {
                
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
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
