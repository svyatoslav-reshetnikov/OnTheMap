//
//  Functions.swift
//  OnTheMap
//
//  Created by SVYAT on 23.05.16.
//  Copyright © 2016 HiT2B. All rights reserved.
//

import Foundation
import UIKit

class Functions {
    
    func colorFromRGB (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        
        let redValue = red/255
        let greenValue = green/255
        let blueValue = blue/255
        
        return UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: alpha)
    }
    
    func getGradientLayer(frame: CGRect, colors: [UIColor], locations: [Double]) -> CAGradientLayer{
        
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = frame
        gradientLayer.colors = colors.map{$0.CGColor}
        gradientLayer.locations = [0.0, 0.25, 0.75, 1.0]
        
        return gradientLayer
    }
    
    func validateEmail(email: String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if emailTest.evaluateWithObject(email) {
            return true
        } else {
            return false
        }
    }
    
}