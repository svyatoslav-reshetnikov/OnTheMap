//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Svyatoslav Reshetnikov on 29.05.16.
//  Copyright © 2016 HiT2B. All rights reserved.
//

import UIKit
import Material
import MapKit

class InformationPostingViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var addressTextField: TextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var urlTextField: TextField!
    @IBOutlet weak var submitButton: RaisedButton!
    
    // Const for set keyboard margin above UITextField
    let keyboardTopMargin: CGFloat = 32
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressTextField.textColor = UIColor.whiteColor()
        urlTextField.textColor = UIColor.whiteColor()
        
        // Set background gradient
        let colors = [Functions().colorFromRGB(255, green: 153, blue: 11, alpha: 1), Functions().colorFromRGB(254, green: 111, blue: 2, alpha: 1)]
        let locations = [0.0, 0.5]
        let backgroundGradient = Functions().getGradientLayer(view.frame, colors: colors, locations: locations)
        view.layer.insertSublayer(backgroundGradient, atIndex: 0)
        
        // Hide keyboard when tap on background
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: UITextField delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == addressTextField {
            dismissKeyboard()
            
            if let address = textField.text {
                let geocoder = CLGeocoder()
                geocoder.geocodeAddressString(address, completionHandler: { placemarks, error in
                    if let error = error {
                        self.showAlert(error.localizedDescription)
                    }
                    if let placemarks = placemarks {
                        // Clean the map
                        let annotationsToRemove = self.mapView.annotations.filter { $0 !== self.mapView.userLocation }
                        self.mapView.removeAnnotations( annotationsToRemove)
                        
                        let placemark = placemarks[0]
                        self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
                        self.mapView.setCenterCoordinate(placemark.location!.coordinate, animated: true)
                        
                        let span = MKCoordinateSpanMake(0.05, 0.05)
                        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: placemark.location!.coordinate.latitude, longitude: placemark.location!.coordinate.longitude), span: span)
                        self.mapView.setRegion(region, animated: true)
                        
                        if let addressDictionary = placemark.addressDictionary {
                            
                            if let addressLines = addressDictionary["FormattedAddressLines"] as? NSArray {
                                for addressLine in addressLines {
                                    print(addressLine)
                                }
                            }
                        }
                    }
                })
                }
        } else if textField == urlTextField {
            dismissKeyboard()
            // TODO: Action here
        }
        return true
    }
    
    // MARK: Keyboard stuff
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    // Change y coordinate if textField is hidden by keyboard
    func keyboardWillShow(notification: NSNotification) {
        // Check if active textField is hidden
        if addressTextField.isFirstResponder() {
            if addressTextField.frame.origin.y + addressTextField.frame.size.height > view.frame.size.height - getKeyboardHeight(notification) {
                view.frame.origin.y = (((addressTextField.frame.origin.y + addressTextField.frame.size.height) - (view.frame.size.height - getKeyboardHeight(notification))) + keyboardTopMargin) * -1
            }
        } else if urlTextField.isFirstResponder() {
            if urlTextField.frame.origin.y + urlTextField.frame.size.height > view.frame.size.height - getKeyboardHeight(notification) {
                view.frame.origin.y = (((urlTextField.frame.origin.y + urlTextField.frame.size.height) - (view.frame.size.height - getKeyboardHeight(notification))) + keyboardTopMargin) * -1
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
