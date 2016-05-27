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

class StudentsMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show progress bar
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.mode = MBProgressHUDMode.Indeterminate
        hud.labelText = "Loading..."
        hud.dimBackground = true
        
        OnTheMapClient.instance.getStudents(100, completionHandler: { success, errorString in
            
            performUIUpdatesOnMain {
                
                // Hide progress bar
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                
                if success {
                    for student in OnTheMapClient.instance.students {
                        let studentAnnotation = StudentAnnotation(title: (student.firstName != nil ? student.firstName! + " " : "") + (student.lastName != nil ? student.lastName! : ""),
                            subtitle: student.mediaURL != nil ? student.mediaURL! : "",
                            coordinate: CLLocationCoordinate2D(latitude: (student.latitude != nil ? student.latitude! : 0.0), longitude: (student.longitude != nil ? student.longitude! : 0.0)))
                        
                        self.mapView.addAnnotation(studentAnnotation)
                    }
                } else {
                    if let errorString = errorString {
                        self.showAlert(errorString)
                    }
                }
            }
        })
    }
    
    @IBAction func logout(sender: AnyObject) {
        
        // Show progress bar
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.mode = MBProgressHUDMode.Indeterminate
        hud.labelText = "Loading..."
        hud.dimBackground = true
        
        // Send request
        OnTheMapClient.instance.udacityLogout() { success, errorString in
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
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let annotationIdentifier = "annotationView"
        let annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(annotationIdentifier)
        
        if annotationView != nil {
            return annotationView
        } else {
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "pinIcon")
            let button = UIButton(type: .DetailDisclosure)
            annotationView.rightCalloutAccessoryView = button
            return annotationView
        }
    }
    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let studentAnnotation = annotationView.annotation as? StudentAnnotation {
            
            let mediaURL = studentAnnotation.subtitle
            
            if Functions().validateUrl(mediaURL) {
                let url = NSURL(string: mediaURL!)
                UIApplication.sharedApplication().openURL(url!)
            }  else {
                showAlert("Users' url is incorrect!")
            }
        }
    }
}
