//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by SVYAT on 27.05.16.
//  Copyright © 2016 HiT2B. All rights reserved.
//

import Foundation

struct StudentIndormation {
    
    var objectId: String?
    var uniqueKey: String?
    var firstName: String?
    var lastName: String?
    var mapString: String?
    var mediaURL: String?
    var latitude: Double?
    var longitude: Double?
    var createdAt: String?
    var updatedAt: String?
    
    init(dictionary: NSDictionary) {
        if let createdAt = dictionary[OnTheMapClient.JSONResponseKeys.CreatedAt] as? String {
            self.createdAt = createdAt
        }
        
        if let firstName = dictionary[OnTheMapClient.JSONResponseKeys.FirstName] as? String {
            self.firstName = firstName
        }
        
        if let lastName = dictionary[OnTheMapClient.JSONResponseKeys.LastName] as? String {
            self.lastName = lastName
        }
        
        if let latitude = dictionary[OnTheMapClient.JSONResponseKeys.Latitude] as? Double {
            self.latitude = latitude
        }
        
        if let longitude = dictionary[OnTheMapClient.JSONResponseKeys.Longitude] as? Double {
            self.longitude = longitude
        }
        
        if let mapString = dictionary[OnTheMapClient.JSONResponseKeys.MapString] as? String {
            self.mapString = mapString
        }
        
        if let mediaURL = dictionary[OnTheMapClient.JSONResponseKeys.MediaURL] as? String {
            self.mediaURL = mediaURL
        }
        
        if let objectId = dictionary[OnTheMapClient.JSONResponseKeys.ObjectId] as? String {
            self.objectId = objectId
        }
        
        if let uniqueKey = dictionary[OnTheMapClient.JSONResponseKeys.UniqueKey] as? String {
            self.uniqueKey = uniqueKey
        }
        
        if let updatedAt = dictionary[OnTheMapClient.JSONResponseKeys.UpdatedAt] as? String {
            self.updatedAt = updatedAt
        }
    }
}