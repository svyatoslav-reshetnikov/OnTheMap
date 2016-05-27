//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by SVYAT on 25.05.16.
//  Copyright © 2016 HiT2B. All rights reserved.
//

import Foundation

// MARK: - TMDBClient: NSObject

class OnTheMapClient : NSObject {
    
    // MARK: Properties
    
    // shared session
    var session = NSURLSession.sharedSession()
    
    // authentication state
    var requestToken: String? = nil
    var sessionID: String? = nil
    var students = [StudentIndormation]()
    
    // MARK: Shared Instance
    static let instance = OnTheMapClient()
    
    // MARK: Create request
    func createRequest(url: NSURL) -> NSMutableURLRequest {
        
        let request = NSMutableURLRequest(URL: url)
        
        request.addValue(Constants.ApplicationJSON, forHTTPHeaderField: JSONHeaderKeys.Accept)
        request.addValue(Constants.ApplicationJSON, forHTTPHeaderField: JSONHeaderKeys.ContentType)
        
        return request
    }
    
    func createParseRequest(url: NSURL) -> NSMutableURLRequest {
        
        let request = createRequest(url)
        
        request.addValue(Constants.ParseAppID, forHTTPHeaderField: JSONHeaderKeys.ParseAppIDHeader)
        request.addValue(Constants.ParseApiKey, forHTTPHeaderField: JSONHeaderKeys.ParseAPIKeyHeader)
        
        return request
        
    }
    
    // MARK: GET
    
    func taskForGETMethod(request: NSMutableURLRequest, completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        request.HTTPMethod = "GET"
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // Different conver functions for Udacity and Parse responses
            if request.URL!.absoluteString.rangeOfString(JSONBodyKeys.Udacity) != nil{
                self.convertDataFromUdacityWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
            } else {
                self.convertDataFromParseWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
            }
        }
        
        task.resume()
        
        return task
    }
    
    /*func taskForGETImage(size: String, filePath: String, completionHandlerForImage: (imageData: NSData?, error: NSError?) -> Void) -> NSURLSessionTask {
        
        /* 1. Set the parameters */
        // There are none...
        
        /* 2/3. Build the URL and configure the request */
        let baseURL = NSURL(string: config.baseImageURLString)!
        let url = baseURL.URLByAppendingPathComponent(size).URLByAppendingPathComponent(filePath)
        let request = NSURLRequest(URL: url)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForImage(imageData: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            completionHandlerForImage(imageData: data, error: nil)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }*/
    
    // MARK: POST
    
    func taskForPOSTMethod(request: NSMutableURLRequest, jsonBody: String, completionHandlerForPOST: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        request.HTTPMethod = "POST"
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(result: nil, error: NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!.localizedDescription)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // Different conver functions for Udacity and Parse responses
            if request.URL!.absoluteString.rangeOfString(JSONBodyKeys.Udacity) != nil{
                self.convertDataFromUdacityWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
            } else {
                self.convertDataFromParseWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
            }
        }
        
        task.resume()
        
        return task
    }
    
    // MARK: DELETE
    
    func taskForDELETEMethod(request: NSMutableURLRequest, completionHandlerForDELETE: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        request.HTTPMethod = "DELETE"
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForDELETE(result: nil, error: NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!.localizedDescription)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // Different conver functions for Udacity and Parse responses
            if request.URL!.absoluteString.rangeOfString(JSONBodyKeys.Udacity) != nil{
                self.convertDataFromUdacityWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForDELETE)
            } else {
                self.convertDataFromParseWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForDELETE)
            }
        }
        
        task.resume()
        
        return task
    }
    
    // MARK: Helpers
    
    // substitute the key for the value that is contained within the method name
    func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    // given raw JSON, return a usable Foundation object
    private func convertDataFromUdacityWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data.subdataWithRange(NSMakeRange(5, data.length - 5)), options: .AllowFragments)
            print(parsedResult)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    private func convertDataFromParseWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            print(parsedResult)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    // Create an URL from parameters
    private func createURLComponentWithParameters(parameters: [String:AnyObject]) -> NSURLComponents {
        
        let components = NSURLComponents()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            var queryItems = components.queryItems ?? [NSURLQueryItem]()
            queryItems.append(queryItem)
        }
        
        return components
    }
    
    func udacityUrlFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = createURLComponentWithParameters(parameters)
        
        components.scheme = OnTheMapClient.Constants.HTTPSScheme
        components.host = OnTheMapClient.Constants.UdacityHost
        components.path = OnTheMapClient.Constants.UdacityPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    
    func parseUrlFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = createURLComponentWithParameters(parameters)
        
        components.scheme = OnTheMapClient.Constants.HTTPSScheme
        components.host = OnTheMapClient.Constants.ParseHost
        components.path = OnTheMapClient.Constants.ParsePath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
}
