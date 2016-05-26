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
        
        // MARK: API Key
        static let ApiKey : String = "4e8bdccc3bb63cefbec21f936eca5651"
        
        // Schemes
        static let HTTPSScheme = "https"
        
        // MARK: Udacity URLs
        static let UdacityHost = "www.udacity.com"
        static let UdacityPath = "/api"
        static let UdacityAuthorizationURL : String = "https://www.themoviedb.org/authenticate/"
        
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
    
    // MARK: URL Keys
    struct URLKeys {
        static let UserID = "id"
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let ApiKey = "api_key"
        static let SessionID = "session_id"
        static let RequestToken = "request_token"
        static let Query = "query"
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
        
        // MARK: Session
        static let Session = "session"
        static let SessionID = "id"
        
    }
    
    /* MARK: Poster Sizes
    struct PosterSizes {
        static let RowPoster = UdacityClient.instance.config.posterSizes[2]
        static let DetailPoster = UdacityClient.instance.config.posterSizes[4]
    }*/
}
