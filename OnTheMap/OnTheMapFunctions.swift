//
//  UdacityFunctions.swift
//  OnTheMap
//
//  Created by SVYAT on 25.05.16.
//  Copyright © 2016 HiT2B. All rights reserved.
//

import Foundation
import MapKit
import FBSDKLoginKit

extension OnTheMapClient {
    
    func udacityAuth(login: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        // 0 - sessionID, 1 - userID
        loginWithUsernamePassword(login, password: password) { success, info, errorString in
            if let sessionID = info.0 {
                // Save sessionID in the UdacityClient
                self.sessionID = sessionID
                // And in the NSUserDefaults
                NSUserDefaults.standardUserDefaults().setObject(sessionID, forKey: "sessionID")
            }
            if let userID = info.1 {
                // Save userID in the UdacityClient
                self.userID = userID
                // And in the NSUserDefaults
                NSUserDefaults.standardUserDefaults().setObject(userID, forKey: "userID")
            }
            completionHandler(success: success, errorString: errorString)
        }
    }
    
    func facebookAuth(completionHandler: (success: Bool, errorString: String?) -> Void) {
        facebookAuthorization { success, accessToken, errorString in
            if success {
                self.loginWithFacebook(accessToken!, completionHandler: { success, info, errorString in
                    if success {
                        if let sessionID = info.0 {
                            // Save sessionID in the UdacityClient
                            self.sessionID = sessionID
                            // And in the NSUserDefaults
                            NSUserDefaults.standardUserDefaults().setObject(sessionID, forKey: "sessionID")
                        }
                        if let userID = info.1 {
                            // Save userID in the UdacityClient
                            self.userID = userID
                            // And in the NSUserDefaults
                            NSUserDefaults.standardUserDefaults().setObject(userID, forKey: "userID")
                        }
                    }
                    completionHandler(success: success, errorString: errorString)
                })
            } else {
                completionHandler(success: success, errorString: errorString)
            }
        }
    }
    
    func udacityLogout(completionHandler: (success: Bool, errorString: String?) -> Void) {
        logout { success, sessionID, errorString in
            if sessionID != nil {
                // Remove sessionID and userID from the UdacityClient
                self.sessionID = ""
                self.userID = ""
                self.objectID = ""
                // And from the NSUserDefaults
                NSUserDefaults.standardUserDefaults().setObject("", forKey: "sessionID")
                NSUserDefaults.standardUserDefaults().setObject("", forKey: "userID")
            }
            completionHandler(success: success, errorString: errorString)
        }
    }
    
    func postLocation(userID: String, placemark: CLPlacemark, mediaURL: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        getPublicUserInfo(userID) { success, info, errorString in
            if success {
                self.postUserLocation(userID, firstName: info.0!, lastName: info.1!, mapString: placemark.addressDictionary!["Name"] as! String, mediaURL: mediaURL, latitude: placemark.location!.coordinate.latitude, longitude: placemark.location!.coordinate.longitude, completionHandler: { success, objectID, errorString in
                    if success {
                        self.objectID = objectID
                        NSUserDefaults.standardUserDefaults().setObject(objectID!, forKey: "objectId")
                    }
                    completionHandler(success: success, errorString: errorString)
                })
            } else {
                completionHandler(success: success, errorString: errorString)
            }
        }
    }
    
    func updateLocation(objectID: String, userID: String, placemark: CLPlacemark, mediaURL: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        getPublicUserInfo(userID) { success, info, errorString in
            if success {
                self.updateUserLocation(objectID, uniqueKey: userID, firstName: info.0!, lastName: info.1!, mapString: placemark.addressDictionary!["Name"] as! String, mediaURL: mediaURL, latitude: placemark.location!.coordinate.latitude, longitude: placemark.location!.coordinate.longitude, completionHandler: { success, errorString in
                    completionHandler(success: success, errorString: errorString)
                })
            } else {
                completionHandler(success: success, errorString: errorString)
            }
        }
    }
    
    func getStudents(limit: Int, completionHandler: (success: Bool, errorString: String?) -> Void) {
        getStudentsFromParse(limit) { success, students, errorString in
            if students != nil {
                self.students = students!
            }
            completionHandler(success: success, errorString: errorString)
        }
    }
    
    private func loginWithUsernamePassword(login: String, password: String, completionHandler: (success: Bool, info: (String?, String?), errorString: String?) -> Void) {
        
        let parameters = [String:AnyObject]()
        let jsonBody = "{\"udacity\": {\"\(OnTheMapClient.JSONBodyKeys.Username)\": \"\(login)\", \"\(OnTheMapClient.JSONBodyKeys.Password)\": \"\(password)\"}}"
        let url = udacityUrlFromParameters(parameters, withPathExtension: Methods.Session)
        
        let request = createRequest(url)
        
        taskForPOSTMethod(request, jsonBody: jsonBody) { results, error in
            if let error = error {
                completionHandler(success: false, info: (nil, nil), errorString: error.localizedDescription)
            } else {
                if let session = results[OnTheMapClient.JSONResponseKeys.Session] as? [String: AnyObject] {
                    if let sessionID = session[OnTheMapClient.JSONResponseKeys.SessionID] as? String {
                        if let account = results[OnTheMapClient.JSONResponseKeys.Account] as? [String: AnyObject] {
                            if let userID = account[OnTheMapClient.JSONResponseKeys.Key] as? String {
                                completionHandler(success: true, info: (sessionID, userID), errorString: "")
                            } else {
                                completionHandler(success: false, info: (nil, nil), errorString: "Could not find \(OnTheMapClient.JSONResponseKeys.Key) in \(account)")
                            }
                        } else {
                            completionHandler(success: false, info: (nil, nil), errorString: "Could not find \(OnTheMapClient.JSONResponseKeys.Account) in \(results)")
                        }
                    } else {
                        completionHandler(success: false, info: (nil, nil), errorString: "Could not find \(OnTheMapClient.JSONResponseKeys.SessionID) in \(session)")
                    }
                } else {
                    completionHandler(success: false, info: (nil, nil), errorString: "Could not find \(OnTheMapClient.JSONResponseKeys.Session) in \(results)")
                }
            }
        }
    }
    
    private func loginWithFacebook(token: String, completionHandler: (success: Bool, info: (String?, String?), errorString: String?) -> Void) {
        let parameters = [String:AnyObject]()
        let jsonBody = "{\"facebook_mobile\": {\"access_token\": \"\(token)\"}}"

        let url = udacityUrlFromParameters(parameters, withPathExtension: Methods.Session)
        
        let request = createRequest(url)
        
        taskForPOSTMethod(request, jsonBody: jsonBody) { results, error in
            if let error = error {
                completionHandler(success: false, info: (nil, nil), errorString: error.localizedDescription)
            } else {
                print(results)
                if let session = results[OnTheMapClient.JSONResponseKeys.Session] as? [String: AnyObject] {
                    if let sessionID = session[OnTheMapClient.JSONResponseKeys.SessionID] as? String {
                        if let account = results[OnTheMapClient.JSONResponseKeys.Account] as? [String: AnyObject] {
                            if let userID = account[OnTheMapClient.JSONResponseKeys.Key] as? String {
                                completionHandler(success: true, info: (sessionID, userID), errorString: "")
                            } else {
                                completionHandler(success: false, info: (nil, nil), errorString: "Could not find \(OnTheMapClient.JSONResponseKeys.Key) in \(account)")
                            }
                        } else {
                            completionHandler(success: false, info: (nil, nil), errorString: "Could not find \(OnTheMapClient.JSONResponseKeys.Account) in \(results)")
                        }
                    } else {
                        completionHandler(success: false, info: (nil, nil), errorString: "Could not find \(OnTheMapClient.JSONResponseKeys.SessionID) in \(session)")
                    }
                } else {
                    completionHandler(success: false, info: (nil, nil), errorString: "Could not find \(OnTheMapClient.JSONResponseKeys.Session) in \(results)")
                }
            }
        }
    }
    
    private func logout(completionHandler: (success: Bool, sessionID: String?, errorString: String?) -> Void) {
        
        let parameters = [String:AnyObject]()
        let url = udacityUrlFromParameters(parameters, withPathExtension: Methods.Session)
        
        let request = createRequest(url)
        
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        taskForDELETEMethod(request) { results, error in
            if let error = error {
                completionHandler(success: false, sessionID: nil, errorString: error.localizedDescription)
            } else {
                if let session = results[OnTheMapClient.JSONResponseKeys.Session] as? [String: AnyObject] {
                    if let sessionID = session[OnTheMapClient.JSONResponseKeys.SessionID] as? String {
                        completionHandler(success: true, sessionID: sessionID, errorString: "")
                    } else {
                        completionHandler(success: false, sessionID: nil, errorString: "Could not find \(OnTheMapClient.JSONResponseKeys.SessionID) in \(session)")
                    }
                } else {
                    completionHandler(success: false, sessionID: nil, errorString: "Could not find \(OnTheMapClient.JSONResponseKeys.Session) in \(results)")
                }
            }
        }
    }
    
    private func getPublicUserInfo(userId: String, completionHandler: (success: Bool, info: (String?, String?), errorString: String?) -> Void) {
        
        let parameters = [String:AnyObject]()
        
        let url = udacityUrlFromParameters(parameters, withPathExtension: Methods.UserInfo + "/\(userID!)")
        
        let request = createParseRequest(url)
        
        taskForGETMethod(request) { results, error in
            if let error = error {
                completionHandler(success: false, info: (nil, nil), errorString: error.localizedDescription)
            } else {
                if let user = results[OnTheMapClient.JSONResponseKeys.User] as? [String: AnyObject] {
                    if let firstName = user[OnTheMapClient.JSONResponseKeys.UdacityFirstName] as? String {
                        if let lastName = user[OnTheMapClient.JSONResponseKeys.UdacityLastName] as? String {
                            completionHandler(success: true, info: (firstName, lastName), errorString: "")
                        } else {
                            completionHandler(success: false, info: (nil, nil), errorString: "Could not find \(OnTheMapClient.JSONResponseKeys.UdacityLastName) in \(user)")
                        }
                    } else {
                        completionHandler(success: false, info: (nil, nil), errorString: "Could not find \(OnTheMapClient.JSONResponseKeys.UdacityFirstName) in \(user)")
                    }
                } else {
                    completionHandler(success: false, info: (nil, nil), errorString: "Could not find \(OnTheMapClient.JSONResponseKeys.User) in \(results)")
                }
            }
        }
    }
    
    private func getStudentsFromParse(limit: Int, completionHandler: (success: Bool, students: [StudentIndormation]?, errorString: String?) -> Void) {
        
        var parameters = [String:AnyObject]()
        if limit != 0 {
            parameters["limit"] = limit
        }
        
        let url = parseUrlFromParameters(parameters, withPathExtension: Methods.StudentLocation)
        
        let request = createParseRequest(url)
        
        taskForGETMethod(request) { results, error in
            if let error = error {
                completionHandler(success: false, students: nil, errorString: error.localizedDescription)
            } else {
                if let resultsArray = results[OnTheMapClient.JSONResponseKeys.Results] as? NSArray {
                    var students = [StudentIndormation]()
                    for result in resultsArray {
                        let student = StudentIndormation(dictionary: result as! NSDictionary)
                        students.append(student)
                    }
                    
                    if students.count == 0 {
                        completionHandler(success: false, students: nil, errorString: "No students")
                    } else {
                        self.students = students
                        completionHandler(success: true, students: students, errorString: nil)
                    }
                } else {
                    completionHandler(success: false, students: nil, errorString: "Could not find \(OnTheMapClient.JSONResponseKeys.Session) in \(results)")
                }
            }
        }
    }
    
    private func postUserLocation(uniqueKey: String, firstName: String, lastName: String, mapString: String, mediaURL: String, latitude: Double, longitude: Double, completionHandler: (success: Bool, objectID: String?, errorString: String?) -> Void) {
        
        let parameters = [String:AnyObject]()
        
        let jsonBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
        
        let url = parseUrlFromParameters(parameters, withPathExtension: Methods.StudentLocation)
        
        let request = createParseRequest(url)
        
        taskForPOSTMethod(request, jsonBody: jsonBody) { results, error in
            if let error = error {
                completionHandler(success: false, objectID: nil, errorString: error.localizedDescription)
            } else {
                if let objectID = results[OnTheMapClient.JSONResponseKeys.ObjectID] as? String {
                    completionHandler(success: true, objectID: objectID, errorString: "")
                } else {
                    completionHandler(success: false, objectID: nil, errorString: "Could not find \(OnTheMapClient.JSONResponseKeys.ObjectID) in \(results)")
                }
            }
        }
    }
    
    private func updateUserLocation(objectID: String, uniqueKey: String, firstName: String, lastName: String, mapString: String, mediaURL: String, latitude: Double, longitude: Double, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        let parameters = [String:AnyObject]()
        
        let jsonBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
        
        let url = parseUrlFromParameters(parameters, withPathExtension: Methods.StudentLocation + "/\(objectID)")
        
        let request = createParseRequest(url)
        
        taskForPUTMethod(request, jsonBody: jsonBody) { results, error in
            if let error = error {
                completionHandler(success: false,  errorString: error.localizedDescription)
            } else {
                if results[OnTheMapClient.JSONResponseKeys.UpdatedAt] != nil {
                    completionHandler(success: true, errorString: "")
                } else {
                    completionHandler(success: false, errorString: "Could not find \(OnTheMapClient.JSONResponseKeys.ObjectID) in \(results)")
                }
            }
        }
    }
    
    private func facebookAuthorization(completionHandler: (success: Bool, accessToken: String?, errorString: String?) -> Void) {
        let loginManager = FBSDKLoginManager()
        let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
        loginManager.logInWithReadPermissions(["public_profile"], fromViewController: rootViewController, handler: { result, error -> Void in
            if let error = error {
                completionHandler(success: false, accessToken: nil, errorString: error.localizedDescription)
            } else if (result.isCancelled) {
                completionHandler(success: false, accessToken: nil, errorString: "Facebook authorization was cancelled")
            } else {
                completionHandler(success: true, accessToken: result.token.tokenString, errorString: nil)
            }
        })
    }
}
