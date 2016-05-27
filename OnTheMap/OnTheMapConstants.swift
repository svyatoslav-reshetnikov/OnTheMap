//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by SVYAT on 25.05.16.
//  Copyright © 2016 HiT2B. All rights reserved.
//

extension OnTheMapClient {
    
    // MARK: Constants
    struct Constants {
        
        // Standart
        static let HTTPSScheme = "https"
        static let ApplicationJSON = "application/json"
        
        // MARK: Udacity keys
        static let UdacityFacebookAppID = "365362206864879"
        
        // MARK: Udacity URLs
        static let UdacityHost = "www.udacity.com"
        static let UdacityPath = "/api"
        static let UdacityAuthorizationURL = "https://www.themoviedb.org/authenticate/"
        
        // MARK: Parse keys
        static let ParseAppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ParseApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        // MARK: Parse URLs
        static let ParseHost = "api.parse.com"
        static let ParsePath = "/1/classes"
    }
    
    // MARK: Methods
    struct Methods {
        
        // MARK: Udacity methods
        
        // Session
        static let Session = "/session"
        
        // MARK: Parse methods
        
        // StudentLocation
        static let StudentLocation = "/StudentLocation"
        
    }
    
    // MARK: Parameter Keys
    struct JSONHeaderKeys {
        
        static let Accept = "Accept"
        static let ContentType = "Content-Type"
        
        static let ParseAppIDHeader = "X-Parse-Application-Id"
        static let ParseAPIKeyHeader = "X-Parse-REST-API-Key"
    }
    
    // MARK: JSON Body Keys
    struct JSONBodyKeys {
        
        // MARK: Udacity keys
        
        // Session
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: Udacity keys
        
        // Session
        static let Session = "session"
        static let SessionID = "id"
        
        // MARK: Parse keys
        
        // Students information
        static let Results = "results"
        
        static let CreatedAt = "createdAt"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let ObjectId = "objectId"
        static let UniqueKey = "uniqueKey"
        static let UpdatedAt = "updatedAt"
        
    }
    
    /* MARK: Poster Sizes
    struct PosterSizes {
        static let RowPoster = UdacityClient.instance.config.posterSizes[2]
        static let DetailPoster = UdacityClient.instance.config.posterSizes[4]
    }*/
}
