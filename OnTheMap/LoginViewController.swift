//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by SVYAT on 23.05.16.
//  Copyright © 2016 HiT2B. All rights reserved.
//

import UIKit
import Material
import MBProgressHUD

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginTextField: TextField!
    @IBOutlet weak var passwordTextField: TextField!
    @IBOutlet weak var loginButton: RaisedButton!
    @IBOutlet weak var loginFacebookButton: RaisedButton!
    
    // Const for set keyboard margin above UITextField
    let keyboardTopMargin: CGFloat = 32
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginTextField.textColor = UIColor.whiteColor()
        passwordTextField.textColor = UIColor.whiteColor()
        
        // Set background gradient
        let colors = [Functions().colorFromRGB(255, green: 153, blue: 11, alpha: 1), Functions().colorFromRGB(254, green: 111, blue: 2, alpha: 1)]
        let locations = [0.0, 0.5]
        let backgroundGradient = Functions().getGradientLayer(view.frame, colors: colors, locations: locations)
        view.layer.insertSublayer(backgroundGradient, atIndex: 0)
        
        // Hide keyboard when tap on background
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // Resize background when device rotating
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        view.layer.sublayers?.first?.frame = self.view.bounds
    }
    
    // MARK: Actions
    @IBAction func udacityAuth(sender: AnyObject) {
        if loginTextField.text != "" && Functions().validateEmail(loginTextField.text!) {
            if passwordTextField.text != "" {
                
                // Show progress bar
                let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
                hud.mode = MBProgressHUDMode.Indeterminate
                hud.labelText = "Loading..."
                hud.dimBackground = true
                
                // Dismiss keyboard
                dismissKeyboard()
                
                // Send request
                UdacityClient.instance.udacityAuth(loginTextField.text!, password: passwordTextField.text!) { success, errorString in
                    performUIUpdatesOnMain {
                        
                        // Hide progress bar
                        MBProgressHUD.hideHUDForView(self.view, animated: true)
                        
                        if success {
                            self.performSegueWithIdentifier("mainVC", sender: nil)
                        } else {
                            if let errorString = errorString {
                                self.showAlert(errorString)
                            }
                        }
                    }
                }
            } else {
                self.showAlert("Password is empty!")
            }
        } else {
            self.showAlert("Login is invalid!")
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: UITextField delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == loginTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            dismissKeyboard()
            udacityAuth(self)
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
        if loginTextField.isFirstResponder() {
            if loginTextField.frame.origin.y + loginTextField.frame.size.height > view.frame.size.height - getKeyboardHeight(notification) {
                view.frame.origin.y = (((loginTextField.frame.origin.y + loginTextField.frame.size.height) - (view.frame.size.height - getKeyboardHeight(notification))) + keyboardTopMargin) * -1
            }
        } else if passwordTextField.isFirstResponder() {
            if passwordTextField.frame.origin.y + passwordTextField.frame.size.height > view.frame.size.height - getKeyboardHeight(notification) {
                view.frame.origin.y = (((passwordTextField.frame.origin.y + passwordTextField.frame.size.height) - (view.frame.size.height - getKeyboardHeight(notification))) + keyboardTopMargin) * -1
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
    
    // Set only portrait orientation
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait, .PortraitUpsideDown]
    }
    
}

