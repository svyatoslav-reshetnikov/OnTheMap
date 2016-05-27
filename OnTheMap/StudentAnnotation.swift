//
//  StudentAnnotation.swift
//  OnTheMap
//
//  Created by SVYAT on 27.05.16.
//  Copyright © 2016 HiT2B. All rights reserved.
//

import MapKit

class StudentAnnotation: NSObject, MKAnnotation {
    
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        
        super.init()
    }
}