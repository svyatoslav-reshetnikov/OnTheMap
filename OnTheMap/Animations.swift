//
//  Animations.swift
//  OnTheMap
//
//  Created by SVYAT on 26.05.16.
//  Copyright © 2016 HiT2B. All rights reserved.
//

import Foundation
import UIKit

class Animations {
    
    static let sharedAnimations = Animations()
    
    func scaleAndHide(view: UIView) {
        UIView.animateWithDuration(0.3, animations: {() in
            view.layer.opacity = 0;
            view.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5);
            }, completion: {
                (value: Bool) in
                view.removeFromSuperview()
        });
    }
}
